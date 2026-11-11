import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../core/database/app_database.dart';
import '../core/device/device_intelligence_service.dart';
import '../core/services/platform_gateway.dart';
import '../core/services/system_services.dart';
import '../data/repositories/settings_repository.dart';
import '../features/rom_manager/rom_library_service.dart';

/// Dependency container. Built once at startup and exposed to widgets via
/// [AppScope]. Tests construct it with a fake [PlatformGateway] and an
/// in-memory database.
class AppServices {
  AppServices({
    required this.gateway,
    required this.db,
    Future<List<String>> Function()? appRoots,
    Future<String> Function()? artworkDir,
  })  : settings = SettingsRepository(db),
        device = DeviceIntelligenceService(gateway, db) {
    connectivity = ConnectivityService(gateway);
    controllers = ControllerService(gateway, db, device);
    storage = StorageService(gateway, db, device);
    emulators = EmulatorDetectionService(gateway, db);
    library = RomLibraryService(
      gateway: gateway,
      db: db,
      settings: settings,
      appRoots: appRoots ?? _defaultAppRoots,
      artworkDir: artworkDir ?? _defaultArtworkDir,
    );
  }

  /// App-specific external directories on every mounted volume (internal,
  /// SD, USB). Readable and writable without any storage permission.
  static Future<List<String>> _defaultAppRoots() async =>
      [for (final d in await getExternalStorageDirectories() ?? <Directory>[]) d.path];

  static Future<String> _defaultArtworkDir() async {
    final dir = Directory('${(await getApplicationSupportDirectory()).path}/artwork');
    await dir.create(recursive: true);
    return dir.path;
  }

  final PlatformGateway gateway;
  final AppDatabase db;
  final SettingsRepository settings;
  final DeviceIntelligenceService device;
  late final ConnectivityService connectivity;
  late final ControllerService controllers;
  late final StorageService storage;
  late final EmulatorDetectionService emulators;
  late final RomLibraryService library;
  Timer? _autoScanDebounce;

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
      if (settings.state.value.autoScan) await library.scanAll();
      // Storage connected/removed: recheck files and rescan (debounced).
      storage.volumes.addListener(_onVolumesChanged);
    }();
  }

  void _onVolumesChanged() {
    if (!settings.state.value.autoScan) return;
    _autoScanDebounce?.cancel();
    _autoScanDebounce = Timer(const Duration(seconds: 3), () async {
      await library.refreshMissing();
      await library.scanAll();
    });
  }

  void dispose() {
    _autoScanDebounce?.cancel();
    storage.volumes.removeListener(_onVolumesChanged);
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
