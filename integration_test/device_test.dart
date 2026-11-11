// On-device test suite. Runs on an Android device or emulator:
//   flutter test integration_test/device_test.dart -d <device-id>
// CI runs it on Android emulators (see .github/workflows/android.yml,
// job "device-tests"). Results on physical TV boxes are recorded in
// docs/DEVICE_COMPATIBILITY.md.
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
    final roots = await services.library.ensureAppFolders();
    expect(roots, isNotEmpty);
    final rom = File('${roots.first}/Games/NES/ci_test_homebrew.nes')..writeAsBytesSync(syntheticNes());
    try {
      await services.library.scanAll();
      final files = await services.db.select(services.db.gameFiles).get();
      final f = files.singleWhere((f) => f.uri == rom.path);
      expect(f.headerStatus, 'valid', reason: f.headerDetail);
      expect(f.sha1, hasLength(40), reason: 'hashed by the native layer');

      // FileProvider must expose GAMEBOX game files to emulators.
      final shared = await gateway.shareableUri(rom.path);
      expect(shared, startsWith('content://com.gamebox.console.files/'));
    } finally {
      rom.deleteSync();
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
    for (var i = 0; i < 20 && find.text('HOME').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    // main() forces landscape; this test bypasses main(), so the screen
    // orientation is whatever the emulator profile provides.
    expect(find.text('HOME'), findsWidgets);
    expect(find.text('MY GAMES'), findsOneWidget);
    // At TV size (CI uses the tv_1080p profile) the whole menu fits; the
    // list is lazy, so this also checks the menu is not taller than a TV.
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    if (size.width > size.height) {
      expect(find.text('ANDROID APPS'), findsOneWidget, reason: 'all 11 menu entries fit on a $size screen');
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
