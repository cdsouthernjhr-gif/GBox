import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/console_catalog.dart';
import '../../core/errors/app_logger.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../integrations/builtin/builtin_player_launcher.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../compatibility/device_report_screen.dart';
import '../controller_manager/controllers_screen.dart';
import '../storage_manager/storage_screen.dart';
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
          const SizedBox(height: 12),
          const SectionHeader('Devices and storage'),
          _Row(
            title: 'Controllers',
            value: 'Connected controllers, button mapping, calibration, dead zone, vibration, input test',
            action: 'Open ›',
            onSelect: () => SubPage.open(context, const ControllersScreen()),
          ),
          _Row(
            title: 'Storage and game folders',
            value: 'Internal storage, USB drives and SD cards, game folders, GAMEBOX folders, BIOS, saves',
            action: 'Open ›',
            onSelect: () => SubPage.open(context, const StorageScreen()),
          ),
          const SizedBox(height: 12),
          const SectionHeader('General'),
            _Choice<RowOrder>(
              title: 'Systems on HOME',
              value: st.rowOrder,
              values: RowOrder.values,
              label: (v) => switch (v) {
                RowOrder.mostGames => 'Most games first',
                RowOrder.recentlyPlayed => 'Recently played first',
                RowOrder.alphabetical => 'Alphabetical',
              },
              onChanged: (v) => s.settings.set(SettingsKeys.rowOrder, v.name),
            ),
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
            value: 'Mapping, calibration, dead zone, vibration and player slots are under SETTINGS → Controllers',
          ),
          const SizedBox(height: 12),
          const SectionHeader('Built-in player'),
          _Choice<PlayerTouch>(
            title: 'On-screen controls',
            value: st.playerTouch,
            values: PlayerTouch.values,
            label: (v) => switch (v) {
              PlayerTouch.auto => 'Automatic (phones and tablets without a controller)',
              PlayerTouch.on => 'Always',
              PlayerTouch.off => 'Never',
            },
            onChanged: (v) => s.settings.set(SettingsKeys.playerTouch, v.name),
          ),
          _Row(
            title: 'Settings for each emulator',
            value: 'Display filter, on-screen controls and emulator options for NES, SNES, PS1, N64, PSP…',
            action: 'Open ›',
            onSelect: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerCoresScreen())),
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
          const _Row(title: 'Application version', value: '$appName $appVersion (pre-release)'),
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
              value: 'Back up / restore emulator saves: SETTINGS → Storage → Save folders, or on each game page.'),
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

/// Consoles each bundled core plays, e.g. "NES" or "Game Boy, Game Boy Color".
String coreConsoles(String core) =>
    [for (final e in builtInCores.entries) if (e.value == core) consoleById(e.key)?.name ?? e.key].join(', ');

/// The built-in player's emulators, each with its own settings.
class PlayerCoresScreen extends StatelessWidget {
  const PlayerCoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final cores = builtInCores.values.toSet().toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: palette.decoration,
        child: SafeArea(
          child: PageFrame(
            title: 'Emulator settings',
            subtitle: 'The emulators built into GAMEBOX. Each one keeps its own settings.',
            actions: [TvButton(label: 'Back', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.pop(context))],
            child: ListView(children: [
              for (final (i, core) in cores.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TvFocusable(
                    autofocus: i == 0,
                    scale: 1.01,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onSelect: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => PlayerCoreSettingsScreen(core: core))),
                    child: Row(children: [
                      const Icon(Icons.memory_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(coreConsoles(core), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(builtInCoreNames[core] ?? core,
                              style: const TextStyle(fontSize: 12, color: Colors.white60)),
                        ]),
                      ),
                      Text('Settings ›', style: TextStyle(color: palette.focus)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Settings of one built-in emulator: display filter, on-screen controls,
/// and the emulator options changed in game (Menu → Emulator options).
class PlayerCoreSettingsScreen extends StatefulWidget {
  const PlayerCoreSettingsScreen({super.key, required this.core});
  final String core;

  @override
  State<PlayerCoreSettingsScreen> createState() => _PlayerCoreSettingsScreenState();
}

class _PlayerCoreSettingsScreenState extends State<PlayerCoreSettingsScreen> {
  Future<Map<String, String>>? _options;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _options ??= _load();
  }

  Future<Map<String, String>> _load() async {
    try {
      return await servicesOf(context).gateway.coreOptions(widget.core);
    } catch (_) {
      return const {};
    }
  }

  Future<void> _reset() async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    bool ok;
    try {
      ok = await s.gateway.resetCoreOptions(widget.core);
    } catch (_) {
      ok = false;
    }
    messenger.showSnackBar(SnackBar(content: Text(ok ? 'Emulator options reset' : 'Could not reset the options')));
    if (!mounted) return;
    final next = _load();
    setState(() {
      _options = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    final core = widget.core;
    String key(String name) => SettingsKeys.playerCore(core, name);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: palette.decoration,
        child: SafeArea(
          child: PageFrame(
            title: coreConsoles(core),
            subtitle: 'Built-in emulator: ${builtInCoreNames[core] ?? core}',
            actions: [
              TvButton(label: 'Back', icon: Icons.arrow_back_rounded, autofocus: true, onPressed: () => Navigator.pop(context)),
            ],
            child: ValueListenableBuilder<SettingsState>(
              valueListenable: s.settings.state,
              builder: (context, st, _) => ListView(children: [
                const SectionHeader('Display'),
                _Choice<PlayerShader>(
                  title: 'Display filter',
                  value: st.shaderFor(core),
                  values: PlayerShader.values,
                  label: (v) => v.label,
                  onChanged: (v) => s.settings.set(key('shader'), v.name),
                ),
                const SectionHeader('Controls'),
                _Choice<String>(
                  title: 'On-screen controls',
                  value: st.hasOwnTouch(core) ? st.touchFor(core).name : 'general',
                  values: const ['general', 'auto', 'on', 'off'],
                  label: (v) => switch (v) {
                    'auto' => 'Automatic (phones and tablets without a controller)',
                    'on' => 'Always',
                    'off' => 'Never',
                    _ => 'Same as the general setting',
                  },
                  onChanged: (v) => s.settings.set(key('touch'), v == 'general' ? '' : v),
                ),
                const SectionHeader('Emulator options',
                    subtitle: 'Change them while playing: BACK (Menu) → Emulator options. '
                        'The list comes from the emulator itself, so it shows its real choices.'),
                FutureBuilder<Map<String, String>>(
                  future: _options,
                  builder: (context, snap) {
                    final m = snap.data;
                    if (m == null) return const SizedBox(height: 24);
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (m.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('No options changed: the emulator uses its defaults.',
                              style: TextStyle(color: Colors.white60)),
                        ),
                      for (final e in m.entries) _Row(title: e.key, value: e.value),
                      if (m.isNotEmpty)
                        _Row(
                          title: 'Reset emulator options',
                          value: 'Go back to the emulator defaults',
                          action: 'Reset',
                          onSelect: _reset,
                        ),
                    ]);
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
