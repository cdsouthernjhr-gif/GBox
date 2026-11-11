import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/hardware_profile.dart';
import '../constants/console_catalog.dart';
import '../database/app_database.dart';
import '../device/device_intelligence_service.dart';
import '../errors/app_logger.dart';
import 'platform_gateway.dart';

/// Online/offline status. GAMEBOX never requires a connection to play.
class ConnectivityService {
  ConnectivityService(this._gateway);
  final PlatformGateway _gateway;
  final ValueNotifier<ConnectivityStatus> status =
      ValueNotifier(ConnectivityStatus.offline);
  StreamSubscription<ConnectivityStatus>? _sub;

  Future<void> initialize() async {
    try {
      status.value = await _gateway.connectivity();
      _sub = _gateway.connectivityChanges().listen((s) => status.value = s,
          onError: (Object e) => AppLogger.instance.warn('Connectivity stream: $e'));
    } catch (e, s) {
      AppLogger.instance.error('Connectivity unavailable', e, s);
    }
  }

  void dispose() => _sub?.cancel();
}

/// Tracks connected input devices and notifies about (dis)connections.
class ControllerService {
  ControllerService(this._gateway, this._db, this._device);
  final PlatformGateway _gateway;
  final AppDatabase _db;
  final DeviceIntelligenceService _device;

  final ValueNotifier<List<InputDeviceInfo>> devices = ValueNotifier(const []);

  /// Human-readable connection notifications for the UI (e.g. snackbars).
  final StreamController<String> notifications = StreamController.broadcast();
  StreamSubscription<Map<String, dynamic>>? _sub;

  List<InputDeviceInfo> get controllers =>
      devices.value.where((d) => d.isGameController).toList();

  Future<void> initialize() async {
    await refresh();
    try {
      _sub = _gateway.inputDeviceEvents().listen(_onEvent,
          onError: (Object e) => AppLogger.instance.warn('Input events: $e'));
    } catch (e, s) {
      AppLogger.instance.error('Input device events unavailable', e, s);
    }
  }

  Future<void> refresh() async {
    try {
      final list = (await _gateway.listInputDevices())
          .map(InputDeviceInfo.fromMap)
          .toList();
      devices.value = list;
      _device.updateInputDevices(list);
      await _db.recordControllers(list);
    } catch (e, s) {
      AppLogger.instance.error('Listing input devices failed', e, s);
    }
  }

  Future<void> _onEvent(Map<String, dynamic> e) async {
    final id = (e['deviceId'] as num?)?.toInt();
    final before = {for (final d in devices.value) d.id: d};
    await refresh();
    final after = {for (final d in devices.value) d.id: d};
    switch (e['event']) {
      case 'added':
        final d = after[id];
        if (d != null && d.isGameController) {
          notifications.add('Controller connected: ${d.name}');
        }
      case 'removed':
        final d = before[id];
        if (d != null && d.isGameController) {
          notifications.add('Controller disconnected: ${d.name}');
        }
    }
  }

  void dispose() {
    _sub?.cancel();
    notifications.close();
  }
}

/// Storage volumes plus user-registered SAF folders.
class StorageService {
  StorageService(this._gateway, this._db, this._device);
  final PlatformGateway _gateway;
  final AppDatabase _db;
  final DeviceIntelligenceService _device;

  final ValueNotifier<List<StorageVolumeInfo>> volumes = ValueNotifier(const []);
  final StreamController<String> notifications = StreamController.broadcast();
  StreamSubscription<Map<String, dynamic>>? _sub;

  Future<void> initialize() async {
    await refresh();
    try {
      _sub = _gateway.storageEvents().listen((e) async {
        final before = {for (final v in volumes.value) v.id: v};
        await refresh();
        final action = e['action'] as String? ?? '';
        if (action.contains('MOUNTED') && !action.contains('UNMOUNTED')) {
          final added = volumes.value.where((v) => !before.containsKey(v.id) || !before[v.id]!.isMounted);
          for (final v in added) {
            notifications.add('Storage connected: ${v.description}');
          }
        } else if (action.contains('REMOVED') ||
            action.contains('EJECT') ||
            action.contains('UNMOUNTED')) {
          notifications.add('Storage disconnected');
        }
      }, onError: (Object e) => AppLogger.instance.warn('Storage events: $e'));
    } catch (e, s) {
      AppLogger.instance.error('Storage events unavailable', e, s);
    }
  }

  Future<void> refresh() async {
    try {
      final list =
          (await _gateway.storageVolumes()).map(StorageVolumeInfo.fromMap).toList();
      volumes.value = list;
      _device.updateStorageVolumes(list);
      await _db.recordStorageVolumes(list);
    } catch (e, s) {
      AppLogger.instance.error('Storage scan failed', e, s);
    }
  }

  void dispose() {
    _sub?.cancel();
    notifications.close();
  }
}

class EmulatorInstallation {
  const EmulatorInstallation(this.emulator, this.installedPackage, this.version);
  final KnownEmulator emulator;
  final String? installedPackage;
  final String? version;
  bool get isInstalled => installedPackage != null;
}

/// Detects which supported external emulator apps are installed.
class EmulatorDetectionService {
  EmulatorDetectionService(this._gateway, this._db);
  final PlatformGateway _gateway;
  final AppDatabase _db;

  final ValueNotifier<List<EmulatorInstallation>?> installations = ValueNotifier(null);

  Future<void> detect() async {
    try {
      final versions = await _gateway.installedVersions(allKnownEmulatorPackages);
      await _db.saveEmulatorDetection(versions);
      installations.value = [
        for (final e in knownEmulators)
          () {
            final pkg = e.packageIds.where(versions.containsKey).firstOrNull;
            return EmulatorInstallation(e, pkg, pkg == null ? null : versions[pkg]);
          }(),
      ];
    } catch (e, s) {
      AppLogger.instance.error('Emulator detection failed', e, s);
      installations.value ??= const [];
    }
  }
}
