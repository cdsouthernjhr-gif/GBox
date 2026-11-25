import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/online/download_engine.dart';
import 'package:gamebox/core/rom/console_detector.dart';
import 'package:gamebox/core/rom/scan_planner.dart';
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:gamebox/core/storage/gamebox_layout.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/download_manager/download_service.dart';
import 'package:gamebox/features/emulator_manager/retroarch_playlist_service.dart';
import 'package:gamebox/features/rom_manager/rom_library_service.dart';
import 'package:gamebox/features/rom_manager/rom_search_service.dart';
import 'package:gamebox/features/save_manager/save_service.dart';
import 'package:gamebox/features/storage_manager/library_location_service.dart';
import 'package:gamebox/features/storage_manager/roms_migration_service.dart';

import 'online_core_test.dart' show TestServer, zipOf;
import 'rom_logic_test.dart' show gbaRom, nesRom;
import 'support/fakes.dart';

const online = ConnectivityStatus(connected: true, validated: true, transport: 'wifi');
const tree = 'content://com.android.externalstorage.documents/tree/primary%3AGames';

/// Synthetic PSP UMD image header (ISO 9660 descriptor + "PSP GAME").
Uint8List pspIso() => Uint8List(0x9000)
  ..setAll(0x8001, 'CD001'.codeUnits)
  ..setAll(0x8008, 'PSP GAME'.codeUnits);

