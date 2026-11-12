import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/console_catalog.dart';
import '../../core/errors/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../compatibility/device_report_screen.dart';
import '../performance/performance_screen.dart';
import 'settings_actions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool? _isDefaultLauncher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLauncher();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check after the user returns from Android's Home settings.
    if (state == AppLifecycleState.resumed) _checkLauncher();
  }

  Future<void> _checkLauncher() async {
    try {
      final v = await servicesOf(context).gateway.isDefaultLauncher();
      if (mounted) setState(() => _isDefaultLauncher = v);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Settings',
      child: ValueListenableBuilder<SettingsState>(
        valueListenable: s.settings.state,
        builder: (context, st, _) => ListView(children: [
          const SectionHeader('Launcher'),
          _Row(
            title: 'Default HOME app',
            value: switch (_isDefaultLauncher) {
              null => 'Checking…',
              true => 'GAMEBOX is the default launcher',
              false => 'GAMEBOX is not the default launcher',
            },
            onSelect: () async {
              final how = await s.gateway.requestDefaultLauncher();
              if (!context.mounted) return;
              if (how == 'unavailable') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('This firmware does not expose a Home app setting.')));
              }
            },
            action: _isDefaultLauncher == true ? 'Change' : 'Set as default',
          ),
          _Row(
            title: 'Android Settings',
            value: 'Open the system settings (Wi-Fi, Bluetooth pairing, display, default apps)',
            onSelect: () => s.gateway.openAndroidSettings(),
            action: 'Open',
          ),
          const SizedBox(height: 12),
          const SectionHeader('General'),
          _Choice<AppThemeId>(
            title: 'Theme',
            value: st.theme,
            values: AppThemeId.values,
            label: (v) => v.label,
            onChanged: (v) => s.settings.set(SettingsKeys.theme, v.name),
          ),
          if (st.theme == AppThemeId.wallpaper)
            _Choice<int>(
              title: 'Wallpaper',
              value: st.wallpaperPreset,
              values: List.generate(wallpaperPresets.length, (i) => i),
              label: (i) => wallpaperPresets[i].$1,
              onChanged: (v) => s.settings.set(SettingsKeys.wallpaperPreset, v),
            ),
          if (st.theme == AppThemeId.wallpaper)
            _Row(
              title: 'Wallpaper image',
              value: st.wallpaperImagePath == null ? 'None (gradient preset is used)' : 'Custom image set',
              action: st.wallpaperImagePath == null ? 'Choose…' : 'Remove',
              onSelect: () => st.wallpaperImagePath == null
                  ? chooseWallpaperAction(context)
                  : s.settings.set(SettingsKeys.wallpaperImage, ''),
            ),
          _Choice<int?>(
            title: 'Accent colour',
            value: st.accentColor,
            values: accentChoices,
            label: (v) => v == null ? 'Theme default' : '#${(v & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            onChanged: (v) => s.settings.set(SettingsKeys.accentColor, v ?? ''),
          ),
          _Toggle(
            title: 'Animations',
            subtitle: 'Focus zoom and transitions (off automatically in low-memory mode)',
            value: st.animations,
            onChanged: (v) => s.settings.set(SettingsKeys.animations, v),
          ),
          _Toggle(
            title: 'Interface sounds',
            subtitle: 'Android system click sound when selecting',
            value: st.sounds,
            onChanged: (v) => s.settings.set(SettingsKeys.sounds, v),
          ),
          const _Row(title: 'Language', value: 'English (the only language available in this version)'),
          _Toggle(
            title: 'Rescan hardware on startup',
            subtitle: 'Otherwise the saved profile is used until you rescan',
            value: st.rescanOnStartup,
            onChanged: (v) => s.settings.set(SettingsKeys.rescanOnStartup, v),
          ),
          const SizedBox(height: 12),
          const SectionHeader('Gaming'),
          _Choice<GameSort>(
            title: 'Game sorting',
            value: st.gameSort,
            values: GameSort.values,
            label: (v) => switch (v) {
              GameSort.title => 'Title',
              GameSort.recentlyPlayed => 'Recently played',
              GameSort.recentlyAdded => 'Recently added',
            },
            onChanged: (v) => s.settings.set(SettingsKeys.gameSort, v.name),
          ),
          _Toggle(
            title: 'Auto scan',
            subtitle: 'Scan game folders at startup and when USB/SD storage is connected',
            value: st.autoScan,
            onChanged: (v) => s.settings.set(SettingsKeys.autoScan, v),
          ),
          _Choice<String>(
            title: 'Default console',
            value: st.defaultConsoleId ?? 'none',
            values: ['none', ...consoleCatalog.map((c) => c.id)],
            label: (v) => v == 'none' ? 'None' : consoleById(v)!.name,
            onChanged: (v) => s.settings.set(SettingsKeys.defaultConsole, v == 'none' ? '' : v),
          ),
          const SizedBox(height: 12),
          const SectionHeader('Controllers'),
          _Toggle(
            title: 'Navigate with analog stick / hat',
            subtitle: 'Uses each controller\'s dead zone, so a drifting stick does not move the focus',
            value: st.stickNavigation,
            onChanged: (v) => s.settings.set(SettingsKeys.stickNavigation, v),
          ),
          _Row(
            title: 'Controllers',
            value: 'Mapping, calibration, dead zone, vibration and player slots are under CONTROLLERS',
          ),
          const SizedBox(height: 12),
          const SectionHeader('Downloads'),
          _Toggle(
            title: 'Pause downloads while playing',
            subtitle: 'Frees bandwidth and storage I/O for the emulator; resumes when you return',
            value: st.pauseDownloadsWhilePlaying,
            onChanged: (v) => s.settings.set(SettingsKeys.pauseDownloadsWhilePlaying, v),
          ),
          _Toggle(
            title: 'Import finished downloads automatically',
            subtitle: 'When the console is known (catalogue entries or chosen when adding)',
            value: st.autoImportDownloads,
            onChanged: (v) => s.settings.set(SettingsKeys.autoImportDownloads, v),
          ),
          _Toggle(
            title: 'Allow http:// downloads',
            subtitle: 'Also accept unencrypted http:// sources and links. The connection is not private and '
                'the file can be altered on the way; prefer https:// or a SHA-256 checksum',
            value: st.allowHttpDownloads,
            onChanged: (v) => s.settings.set(SettingsKeys.allowHttpDownloads, v),
          ),
          _Choice<int>(
            title: 'Largest allowed download',
            value: st.downloadMaxGb,
            values: const [1, 2, 4, 8, 16, 32, 64, 0],
            label: (v) => v == 0 ? 'No limit (free space is still checked)' : '$v GB',
            onChanged: (v) => s.settings.set(SettingsKeys.downloadMaxGb, v),
          ),
          const SizedBox(height: 12),
          const SectionHeader('Performance'),
          _Choice<LowMemoryMode>(
            title: 'Low memory mode',
            value: st.lowMemoryMode,
            values: LowMemoryMode.values,
            label: (v) => switch (v) {
              LowMemoryMode.auto => 'Automatic (on for devices under 2.5 GB RAM)',
              LowMemoryMode.on => 'On',
              LowMemoryMode.off => 'Off',
            },
            onChanged: (v) => s.settings.set(SettingsKeys.lowMemoryMode, v.name),
          ),
          _Choice<int>(
            title: 'Image cache size',
            value: st.imageCacheMb,
            values: const [24, 48, 96, 160],
            label: (v) => '$v MB',
            onChanged: (v) => s.settings.set(SettingsKeys.imageCacheMb, v),
          ),
          const SizedBox(height: 12),
          const SectionHeader('System'),
          _Row(
            title: 'Device information & compatibility report',
            value: 'Hardware profile, performance category and console estimates',
            onSelect: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const DeviceReportScreen())),
            action: 'Open',
          ),
          _Row(
            title: 'Logs',
            value: AppLogger.instance.logPath ?? 'In-memory only',
            onSelect: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const LogsScreen())),
            action: 'View',
          ),
          const _Row(title: 'Application version', value: '$appName $appVersion (Phase 8 release preparation)'),
          _Row(
            title: 'Performance & benchmarks',
            value: 'Live RAM, CPU clocks, temperatures; CPU, memory, storage and rendering benchmarks',
            onSelect: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PerformanceScreen())),
            action: 'Open',
          ),
          _Row(
            title: 'Back up library',
            value: 'Copies the GAMEBOX database (library, settings, history, profiles) to GAMEBOX/Backups/library',
            action: 'Back up',
            onSelect: () => backupLibraryAction(context),
          ),
          _Row(
            title: 'Restore library…',
            value: 'Choose a library backup; it is applied the next time GAMEBOX starts',
            action: 'Choose',
            onSelect: () => restoreLibraryAction(context),
          ),
          const _Row(
              title: 'Save games',
              value: 'Back up / restore emulator saves: STORAGE → Save folders, or on each game page.'),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.value, this.onSelect, this.action});
  final String title;
  final String value;
  final VoidCallback? onSelect;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TvFocusable(
        scale: 1.01,
        onSelect: onSelect,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium),
              Text(value, style: t.bodySmall?.copyWith(color: Colors.white60)),
            ]),
          ),
          if (action != null)
            Text(action!, style: t.labelLarge?.copyWith(color: GameboxPalette.of(context).focus)),
        ]),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.title, required this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TvFocusable(
        scale: 1.01,
        onSelect: () => onChanged(!value),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium),
              Text(subtitle, style: t.bodySmall?.copyWith(color: Colors.white60)),
            ]),
          ),
          ExcludeFocus(child: Switch(value: value, onChanged: onChanged)),
        ]),
      ),
    );
  }
}

/// Cycles through values on select (left/right-free, remote friendly).
class _Choice<T> extends StatelessWidget {
  const _Choice({required this.title, required this.value, required this.values, required this.label, required this.onChanged});
  final String title;
  final T value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final i = values.indexOf(value);
    return _Row(
      title: title,
      value: label(i < 0 ? values.first : value),
      action: 'Change ›',
      onSelect: () => onChanged(values[(i + 1) % values.length]),
    );
  }
}

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final lines = AppLogger.instance.recent.reversed.toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: palette.decoration,
        child: SafeArea(
          child: PageFrame(
            title: 'Logs',
            subtitle: AppLogger.instance.logPath ?? 'In-memory log',
            actions: [TvButton(label: 'Back', autofocus: true, onPressed: () => Navigator.pop(context))],
            child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (_, i) => Text(lines[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white70)),
            ),
          ),
        ),
      ),
    );
  }
}
