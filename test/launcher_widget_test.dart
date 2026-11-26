import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/features/rom_manager/rom_search_service.dart';
import 'package:gamebox/features/setup/rom_search_screen.dart';
import 'package:gamebox/core/rom/scan_planner.dart';
import 'package:gamebox/features/source_manager/find_online_screen.dart';
import 'package:gamebox/features/game_scraper/cover_art_service.dart';
import 'package:gamebox/features/game_library/game_detail_screen.dart';
import 'package:gamebox/features/settings/settings_screen.dart';
import 'player_covers_test.dart' show ps2Iso;
import 'package:gamebox/app/app_services.dart';
import 'package:gamebox/app/gamebox_app.dart';
import 'package:gamebox/core/online/download_engine.dart';
import 'package:drift/drift.dart' show Value;
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/features/compatibility/device_report_screen.dart';

import 'rom_logic_test.dart' show gbaRom, nesRom;

import 'support/fakes.dart';

/// Pumps frames while letting real async database work complete.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
  }
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  late FakeGateway gateway;
  late AppServices services;

  Future<void> boot(WidgetTester tester,
      {Map<String, dynamic>? scan,
      void Function(String appRoot)? prepare,
      void Function(FakeGateway)? configure,
      DownloadEngine? engine,
      CoverFetcher? coverFetch,
      HomeStyle home = HomeStyle.dashboard}) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    // 1920x1080 at xhdpi = 960x540 logical, a typical Android TV layout size.
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    gateway = FakeGateway(scan: scan);
    configure?.call(gateway);
    final temp = Directory.systemTemp.createTempSync('gamebox_widget');
    addTearDown(() => temp.deleteSync(recursive: true));
    prepare?.call('${temp.path}/ext0');
    services = AppServices(
      gateway: gateway,
      db: AppDatabase(NativeDatabase.memory()),
      appRoots: () async => ['${temp.path}/ext0'],
      artworkDir: () async => '${temp.path}/artwork',
      downloadEngine: engine,
      coverFetch: coverFetch,
    );
    await tester.runAsync(() async {
      // Most tests drive the side menu from the dashboard; the game launcher
      // (the default) has its own tests.
      await services.db.setSetting(SettingsKeys.homeStyle, home.name);
      await services.initialize();
      // Let background detection + first scan finish.
      for (var i = 0;
          i < 100 && (services.device.state.value.profile == null || services.library.progress.value.finishedAt == null);
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpWidget(GameboxApp(services: services));
    await settle(tester);
  }

  Future<void> shutdown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Flush Drift's stream-cleanup timers (fake time) before closing.
    await tester.pump(const Duration(seconds: 1));
    services.dispose();
    var closed = false;
    services.db.close().whenComplete(() => closed = true);
    for (var i = 0; i < 50 && !closed; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    }
    expect(closed, isTrue, reason: 'database closed cleanly');
  }

  /// Pumps until [done] (real file I/O of the built-in player's preparation
  /// only advances in runAsync windows).
  Future<void> settleUntil(WidgetTester tester, bool Function() done, {int max = 30}) async {
    for (var i = 0; i < max && !done(); i++) {
      await settle(tester);
    }
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await settle(tester);
  }

  testWidgets('launcher shows all navigation sections and offline status', (tester) async {
    await boot(tester);
    for (final label in [
      'HOME', 'MY GAMES', 'CONSOLES', 'RECENTLY PLAYED', 'FAVOURITES', 'DOWNLOADS',
      'EMULATORS', 'CONTROLLERS', 'STORAGE', 'SETTINGS', 'ANDROID APPS',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('Offline'), findsWidgets);
    expect(find.text('WELCOME TO GAMEBOX'), findsOneWidget);
    expect(find.text('1 controller'), findsOneWidget);
    expect(gateway.scanCount, 1);
    await shutdown(tester);
  });

  testWidgets('D-pad down moves through the menu and switches sections', (tester) async {
    await boot(tester);
    await press(tester, LogicalKeyboardKey.arrowDown); // MY GAMES
    expect(find.text('No games in your library yet'), findsOneWidget);
    await press(tester, LogicalKeyboardKey.arrowDown); // CONSOLES
    expect(find.text('Retro systems'.toUpperCase()), findsOneWidget);
    await shutdown(tester);
  });

  testWidgets('BACK never closes the launcher and returns to HOME', (tester) async {
    await boot(tester);
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowDown);
    // Simulate Android's system BACK (flutter/navigation popRoute).
    var appExited = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (call) async {
      if (call.method == 'SystemNavigator.pop') appExited = true;
      return null;
    });
    final message = const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
    await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage('flutter/navigation', message, (_) {});
    await tester.pump(const Duration(milliseconds: 300));
    expect(appExited, isFalse, reason: 'the launcher never closes on BACK');
    expect(find.text('WELCOME TO GAMEBOX'), findsOneWidget);
    await shutdown(tester);
  });

  testWidgets('emulator screen reflects detected installs', (tester) async {
    await boot(tester);
    for (var i = 0; i < 6; i++) {
      await press(tester, LogicalKeyboardKey.arrowDown);
    }
    expect(find.text('Emulators'), findsOneWidget);
    expect(find.textContaining('Installed 1.17.1'), findsOneWidget);
    expect(find.text('Not installed'), findsWidgets);
    await shutdown(tester);
  });

  testWidgets('settings change theme and persist to the database', (tester) async {
    await boot(tester);
    for (var i = 0; i < 9; i++) {
      await press(tester, LogicalKeyboardKey.arrowDown);
    }
    expect(find.text('Dark Gaming'), findsOneWidget);
    await tester.runAsync(() => services.settings.set(SettingsKeys.theme, AppThemeId.retroArcade.name));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Retro Arcade'), findsOneWidget);
    expect(await tester.runAsync(() => services.db.getSetting(SettingsKeys.theme)), 'retroArcade');
    await shutdown(tester);
  });

  testWidgets('unknown hardware values are shown as UNKNOWN', (tester) async {
    final scan = syntheticNativeScan(renderer: null, cpuInfo: null)..remove('buildId');
    await boot(tester, scan: scan);
    await tester.tap(find.text('Device compatibility'.toUpperCase()));
    await settle(tester);
    await settle(tester);
    expect(find.byType(DeviceReportScreen), findsOneWidget);
    expect(find.text('Device compatibility report'), findsOneWidget);
    expect(find.text('UNKNOWN'), findsWidgets);
    await shutdown(tester);
  });

  testWidgets('startup scan fills My Games and search filters it', (tester) async {
    await boot(tester, prepare: (root) {
      for (final (folder, name, bytes) in [
        ('NES', 'Space Quest (USA).nes', nesRom()),
        ('GBA', 'Farm Life.gba', gbaRom()),
      ]) {
        File('$root/GAMEBOX/Games/$folder/$name')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
      }
    });
    await press(tester, LogicalKeyboardKey.arrowDown); // MY GAMES
    // Each card shows the title on the generated cover and in the caption.
    expect(find.text('Space Quest'), findsWidgets);
    expect(find.text('Farm Life'), findsWidgets);
    expect(find.textContaining('2 added'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'farm');
    await settle(tester);
    expect(find.text('Farm Life'), findsWidgets);
    expect(find.text('Space Quest'), findsNothing);
    await shutdown(tester);
  });

  testWidgets('Play on the game page starts the built-in player and records the session', (tester) async {
    await boot(
      tester,
      configure: (g) => g.installed['com.retroarch'] = '1.20.0',
      prepare: (root) => File('$root/GAMEBOX/Games/NES/Space Quest.nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom()),
    );
    await press(tester, LogicalKeyboardKey.arrowDown); // MY GAMES
    await tester.tap(find.text('Space Quest').last);
    await settle(tester);
    await settle(tester);
    expect(find.text('Play with…'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await settleUntil(tester, () => gateway.launchedSpecs.isNotEmpty);
    await settle(tester);
    // NES plays in the built-in player by default, straight from GAMEBOX's
    // own folder (no copy needed).
    expect(gateway.launchedSpecs, hasLength(1));
    final spec = gateway.launchedSpecs.single;
    expect(spec['package'], 'com.gamebox.console');
    expect(spec['className'], 'com.gamebox.console.player.PlayerActivity');
    final extras = spec['extras'] as Map;
    expect(extras['core'], 'fceumm');
    expect(extras['rom'], endsWith('/GAMEBOX/Games/NES/Space Quest.nes'));
    expect(extras['saves'], endsWith('/GAMEBOX/Saves/GAMEBOX/nes'));
    expect(extras['layout'], 'nes');
    expect(find.textContaining('Starting Space Quest in GAMEBOX Player'), findsOneWidget);
    final game = (await tester.runAsync(() => services.db.select(services.db.games).get()))!.single;
    expect(game.playCount, 1);
    await shutdown(tester);
  });

  testWidgets('mapping wizard: binds pad keys, ignores B→BACK fallback, remote BACK skips', (tester) async {
    await boot(tester);
    for (var i = 0; i < 7; i++) {
      await press(tester, LogicalKeyboardKey.arrowDown); // CONTROLLERS
    }
    await tester.tap(find.text('Map buttons'));
    await settle(tester);
    expect(find.text('A'), findsOneWidget);

    Future<void> padKey(int code) async {
      gateway.raw.add(RawInputEvent(type: 'key', deviceId: 5, keyCode: code, keyName: '$code', isDown: true));
      await tester.pump();
      // Real time must pass: the wizard ignores input for 350 ms after a bind.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 380)));
      await tester.pump();
    }

    Future<void> systemBack() async {
      final message = const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute'));
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage('flutter/navigation', message, (_) {});
      await tester.pump();
    }

    // A ← physical B (97). Android then falls back to BACK immediately:
    gateway.raw.add(const RawInputEvent(type: 'key', deviceId: 5, keyCode: 97, keyName: 'BUTTON_B', isDown: true));
    await tester.pump();
    await systemBack(); // must NOT skip the next step
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 380)));
    await tester.pump();
    expect(find.text('B'), findsOneWidget, reason: 'now asking for B');

    await padKey(96); // B ← physical A
    expect(find.text('X'), findsOneWidget);
    await systemBack(); // remote BACK: skip X
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 380)));
    await tester.pump();
    expect(find.text('Y'), findsOneWidget);
    for (final code in [100, 102, 103, 104, 105, 108, 109, 19, 20, 21, 22, 106, 107]) {
      await padKey(code);
    }
    await settle(tester);
    expect(find.text('Save mapping'), findsOneWidget);
    expect(find.textContaining('not mapped'), findsOneWidget, reason: 'X was skipped');

    await tester.tap(find.text('Save mapping'));
    await settle(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await settle(tester);
    final remaps = gateway.lastInputConfig!['remaps'] as Map;
    expect(remaps['abc123'], {97: 96, 96: 97});
    await shutdown(tester);
  });

  testWidgets('Downloads: completed file can be imported from the queue; Sources view', (tester) async {
    // Network transfers are covered by test/online_services_test.dart (real
    // local server). Here: the UI for a finished download.
    late String file;
    await boot(tester, prepare: (root) {
      file = '$root/GAMEBOX/Downloads/demo.nes';
      File(file)
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom());
    });
    for (var i = 0; i < 5; i++) {
      await press(tester, LogicalKeyboardKey.arrowDown); // DOWNLOADS
    }
    final now = DateTime.now();
    final insert = services.db.into(services.db.downloadQueue).insert(DownloadQueueCompanion.insert(
          name: 'demo.nes',
          url: 'https://example.org/demo.nes',
          destination: File(file).parent.path,
          status: 'completed',
          createdAt: now,
          updatedAt: now,
          filePath: Value(file),
          totalBytes: const Value(16400),
          downloadedBytes: const Value(16400),
        ));
    await settle(tester);
    await insert;
    await settle(tester);
    expect(find.text('COMPLETED'), findsOneWidget);

    await tester.tap(find.text('Import into library'));
    for (var i = 0; i < 4; i++) {
      await settle(tester);
    }
    expect(find.text('IN LIBRARY'), findsOneWidget);

    await tester.tap(find.text('Sources'));
    await settle(tester);
    expect(find.text('No sources'), findsOneWidget);
    await shutdown(tester);
  });

  testWidgets('after returning from a game, GAMEBOX asks how it ran and stores the answer', (tester) async {
    await boot(
      tester,
      configure: (g) => g.installed['com.retroarch'] = '1.20.0',
      prepare: (root) => File('$root/GAMEBOX/Games/NES/Space Quest.nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom()),
    );
    await press(tester, LogicalKeyboardKey.arrowDown); // MY GAMES
    await tester.tap(find.text('Space Quest').last);
    await settle(tester);
    await settle(tester);
    await tester.tap(find.text('Play'));
    await settleUntil(tester, () => gateway.launchedSpecs.isNotEmpty);
    await settle(tester);
    expect(gateway.launchedSpecs, hasLength(1));

    final back = services.launcher.onReturned(); // user comes back from the game
    await settle(tester);
    await back;
    await settle(tester);
    expect(find.text('How did Space Quest run?'), findsOneWidget);
    await tester.tap(find.text('Good'));
    await settle(tester);
    await settle(tester);
    final results = services.db.select(services.db.compatibilityTestResults).get();
    await settle(tester);
    final rows = await results;
    expect(rows.single.result, 'good');
    expect(rows.single.emulatorId, 'gamebox');
    expect(rows.single.consentToShare, isFalse, reason: 'sharing is opt-in');
    await shutdown(tester);
  });

  testWidgets('performance screen shows live data and honest unavailability', (tester) async {
    await boot(tester);
    for (var i = 0; i < 9; i++) {
      await press(tester, LogicalKeyboardKey.arrowDown); // SETTINGS
    }
    await tester.scrollUntilVisible(find.text('Performance & benchmarks'), 200,
        scrollable: find.byType(Scrollable).last);
    // Bring the whole row on screen (scrollUntilVisible can stop at the edge).
    await tester.ensureVisible(find.text('Performance & benchmarks'));
    await settle(tester);
    await tester.tap(find.text('Performance & benchmarks'));
    await settle(tester);
    await settle(tester);
    expect(find.text('Not accessible to apps on Android 8+'), findsOneWidget);
    expect(find.text('52.0 °C'), findsOneWidget);
    expect(find.text('1200 / 1800 MHz'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await settle(tester);
    await shutdown(tester);
  });

  testWidgets('Game Home: opens on the games, rows per console, A plays, left opens the menu', (tester) async {
    await boot(
      tester,
      home: HomeStyle.games,
      configure: (g) => g.installed['com.retroarch'] = '1.20.0',
      prepare: (root) {
        for (final (folder, name, bytes) in [
          ('NES', 'Alpha Quest.nes', nesRom()),
          ('NES', 'Beta Run.nes', nesRom()),
          ('GBA', 'Gamma Race.gba', gbaRom()),
        ]) {
          File('$root/GAMEBOX/Games/$folder/$name')
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes);
        }
      },
    );
    expect(find.byKey(const ValueKey('game-home')), findsOneWidget);
    // One row per console, most games first; the menu is icons only.
    expect(find.text('NES'), findsOneWidget);
    expect(find.text('Game Boy Advance'), findsOneWidget);
    expect(find.text('MY GAMES'), findsNothing);
    expect(tester.getTopLeft(find.text('NES')).dy,
        lessThan(tester.getTopLeft(find.text('Game Boy Advance')).dy));

    // The first game has focus and fills the panel.
    Text hero() => tester.widget<Text>(find.byKey(const ValueKey('hero-title')));
    expect(hero().data, 'Alpha Quest');
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(hero().data, 'Beta Run');
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(hero().data, 'Gamma Race');
    await press(tester, LogicalKeyboardKey.arrowUp);

    // Y toggles the favourite: a Favourites row appears.
    await press(tester, LogicalKeyboardKey.gameButtonY);
    await settle(tester);
    expect(find.text('Favourites'), findsOneWidget);

    // A / OK plays straight away with the console default (built-in player).
    await press(tester, LogicalKeyboardKey.enter);
    await settleUntil(tester, () => gateway.launchedSpecs.isNotEmpty);
    await settle(tester);
    expect(gateway.launchedSpecs, hasLength(1));
    expect(gateway.launchedSpecs.single['className'], 'com.gamebox.console.player.PlayerActivity');
    expect(find.textContaining('Starting Alpha Quest in GAMEBOX Player'), findsOneWidget);

    // Left on the first game of a row opens the full menu.
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('MY GAMES'), findsOneWidget, reason: 'menu expanded');
    // BACK on the menu returns to the games and shrinks the menu again.
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation', const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')), (_) {});
    await settle(tester);
    expect(find.text('MY GAMES'), findsNothing);
    expect(find.byKey(const ValueKey('game-home')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await shutdown(tester);
  });

  testWidgets('Game Home with an empty library offers setup and the ROM search', (tester) async {
    await boot(tester, home: HomeStyle.games);
    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('Set up GAMEBOX'), findsOneWidget);
    expect(find.text('Find ROMs on this device'), findsOneWidget);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('SETTINGS'), findsOneWidget, reason: 'left opens the menu');
    expect(tester.takeException(), isNull);
    await shutdown(tester);
  });

  testWidgets('after a player crash, GAMEBOX shows the details to copy on its next start', (tester) async {
    await boot(
      tester,
      configure: (g) => g.crashReport = {
        'core': 'fceumm',
        'rom': '/storage/emulated/0/ROMs/nes/Hero.nes',
        'frames': 0,
        'message': '',
        'log': 'F libc: Fatal signal 6 (SIGABRT)',
      },
    );
    await settle(tester);
    expect(find.text('The game stopped unexpectedly'), findsOneWidget);
    expect(find.textContaining('Fatal signal 6'), findsOneWidget);
    expect(find.text('Copy details'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await settle(tester);
    expect(find.text('The game stopped unexpectedly'), findsNothing);
    await shutdown(tester);
  });

  testWidgets('ROM search lists games per console with their folder and a summary before copying', (tester) async {
    await boot(tester);
    RomSearchHit hit(String name, String? console, int size) {
      final e = ScannedEntry(uri: '/storage/emulated/0/Download/$name', name: name, dirSegments: const ['Download'], size: size);
      return RomSearchHit(files: [e], primary: e, consoleId: console, candidates: console == null ? ['psp', 'ps2'] : const []);
    }

    services.romSearch.last.value = RomSearchResult(hits: [
      hit('Alpha.nes', 'nes', 40960),
      hit('Beta.nes', 'nes', 40960),
      hit('Gamma.gba', 'gba', 4194304),
      hit('mystery.iso', null, 1048576),
    ], foldersSearched: 12);
    Navigator.of(tester.element(find.byType(Scaffold).first))
        .push(MaterialPageRoute<void>(builder: (_) => const RomSearchScreen()));
    await settle(tester);

    expect(find.text('NES · 2'), findsOneWidget);
    expect(find.textContaining('→ ROMs/nes/'), findsOneWidget);

    // Select all NES games, then summarise.
    await tester.tap(find.text('All').first);
    await settle(tester);
    expect(tester.widget<Text>(find.byKey(const ValueKey('search-selection'))).data, contains('2 game(s)'));
    await tester.tap(find.text('Copy 2 to ROMs…'));
    await settle(tester);
    expect(find.text('Copy 2 game(s) to ROMs?'), findsOneWidget);
    expect(find.text('NES: 2 game(s)'), findsOneWidget);
    expect(find.textContaining('→  ROMs/nes/'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Copy 2 game(s) to ROMs?'), findsNothing);

    // "None" for NES clears the selection.
    await tester.tap(find.text('None').first);
    await settle(tester);
    expect(find.byKey(const ValueKey('search-selection')), findsNothing);

    // Further down: the GBA section with its folder, then files needing a console.
    final list = find.descendant(of: find.byType(RomSearchScreen), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('GAME BOY ADVANCE · 1'), 200, scrollable: list);
    expect(find.textContaining('→ ROMs/gba/'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('NEEDS A CONSOLE (1)'), 200, scrollable: list);
    await settle(tester);
    expect(tester.takeException(), isNull);
    await shutdown(tester);
  });

  testWidgets('no emulator installed: a popup offers the official sources', (tester) async {
    await boot(
      tester,
      home: HomeStyle.games,
      // Saturn: not built in, and no emulator installed.
      prepare: (root) => File('$root/GAMEBOX/Games/SATURN/Race.cue')
        ..createSync(recursive: true)
        ..writeAsStringSync('FILE "Race.bin" BINARY'),
    );
    await press(tester, LogicalKeyboardKey.enter); // play the focused game
    await settleUntil(tester, () => find.textContaining('Get an emulator for').evaluate().isNotEmpty);
    expect(find.textContaining('Get an emulator for'), findsOneWidget);
    expect(find.text('RetroArch'), findsOneWidget);
    expect(gateway.launchedSpecs, isEmpty);

    await tester.tap(find.text('Play Store').first);
    await settle(tester);
    expect(gateway.openedUrls, ['market://details?id=com.retroarch']);

    gateway.canOpenUrls = false;
    await tester.tap(find.text('Official site').first);
    await settle(tester);
    expect(find.textContaining('No app on this device can open the link'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await settle(tester);
    await shutdown(tester);
  });

  testWidgets('Find games online: search opens the browser; homebrew sources open their sites', (tester) async {
    await boot(tester);
    Navigator.of(tester.element(find.byType(Scaffold).first))
        .push(MaterialPageRoute<void>(builder: (_) => const FindOnlineScreen()));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('web-search')), 'pixel quest');
    await tester.tap(find.text('Search'));
    await settle(tester);
    expect(gateway.openedUrls, ['https://www.google.com/search?q=pixel+quest']);
    await tester.tap(find.text('Homebrew Hub'));
    await settle(tester);
    expect(gateway.openedUrls.last, 'https://hh.gbdev.io/');
    expect(tester.takeException(), isNull);
    await shutdown(tester);
  });

  testWidgets('a PS2 disc in the PSP list: popup to move it or get a PS2 emulator', (tester) async {
    await boot(
      tester,
      home: HomeStyle.games,
      prepare: (root) => File('$root/GAMEBOX/Games/PSP/Racer.iso')
        ..createSync(recursive: true)
        ..writeAsBytesSync(ps2Iso()),
    );
    await press(tester, LogicalKeyboardKey.enter); // play the focused game
    await settleUntil(tester, () => find.textContaining('This looks like a PlayStation 2 game').evaluate().isNotEmpty);
    expect(find.textContaining('it is in the PSP list'), findsOneWidget);
    expect(gateway.launchedSpecs, isEmpty, reason: 'not started with the PSP emulator');
    await tester.tap(find.text('Get PlayStation 2 emulator'));
    await settleUntil(tester, () => find.text('Get a PlayStation 2 emulator').evaluate().isNotEmpty);
    expect(find.text('AetherSX2 / NetherSX2'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await settle(tester);

    // Moving it files the game under PS2 (no PS2 emulator: the get-emulator popup).
    final game = (await tester.runAsync(() => services.db.watchAllGames().first))!.single.game;
    await tester.runAsync(() => services.db.setGameConsole(game.id, 'ps2'));
    final moved = (await tester.runAsync(() => services.db.gameById(game.id)))!;
    expect(moved.consoleId, 'ps2');
    await shutdown(tester);
  });

  testWidgets('the built-in player could not open the game: other emulators are offered', (tester) async {
    await boot(
      tester,
      home: HomeStyle.games,
      prepare: (root) => File('$root/GAMEBOX/Games/NES/Hero.nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom()),
    );
    await press(tester, LogicalKeyboardKey.enter);
    await settleUntil(tester, () => gateway.launchedSpecs.isNotEmpty);
    expect(gateway.launchedSpecs.single['className'], 'com.gamebox.console.player.PlayerActivity');
    expect((gateway.launchedSpecs.single['extras'] as Map)['shader'], 'default');
    gateway.player = {'state': 'error', 'errorKind': 'load_game', 'frames': 0};
    await tester.runAsync(() => services.launcher.onReturned());
    await settleUntil(tester, () => find.text('GAMEBOX could not open this game').evaluate().isNotEmpty);
    expect(find.text('RetroArch'), findsOneWidget, reason: 'where to get another NES emulator');
    expect(find.textContaining('How did'), findsNothing, reason: 'no rating question');
    await tester.tap(find.text('Close'));
    await settle(tester);
    await shutdown(tester);
  });

  testWidgets('game details: Download cover finds the box art, or asks for the name', (tester) async {
    final asked = <String>[];
    // A 1x1 PNG.
    final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
    await boot(
      tester,
      prepare: (root) => File('$root/GAMEBOX/Games/NES/Hero Quest (USA).nes')
        ..createSync(recursive: true)
        ..writeAsBytesSync(nesRom()),
      coverFetch: (url) async {
        asked.add(Uri.decodeComponent(url.pathSegments.last));
        if (url.host == 'thumbnails.libretro.com') throw const SocketException('blocked');
        return url.pathSegments.last == 'Hero Quest (Proto).png' ? png : null;
      },
    );
    final game = (await tester.runAsync(() => services.db.watchAllGames().first))!.single.game;
    Navigator.of(tester.element(find.byType(Scaffold).first))
        .push(MaterialPageRoute<void>(builder: (_) => GameDetailScreen(gameId: game.id)));
    await settle(tester);
    await tester.ensureVisible(find.text('Download cover'));
    await tester.tap(find.text('Download cover'));
    await settleUntil(tester, () => find.text('No cover found').evaluate().isNotEmpty);
    // The server could not be reached: GitHub was used; the file name was tried first.
    expect(asked.first, 'Hero Quest (USA).png');
    expect(asked[1], 'Hero Quest (USA).png');
    expect(asked, contains('Hero Quest (Japan).png'), reason: 'common regions are tried');
    await tester.enterText(find.byKey(const ValueKey('cover-name')), 'Hero Quest (Proto)');
    await tester.tap(find.text('Search'));
    await settleUntil(tester, () => find.textContaining('Cover downloaded').evaluate().isNotEmpty);
    expect(asked.last, 'Hero Quest (Proto).png');
    final covers = await tester.runAsync(() => services.db.watchCoverPaths().first);
    expect(covers![game.id], isNotNull);
    await shutdown(tester);
  });

  testWidgets('emulator settings: each built-in emulator has its own display filter and controls', (tester) async {
    await boot(tester, configure: (g) => g.savedCoreOptions['snes9x'] = {'snes9x_region': 'PAL'});
    Navigator.of(tester.element(find.byType(Scaffold).first))
        .push(MaterialPageRoute<void>(builder: (_) => const PlayerCoresScreen()));
    await settle(tester);
    expect(find.text('Game Boy, Game Boy Color'), findsOneWidget);
    await tester.tap(find.text('SNES'));
    await settle(tester);
    expect(find.text('snes9x_region'), findsOneWidget, reason: 'options changed in game are listed');
    await tester.tap(find.text('Display filter'));
    await settle(tester);
    await settleUntil(tester, () => services.settings.state.value.shaderFor('snes9x') == PlayerShader.sharp);
    expect(find.text('Sharp pixels'), findsOneWidget);
    await tester.tap(find.text('On-screen controls'));
    await settleUntil(tester, () => services.settings.state.value.hasOwnTouch('snes9x'));
    expect(services.settings.state.value.touchFor('snes9x'), PlayerTouch.auto);
    await tester.ensureVisible(find.text('Reset emulator options'));
    await tester.tap(find.text('Reset emulator options'));
    await settleUntil(tester, () => find.text('Emulator options reset').evaluate().isNotEmpty);
    expect(gateway.savedCoreOptions['snes9x'], isNull);
    await shutdown(tester);
  });
}