void main() {
  group('layout', () {
    test('ROMs/<system> uses the standard names; GAMEBOX data folders are complete', () {
      expect(gamesDirFor('nes'), 'ROMs/nes');
      expect(gamesDirFor('ps1'), 'ROMs/psx');
      expect(gamesDirFor('sms'), 'ROMs/mastersystem');
      expect(gamesDirFor('gamecube'), 'ROMs/gc');
      expect(romFolderNames.keys.toSet(), {for (final c in consoleCatalog) c.id}, reason: 'every console');
      final f = gameboxFolders();
      expect(f, containsAll(['ROMs/nes', 'ROMs/psx', 'ROMs/wii', 'GAMEBOX/Artwork/Covers', 'GAMEBOX/Downloads']));
      expect(f, containsAll(['GAMEBOX/Saves/RetroArch/saves', 'GAMEBOX/Saves/RetroArch/states', 'GAMEBOX/Saves/PPSSPP']));
      expect(f, containsAll(['GAMEBOX/BIOS/PS1', 'GAMEBOX/BIOS/RetroArch', 'GAMEBOX/Playlists']));
      expect(f.toSet(), hasLength(f.length), reason: 'no duplicates');
      expect(saveLayoutFor('retroarch')!.root, 'GAMEBOX/Saves/RetroArch');
    });

    test('the standard folder names are recognised by the scanner', () {
      final detector = ConsoleDetector();
      for (final c in consoleCatalog) {
        expect(detector.consoleFromFolders([romsDir, gamesDirFor(c.id).split('/').last]), c.id, reason: c.id);
      }
    });

    test('BIOS and GAMEBOX data folders are never scanned for games; artwork is', () {
      expect(isNonGameFolder(['GAMEBOX', 'BIOS', 'PS1']), isTrue);
      expect(isNonGameFolder(['RetroArch', 'system', 'bios']), isTrue);
      expect(isNonGameFolder(['GAMEBOX', 'Saves', 'RetroArch']), isTrue);
      expect(isNonGameFolder(['Saves', 'RetroArch']), isTrue);
      expect(isNonGameFolder(['GAMEBOX', 'Playlists']), isTrue);
      expect(isNonGameFolder(['Artwork']), isFalse);
      expect(isNonGameFolder(['ROMs', 'psx']), isFalse);
      expect(isNonGameFolder(const []), isFalse);
    });

    test('BIOS status: named files or any dump', () {
      final ps1 = biosInfo.firstWhere((b) => b.consoleId == 'ps1');
      expect(ps1.dir, 'GAMEBOX/BIOS/PS1');
      expect(BiosStatus(ps1, const ['readme.txt']).ready, isFalse);
      expect(BiosStatus(ps1, const ['SCPH5501.BIN']).ready, isTrue, reason: 'case-insensitive');
      final ps2 = biosInfo.firstWhere((b) => b.consoleId == 'ps2');
      expect(BiosStatus(ps2, const ['my_ps2_dump.bin']).ready, isTrue);
    });

    test('disc images are identified from their header', () {
      expect(discConsoleFromHeader('iso', pspIso()), 'psp');
      expect(discConsoleFromHeader('iso', Uint8List(0x9000)..setAll(0x8001, 'CD001'.codeUnits)..setAll(0x8008, 'PLAYSTATION'.codeUnits)), 'ps2');
      expect(discConsoleFromHeader('iso', Uint8List(0x40)..setAll(0x1C, [0xC2, 0x33, 0x9F, 0x3D])), 'gamecube');
      expect(discConsoleFromHeader('iso', Uint8List(0x9000)), isNull);
    });

    test('search results: grouped by console (biggest first) and summarised before copying', () {
      RomSearchHit hit(String name, String? console, int size) {
        final e = ScannedEntry(uri: '/d/$name', name: name, dirSegments: const ['Download'], size: size);
        return RomSearchHit(files: [e], primary: e, consoleId: console);
      }

      final hits = [
        hit('a.gba', 'gba', 4 << 20),
        hit('b.nes', 'nes', 40 << 10),
        hit('c.nes', 'nes', 40 << 10),
        hit('d.iso', null, 1 << 30),
        hit('e.sfc', 'snes', 1 << 20),
      ];
      final groups = groupHitsByConsole(hits);
      expect([for (final (c, l) in groups) '$c:${l.length}'], ['nes:2', 'gba:1', 'snes:1'],
          reason: 'unidentified files are not grouped; ties by console name');

      final sum = OrganiseSummary.of(hits);
      expect(sum.games, 4, reason: 'only files with a console');
      expect(sum.perConsole['nes'], (2, 80 << 10));
      expect(sum.bytes, (4 << 20) + (80 << 10) + (1 << 20));
      expect(sum.fits(100 << 20, move: false), isTrue);
      expect(sum.fits(40 << 20, move: false), isFalse, reason: '50 MB stay free');
      expect(sum.fits(1, move: true), isTrue, reason: 'a move needs no extra space');
      expect(sum.fits(null, move: false), isTrue, reason: 'unknown free space does not block');
    });

    test('RetroArch playlist format', () {
      final m = jsonDecode(RetroArchPlaylistService.playlistJson('nes', [('/s/ROMs/nes/a.nes', 'A')])) as Map;
      expect(m['version'], '1.5');
      final item = (m['items'] as List).single as Map;
      expect(item, {
        'path': '/s/ROMs/nes/a.nes',
        'label': 'A',
        'core_path': 'DETECT',
        'core_name': 'DETECT',
        'crc32': 'DETECT',
        'db_name': 'Nintendo - Nintendo Entertainment System.lpl',
      });
      expect(retroArchDbNames.keys.toSet(), {for (final c in consoleCatalog) c.id});
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
    late RomSearchService search;
    late RomsMigrationService migration;
    late RetroArchPlaylistService playlists;
    var installed = <String>['retroarch', 'ppsspp'];

    // A volume laid out like Android: public root + the app folder inside it.
    String public() => '${temp.path}/emulated0';
    String appBase() => '${public()}/Android/data/com.gamebox.console/files';
    String appRoot() => '${appBase()}/GAMEBOX';

    Future<void> grantAccess() async {
      gateway.storageStatus = StorageAccessStatus(
          sdkInt: 33, granted: true, allFilesMode: true, settingsAvailable: true, publicRoot: public());
      await location.refreshAccess();
    }

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      srv = TestServer();
      await srv.start();
      temp = await Directory.systemTemp.createTemp('gamebox_loc');
      Directory(appBase()).createSync(recursive: true);
      db = AppDatabase(NativeDatabase.memory());
      settings = SettingsRepository(db);
      await settings.initialize();
      gateway = FakeGateway();
      library = RomLibraryService(
        gateway: gateway,
        db: db,
        settings: settings,
        appRoots: () async => [appBase()],
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
        appBases: () async => [appBase()],
      );
      library.extraLocalRoots = location.localScanRoots;
      await location.refreshAccess();
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
      search = RomSearchService(db: db, library: library, location: location);
      migration = RomsMigrationService(db, location);
      playlists = RetroArchPlaylistService(db, location);
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

    File put(String path, List<int> bytes) => File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    test('without storage access: the app folder is used and flagged as not shared', () async {
      expect(location.mode, LocationMode.app);
      expect(location.isPublic, isFalse);
      expect(await location.ensureStructure(), isEmpty);
      expect(Directory('${appBase()}/ROMs/nes').existsSync(), isTrue);
      final r = await download('/a.nes', nesRom());
      expect(r.filePath, '${appBase()}/ROMs/nes/a.nes');
      expect((await search.search()).needsAccess, isTrue);
      expect((await playlists.writeAll()).note, isNotNull);
    });

    test('with storage access: ROMs/ and GAMEBOX/ are created on shared storage', () async {
      await grantAccess();
      expect(location.mode, LocationMode.device);
      expect(await location.describe(romsDir), '${public()}/ROMs');
      expect(await location.ensureStructure(), isEmpty);
      for (final f in ['ROMs/nes', 'ROMs/psx', 'GAMEBOX/Saves/RetroArch/saves', 'GAMEBOX/BIOS/PS1', 'GAMEBOX/Playlists']) {
        expect(Directory('${public()}/$f').existsSync(), isTrue, reason: f);
      }
      expect(await location.localScanRoots(), containsAll(['${public()}/ROMs', '${appBase()}/ROMs']));
    });

    test('downloads go straight into ROMs/<system> on shared storage', () async {
      await grantAccess();
      final r = await download('/Pixel%20Quest.nes', nesRom());
      expect(r.status, 'completed', reason: r.errorMessage);
      expect(r.importedGameId, isNotNull);
      expect(r.filePath, '${public()}/ROMs/nes/Pixel Quest.nes');
      expect(Directory('${appRoot()}/Downloads').listSync().whereType<File>(), isEmpty, reason: 'nothing left behind');

      final again = await download('/Pixel%20Quest.nes', nesRom());
      expect(again.filePath, '${public()}/ROMs/nes/Pixel Quest (2).nes', reason: 'never overwritten');

      // Unknown console: waits in Downloads, moved once chosen.
      final iso = await download('/game.iso', Uint8List(64));
      expect(iso.importedGameId, isNull);
      final out = await downloads.importIntoLibrary(iso.id, consoleId: 'psp');
      expect(out.gameIds, hasLength(1));
      expect((await db.downloadById(iso.id)).filePath, '${public()}/ROMs/psp/game.iso');

      // ZIP of one console: extracted into ROMs/<system>/<name>/.
      final zip = await download('/pack.zip', zipOf({'x/a.nes': nesRom(), 'b.nes': nesRom()}));
      expect(zip.importedGameId, isNotNull, reason: zip.errorMessage);
      expect(File('${public()}/ROMs/nes/pack/x/a.nes').existsSync(), isTrue);
      expect(File('${appRoot()}/Downloads/pack.zip').existsSync(), isFalse);
    });

    test('games copied into ROMs/ by hand are found by the scan; BIOS dumps are not', () async {
      await grantAccess();
      await location.ensureStructure();
      put('${public()}/ROMs/gba/Space Race.gba', gbaRom());
      put('${public()}/ROMs/psx/bios/scph5501.bin', Uint8List(512 * 1024));
      put('${public()}/GAMEBOX/BIOS/PS1/scph5501.bin', Uint8List(512 * 1024));
      await library.scanAll();
      final games = await db.select(db.games).get();
      expect(games.map((g) => g.consoleId), ['gba']);
      final ps1 = (await location.biosStatus()).firstWhere((b) => b.info.consoleId == 'ps1');
      expect(ps1.has('scph5501.bin'), isTrue);
    });

    test('ROM search finds games anywhere, identifies them and sorts them into ROMs/', () async {
      await grantAccess();
      await location.ensureStructure();
      put('${public()}/Download/Hero (USA).nes', nesRom());
      put('${public()}/WhatsApp/Media/Documents/race.gba', [...gbaRom(), ...Uint8List(16 * 1024)]);
      put('${public()}/Download/umd.iso', pspIso());
      put('${public()}/Download/mystery.iso', Uint8List(0x9000));
      put('${public()}/Download/photos.zip', zipOf({'a.jpg': [1, 2, 3]}));
      put('${public()}/Download/tiny.nes', Uint8List(100));
      put('${public()}/DCIM/Camera/clip.nes', nesRom());
      put('${appBase()}/private.nes', nesRom());
      put('${public()}/RetroArch/system/scph5501.bin', Uint8List(512 * 1024));
      put('${public()}/ROMs/nes/already.nes', nesRom());

      final r = await search.search();
      expect(r.needsAccess, isFalse);
      final byName = {for (final h in r.hits) h.primary.name: h};
      expect(byName.keys.toSet(), {'Hero (USA).nes', 'race.gba', 'umd.iso', 'mystery.iso'});
      expect(byName['Hero (USA).nes']!.consoleId, 'nes');
      expect(byName['Hero (USA).nes']!.how, 'file header');
      expect(byName['race.gba']!.consoleId, 'gba');
      expect(byName['umd.iso']!.consoleId, 'psp', reason: 'PSP GAME volume id');
      expect(byName['mystery.iso']!.consoleId, isNull);
      expect(byName['mystery.iso']!.candidates, containsAll(['psp', 'ps2', 'gamecube', 'wii']));
      expect(r.unidentified, 1);

      // Copy the identified ones; then choose a console for the other.
      final o = await search.organise(r.hits.where((h) => h.consoleId != null).toList());
      expect(o.placed, 3);
      expect(o.failed, isEmpty);
      expect(File('${public()}/ROMs/nes/Hero (USA).nes').existsSync(), isTrue);
      expect(File('${public()}/ROMs/gba/race.gba').existsSync(), isTrue);
      expect(File('${public()}/ROMs/psp/umd.iso').existsSync(), isTrue);
      expect(File('${public()}/Download/Hero (USA).nes').existsSync(), isTrue, reason: 'copy keeps the original');
      expect(await db.select(db.games).get(), hasLength(3));
      expect(search.last.value!.hits.map((h) => h.primary.name), ['mystery.iso']);

      final mystery = search.last.value!.hits.single..consoleId = 'ps2';
      final moved = await search.organise([mystery], move: true);
      expect(moved.placed, 1);
      expect(File('${public()}/ROMs/ps2/mystery.iso').existsSync(), isTrue);
      expect(File('${public()}/Download/mystery.iso').existsSync(), isFalse, reason: 'moved');

      // Searching again: the originals that were copied are not offered again.
      final again = await search.search();
      expect(again.hits, isEmpty);
      expect(again.alreadyInLibrary, greaterThanOrEqualTo(3));
    });

    test('a .cue with its tracks is kept together in its own folder', () async {
      await grantAccess();
      put('${public()}/Download/PS1/Racer.cue', utf8.encode('FILE "Racer (Track 1).bin" BINARY\n  TRACK 01 MODE2/2352\nFILE "Racer (Track 2).bin" BINARY\n'));
      put('${public()}/Download/PS1/Other.bin', Uint8List(64 * 1024)); // not referenced
      put('${public()}/Download/PS1/Racer (Track 1).bin', Uint8List(64 * 1024));
      put('${public()}/Download/PS1/Racer (Track 2).bin', Uint8List(64 * 1024));
      final r = await search.search();
      final h = r.hits.single;
      expect(h.consoleId, 'ps1');
      expect(h.files, hasLength(3));
      await search.organise([h]);
      expect(File('${public()}/ROMs/psx/Racer/Racer.cue').existsSync(), isTrue);
      expect(File('${public()}/ROMs/psx/Racer/Racer (Track 2).bin').existsSync(), isTrue);
    });

    test('games in the app folder are moved into ROMs/ keeping the library entry', () async {
      // Before access: a download lands in the app folder.
      final r = await download('/old.nes', nesRom());
      final gameId = r.importedGameId!;
      await db.setFavorite(gameId, true);
      expect(await migration.countAppFolderGames(), 1);

      await grantAccess();
      final m = await migration.moveAppFolderGamesToRoms();
      expect(m.games, 1);
      expect(m.failed, isEmpty);
      expect(await migration.countAppFolderGames(), 0);
      final file = (await db.select(db.gameFiles).get()).single;
      expect(file.uri, '${public()}/ROMs/nes/old.nes');
      expect(file.gameId, gameId, reason: 'same game: history and favourites kept');
      expect(await db.select(db.favorites).get(), hasLength(1));
      expect(File('${appBase()}/ROMs/nes/old.nes').existsSync(), isFalse);

      // The next scan finds the moved file and does not duplicate it.
      await library.scanAll();
      expect(await db.select(db.games).get(), hasLength(1));
      expect((await db.select(db.gameFiles).get()).single.fileExists, isTrue);
    });

    test('also moves 0.9.0 GAMEBOX/Games/<CONSOLE> games', () async {
      put('${appRoot()}/Games/GBA/legacy.gba', gbaRom());
      await library.scanAll();
      expect(await migration.countAppFolderGames(), 1);
      await grantAccess();
      await migration.moveAppFolderGamesToRoms();
      expect(File('${public()}/ROMs/gba/legacy.gba').existsSync(), isTrue);
    });

    test('RetroArch playlists list the readable games per console', () async {
      await grantAccess();
      Directory('${public()}/RetroArch/playlists').createSync(recursive: true);
      // Playlist RetroArch made itself: never touched.
      put('${public()}/RetroArch/playlists/Nintendo - Nintendo Entertainment System.lpl', utf8.encode('{}'));
      await download('/b.nes', nesRom());
      await download('/a.nes', nesRom());
      await download('/x.gba', Uint8List.fromList([...gbaRom(), ...Uint8List(16 * 1024)]));
      // A game RetroArch can't read (app folder).
      final gid = await db.into(db.games).insert(GamesCompanion.insert(
          title: 'Hidden', sortTitle: 'hidden', consoleId: 'snes', addedAt: DateTime.now()));
      await db.into(db.gameFiles).insert(GameFilesCompanion.insert(
          gameId: gid, uri: '${appBase()}/ROMs/snes/h.sfc', displayPath: 'h.sfc', extension: 'sfc', isPrimary: const Value(true)));

      final r = await playlists.writeAll();
      expect(r.note, isNull);
      expect(r.playlists, 2);
      expect(r.games, 3);
      expect(r.unreadable, 1);
      expect(r.dirs, ['${public()}/GAMEBOX/Playlists', '${public()}/RetroArch/playlists']);
      for (final dir in r.dirs) {
        final nes = jsonDecode(File('$dir/${RetroArchPlaylistService.fileNameFor('nes')}').readAsStringSync()) as Map;
        expect([for (final i in nes['items'] as List) (i as Map)['path']],
            ['${public()}/ROMs/nes/a.nes', '${public()}/ROMs/nes/b.nes']);
      }
      expect(File('${public()}/RetroArch/playlists/Nintendo - Nintendo Entertainment System.lpl').readAsStringSync(), '{}');

      // A console that no longer has games loses its GAMEBOX playlist.
      await db.delete(db.games).go();
      await playlists.writeAll();
      expect(File('${public()}/GAMEBOX/Playlists/${RetroArchPlaylistService.fileNameFor('nes')}').existsSync(), isFalse);
    });

    test('picked folder: layout, downloads and save folders inside the tree', () async {
      gateway.trees[tree] = [];
      expect(await location.choose(tree), isEmpty);
      expect(location.mode, LocationMode.tree);
      expect(gateway.treeDirs[tree], containsAll(gameboxFolders()));
      expect(settings.state.value.romFolders, contains(tree));
      expect({for (final f in settings.state.value.saveFolders) f.uri: f.emulatorId}, {
        '$tree#GAMEBOX/Saves/GAMEBOX': 'gamebox',
        '$tree#GAMEBOX/Saves/RetroArch': 'retroarch',
        '$tree#GAMEBOX/Saves/PPSSPP': 'ppsspp',
      });
      expect(await location.registerSaveFolders(), 0);
      installed = [...installed, 'duckstation'];
      expect(await location.registerSaveFolders(), 1);

      final r = await download('/hero.nes', nesRom());
      expect(r.importedGameId, isNotNull, reason: r.errorMessage);
      expect(gateway.trees[tree]!.single['dir'], ['ROMs', 'nes']);
      final file = (await db.select(db.gameFiles).get()).single;
      expect(file.rootUri, tree);
      await library.scanAll();
      expect(await db.select(db.games).get(), hasLength(1));
      await downloads.remove(r.id);
      expect(gateway.deleted, contains(r.filePath));
    });

    test('save folder inside a picked folder: only that part of the tree is scanned', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      await download('/Hero.nes', nesRom());
      gateway.trees[tree]!.addAll([
        {'uri': '$tree/document/s1', 'name': 'Hero.srm', 'dir': ['GAMEBOX', 'Saves', 'RetroArch', 'saves'], 'size': 8192},
        {'uri': '$tree/document/s2', 'name': 'Hero.state1', 'dir': ['GAMEBOX', 'Saves', 'RetroArch', 'states'], 'size': 9000},
        {'uri': '$tree/document/s3', 'name': 'Hero.srm', 'dir': ['ROMs', 'nes'], 'size': 8192},
      ]);
      final r = await saves.scan();
      expect(r.unavailable, isEmpty);
      expect(r.found, 2, reason: 'the .srm next to the game is outside GAMEBOX/Saves/RetroArch');
      final rows = await db.allSaves();
      expect(rows.every((s) => s.folderUri == '$tree#GAMEBOX/Saves/RetroArch'), isTrue);
    });

    test('leaving a picked folder: back to shared storage when access is granted', () async {
      gateway.trees[tree] = [];
      await location.choose(tree);
      await grantAccess();
      expect(location.mode, LocationMode.tree, reason: 'an explicit choice wins');
      await location.useDefault();
      expect(location.mode, LocationMode.device);
      final r = await download('/later.nes', nesRom());
      expect(r.filePath, '${public()}/ROMs/nes/later.nes');
      expect(settings.state.value.saveFolders.map((f) => f.uri), contains('${public()}/GAMEBOX/Saves/RetroArch'));
    });
  });
}
