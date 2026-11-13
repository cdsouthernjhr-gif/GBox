import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../core/database/app_database.dart';
import '../core/errors/app_logger.dart';
import '../core/device/device_intelligence_service.dart';
import '../core/services/platform_gateway.dart';
import '../core/services/system_services.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/controller_profile_repository.dart';
import '../features/storage_manager/library_location_service.dart';
import '../features/controller_manager/controller_config_service.dart';
import '../core/online/download_engine.dart';
import '../features/download_manager/download_service.dart';
import '../features/compatibility/compatibility_service.dart';
import '../features/emulator_manager/launch_service.dart';
import '../features/performance/benchmark_service.dart';
import '../features/save_manager/save_service.dart';
import '../features/source_manager/source_service.dart';
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
    DownloadEngine? downloadEngine,
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
    controllerConfig = ControllerConfigService(
      gateway: gateway,
      repo: ControllerProfileRepository(db),
      settings: settings,
      exportDir: () async {
        final roots = await (appRoots ?? _defaultAppRoots)();
        return roots.isEmpty ? null : '${roots.first}/GAMEBOX/Controllers';
      },
    );
    launcher = LaunchService(
      gateway: gateway,
      db: db,
      emulators: emulators,
      device: device,
      beforeLaunch: () {
        PaintingBinding.instance.imageCache.clear();
        downloads.pauseForGameplay();
      },
    );
    final engine = downloadEngine ?? DownloadEngine(freeSpace: gateway.freeSpace);
    void applyHttpSetting() => engine.userAllowsHttp = settings.state.value.allowHttpDownloads;
    settings.state.addListener(applyHttpSetting);
    applyHttpSetting();
    sources = SourceService(db, engine);
    Future<String> gameboxRoot() async {
      final roots = await (appRoots ?? _defaultAppRoots)();
      if (roots.isEmpty) throw StateError('No storage available');
      return '${roots.first}/GAMEBOX';
    }

    this.gameboxRoot = gameboxRoot;
    saves = SaveService(gateway: gateway, db: db, settings: settings, gameboxRoot: gameboxRoot);
    compatibility = CompatibilityService(db, device);
    benchmarks = BenchmarkService(db, device);
    location = LibraryLocationService(
      gateway: gateway,
      settings: settings,
      appRoot: gameboxRoot,
      saves: saves,
      installedEmulators: () => [
        for (final i in emulators.installations.value ?? const <EmulatorInstallation>[])
          if (i.isInstalled) i.emulator.id,
      ],
    );
    downloads = DownloadService(
      db: db,
      engine: engine,
      library: library,
      settings: settings,
      connectivity: connectivity.status,
      downloadsDir: () async {
        final roots = await (appRoots ?? _defaultAppRoots)();
        if (roots.isEmpty) throw StateError('No storage available for downloads');
        return '${roots.first}/GAMEBOX/Downloads';
      },
      location: location,
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
  late final LaunchService launcher;
  late final ControllerConfigService controllerConfig;
  late final SourceService sources;
  late final DownloadService downloads;
  late final SaveService saves;
  late final CompatibilityService compatibility;
  late final BenchmarkService benchmarks;

  /// Where the GAMEBOX folder lives (app folder or the user's public folder).
  late final LibraryLocationService location;

  /// `<primary app folder>/GAMEBOX`.
  late final Future<String> Function() gameboxRoot;
  AppLifecycleListener? _lifecycle;
  Timer? _autoScanDebounce;

  /// Settings load first (theme), then the cached hardware profile; slower
  /// scans continue in the background so the launcher appears quickly.
  Future<void> initialize() async {
    // Returning from an emulator ends the play session.
    _lifecycle = AppLifecycleListener(onResume: () {
      launcher.onReturned();
      downloads.resumeAfterGameplay();
    });
    await settings.initialize();
    await device.initialize(rescan: false);
    await controllerConfig.initialize();
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
      // Recreate any missing folders of the layout (e.g. deleted by the user,
      // or new folders added by an update), and register save folders of
      // newly installed emulators when a public folder is used.
      try {
        await location.ensureStructure();
        if (location.isPublic) await location.registerSaveFolders();
      } catch (e, st) {
        AppLogger.instance.error('Preparing the GAMEBOX folders failed', e, st);
      }
      await downloads.initialize();
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
    _lifecycle?.dispose();
    storage.volumes.removeListener(_onVolumesChanged);
    controllerConfig.dispose();
    downloads.dispose();
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
