import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/device/device_intelligence_service.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/settings_repository.dart';
import '../features/launcher/launcher_shell.dart';
import '../shared/widgets/tv_widgets.dart';
import 'app_services.dart';

/// Whether low-memory mode is in effect for this device and setting.
bool isLowMemoryActive(SettingsState s, DeviceState d) => switch (s.lowMemoryMode) {
      LowMemoryMode.on => true,
      LowMemoryMode.off => false,
      LowMemoryMode.auto => (d.profile?.isLowRamDevice ?? false) ||
          ((d.profile?.totalRamBytes ?? 0) > 0 &&
              d.profile!.totalRamBytes! < 2.5 * 1024 * 1024 * 1024),
    };

class GameboxApp extends StatelessWidget {
  const GameboxApp({super.key, required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ValueListenableBuilder<SettingsState>(
        valueListenable: services.settings.state,
        builder: (context, settings, _) => ValueListenableBuilder<DeviceState>(
          valueListenable: services.device.state,
          builder: (context, device, _) {
            final lowMem = isLowMemoryActive(settings, device);
            final cacheMb = lowMem ? 24 : settings.imageCacheMb;
            PaintingBinding.instance.imageCache.maximumSizeBytes = cacheMb * 1024 * 1024;
            return MotionSettings(
              animate: settings.animations && !lowMem,
              sounds: settings.sounds,
              child: MaterialApp(
                title: 'GAMEBOX',
                debugShowCheckedModeBanner: false,
                theme: buildTheme(settings.theme, wallpaperPreset: settings.wallpaperPreset),
                themeAnimationDuration: Duration.zero,
                shortcuts: {
                  ...WidgetsApp.defaultShortcuts,
                  // Remote "OK" variants and gamepad A activate; B is left to
                  // Android, which falls back to BACK.
                  const SingleActivator(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
                  const SingleActivator(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
                },
                home: const LauncherShell(),
              ),
            );
          },
        ),
      ),
    );
  }
}
