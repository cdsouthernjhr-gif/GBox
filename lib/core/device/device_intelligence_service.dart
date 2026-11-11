import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/hardware_profile.dart';
import '../database/app_database.dart';
import '../errors/app_logger.dart';
import '../services/platform_gateway.dart';
import 'cpuinfo_parser.dart';
import 'performance_classifier.dart';

class DeviceState {
  const DeviceState({this.profile, this.classification, this.scanning = false, this.error});
  final HardwareProfile? profile;
  final DeviceClassification? classification;
  final bool scanning;
  final String? error;
}

/// Device Intelligence Engine: scans hardware through the native layer,
/// classifies it and stores the profile locally (works fully offline).
class DeviceIntelligenceService {
  DeviceIntelligenceService(this._gateway, this._db, {PerformanceClassifier? classifier})
      : _classifier = classifier ?? const PerformanceClassifier();

  final PlatformGateway _gateway;
  final AppDatabase _db;
  final PerformanceClassifier _classifier;

  final ValueNotifier<DeviceState> state = ValueNotifier(const DeviceState());

  PerformanceClassifier get classifier => _classifier;

  /// Loads the last saved profile so the UI is ready instantly. When
  /// [rescan] is true a fresh scan follows; otherwise the caller decides.
  Future<void> initialize({bool rescan = true}) async {
    try {
      final cached = await _db.latestHardwareProfile();
      if (cached != null) {
        state.value = DeviceState(
          profile: cached,
          classification: _classifier.classify(cached),
        );
      }
    } catch (e, s) {
      AppLogger.instance.error('Loading cached hardware profile failed', e, s);
    }
    if (rescan) await scan();
  }

  Future<HardwareProfile?> scan() async {
    final previous = state.value;
    state.value = DeviceState(
      profile: previous.profile,
      classification: previous.classification,
      scanning: true,
    );
    try {
      final raw = await _gateway.scanHardware();
      final profile = profileFromNative(raw);
      final classification = _classifier.classify(profile);
      await _db.saveHardwareProfile(profile, classification);
      await _db.recordStorageVolumes(profile.storageVolumes);
      await _db.recordControllers(profile.inputDevices);
      state.value = DeviceState(profile: profile, classification: classification);
      AppLogger.instance.info('Hardware scan complete: '
          '${profile.manufacturer} ${profile.model}, tier ${classification.tier.name}');
      return profile;
    } catch (e, s) {
      AppLogger.instance.error('Hardware scan failed', e, s);
      state.value = DeviceState(
        profile: previous.profile,
        classification: previous.classification,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Updates only the input/storage parts of the profile (cheap, no rescan).
  void updateInputDevices(List<InputDeviceInfo> devices) {
    final s = state.value;
    if (s.profile == null) return;
    state.value = DeviceState(
      profile: s.profile!.copyWith(inputDevices: devices),
      classification: s.classification,
      scanning: s.scanning,
    );
  }

  void updateStorageVolumes(List<StorageVolumeInfo> volumes) {
    final s = state.value;
    if (s.profile == null) return;
    state.value = DeviceState(
      profile: s.profile!.copyWith(storageVolumes: volumes),
      classification: s.classification,
      scanning: s.scanning,
    );
  }

  /// Merges the native scan map with the parsed `/proc/cpuinfo`.
  static HardwareProfile profileFromNative(Map<String, dynamic> raw,
      {DateTime? now}) {
    final cpu = parseCpuInfo(raw['cpuInfoRaw'] as String?);
    final socFromCpuInfo = cpu.hardware;
    final cpuModel = [
      if (cpu.coreDescription != null) cpu.coreDescription,
      if (cpu.coreDescription == null && cpu.modelName != null) cpu.modelName,
    ].join();
    return HardwareProfile.fromMap({
      ...raw,
      'scannedAt': (now ?? DateTime.now()).toIso8601String(),
      'socModel': raw['socModel'] ?? socFromCpuInfo,
      'cpuModel': cpuModel.isEmpty ? null : cpuModel,
      'cpuCores': raw['cpuCores'] ?? cpu.processorCount,
      'cpuParts': cpu.parts,
      'cpuImplementer': cpu.implementer,
      'cpuFeatures': cpu.features,
    });
  }
}
