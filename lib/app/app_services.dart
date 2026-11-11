import 'package:flutter/widgets.dart';

import '../core/database/app_database.dart';
import '../core/device/device_intelligence_service.dart';
import '../core/services/platform_gateway.dart';
import '../core/services/system_services.dart';
import '../data/repositories/settings_repository.dart';

/// Dependency container. Built once at startup and exposed to widgets via
/// [AppScope]. Tests construct it with a fake [PlatformGateway] and an
/// in-memory database.
class AppServices {
  AppServices({required this.gateway, required this.db})
      : settings = SettingsRepository(db),
        device = DeviceIntelligenceService(gateway, db) {
    connectivity = ConnectivityService(gateway);
    controllers = ControllerService(gateway, db, device);
    storage = StorageService(gateway, db, device);
    emulators = EmulatorDetectionService(gateway, db);
  }

  final PlatformGateway gateway;
  final AppDatabase db;
  final SettingsRepository settings;
  final DeviceIntelligenceService device;
  late final ConnectivityService connectivity;
  late final ControllerService controllers;
  late final StorageService storage;
  late final EmulatorDetectionService emulators;

  /// Settings load first (theme), then the cached hardware profile; slower
  /// scans continue in the background so the launcher appears quickly.
  Future<void> initialize() async {
    await settings.initialize();
    await device.initialize(rescan: false);
    // Background work; failures are logged and never block the UI.
    () async {
      await Future.wait([
        connectivity.initialize(),
        controllers.initialize(),
        storage.initialize(),
        emulators.detect(),
      ]);
      if (settings.state.value.rescanOnStartup || device.state.value.profile == null) {
        await device.scan();
      }
    }();
  }

  void dispose() {
    settings.dispose();
    connectivity.dispose();
    controllers.dispose();
    storage.dispose();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});
  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
