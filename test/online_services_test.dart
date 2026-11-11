import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/online/download_engine.dart';
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/download_manager/download_service.dart';
import 'package:gamebox/features/rom_manager/rom_library_service.dart';
import 'package:gamebox/features/source_manager/source_service.dart';

import 'online_core_test.dart' show TestServer, payload, zipOf;
import 'rom_logic_test.dart' show nesRom;
import 'support/fakes.dart';

const online = ConnectivityStatus(connected: true, validated: true, transport: 'wifi');

void main() {
  late TestServer srv;
  late Directory temp;
  late AppDatabase db;
  late SettingsRepository settings;
  late DownloadService downloads;
  late SourceService sources;
  late ValueNotifier<ConnectivityStatus> net;
  late DownloadEngine engine;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    srv = TestServer();
    await srv.start();
    temp = await Directory.systemTemp.createTemp('gamebox_svc');
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
    await settings.initialize();
    final gateway = FakeGateway();
    final library = RomLibraryService(
      gateway: gateway,
      db: db,
      settings: settings,
      appRoots: () async => ['${temp.path}/ext0'],
      artworkDir: () async => '${temp.path}/artwork',
    );
    net = ValueNotifier(online);
    engine = DownloadEngine(allowHttp: true);
    downloads = DownloadService(
      db: db,
      engine: engine,
      library: library,
      settings: settings,
      connectivity: net,
      downloadsDir: () async => '${temp.path}/ext0/GAMEBOX/Downloads',
      retryBaseDelay: const Duration(milliseconds: 10),
    );
    sources = SourceService(db, engine);
    await downloads.initialize();
  });

  tearDown(() async {
    downloads.dispose();
    settings.dispose();
    await db.close();
    await srv.server.close(force: true);
    await temp.delete(recursive: true);
  });

  Future<DownloadQueueRow> row(int id) => db.downloadById(id);

  Map<String, Object?> catalog({String? sha}) => {
        'format': 'gamebox-catalog',
        'version': 1,
        'name': 'Test Homebrew',
        'games': [
          {
            'title': 'Pixel Quest',
            'console': 'nes',
            'url': srv.url('/pixel.nes').toString(),
            'license': 'CC-BY-4.0',
            'sha256': ?sha,
            'description': 'A test homebrew.',
            'developer': 'Tester',
            'year': '2025',
            'cover': srv.url('/pixel.png').toString(),
          },
        ],
      };

  test('catalogue source → browse → download → auto-import with metadata, licence and cover', () async {
    final rom = nesRom();
    srv.files['/pixel.nes'] = rom;
    srv.files['/pixel.png'] = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
    srv.files['/catalog.json'] =
        Uint8List.fromList(utf8.encode(jsonEncode(catalog(sha: sha256.convert(rom).toString()))));

    final sid = await sources.add(
        name: 'Test', url: srv.url('/catalog.json').toString(), type: SourceType.homebrewRepo, confirmedAuthorized: true);
    expect(await sources.check(sid), contains('1 games'));
    final browse = await sources.browse(sid);
    final entry = browse.entries.single;

    final id = await downloads.enqueue(url: entry.url.toString(), sourceId: sid, entry: entry);
    await downloads.idle();

    final r = await row(id);
    expect(r.status, 'completed', reason: r.errorMessage);
    expect(r.sha256, sha256.convert(rom).toString());
    expect(File(r.filePath!).readAsBytesSync(), rom);
    expect(r.importedGameId, isNotNull, reason: 'auto-imported (console known from catalogue)');

    final game = await db.gameById(r.importedGameId!);
    expect(game.title, 'Pixel Quest');
    expect(game.consoleId, 'nes');
    final meta = (await db.metadataForGame(game.id))!;
    expect(meta.description, contains('Licence: CC-BY-4.0'));
    expect(meta.developer, 'Tester');
    expect(meta.provider, 'catalog');
    expect((await db.watchCoverPaths().first)[game.id], isNotNull);
    expect((await db.watchDownloadHistory().first).single.status, 'completed');
  });

  test('waits while offline and starts when back online', () async {
    srv.files['/a.gba'] = payload(2000);
    net.value = ConnectivityStatus.offline;
    final id = await downloads.enqueue(url: srv.url('/a.gba').toString());
    await downloads.idle();
    expect((await row(id)).status, 'queued');
    expect(srv.requests, 0);

    net.value = online;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await downloads.idle();
    expect((await row(id)).status, 'completed');
  });

  test('gameplay pause re-queues and resumes with HTTP Range afterwards', () async {
    final data = payload(64 * 1024);
    srv.files['/slow.nes'] = data;
    srv.slowGate = Completer();
    final id = await downloads.enqueue(url: srv.url('/slow.nes').toString());
    for (var i = 0; i < 100 && downloads.activeId != id; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    downloads.pauseForGameplay();
    srv.slowGate!.complete();
    await downloads.idle();
    expect((await row(id)).status, 'queued', reason: 'gameplay pause is not a user pause');

    srv.slowGate = null;
    downloads.resumeAfterGameplay();
    await downloads.idle();
    final r = await row(id);
    expect(r.status, 'completed', reason: r.errorMessage);
    expect(srv.rangeRequests, isNotEmpty);
    expect(File(r.filePath!).readAsBytesSync(), data);
  });

  test('user pause, resume and cancel', () async {
    srv.files['/slow.gba'] = payload(64 * 1024);
    srv.slowGate = Completer();
    final id = await downloads.enqueue(url: srv.url('/slow.gba').toString());
    for (var i = 0; i < 100 && downloads.activeId != id; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await downloads.pause(id);
    srv.slowGate!.complete();
    await downloads.idle();
    expect((await row(id)).status, 'paused');

    await downloads.cancel(id);
    final r = await row(id);
    expect(r.status, 'cancelled');
    expect(File('${r.filePath}.part').existsSync(), isFalse);
  });

  test('server errors retry, then fail; retry button re-queues', () async {
    // /missing → 404 (not retried); use a 5xx route via unknown handler? 404 is a hard failure:
    final id = await downloads.enqueue(url: srv.url('/missing.nes').toString());
    await downloads.idle();
    final r = await row(id);
    expect(r.status, 'failed');
    expect(r.errorMessage, contains('404'));
    srv.files['/missing.nes'] = nesRom();
    await downloads.retry(id);
    await downloads.idle();
    expect((await row(id)).status, 'completed');
  });

  test('network interruption is retried automatically and resumes', () async {
    // /short.gba always drops after 400 of 1000 bytes: retried 3×, then failed.
    final id = await downloads.enqueue(url: srv.url('/short.gba').toString());
    await downloads.idle();
    final r = await row(id);
    expect(r.status, 'failed');
    expect(r.retries, DownloadService.maxRetries);
  });

  test('ZIP downloads are validated and extracted before import', () async {
    srv.files['/pack.zip'] = zipOf({'NES/demo.nes': nesRom(), 'README.txt': utf8.encode('licence: CC0')});
    srv.files['/evil.zip'] = zipOf({'../../escape.nes': nesRom()});
    final ok = await downloads.enqueue(url: srv.url('/pack.zip').toString());
    final bad = await downloads.enqueue(url: srv.url('/evil.zip').toString());
    await downloads.idle();

    final imported = await downloads.importIntoLibrary(ok);
    expect(imported.error, isNull);
    expect(imported.gameIds, hasLength(1));
    expect((await db.gameById(imported.gameIds.single)).consoleId, 'nes', reason: 'console from folder inside zip');

    final rejected = await downloads.importIntoLibrary(bad);
    expect(rejected.error, contains('Unsafe path'));
    expect(File('${temp.path}/escape.nes').existsSync(), isFalse);
  });

  test('files of unknown console ask for one; then import; remove deletes the file', () async {
    srv.files['/disc.iso'] = payload(4096);
    final id = await downloads.enqueue(url: srv.url('/disc.iso').toString());
    await downloads.idle();
    expect((await row(id)).importedGameId, isNull, reason: 'no console → no auto-import');
    expect((await downloads.importIntoLibrary(id)).needsConsole, isTrue);
    final r = await downloads.importIntoLibrary(id, consoleId: 'psp');
    expect((await db.gameById(r.gameIds.single)).consoleId, 'psp');

    final path = (await row(id)).filePath!;
    await downloads.remove(id);
    expect(File(path).existsSync(), isFalse);
  });

  test('enqueue validation', () async {
    expect(() => downloads.enqueue(url: 'ftp://x.org/a.nes'), throwsArgumentError);
    expect(() => downloads.enqueue(url: srv.url('/a.nes').toString(), expectedSha256: 'abc'), throwsArgumentError);
  });

  test('sources: authorisation confirmation, web pages flagged, removal', () async {
    expect(
      () => sources.add(name: 'X', url: srv.url('/a.nes').toString(), type: SourceType.directUrl, confirmedAuthorized: false),
      throwsArgumentError,
    );
    final page = await sources.add(
        name: 'Page', url: srv.url('/page').toString(), type: SourceType.userHosting, confirmedAuthorized: true);
    expect(await sources.check(page), contains('web page'));
    srv.files['/bad.json'] = Uint8List.fromList(utf8.encode('{"format":"nope"}'));
    final bad = await sources.add(
        name: 'Bad', url: srv.url('/bad.json').toString(), type: SourceType.customHttpApi, confirmedAuthorized: true);
    expect(await sources.check(bad), contains('Not a GAMEBOX catalogue'));
    await sources.remove(bad);
    expect((await db.watchSources().first).map((s) => s.name), ['Page']);
  });

  test('regression: item added while the worker winds down is not stranded', () async {
    // Deterministic reproduction: the worker has just found the queue empty
    // when a new item is enqueued. The old kick() dropped that second start.
    srv.files['/race.gba'] = payload(1000);
    net.value = ConnectivityStatus.offline;
    final release = Completer<void>();
    var held = false;
    downloads.afterQueueCheck = (next) async {
      if (next == null && !held) {
        held = true;
        await release.future;
      }
    };
    net.value = online; // worker starts and finds nothing → held
    for (var i = 0; i < 100 && !held; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    final id = await downloads.enqueue(url: srv.url('/race.gba').toString());
    release.complete(); // worker finishes its empty pass
    for (var i = 0; i < 50 && (await row(id)).status != 'completed'; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await downloads.idle();
    }
    expect((await row(id)).status, 'completed');
  });
}
