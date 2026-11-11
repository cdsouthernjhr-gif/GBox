import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/rom/rom_header_validator.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/rom_manager/rom_library_service.dart';

import 'rom_logic_test.dart' show gbRom, gbaRom, nesRom;
import 'support/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeGateway gateway;
  late SettingsRepository settings;
  late RomLibraryService library;
  late Directory temp;
  late String appRoot;

  const tree = 'content://com.android.externalstorage.documents/tree/ABCD-1234%3AROMs';
  String doc(String path) => 'content://com.android.externalstorage.documents/tree/ABCD-1234%3AROMs/document/'
      '${Uri.encodeComponent('ABCD-1234:ROMs/$path')}';

  void addTreeFile(String path, Uint8List bytes) {
    final parts = path.split('/');
    gateway.documents[doc(path)] = bytes;
    gateway.trees.putIfAbsent(tree, () => []).add({
      'uri': doc(path),
      'name': parts.last,
      'dir': parts.sublist(0, parts.length - 1),
      'size': bytes.length,
    });
  }

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    temp = await Directory.systemTemp.createTemp('gamebox_lib');
    appRoot = '${temp.path}/external0';
    db = AppDatabase(NativeDatabase.memory());
    gateway = FakeGateway();
    settings = SettingsRepository(db);
    await settings.initialize();
    library = RomLibraryService(
      gateway: gateway,
      db: db,
      settings: settings,
      appRoots: () async => [appRoot],
      artworkDir: () async => '${temp.path}/artwork',
    );
  });

  tearDown(() async {
    settings.dispose();
    await db.close();
    await temp.delete(recursive: true);
  });

  Future<void> waitForSettings() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('creates the recommended GAMEBOX folder layout', () async {
    final roots = await library.ensureAppFolders();
    expect(roots, ['$appRoot/GAMEBOX']);
    for (final sub in ['Games/NES', 'Games/PS2', 'Artwork/Covers', 'Saves', 'Backups', 'Downloads']) {
      expect(Directory('$appRoot/GAMEBOX/$sub').existsSync(), isTrue, reason: sub);
    }
  });

  test('scans app folders: imports, verifies headers, hashes small files', () async {
    await library.ensureAppFolders();
    File('$appRoot/GAMEBOX/Games/NES/alpha (USA).nes').writeAsBytesSync(nesRom());
    File('$appRoot/GAMEBOX/Games/GAMEBOY/beta.gb').writeAsBytesSync(gbRom());
    File('$appRoot/GAMEBOX/Games/GAMEBOY/broken.gb').writeAsBytesSync(gbRom(corruptChecksum: true));
    File('$appRoot/GAMEBOX/Games/PS2/unknown-folder-iso.iso').writeAsBytesSync(Uint8List(64));

    await library.scanAll();

    final games = await db.watchLibrary().first;
    expect(games.map((g) => g.game.title), ['alpha', 'beta', 'broken', 'unknown-folder-iso']);
    expect(games.first.game.regions, 'USA');

    final files = await db.select(db.gameFiles).get();
    final byName = {for (final f in files) f.displayPath.split('/').last: f};
    expect(byName['alpha (USA).nes']!.headerStatus, HeaderStatus.valid.name);
    expect(byName['beta.gb']!.headerStatus, HeaderStatus.valid.name);
    expect(byName['broken.gb']!.headerStatus, HeaderStatus.invalid.name);
    expect(byName['beta.gb']!.sha1, isNotNull, reason: 'small files are hashed automatically');
    expect(library.progress.value.running, isFalse);
    expect(library.progress.value.totalImported, 4);
  });

  test('rescans are idempotent and detect missing files', () async {
    await library.ensureAppFolders();
    final f = File('$appRoot/GAMEBOX/Games/GBA/gamma.gba')..writeAsBytesSync(gbaRom());
    await library.scanAll();
    await library.scanAll();
    expect(await db.select(db.games).get(), hasLength(1));

    f.deleteSync();
    await library.scanAll();
    final game = (await db.select(db.games).get()).single;
    expect(game.isMissing, isTrue);
    expect(library.progress.value.totalMissing, 1);

    f.writeAsBytesSync(gbaRom());
    await library.scanAll();
    expect((await db.select(db.games).get()).single.isMissing, isFalse, reason: 'file came back');
  });

  test('SAF folders: unresolved files reported, covers imported', () async {
    addTreeFile('SNES/Demo World (USA).sfc', Uint8List(0x10000));
    addTreeFile('Artwork/Demo World.png', Uint8List.fromList([1, 2, 3]));
    addTreeFile('Mixed/thing.iso', Uint8List(64));
    await settings.setRomFolders([tree]);
    await waitForSettings();

    await library.scanAll();

    final games = await db.select(db.games).get();
    expect(games.single.title, 'Demo World');
    expect(games.single.consoleId, 'snes');
    final covers = await db.watchCoverPaths().first;
    expect(File(covers[games.single.id]!).existsSync(), isTrue);
    final saf = library.progress.value.results.firstWhere((r) => r.root.uri == tree);
    expect(saf.unresolved.map((u) => u.name), ['thing.iso']);
  });

  test('disconnected SAF storage does not mark files missing', () async {
    addTreeFile('NES/delta.nes', nesRom());
    await settings.setRomFolders([tree]);
    await waitForSettings();
    await library.scanAll();

    gateway.inaccessibleTrees.add(tree); // USB drive unplugged
    await library.scanAll();

    expect((await db.select(db.games).get()).single.isMissing, isFalse);
    final r = library.progress.value.results.firstWhere((r) => r.root.uri == tree);
    expect(r.available, isFalse);
  });

  test('exact duplicates are detected by hash', () async {
    await library.ensureAppFolders();
    File('$appRoot/GAMEBOX/Games/NES/one.nes').writeAsBytesSync(nesRom());
    File('$appRoot/GAMEBOX/Games/NES/copy of one.nes').writeAsBytesSync(nesRom());
    await library.scanAll();
    final files = await db.select(db.gameFiles).get();
    final result = await library.verifyFile(files.first);
    expect(result.duplicates, hasLength(1));
  });

  test('manual import: detected by extension, otherwise user chooses console', () async {
    const picked1 = 'content://media/document/primary%3ADownload%2Fhomebrew.gba';
    const picked2 = 'content://media/document/primary%3ADownload%2Fdisc.iso';
    gateway.documents[picked1] = gbaRom();
    gateway.documents[picked2] = Uint8List(64);

    final r = await library.importPicked([picked1, picked2]);
    expect(r.imported, 1);
    expect(r.needsConsole.map((e) => e.name), ['disc.iso']);

    final n = await library.importWithConsole(r.needsConsole, 'psp');
    expect(n, 1);
    final games = await db.select(db.games).get();
    expect(games.map((g) => g.consoleId).toSet(), {'gba', 'psp'});

    final again = await library.importPicked([picked1]);
    expect(again.alreadyKnown, 1);
  });

  test('delete removes the files and then the library entry', () async {
    await library.ensureAppFolders();
    final f = File('$appRoot/GAMEBOX/Games/NES/zeta.nes')..writeAsBytesSync(nesRom());
    await library.scanAll();
    final id = (await db.select(db.games).get()).single.id;

    final failed = await library.deleteGameAndFiles(id);
    expect(failed, isEmpty);
    expect(f.existsSync(), isFalse);
    expect(await db.select(db.games).get(), isEmpty);
  });

  test('search, filters and sorting', () async {
    await library.ensureAppFolders();
    File('$appRoot/GAMEBOX/Games/NES/Space Quest.nes').writeAsBytesSync(nesRom());
    File('$appRoot/GAMEBOX/Games/GBA/Space Race.gba').writeAsBytesSync(gbaRom());
    File('$appRoot/GAMEBOX/Games/GBA/Farm Life.gba').writeAsBytesSync(gbaRom());
    await library.scanAll();

    Future<List<String>> titles({String q = '', String? console, bool fav = false}) async =>
        (await db.watchLibrary(query: q, consoleId: console, favoritesOnly: fav).first)
            .map((g) => g.game.title)
            .toList();

    expect(await titles(q: 'space'), ['Space Quest', 'Space Race']);
    expect(await titles(q: 'space race'), ['Space Race']);
    expect(await titles(q: '100%'), isEmpty, reason: 'LIKE wildcards are escaped');
    expect(await titles(console: 'gba'), ['Farm Life', 'Space Race']);

    final farm = (await db.select(db.games).get()).firstWhere((g) => g.title == 'Farm Life');
    await db.setFavorite(farm.id, true);
    expect(await titles(fav: true), ['Farm Life']);
  });

  test('manual metadata editing is kept and flagged', () async {
    await library.ensureAppFolders();
    File('$appRoot/GAMEBOX/Games/NES/eta.nes').writeAsBytesSync(nesRom());
    await library.scanAll();
    final id = (await db.select(db.games).get()).single.id;
    await db.saveManualMetadata(id, title: 'Eta Remix', sortTitle: 'eta remix', genre: 'Puzzle', developer: ' ');
    final g = (await db.select(db.games).get()).single;
    final m = (await db.metadataForGame(id))!;
    expect(g.title, 'Eta Remix');
    expect(m.genre, 'Puzzle');
    expect(m.developer, isNull, reason: 'blank values stored as null');
    expect(m.editedManually, isTrue);
  });
}
