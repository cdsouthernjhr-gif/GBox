import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/controllers/controller_profile.dart';
import '../../core/controllers/retroarch_autoconfig.dart';
import '../../core/errors/app_logger.dart';
import '../../core/services/platform_gateway.dart';
import '../../data/repositories/controller_profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/hardware_profile.dart';

/// Controller Manager (Phase 4): profiles, mapping, calibration, dead zone,
/// vibration, player slots. Mappings apply to GAMEBOX itself (native key
/// remapping and stick navigation); external emulators keep their own input
/// settings, so a RetroArch autoconfig file can be exported for import.
class ControllerConfigService {
  ControllerConfigService({
    required this._gateway,
    required this._repo,
    required this._settings,
    required this._exportDir,
  });

  final PlatformGateway _gateway;
  final ControllerProfileRepository _repo;
  final SettingsRepository _settings;
  final Future<String?> Function() _exportDir;

  /// Universal profile per controller descriptor.
  final ValueNotifier<Map<String, ControllerProfile>> profiles = ValueNotifier(const {});
  final ValueNotifier<Map<String, int?>> players = ValueNotifier(const {});

  ControllerProfileRepository get repository => _repo;

  Future<void> initialize() async {
    await reload();
    _settings.state.addListener(_push);
  }

  Future<void> reload() async {
    final all = await _repo.all();
    profiles.value = {
      for (final p in all)
        if (p.descriptor != null && p.consoleId == null) p.descriptor!: p,
    };
    players.value = await _repo.assignedPlayers();
    await _push();
  }

  Future<void> _push() async {
    try {
      await _gateway.setInputConfig(
        remaps: {
          for (final e in profiles.value.entries)
            if (e.value.keyRemap().isNotEmpty) e.key: e.value.keyRemap(),
        },
        deadZones: {for (final e in profiles.value.entries) e.key: e.value.deadZone},
        stickNavigation: _settings.state.value.stickNavigation,
      );
    } catch (e, s) {
      AppLogger.instance.error('Pushing controller config failed', e, s);
    }
  }

  /// The stored universal profile for [device], or a fresh default.
  ControllerProfile profileFor(InputDeviceInfo device) =>
      profiles.value[device.descriptor] ?? ControllerProfile(name: device.name, descriptor: device.descriptor);

  Future<ControllerProfile> save(ControllerProfile p) async {
    final saved = await _repo.save(p);
    await reload();
    return saved;
  }

  /// Removes the controller's mapping and calibration (back to defaults).
  Future<void> reset(String descriptor) async {
    await _repo.delete(descriptor);
    await reload();
  }

  Future<void> setPlayer(String descriptor, int? player) async {
    // A slot belongs to one controller at a time.
    if (player != null) {
      for (final e in players.value.entries) {
        if (e.value == player && e.key != descriptor) await _repo.setAssignedPlayer(e.key, null);
      }
    }
    await _repo.setAssignedPlayer(descriptor, player);
    players.value = await _repo.assignedPlayers();
  }

  Future<bool> testVibration(InputDeviceInfo device) async {
    if (!device.hasVibrator) return false;
    if (!profileFor(device).vibration) return false;
    return _gateway.vibrate(device.id);
  }

  /// Writes a RetroArch autoconfig file and returns its path.
  Future<String?> exportRetroArch(InputDeviceInfo device) async {
    final dir = await _exportDir();
    if (dir == null) return null;
    final text = retroArchAutoconfig(
      deviceName: device.name,
      vendorId: device.vendorId,
      productId: device.productId,
      profile: profileFor(device),
    );
    final file = File('$dir/${autoconfigFileName(device.name)}');
    await file.parent.create(recursive: true);
    await file.writeAsString(text);
    return file.path;
  }

  void dispose() => _settings.state.removeListener(_push);
}
