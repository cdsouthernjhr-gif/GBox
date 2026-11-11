import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/app/app_services.dart';
import 'package:gamebox/app/gamebox_app.dart';
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

  Future<void> boot(WidgetTester tester, {Map<String, dynamic>? scan, void Function(String appRoot)? prepare}) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    // 1920x1080 at xhdpi = 960x540 logical, a typical Android TV layout size.
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    gateway = FakeGateway(scan: scan);
    final temp = Directory.systemTemp.createTempSync('gamebox_widget');
    addTearDown(() => temp.deleteSync(recursive: true));
    prepare?.call('${temp.path}/ext0');
    services = AppServices(
      gateway: gateway,
      db: AppDatabase(NativeDatabase.memory()),
      appRoots: () async => ['${temp.path}/ext0'],
      artworkDir: () async => '${temp.path}/artwork',
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
}
