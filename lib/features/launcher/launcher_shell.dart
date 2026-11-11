import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../console_manager/consoles_screen.dart';
import '../controller_manager/controllers_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../download_manager/downloads_screen.dart';
import '../emulator_manager/emulators_screen.dart';
import '../game_library/library_screens.dart';
import '../settings/settings_screen.dart';
import '../storage_manager/storage_screen.dart';
import 'apps_screen.dart';

enum LauncherSection {
  home('HOME', Icons.home_rounded),
  myGames('MY GAMES', Icons.sports_esports_rounded),
  consoles('CONSOLES', Icons.videogame_asset_rounded),
  recent('RECENTLY PLAYED', Icons.history_rounded),
  favourites('FAVOURITES', Icons.star_rounded),
  downloads('DOWNLOADS', Icons.download_rounded),
  emulators('EMULATORS', Icons.memory_rounded),
  controllers('CONTROLLERS', Icons.gamepad_rounded),
  storage('STORAGE', Icons.sd_storage_rounded),
  settings('SETTINGS', Icons.settings_rounded),
  apps('ANDROID APPS', Icons.apps_rounded);

  const LauncherSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Root of the launcher: side navigation + content. Never exits on BACK,
/// because GAMEBOX may be the device HOME app.
class LauncherShell extends StatefulWidget {
  const LauncherShell({super.key});

  @override
  State<LauncherShell> createState() => LauncherShellState();
}

class LauncherShellState extends State<LauncherShell> {
  LauncherSection _section = LauncherSection.home;
  late final List<FocusNode> _navNodes =
      List.generate(LauncherSection.values.length, (i) => FocusNode(debugLabel: 'nav$i'));
  final _contentScope = FocusScopeNode(debugLabel: 'content');
  final List<StreamSubscription<Object?>> _subs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subs.isNotEmpty) return;
    final s = servicesOf(context);
    _subs.add(s.gateway.homePressed().listen((_) => goHome()));
    void notify(String msg) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
    }
    _subs.add(s.controllers.notifications.stream.listen(notify));
    _subs.add(s.storage.notifications.stream.listen(notify));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    for (final n in _navNodes) {
      n.dispose();
    }
    _contentScope.dispose();
    super.dispose();
  }

  void goHome() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    select(LauncherSection.home, focusNav: true);
  }

  void select(LauncherSection s, {bool focusNav = false}) {
    if (_section != s) setState(() => _section = s);
    if (focusNav) _navNodes[s.index].requestFocus();
  }

  Widget _content() => switch (_section) {
        LauncherSection.home => DashboardScreen(onNavigate: (s) => select(s, focusNav: true)),
        LauncherSection.myGames => const MyGamesScreen(),
        LauncherSection.consoles => const ConsolesScreen(),
        LauncherSection.recent => const RecentlyPlayedScreen(),
        LauncherSection.favourites => const FavouritesScreen(),
        LauncherSection.downloads => const DownloadsScreen(),
        LauncherSection.emulators => const EmulatorsScreen(),
        LauncherSection.controllers => const ControllersScreen(),
        LauncherSection.storage => const StorageScreen(),
        LauncherSection.settings => const SettingsScreen(),
        LauncherSection.apps => const AppsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // BACK inside content returns focus to the menu; on the menu it
        // goes to HOME. The launcher itself never closes.
        if (_contentScope.hasFocus) {
          _navNodes[_section.index].requestFocus();
        } else if (_section != LauncherSection.home) {
          select(LauncherSection.home, focusNav: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: palette.background),
          child: SafeArea(
            child: Row(children: [
              _NavRail(
                nodes: _navNodes,
                selected: _section,
                onSelect: (s) => select(s),
              ),
              Expanded(
                child: Column(children: [
                  const _StatusBar(),
                  Expanded(
                    child: FocusScope(
                      node: _contentScope,
                      child: KeyedSubtree(key: ValueKey(_section), child: _content()),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({required this.nodes, required this.selected, required this.onSelect});
  final List<FocusNode> nodes;
  final LauncherSection selected;
  final ValueChanged<LauncherSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    return Container(
      width: 196,
      color: palette.surface.withValues(alpha: 0.85),
      child: FocusTraversalGroup(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
            child: Row(children: [
              Image.asset('assets/images/gamebox_logo.png', width: 30, height: 30,
                  cacheWidth: 60, cacheHeight: 60),
              const SizedBox(width: 8),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('GAMEBOX',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (final s in LauncherSection.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TvFocusable(
                      focusNode: nodes[s.index],
                      autofocus: s == LauncherSection.home,
                      scale: 1.0,
                      borderRadius: 10,
                      color: s == selected
                          ? palette.accent.withValues(alpha: 0.28)
                          : Colors.transparent,
                      onFocus: (f) {
                        if (f) onSelect(s);
                      },
                      onSelect: () {
                        onSelect(s);
                        FocusScope.of(context).focusInDirection(TraversalDirection.right);
                      },
                      semanticLabel: s.label,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(children: [
                        Icon(s.icon, size: 20,
                            color: s == selected ? palette.focus : Colors.white70),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(s.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: s == selected ? Colors.white : Colors.white70,
                              )),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatusBar extends StatefulWidget {
  const _StatusBar();

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(children: [
        ValueListenableBuilder(
          valueListenable: s.device.state,
          builder: (_, st, _) {
            final c = st.classification;
            if (st.scanning && c == null) {
              return const StatusChip('Scanning hardware…', color: Colors.white70, icon: Icons.radar);
            }
            if (c == null) return const SizedBox.shrink();
            return StatusChip(c.tier.label, color: palette.focus, icon: Icons.speed_rounded);
          },
        ),
        const Spacer(),
        ValueListenableBuilder<List<InputDeviceInfo>>(
          valueListenable: s.controllers.devices,
          builder: (_, list, _) {
            final n = list.where((d) => d.isGameController).length;
            return StatusChip(n == 0 ? 'No controller' : '$n controller${n == 1 ? '' : 's'}',
                color: n == 0 ? Colors.white54 : palette.success, icon: Icons.gamepad_rounded);
          },
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<ConnectivityStatus>(
          valueListenable: s.connectivity.status,
          builder: (_, c, _) => StatusChip(
            c.isOnline ? 'Online' : (c.connected ? 'No internet' : 'Offline'),
            color: c.isOnline ? palette.success : Colors.white54,
            icon: c.isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }
}
