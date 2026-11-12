import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
      DownloadEngine? engine}) async {
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
    );
    await tester.runAsync(() async {
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

  testWidgets('Play on the game page launches RetroArch and records the session', (tester) async {
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
    await settle(tester);
    await settle(tester);
    // The synthetic device is Android 9 (API 28), so RetroArch may read the
    // GAMEBOX folder path directly.
    expect(gateway.launchedSpecs, hasLength(1));
    expect(gateway.launchedSpecs.single['className'], 'com.retroarch.browser.retroactivity.RetroActivityFuture');
    expect(find.textContaining('Starting Space Quest in RetroArch'), findsOneWidget);
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
    await settle(tester);
    await settle(tester);
    expect(gateway.launchedSpecs, hasLength(1));

    final back = services.launcher.onReturned(); // user comes back from RetroArch
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
    expect(rows.single.emulatorId, 'retroarch');
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
}
