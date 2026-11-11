import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamebox/core/controllers/controller_profile.dart';
import 'package:gamebox/core/controllers/retroarch_autoconfig.dart';
import 'package:gamebox/core/database/app_database.dart';
import 'package:gamebox/data/repositories/controller_profile_repository.dart';
import 'package:gamebox/data/repositories/settings_repository.dart';
import 'package:gamebox/domain/entities/hardware_profile.dart';
import 'package:gamebox/features/controller_manager/controller_config_service.dart';

import 'support/fakes.dart';

void main() {
  group('profile logic', () {
    test('key remap: swapped A/B, identities omitted', () {
      const p = ControllerProfile(name: 'p', bindings: {
        PadAction.a: Binding.key(AndroidKey.buttonB),
        PadAction.b: Binding.key(AndroidKey.buttonA),
        PadAction.start: Binding.key(AndroidKey.buttonStart),
        PadAction.l2: Binding.axis(AndroidAxis.lTrigger, 1),
      });
      expect(p.keyRemap(), {AndroidKey.buttonB: AndroidKey.buttonA, AndroidKey.buttonA: AndroidKey.buttonB});
    });

    test('conflicts are reported and the first action keeps the key', () {
      const p = ControllerProfile(name: 'p', bindings: {
        PadAction.x: Binding.key(200),
        PadAction.y: Binding.key(200),
      });
      expect(p.conflicts().single, (PadAction.x, PadAction.y));
      expect(p.keyRemap(), {200: AndroidKey.buttonX});
    });

    test('calibration: off-centre stick, dead zone and rescaling', () {
      const c = AxisCalibration(center: 0.1, min: -0.9, max: 0.9);
      expect(c.apply(0.1, 0.2), 0);
      expect(c.apply(0.2, 0.2), 0, reason: 'inside dead zone');
      expect(c.apply(0.9, 0.2), closeTo(1.0, 1e-9));
      expect(c.apply(-0.9, 0.2), closeTo(-1.0, 1e-9));
      expect(c.apply(0.5, 0.2), closeTo(0.375, 1e-9), reason: '(0.5-0.2)/0.8');
    });

    test('suggested dead zone from resting noise', () {
      final dz = suggestDeadZone({'X': (-0.06, 0.04)}, {'X': (-1.0, 1.0)});
      expect(dz, closeTo(0.15, 1e-9));
      expect(suggestDeadZone(const {}, const {}), 0.05);
      expect(suggestDeadZone({'X': (-0.9, 0.9)}, {'X': (-1.0, 1.0)}), 0.5, reason: 'clamped');
    });

    test('bindings and calibration serialise', () {
      expect(Binding.fromJson(const Binding.axis(15, -1).toJson()), const Binding.axis(15, -1));
      expect(Binding.fromJson(const Binding.key(96).toJson()), const Binding.key(96));
      const p = ControllerProfile(name: 'p', calibration: {'X': AxisCalibration(center: 0.01, min: -1, max: 0.98)});
      final back = ControllerProfile.parseCalibration(p.calibrationJson());
      expect(back['X']!.max, 0.98);
      expect(ControllerProfile.parseCalibration('not json'), isEmpty);
    });

    test('player slot cycle', () {
      expect([null, 1, 2, 3, 4].map(nextPlayer).toList(), [1, 2, 3, 4, null]);
    });
  });

  group('RetroArch autoconfig export', () {
    test('uses RetroPad naming and Android key codes', () {
      final text = retroArchAutoconfig(
        deviceName: 'Pad "Pro"\nX',
        vendorId: 1118,
        productId: 654,
        profile: const ControllerProfile(name: 'p', bindings: {
          PadAction.a: Binding.key(AndroidKey.buttonB),
          PadAction.l2: Binding.axis(AndroidAxis.lTrigger, 1),
        }),
      );
      expect(text, contains('input_driver = "android"'));
      expect(text, contains('input_device = "Pad \'Pro\' X"'), reason: 'quotes/newlines sanitised');
      expect(text, contains('input_vendor_id = "1118"'));
      // Bottom face button (Android A) is RetroPad "b".
      expect(text, contains('input_b_btn = "97"'));
      expect(text, contains('input_a_btn = "97"'), reason: 'unmapped B keeps its standard code');
      expect(text, contains('input_start_btn = "108"'));
      expect(text, isNot(contains('input_l2_btn')));
      expect(text, contains('L2: bound to an axis'));
    });

    test('file names are safe', () {
      expect(autoconfigFileName('8BitDo SN30 Pro+ / v2'), '8BitDo_SN30_Pro_v2.cfg');
      expect(autoconfigFileName('***'), 'controller.cfg');
    });
  });

  group('persistence and native config', () {
    late AppDatabase db;
    late FakeGateway gateway;
    late SettingsRepository settings;
    late ControllerProfileRepository repo;
    late ControllerConfigService service;
    late Directory temp;

    final pad = InputDeviceInfo.fromMap(
        (syntheticNativeScan()['inputDevices'] as List).first as Map<String, dynamic>);

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      gateway = FakeGateway();
      settings = SettingsRepository(db);
      await settings.initialize();
      repo = ControllerProfileRepository(db);
      temp = await Directory.systemTemp.createTemp('gamebox_ctl');
      service = ControllerConfigService(
          gateway: gateway, repo: repo, settings: settings, exportDir: () async => temp.path);
      await db.recordControllers([pad]);
      await service.initialize();
    });

    tearDown(() async {
      service.dispose();
      settings.dispose();
      await db.close();
      await temp.delete(recursive: true);
    });

    test('profile round-trip with bindings and calibration', () async {
      await repo.save(ControllerProfile(
        name: 'Pad',
        descriptor: pad.descriptor,
        deadZone: 0.3,
        bindings: const {PadAction.a: Binding.key(97), PadAction.dpadUp: Binding.axis(16, -1)},
        calibration: const {'X': AxisCalibration(center: 0.02, min: -0.95, max: 1)},
      ));
      final p = (await repo.load(pad.descriptor))!;
      expect(p.deadZone, 0.3);
      expect(p.bindings[PadAction.a], const Binding.key(97));
      expect(p.bindings[PadAction.dpadUp], const Binding.axis(16, -1));
      expect(p.calibration['X']!.center, 0.02);

      // Saving again replaces, not duplicates.
      await repo.save(p.copyWith(bindings: const {PadAction.b: Binding.key(96)}));
      final again = (await repo.load(pad.descriptor))!;
      expect(again.bindings.keys, [PadAction.b]);
      expect(await db.select(db.controllerProfiles).get(), hasLength(1));
    });

    test('per-console profile overrides the universal one', () async {
      await repo.save(ControllerProfile(name: 'u', descriptor: pad.descriptor, deadZone: 0.2));
      await repo.save(ControllerProfile(name: 's', descriptor: pad.descriptor, consoleId: 'snes', deadZone: 0.4));
      expect((await repo.effective(pad.descriptor, consoleId: 'snes'))!.deadZone, 0.4);
      expect((await repo.effective(pad.descriptor, consoleId: 'nes'))!.deadZone, 0.2);
    });

    test('saving pushes remaps and dead zones to the native layer', () async {
      await service.save(service.profileFor(pad).copyWith(
          deadZone: 0.25, bindings: const {PadAction.a: Binding.key(97), PadAction.b: Binding.key(96)}));
      final cfg = gateway.lastInputConfig!;
      expect((cfg['remaps'] as Map)[pad.descriptor], {97: 96, 96: 97});
      expect((cfg['deadZones'] as Map)[pad.descriptor], 0.25);
      expect(cfg['stickNavigation'], isTrue);

      await settings.set(SettingsKeys.stickNavigation, false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(gateway.lastInputConfig!['stickNavigation'], isFalse);

      await service.reset(pad.descriptor);
      expect((gateway.lastInputConfig!['remaps'] as Map), isEmpty);
    });

    test('a player slot belongs to one controller', () async {
      await db.recordControllers([
        InputDeviceInfo.fromMap({...pad.toMap(), 'id': 6, 'descriptor': 'other', 'name': 'Second'}),
      ]);
      await service.setPlayer(pad.descriptor, 1);
      await service.setPlayer('other', 1);
      expect(service.players.value[pad.descriptor], isNull);
      expect(service.players.value['other'], 1);
    });

    test('vibration test respects capability and setting; export writes a file', () async {
      expect(await service.testVibration(pad), isFalse, reason: 'synthetic pad has no vibrator');
      final rumble = InputDeviceInfo.fromMap({...pad.toMap(), 'hasVibrator': true});
      expect(await service.testVibration(rumble), isTrue);
      await service.save(service.profileFor(rumble).copyWith(vibration: false));
      expect(await service.testVibration(rumble), isFalse);
      expect(gateway.vibrations, [pad.id]);

      final path = await service.exportRetroArch(pad);
      expect(File(path!).readAsStringSync(), contains('input_device = "Test Gamepad"'));
    });
  });
}
