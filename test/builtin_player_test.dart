import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/constants/emulator_links.dart';
import 'package:gamebox/features/source_manager/find_online_screen.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/services/system_services.dart';
import 'package:gamebox/features/emulator_manager/launch_service.dart';
import 'package:gamebox/features/emulator_manager/player_files.dart';
import 'package:gamebox/integrations/builtin/builtin_player_launcher.dart';
import 'package:gamebox/integrations/emulator_adapters/emulator_adapter.dart';
import 'package:gamebox/integrations/emulator_adapters/launcher_registry.dart';

import 'online_core_test.dart' show zipOf;
import 'rom_logic_test.dart' show nesRom;
import 'support/fakes.dart';

const tree = 'content://com.android.externalstorage.documents/tree/1234-5678%3AGames';

void main() {
  final player = BuiltInPlayerLauncher();
  const env = LaunchEnvironment(
      installedPackage: 'com.gamebox.console', sdkInt: 33, systemDir: '/b/GAMEBOX/BIOS/PS1', savesDir: '/b/s');

  group('plan', () {
    test('covers the bundled systems with one core each', () {
      expect(player.builtIn, isTrue);
      expect(player.consoleIds, {'nes', 'snes', 'sms', 'megadrive', 'gb', 'gbc', 'gba', 'ps1'});
      for (final c in player.consoleIds) {
        expect(builtInCoreNames.containsKey(builtInCores[c]), isTrue, reason: c);
        expect(builtInTouchLayouts.containsKey(c), isTrue, reason: c);
        expect(player.options(c).single.values.keys.single, builtInCores[c]);
      }
      expect(launchersForConsole('gba').first, isA<BuiltInPlayerLauncher>());
    });

    test('starts PlayerActivity in GAMEBOX with core, game, BIOS and save folders', () {
      const t = LaunchTarget(
          consoleId: 'ps1', originalUri: 'x', extension: 'cue', localPath: '/r/ROMs/psx/Crash.cue', title: 'Crash');
      final p = player.plan(t, env, const {}) as LaunchReady;
      expect(p.spec.packageName, 'com.gamebox.console');
      expect(p.spec.className, 'com.gamebox.console.player.PlayerActivity');
      expect(p.spec.extras, {
        'core': 'pcsx_rearmed',
        'rom': '/r/ROMs/psx/Crash.cue',
        'system': '/b/GAMEBOX/BIOS/PS1',
        'saves': '/b/s',
        'title': 'Crash',
        'touch': 'auto',
        'layout': 'ps1',
      });
      expect(p.spec.flags, isEmpty, reason: 'same task: BACK returns to GAMEBOX');
    });

    test('blocks without a readable file, for other consoles and unsupported file types', () {
      expect(player.plan(const LaunchTarget(consoleId: 'nes', originalUri: 'x', extension: 'nes'), env, const {}),
          isA<LaunchBlocked>());
      expect(
          player.plan(const LaunchTarget(consoleId: 'n64', originalUri: 'x', extension: 'z64', localPath: '/a.z64'), env,
              const {}),
          isA<LaunchBlocked>());
      final b = player.plan(
          const LaunchTarget(consoleId: 'nes', originalUri: 'x', extension: 'txt', localPath: '/a.txt'), env, const {});
      expect((b as LaunchBlocked).reasons.single, contains('Play with'));
    });
  });

  group('files', () {
    late Directory temp;
    late FakeGateway gateway;
    late PlayerFiles files;
    var nextId = 1;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('gamebox_player');
      gateway = FakeGateway();
      files = PlayerFiles(
        gateway: gateway,
        cacheDir: () async => '${temp.path}/cache',
        dataBase: () async => '${temp.path}/base',
      );
    });
    tearDown(() => temp.deleteSync(recursive: true));

    GameRow game(String console) => GameRow(
        id: nextId++, title: 'T', sortTitle: 't', consoleId: console, addedAt: DateTime(2026), playCount: 0, isMissing: false);
    GameFileRow file(int gameId, String uri, {bool primary = true}) => GameFileRow(
          id: nextId++,
          gameId: gameId,
          uri: uri,
          displayPath: Uri.decodeComponent(uri).split(RegExp('[/:]')).last,
          extension: uri.split('.').last,
          fileExists: true,
          isPrimary: primary,
        );

    test('a readable file is used in place; BIOS and save folders are created', () async {
      final rom = File('${temp.path}/ROMs/nes/Hero.nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom());
      final g = game('nes');
      final p = await files.prepare(g, [file(g.id, rom.path)]);
      expect(p.problem, isNull);
      expect(p.romPath, rom.path);
      expect(p.savesDir, '${temp.path}/base/GAMEBOX/Saves/GAMEBOX/nes');
      expect(Directory(p.savesDir!).existsSync(), isTrue);
      expect(p.systemDir, '${temp.path}/base/GAMEBOX/BIOS/NES');

      final ps1 = game('ps1');
      final rom2 = File('${temp.path}/ROMs/psx/a.chd')..createSync(recursive: true);
      final q = await files.prepare(ps1, [file(ps1.id, rom2.path)]);
      expect(q.systemDir, '${temp.path}/base/GAMEBOX/BIOS/PS1', reason: 'PCSX ReARMed finds a real BIOS here');
      expect(q.savesDir, endsWith('/Saves/GAMEBOX/psx'));
    });

    test('a game in a picked (SAF) folder is copied with all its files', () async {
      final g = game('ps1');
      final cue = '$tree/document/1234-5678%3AGames%2Fpsx%2FCrash.cue';
      final bin = '$tree/document/1234-5678%3AGames%2Fpsx%2FCrash%20(Track%201).bin';
      gateway.documents[cue] = Uint8List.fromList('FILE "Crash (Track 1).bin" BINARY'.codeUnits);
      gateway.documents[bin] = Uint8List(4096);
      final p = await files.prepare(g, [file(g.id, cue), file(g.id, bin, primary: false)]);
      expect(p.problem, isNull);
      expect(p.romPath, '${temp.path}/cache/player/${g.id}/Crash.cue');
      expect(File('${temp.path}/cache/player/${g.id}/Crash (Track 1).bin').lengthSync(), 4096);

      // The next game's preparation removes this copy.
      final other = game('nes');
      final rom = File('${temp.path}/x.nes')..writeAsBytesSync(nesRom());
      await files.prepare(other, [file(other.id, rom.path)]);
      expect(Directory('${temp.path}/cache/player/${g.id}').existsSync(), isFalse);
    });

    test('ZIP archives are extracted; .7z is refused', () async {
      final g = game('nes');
      final zip = File('${temp.path}/pack.zip')
        ..writeAsBytesSync(zipOf({'readme.txt': 'hi'.codeUnits, 'game/Hero.nes': nesRom()}));
      final p = await files.prepare(g, [file(g.id, zip.path)]);
      expect(p.problem, isNull);
      expect(p.romPath, endsWith('/game/Hero.nes'));
      expect(File(p.romPath!).readAsBytesSync(), nesRom());

      final empty = File('${temp.path}/docs.zip')..writeAsBytesSync(zipOf({'readme.txt': 'hi'.codeUnits}));
      expect((await files.prepare(g, [file(g.id, empty.path)])).problem, contains('no game file'));

      final seven = File('${temp.path}/a.7z')..writeAsBytesSync([1, 2, 3]);
      expect((await files.prepare(g, [file(g.id, seven.path)])).problem, contains('.7z'));
    });
  });

  group('launch service', () {
    test('plays NES in the built-in player when nothing is installed', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final temp = Directory.systemTemp.createTempSync('gamebox_player_ls');
      addTearDown(() => temp.deleteSync(recursive: true));
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final gateway = FakeGateway()..installed.clear();
      final device = DeviceIntelligenceService(gateway, db);
      await device.scan();
      final launcher = LaunchService(
        gateway: gateway,
        db: db,
        emulators: EmulatorDetectionService(gateway, db),
        device: device,
      )..playerFiles = PlayerFiles(
          gateway: gateway,
          cacheDir: () async => '${temp.path}/cache',
          dataBase: () async => '${temp.path}/base',
        );
      final rom = File('${temp.path}/ROMs/nes/Hero.nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom());
      final id = await db.insertGameWithFiles(
        GamesCompanion.insert(title: 'Hero', sortTitle: 'hero', consoleId: 'nes', addedAt: DateTime(2026)),
        [GameFilesCompanion.insert(gameId: 0, uri: rom.path, displayPath: 'nes/Hero.nes', extension: 'nes', isPrimary: const Value(true))],
      );
      final o = await launcher.play(id);
      expect(o.ok, isTrue, reason: o.reasons.join());
      expect(o.emulatorName, 'GAMEBOX Player');
      final extras = gateway.launchedSpecs.single['extras'] as Map;
      expect(extras['core'], 'fceumm');
      expect(extras['rom'], rom.path);
      expect(extras['title'], 'Hero');
      expect((await db.historyForGame(id)).single.emulatorId, 'gamebox');
    });

    test('a crash of the built-in player is reported instead of the "how did it run?" question', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final temp = Directory.systemTemp.createTempSync('gamebox_player_crash');
      addTearDown(() => temp.deleteSync(recursive: true));
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final gateway = FakeGateway()..installed.clear();
      final device = DeviceIntelligenceService(gateway, db);
      await device.scan();
      final launcher = LaunchService(gateway: gateway, db: db, emulators: EmulatorDetectionService(gateway, db), device: device)
        ..playerFiles = PlayerFiles(
            gateway: gateway, cacheDir: () async => '${temp.path}/c', dataBase: () async => '${temp.path}/b');
      final rom = File('${temp.path}/Hero.nes')..writeAsBytesSync(nesRom());
      final id = await db.insertGameWithFiles(
        GamesCompanion.insert(title: 'Hero', sortTitle: 'hero', consoleId: 'nes', addedAt: DateTime(2026)),
        [GameFilesCompanion.insert(gameId: 0, uri: rom.path, displayPath: 'Hero.nes', extension: 'nes')],
      );
      expect((await launcher.play(id)).ok, isTrue);

      gateway.crashReport = {
        'core': 'fceumm',
        'rom': rom.path,
        'frames': 0,
        'message': '',
        'log': 'F libc: Fatal signal 11 (SIGSEGV)',
      };
      await launcher.onReturned();
      expect(launcher.finishedSession.value, isNull);
      final crash = launcher.playerCrash.value!;
      expect(crash.game, 'Hero.nes');
      expect(crash.frames, 0);
      expect(crash.details, allOf(contains('Core: fceumm'), contains('Fatal signal 11')));

      // Reported once; a normal return asks how it ran again.
      launcher.playerCrash.value = null;
      expect((await launcher.play(id)).ok, isTrue);
      await launcher.onReturned();
      expect(launcher.playerCrash.value, isNull);
      expect(launcher.finishedSession.value, (id, 'gamebox'));
    });
  });

  group('emulator links and web search', () {
    test('every emulator GAMEBOX can launch has an official source (or says why not)', () {
      for (final e in knownEmulators.where((e) => e.id != 'gamebox')) {
        final l = emulatorLinks[e.id];
        expect(l, isNotNull, reason: e.id);
        expect(l!.playPackage != null || l.site != null || l.note != null, isTrue, reason: e.id);
        if (l.site != null) expect(l.site, startsWith('https://'), reason: e.id);
        if (l.playPackage != null) expect(e.packageIds, contains(l.playPackage), reason: 'the package GAMEBOX detects');
      }
      expect(emulatorLinks['retroarch']!.playStoreApp, 'market://details?id=com.retroarch');
      expect(homebrewSources.every((s) => s.url.startsWith('https://')), isTrue);
    });

    test('web search only opens the browser with what was typed', () {
      expect(webSearchUrl('  Pixel Quest nes '), 'https://www.google.com/search?q=Pixel+Quest+nes');
      expect(webSearchUrl('a&b=c'), 'https://www.google.com/search?q=a%26b%3Dc');
    });
  });
}

