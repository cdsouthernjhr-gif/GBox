import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/console_catalog.dart';
import '../../core/errors/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../compatibility/device_report_screen.dart';

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
          const _Row(title: 'Application version', value: '$appName $appVersion (Phase 2 game library)'),
          const _Row(
              title: 'Backup & restore',
              value: 'Library and save backup are part of the Save Manager (Phase 7).'),
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
        decoration: BoxDecoration(gradient: palette.background),
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
