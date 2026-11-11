import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/constants/console_catalog.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/core/device/device_intelligence_service.dart';
import 'package:gamebox/core/services/system_services.dart';
import 'package:gamebox/features/emulator_manager/launch_service.dart';
import 'package:gamebox/integrations/emulator_adapters/emulator_adapter.dart';
import 'package:gamebox/integrations/emulator_adapters/launcher_registry.dart';
import 'package:gamebox/integrations/retroarch/retroarch_launcher.dart';

import 'support/fakes.dart';

const content = 'content://com.android.externalstorage.documents/tree/primary%3AROMs/document/primary%3AROMs%2Fx';
const path = '/storage/emulated/0/ROMs/x';

LaunchTarget target(String console, {String? contentUri = content, String? fsPath = path}) =>
    LaunchTarget(consoleId: console, originalUri: contentUri ?? fsPath!, extension: 'bin',
        filesystemPath: fsPath, contentUri: contentUri);

LaunchEnvironment env(String pkg, {int sdk = 33, bool arm64 = true}) =>
    LaunchEnvironment(installedPackage: pkg, sdkInt: sdk, supportsArm64: arm64);

IntentSpec ready(LaunchPlan p) {
  expect(p, isA<LaunchReady>(), reason: p is LaunchBlocked ? p.reasons.join() : null);
  return (p as LaunchReady).spec;
}

