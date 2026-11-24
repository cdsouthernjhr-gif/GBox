// On-device test suite. Runs on an Android device or emulator:
//   flutter test integration_test/device_test.dart -d <device-id>
// CI runs it on Android emulators (see .github/workflows/android.yml,
// job "device-tests"). Results on physical TV boxes are recorded in
// docs/DEVICE_COMPATIBILITY.md.
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/app/app_services.dart';
import 'package:gamebox/app/gamebox_app.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/services/platform_gateway.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// Synthetic iNES header (format documentation only — not game data).
Uint8List syntheticNes() => Uint8List(0x4010)..setAll(0, [0x4E, 0x45, 0x53, 0x1A, 1, 1, 0, 0]);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final gateway = MethodChannelGateway();

  testWidgets('hardware scan returns a real profile', (tester) async {
    final p = DeviceIntelligenceService.profileFromNative(await gateway.scanHardware());
    // Printed so the CI log doubles as a device report.
    // ignore: avoid_print
    print('DEVICE: ${p.manufacturer} ${p.model} · Android ${p.androidVersion} (API ${p.sdkInt}) · '
        'ABIs ${p.supportedAbis} · cores ${p.cpuCores} · RAM ${p.totalRamBytes} · '
        'GL ${p.glRenderer} ES ${p.glEsVersion} · Vulkan ${p.vulkanSupported} · '
        '${p.displayWidth}x${p.displayHeight} · TV ${p.isTelevision}');
    expect(p.sdkInt, greaterThanOrEqualTo(24));
    expect(p.supportedAbis, isNotEmpty);
    expect(p.totalRamBytes, greaterThan(0));
    expect(p.displayWidth, greaterThan(0));
    expect(p.storageVolumes.where((v) => v.isPrimary), isNotEmpty);
  });

  testWidgets('bundled SQLite: the real database file opens, seeds and backs up', (tester) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ci_device_test.sqlite');
    if (file.existsSync()) file.deleteSync();
    final db = AppDatabase(NativeDatabase(file));
    expect(await db.select(db.consoles).get(), hasLength(16));
    await db.setSetting('ci', 'ok');
    final backup = '${dir.path}/ci_device_test_backup.sqlite';
    await db.backupTo(backup);
    await db.close();
    final again = AppDatabase(NativeDatabase(File(backup)));
    expect(await again.getSetting('ci'), 'ok');
    await again.close();
    file.deleteSync();
    File(backup).deleteSync();
  });

  testWidgets('library: GAMEBOX folder scan, native header read and hashing', (tester) async {
    final services = AppServices(gateway: gateway, db: AppDatabase(NativeDatabase.memory()));
    await services.settings.initialize();
    expect(await services.library.ensureAppFolders(), isNotEmpty);
    // The full folder layout (games, saves, BIOS) exists on device storage.
    final access = await services.location.refreshAccess();
    expect(access.sdkInt, greaterThanOrEqualTo(24));
    expect(access.publicRoot, isNotNull);
    expect(await services.location.ensureStructure(), isEmpty);
    final base = (await services.location.localBase())!;
    for (final f in ['ROMs/psx', 'ROMs/nes', 'GAMEBOX/Saves/RetroArch/saves', 'GAMEBOX/BIOS/PS1', 'GAMEBOX/Playlists']) {
      expect(Directory('$base/$f').existsSync(), isTrue, reason: f);
    }
    final rom = File('$base/ROMs/nes/ci_test_homebrew.nes')..writeAsBytesSync(syntheticNes());
    try {
      await services.library.scanAll();
      final files = await services.db.select(services.db.gameFiles).get();
      final f = files.singleWhere((f) => f.uri == rom.path);
      expect(f.headerStatus, 'valid', reason: f.headerDetail);
      expect(f.sha1, hasLength(40), reason: 'hashed by the native layer');

      // FileProvider must expose the game folder to emulators.
      final shared = await gateway.shareableUri(rom.path);
      expect(shared, startsWith('content://com.gamebox.console.files/'));
    } finally {
      rom.deleteSync();
      await services.db.close();
    }
  });

  testWidgets('built-in player loads a bundled core and renders frames', (tester) async {
    final services = AppServices(gateway: gateway, db: AppDatabase(NativeDatabase.memory()));
    await services.settings.initialize();
    await services.location.refreshAccess();
    await services.location.ensureStructure();
    final base = (await services.location.localBase())!;
    // Synthetic iNES image: header + 16 KB PRG + 8 KB CHR of zeros (format
    // documentation only, not game data). FCEUmm runs it as a blank screen.
    final bytes = Uint8List(16 + 16384 + 8192)..setAll(0, [0x4E, 0x45, 0x53, 0x1A, 1, 1, 0, 0]);
    final rom = File('$base/ROMs/nes/ci_player_test.nes')..writeAsBytesSync(bytes);
    try {
      final id = await services.db.insertGameWithFiles(
        GamesCompanion.insert(title: 'CI player test', sortTitle: 'ci', consoleId: 'nes', addedAt: DateTime.now()),
        [GameFilesCompanion.insert(gameId: 0, uri: rom.path, displayPath: 'nes/ci_player_test.nes', extension: 'nes')],
      );
      final outcome = await services.launcher.play(id);
      expect(outcome.ok, isTrue, reason: outcome.reasons.join());
      expect(outcome.emulatorName, 'GAMEBOX Player');

      Map<String, dynamic> st = {};
      for (var i = 0; i < 60; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        st = await gateway.playerStatus();
        if (st['state'] == 'error' || ((st['frames'] as num?) ?? 0) > 60) break;
      }
      // ignore: avoid_print
      print('PLAYER: $st');
      expect(st['state'], 'running', reason: '$st');
      expect((st['frames'] as num) > 60, isTrue, reason: 'the core renders frames: $st');
      expect(st['core'], 'fceumm');

      await gateway.closePlayer();
      for (var i = 0; i < 20 && (await gateway.playerStatus())['state'] != 'closed'; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      expect((await gateway.playerStatus())['state'], 'closed');
    } finally {
      if (rom.existsSync()) rom.deleteSync();
      await services.db.close();
    }
  });

  testWidgets('emulator launch errors are reported, never thrown', (tester) async {
    final r = await gateway.launchIntent({
      'package': 'com.example.not.installed',
      'className': 'com.example.not.installed.Main',
      'fallbacks': [
        {'package': 'com.example.not.installed', 'action': 'android.intent.action.VIEW'},
      ],
    });
    expect(r['ok'], isFalse);
    expect(r['code'], 'not_found');
  });

  testWidgets('storage, input, connectivity, performance and launcher channels respond', (tester) async {
    expect(await gateway.storageVolumes(), isNotEmpty);
    expect(await gateway.listInputDevices(), isA<List<Map<String, dynamic>>>());
    expect((await gateway.connectivity()).transport, isNotEmpty);
    final perf = await gateway.performanceSnapshot();
    expect(perf['totalRamBytes'], greaterThan(0));
    expect(await gateway.isDefaultLauncher(), isA<bool>());
    expect(await gateway.listApps(), isA<List<InstalledApp>>());
    final free = await gateway.freeSpace((await getApplicationDocumentsDirectory()).path);
    expect(free, greaterThan(0));
    await gateway.setInputConfig(remaps: const {}, deadZones: const {}, stickNavigation: true);
  });

  testWidgets('launcher UI boots with the real native layer', (tester) async {
    final services = AppServices(gateway: gateway, db: AppDatabase(NativeDatabase.memory()));
    await services.initialize();
    await tester.pumpWidget(GameboxApp(services: services));
    // HOME is the game launcher. Wait for the library to load: either the
    // empty state (setup) or the first game in the panel.
    bool loaded() =>
        find.text('No games yet').evaluate().isNotEmpty || find.byKey(const ValueKey('hero-title')).evaluate().isNotEmpty;
    for (var i = 0; i < 40 && !loaded(); i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.byKey(const ValueKey('game-home')), findsOneWidget);
    expect(loaded(), isTrue, reason: 'the launcher shows the games or the setup prompt');
    if (find.text('No games yet').evaluate().isNotEmpty) expect(find.text('Set up GAMEBOX'), findsOneWidget);
    // Left opens the side menu.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('MY GAMES'), findsOneWidget);
    // main() forces landscape; this test bypasses main(), so the screen
    // orientation is whatever the emulator profile provides. At TV size
    // (CI uses the tv_1080p profile) the whole menu fits; the list is lazy,
    // so this also checks the menu is not taller than a TV.
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    if (size.width > size.height) {
      expect(find.text('ANDROID APPS'), findsOneWidget, reason: 'all 11 menu entries fit on a $size screen');
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
