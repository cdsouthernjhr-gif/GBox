import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/online/download_engine.dart';
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:gamebox/core/storage/gamebox_layout.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/download_manager/download_service.dart';
import 'package:gamebox/features/rom_manager/rom_library_service.dart';
import 'package:gamebox/features/save_manager/save_service.dart';
import 'package:gamebox/features/storage_manager/library_location_service.dart';

import 'online_core_test.dart' show TestServer, zipOf;
import 'rom_logic_test.dart' show nesRom;
import 'support/fakes.dart';

const online = ConnectivityStatus(connected: true, validated: true, transport: 'wifi');
const tree = 'content://com.android.externalstorage.documents/tree/primary%3AGAMEBOX';

void main() {
  group('layout', () {
    test('every console, emulator save folder and BIOS folder is part of the layout', () {
      final f = gameboxFolders();
      expect(f, containsAll(['Games/NES', 'Games/PS1', 'Games/WII', 'Artwork/Covers', 'Downloads', 'Backups', 'Exports']));
      expect(f, containsAll(['Saves/RetroArch/saves', 'Saves/RetroArch/states', 'Saves/PPSSPP', 'Saves/DuckStation']));
      expect(f, containsAll(['BIOS/PS1', 'BIOS/PS2', 'BIOS/SATURN', 'BIOS/DREAMCAST', 'BIOS/RetroArch']));
      expect(f.toSet(), hasLength(f.length), reason: 'no duplicates');
      expect(gamesDirFor('megadrive'), 'Games/MEGADRIVE');
    });

    test('BIOS and GAMEBOX save/backup folders are never scanned for games', () {
      expect(isNonGameFolder(['BIOS', 'PS1']), isTrue);
      expect(isNonGameFolder(['RetroArch', 'system', 'bios']), isTrue);
      expect(isNonGameFolder(['Saves', 'RetroArch', 'saves']), isTrue);
      expect(isNonGameFolder(['Backups']), isTrue);
      expect(isNonGameFolder(['Games', 'PS1']), isFalse);
      expect(isNonGameFolder(['Downloads']), isFalse);
      expect(isNonGameFolder(const []), isFalse);
    });

    test('BIOS status: named files or any dump', () {
      final ps1 = biosInfo.firstWhere((b) => b.consoleId == 'ps1');
      expect(BiosStatus(ps1, const []).ready, isFalse);
      expect(BiosStatus(ps1, const ['readme.txt']).ready, isFalse);
      expect(BiosStatus(ps1, const ['SCPH5501.BIN']).ready, isTrue, reason: 'case-insensitive');
      final ps2 = biosInfo.firstWhere((b) => b.consoleId == 'ps2');
      expect(BiosStatus(ps2, const ['my_ps2_dump.bin']).ready, isTrue);
    });
  });

  group('services', () {
    late TestServer srv;
    late Directory temp;
    late AppDatabase db;
    late SettingsRepository settings;
    late FakeGateway gateway;
    late RomLibraryService library;
    late SaveService saves;
    late LibraryLocationService location;
    late DownloadService downloads;
    var installed = <String>['retroarch', 'ppsspp'];

    String appRoot() => '${temp.path}/ext0/GAMEBOX';

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      srv = TestServer();
      await srv.start();
      temp = await Directory.systemTemp.createTemp('gamebox_loc');
      db = AppDatabase(NativeDatabase.memory());
      settings = SettingsRepository(db);
      await settings.initialize();
      gateway = FakeGateway();
      library = RomLibraryService(
        gateway: gateway,
        db: db,
        settings: settings,
        appRoots: () async => ['${temp.path}/ext0'],
        artworkDir: () async => '${temp.path}/artwork',
      );
      saves = SaveService(gateway: gateway, db: db, settings: settings, gameboxRoot: () async => appRoot());
      installed = ['retroarch', 'ppsspp'];
      location = LibraryLocationService(
        gateway: gateway,
        settings: settings,
        appRoot: () async => appRoot(),
        saves: saves,
        installedEmulators: () => installed,
      );
      final engine = DownloadEngine(allowHttp: true);
      downloads = DownloadService(
        db: db,
        engine: engine,
        library: library,
        settings: settings,
        connectivity: ValueNotifier(online),
        downloadsDir: () async => '${appRoot()}/Downloads',
        retryBaseDelay: const Duration(milliseconds: 10),
        location: location,
      );
      await downloads.initialize();
    });

    tearDown(() async {
      downloads.dispose();
      settings.dispose();
      await db.close();
      await srv.server.close(force: true);
      await temp.delete(recursive: true);
    });

    Future<DownloadQueueRow> download(String path, Uint8List bytes, {String? console}) async {
      srv.files[path] = bytes;
      final id = await downloads.enqueue(url: srv.url(path).toString(), consoleId: console);
      await downloads.idle();
      return db.downloadById(id);
    }

    test('app folder: the whole layout is created', () async {
      expect(await location.ensureStructure(), isEmpty);
      for (final f in ['Games/NES', 'Saves/RetroArch/states', 'BIOS/PS1', 'BIOS/RetroArch', 'Exports']) {
        expect(Directory('${appRoot()}/$f').existsSync(), isTrue, reason: f);
      }
    });

    test('a download with a known console is moved into Games/<CONSOLE> and imported there', () async {
      final r = await download('/Pixel%20Quest.nes', nesRom());
      expect(r.status, 'completed', reason: r.errorMessage);
      expect(r.importedGameId, isNotNull);
      expect(r.filePath, '${appRoot()}/Games/NES/Pixel Quest.nes');
      expect(File(r.filePath!).existsSync(), isTrue);
      expect(Directory('${appRoot()}/Downloads').listSync().whereType<File>(), isEmpty, reason: 'nothing left behind');
      final file = (await db.select(db.gameFiles).get()).single;
      expect(file.uri, r.filePath);
      expect((await db.gameById(file.gameId)).consoleId, 'nes');

      // Same name again: a second copy, nothing overwritten.
      final again = await download('/Pixel%20Quest.nes', nesRom());
      expect(again.filePath, '${appRoot()}/Games/NES/Pixel Quest (2).nes');
    });

    test('a file of unknown console waits in Downloads until the console is chosen', () async {
      final r = await download('/game.iso', payload(64));
      expect(r.importedGameId, isNull);
      expect(r.filePath, startsWith('${appRoot()}/Downloads/'));

      final out = await downloads.importIntoLibrary(r.id, consoleId: 'psp');
      expect(out.gameIds, hasLength(1));
      final moved = await db.downloadById(r.id);
      expect(moved.filePath, '${appRoot()}/Games/PSP/game.iso');
      expect((await db.gameById(out.gameIds.single)).consoleId, 'psp');
    });

    test('a ZIP is extracted into Games/<CONSOLE>/<name>/ and the archive removed', () async {
      final zip = zipOf({'Demo/demo.nes': nesRom(), 'Demo/readme.txt': utf8.encode('CC0')});
      final r = await download('/demo-pack.zip', zip, console: 'nes');
      expect(r.importedGameId, isNotNull, reason: r.errorMessage);
      expect(File('${appRoot()}/Games/NES/demo-pack/Demo/demo.nes').existsSync(), isTrue);
      expect(File('${appRoot()}/Games/NES/demo-pack/Demo/readme.txt').existsSync(), isTrue);
      expect(File('${appRoot()}/Downloads/demo-pack.zip').existsSync(), isFalse);
      expect(Directory('${appRoot()}/Downloads/demo-pack_files').existsSync(), isFalse);
      final file = (await db.select(db.gameFiles).get()).single;
      expect(file.uri, '${appRoot()}/Games/NES/demo-pack/Demo/demo.nes');
    });

    test('a ZIP whose games all share a console needs no console choice', () async {
      final zip = zipOf({'a.nes': nesRom(), 'b.nes': nesRom()});
      final r = await download('/two.zip', zip);
      expect(r.importedGameId, isNotNull, reason: r.errorMessage);
      expect(File('${appRoot()}/Games/NES/two/a.nes').existsSync(), isTrue);
      expect(await db.select(db.games).get(), hasLength(2));
    });

    test('public folder: choose creates the layout, scans it and registers save folders', () async {
      gateway.trees[tree] = [];
      expect(await location.choose(tree), isEmpty);
      expect(location.isPublic, isTrue);
      expect(gateway.treeDirs[tree], containsAll(gameboxFolders()));
      expect(settings.state.value.romFolders, contains(tree));
      final folders = settings.state.value.saveFolders;
      expect({for (final f in folders) f.uri: f.emulatorId}, {
        '$tree#Saves/RetroArch': 'retroarch',
        '$tree#Saves/PPSSPP': 'ppsspp',
      }, reason: 'only installed emulators');

      // Registering again adds nothing; a newly installed emulator is added.
      expect(await location.registerSaveFolders(), 0);
      installed = [...installed, 'duckstation'];
      expect(await location.registerSaveFolders(), 1);
    });

    test('public folder: downloads go into the tree and are imported from there', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      final r = await download('/hero.nes', nesRom());
      expect(r.importedGameId, isNotNull, reason: r.errorMessage);
      expect(r.filePath, startsWith('$tree/document/'));
      expect(gateway.documents[r.filePath], nesRom());
      final placed = gateway.trees[tree]!.single;
      expect(placed['dir'], ['Games', 'NES']);
      expect(placed['name'], 'hero.nes');
      expect(Directory('${appRoot()}/Downloads').listSync().whereType<File>(), isEmpty);

      final file = (await db.select(db.gameFiles).get()).single;
      expect(file.uri, r.filePath);
      expect(file.rootUri, tree, reason: 'missing-file checks work for the public folder');

      // A later scan of the tree finds the same file and doesn't duplicate it.
      await library.scanAll();
      expect(await db.select(db.games).get(), hasLength(1));

      // Deleting the download deletes the document.
      await downloads.remove(r.id);
      expect(gateway.deleted, contains(r.filePath));
    });

    test('public folder: ZIP contents keep their folders inside Games/<CONSOLE>/<name>/', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      final r = await download('/pack.zip', zipOf({'x/one.nes': nesRom()}), console: 'nes');
      expect(r.importedGameId, isNotNull, reason: r.errorMessage);
      expect(gateway.trees[tree]!.single['dir'], ['Games', 'NES', 'pack', 'x']);
    });

    test('BIOS dumps in BIOS/ are not imported as games; status reports them', () async {
      await location.ensureStructure();
      File('${appRoot()}/BIOS/PS1/scph5501.bin').writeAsBytesSync(Uint8List(512 * 1024));
      File('${appRoot()}/Games/NES/ok.nes').writeAsBytesSync(nesRom());
      await library.scanAll();
      final games = await db.select(db.games).get();
      expect(games.map((g) => g.consoleId), ['nes']);
      final ps1 = (await location.biosStatus()).firstWhere((b) => b.info.consoleId == 'ps1');
      expect(ps1.ready, isTrue);
      expect(ps1.has('scph5501.bin'), isTrue);
      expect((await location.biosStatus()).firstWhere((b) => b.info.consoleId == 'saturn').ready, isFalse);
    });

    test('save folder inside the public folder: only that part of the tree is scanned', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      await download('/Hero.nes', nesRom());
      gateway.trees[tree]!.addAll([
        {'uri': '$tree/document/s1', 'name': 'Hero.srm', 'dir': ['Saves', 'RetroArch', 'saves'], 'size': 8192},
        {'uri': '$tree/document/s2', 'name': 'Hero.state1', 'dir': ['Saves', 'RetroArch', 'states'], 'size': 9000},
        {'uri': '$tree/document/s3', 'name': 'Hero.srm', 'dir': ['Games', 'NES'], 'size': 8192},
      ]);
      gateway.documents['$tree/document/s1'] = Uint8List(8192);
      final r = await saves.scan();
      expect(r.unavailable, isEmpty);
      expect(r.found, 2, reason: 'the .srm next to the game is outside Saves/RetroArch');
      expect(r.matched, 2);
      final rows = await db.allSaves();
      expect(rows.map((s) => s.emulatorId).toSet(), {'retroarch'});
      expect(rows.every((s) => s.folderUri == '$tree#Saves/RetroArch'), isTrue);
    });

    test('back to the app folder: new downloads go there, nothing is moved', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      await location.useAppStorage();
      expect(location.isPublic, isFalse);
      final r = await download('/later.nes', nesRom());
      expect(r.filePath, '${appRoot()}/Games/NES/later.nes');
    });
  });
}

Uint8List payload(int n) => Uint8List.fromList(List.generate(n, (i) => i % 251));