void main() {
  group('registry', () {
    test('every known emulator can launch games and every console has a launcher', () {
      for (final e in knownEmulators) {
        expect(launcherFor(e.id), isNotNull, reason: e.id);
      }
      for (final c in consoleCatalog) {
        expect(launchersForConsole(c.id), isNotEmpty, reason: c.id);
      }
    });

    test('dedicated emulators are preferred for 3D/handheld consoles, RetroArch for retro', () {
      expect(launchersForConsole('psp').first.emulatorId, 'ppsspp');
      expect(launchersForConsole('n64').first.emulatorId, 'mupen64plus_fz');
      expect(launchersForConsole('nes').first.emulatorId, 'retroarch');
      expect(launchersForConsole('ps1').first.emulatorId, 'retroarch');
    });

    test('nothing is verified on a device yet', () {
      expect(gameLaunchers.where((l) => l.verifiedOnDevice), isEmpty);
    });

    test('RetroArch cores cover the new systems', () {
      final ra = RetroArchLauncher();
      for (final c in ['n64', 'nds', 'psp', 'saturn', 'dreamcast']) {
        expect(ra.options(c).single.values, isNotEmpty, reason: c);
      }
      final spec = ready(ra.plan(target('n64'), env('com.retroarch'), const {}));
      expect(spec.extras['LIBRETRO'], endsWith('mupen64plus_next_libretro_android.so'));
    });
  });

  group('recipes', () {
    test('PPSSPP: content URI as data, granted, generic VIEW fallback, works for the Gold package', () {
      final spec = ready(launcherFor('ppsspp')!.plan(target('psp'), env('org.ppsspp.ppssppgold'), const {}));
      expect(spec.packageName, 'org.ppsspp.ppssppgold');
      expect(spec.className, 'org.ppsspp.ppsspp.PpssppActivity');
      expect(spec.data, content);
      expect(spec.grantReadUris, [content]);
      final fb = spec.fallbacks.single;
      expect(fb.className, isNull);
      expect(fb.action, 'android.intent.action.VIEW');
      expect(fb.data, content);
      expect(spec.toMap()['fallbacks'], hasLength(1));
    });

    test('content-only emulators are blocked without a shareable link', () {
      final p = launcherFor('ppsspp')!.plan(target('psp', contentUri: null), env('org.ppsspp.ppsspp'), const {});
      expect(p, isA<LaunchBlocked>());
    });

    test('Dolphin: arm64 required; AutoStartFile prefers the content URI', () {
      final dolphin = launcherFor('dolphin')!;
      expect(dolphin.plan(target('gamecube'), env('org.dolphinemu.dolphinemu', arm64: false), const {}),
          isA<LaunchBlocked>());
      final spec = ready(dolphin.plan(target('wii'), env('org.dolphinemu.dolphinemu'), const {}));
      expect(spec.extras['AutoStartFile'], content);
      expect(spec.grantReadUris, [content]);
      final pathOnly = ready(dolphin.plan(target('wii', contentUri: null), env('org.dolphinemu.dolphinemu'), const {}));
      expect(pathOnly.extras['AutoStartFile'], path);
      expect(pathOnly.grantReadUris, isEmpty);
    });

    test('DraStic: path extra, Android/data rule, no generic fallback', () {
      final drastic = launcherFor('drastic')!;
      final spec = ready(drastic.plan(target('nds'), env('com.dsemu.drastic'), const {}));
      expect(spec.extras['GAMEPATH'], path);
      expect(spec.fallbacks, isEmpty);
      const priv = '/storage/emulated/0/Android/data/com.gamebox.console/files/GAMEBOX/Games/NDS/x.nds';
      expect(drastic.plan(target('nds', fsPath: priv), env('com.dsemu.drastic'), const {}), isA<LaunchBlocked>());
      expect(drastic.plan(target('nds', fsPath: priv), env('com.dsemu.drastic', sdk: 29), const {}), isA<LaunchReady>());
    });

    test('melonDS: custom action, uri extra, VIEW fallback', () {
      final spec = ready(launcherFor('melonds')!.plan(target('nds'), env('me.magnum.melonds'), const {}));
      expect(spec.action, 'me.magnum.melonds.LAUNCH_ROM');
      expect(spec.className, isNull);
      expect(spec.extras['uri'], content);
      expect(spec.fallbacks, hasLength(1));
    });

    test('Flycast / Redream: generic VIEW is already the primary (no duplicate fallback)', () {
      for (final id in ['flycast', 'redream']) {
        final spec = ready(launcherFor(id)!.plan(target('dreamcast'), env('pkg.$id'), const {}));
        expect(spec.action, 'android.intent.action.VIEW');
        expect(spec.data, content);
        expect(spec.fallbacks, isEmpty, reason: id);
      }
    });

    test('AetherSX2: arm64, bootPath, rejects other consoles', () {
      final a = launcherFor('aethersx2')!;
      expect(ready(a.plan(target('ps2'), env('xyz.aethersx2.android'), const {})).extras['bootPath'], content);
      expect(a.plan(target('ps1'), env('xyz.aethersx2.android'), const {}), isA<LaunchBlocked>());
      expect(a.plan(target('ps2'), env('xyz.aethersx2.android', arm64: false), const {}), isA<LaunchBlocked>());
    });
  });

  group('launch service with device intelligence', () {
    late AppDatabase db;
    tearDown(() => db.close());

    Future<(LaunchService, FakeGateway)> setup(Map<String, dynamic> scan) async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      final gateway = FakeGateway(scan: scan)..installed.clear();
      final device = DeviceIntelligenceService(gateway, db);
      await device.scan();
      return (
        LaunchService(gateway: gateway, db: db, emulators: EmulatorDetectionService(gateway, db), device: device),
        gateway,
      );
    }

    Future<int> addGame(String console, String uri) => db.insertGameWithFiles(
          GamesCompanion.insert(title: 'G', sortTitle: 'g', consoleId: console, addedAt: DateTime(2026)),
          [GameFilesCompanion.insert(gameId: 0, uri: uri, displayPath: 'x', extension: 'iso')],
        );

    test('below the estimated tier: launches but warns', () async {
      // Synthetic profile = ADVANCED tier; PS2 is estimated at HIGH.
      final (svc, gw) = await setup(syntheticNativeScan());
      gw.installed['xyz.aethersx2.android'] = '1.5';
      final id = await addGame('ps2', content);
      final o = await svc.play(id);
      expect(o.ok, isTrue, reason: o.reasons.join());
      expect(o.notes.join(), contains('below the estimated requirement'));
    });

    test('32-bit Android: GameCube via Dolphin is blocked with an explanation', () async {
      final (svc, gw) = await setup(syntheticNativeScan(abis: const ['armeabi-v7a', 'armeabi'], abis64: const []));
      gw.installed['org.dolphinemu.dolphinemu'] = '2412';
      final id = await addGame('gamecube', content);
      final o = await svc.play(id);
      expect(o.ok, isFalse);
      expect(o.reasons.single, contains('64-bit'));
      expect(gw.launchedSpecs, isEmpty);
    });

    test('PSP prefers PPSSPP over RetroArch when both are installed', () async {
      final (svc, gw) = await setup(syntheticNativeScan());
      gw.installed['org.ppsspp.ppsspp'] = '1.18';
      gw.installed['com.retroarch'] = '1.20';
      final id = await addGame('psp', content);
      final o = await svc.play(id);
      expect(o.emulatorName, 'PPSSPP');
      expect(gw.launchedSpecs.single['package'], 'org.ppsspp.ppsspp');
    });
  });
}
