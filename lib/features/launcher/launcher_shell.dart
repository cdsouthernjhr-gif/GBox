import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../emulator_manager/launch_dialogs.dart';
import '../game_home/game_home_screen.dart';
import '../game_home/home_dashboard.dart' show HomeNavigation;
import '../download_manager/downloads_screen.dart';
import '../emulator_manager/emulators_screen.dart';
import '../game_library/my_games_screen.dart';
import '../settings/settings_screen.dart';
import '../compatibility/rating_prompt.dart';
import 'apps_screen.dart';

enum LauncherSection {
  /// Featured game, continue playing, systems, favourites, recently added.
  home('HOME', Icons.home_rounded),

  /// Every game, filtered by console / favourites / missing, searchable.
  games('GAMES', Icons.sports_esports_rounded),

  /// Find ROMs on the device, find games online, downloads.
  addGames('ADD GAMES', Icons.add_circle_outline_rounded),

  /// Emulators per system, built-in emulator settings, compatibility.
  emulators('EMULATORS', Icons.memory_rounded),

  /// Settings, controllers, storage and the device report.
  settings('SETTINGS', Icons.settings_rounded),
  apps('ANDROID APPS', Icons.apps_rounded);

  const LauncherSection(this.label, this.icon);
  final String label;
  final IconData icon;

  /// Label in the phone's bottom navigation.
  String get shortLabel => switch (this) {
    home => 'Home',
    games => 'Games',
    addGames => 'Add',
    emulators => 'Emulators',
    settings => 'Settings',
    apps => 'Apps',
  };
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
  late final List<FocusNode> _navNodes = List.generate(
    LauncherSection.values.length,
    (i) => FocusNode(debugLabel: 'nav$i'),
  );
  final _contentScope = FocusScopeNode(debugLabel: 'content');

  /// The side menu has focus (it is then shown in full).
  bool _railFocused = false;
  final List<StreamSubscription<Object?>> _subs = [];
  AppServices? _services;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subs.isNotEmpty) return;
    final s = servicesOf(context);
    _services = s;
    _subs.add(s.gateway.homePressed().listen((_) => goHome()));
    void notify(String msg) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
    }

    _subs.add(s.controllers.notifications.stream.listen(notify));
    s.launcher.finishedSession.addListener(_onFinished);
    s.launcher.playerCrash.addListener(_onPlayerCrash);
    if (s.launcher.playerCrash.value != null) WidgetsBinding.instance.addPostFrameCallback((_) => _onPlayerCrash());
    s.launcher.playerCouldNotOpen.addListener(_onCouldNotOpen);
    _subs.add(s.storage.notifications.stream.listen(notify));
  }

  void _onFinished() {
    final s = servicesOf(context);
    final done = s.launcher.finishedSession.value;
    if (done == null || !mounted) return;
    s.launcher.finishedSession.value = null;
    askHowItRan(context, done.$1, done.$2);
  }

  void _onPlayerCrash() {
    final s = _services;
    final crash = s?.launcher.playerCrash.value;
    if (crash == null || !mounted) return;
    s!.launcher.playerCrash.value = null;
    showPlayerCrashDialog(context, crash);
  }

  Future<void> _onCouldNotOpen() async {
    final s = _services;
    final id = s?.launcher.playerCouldNotOpen.value;
    if (id == null || !mounted) return;
    s!.launcher.playerCouldNotOpen.value = null;
    try {
      final game = await s.db.gameById(id);
      if (mounted) await showOtherEmulatorsDialog(context, game);
    } catch (_) {}
  }

  @override
  void dispose() {
    _services?.launcher.playerCouldNotOpen.removeListener(_onCouldNotOpen);
    _services?.launcher.finishedSession.removeListener(_onFinished);
    _services?.launcher.playerCrash.removeListener(_onPlayerCrash);
    for (final s in _subs) {
      s.cancel();
    }
    for (final n in _navNodes) {
      n.dispose();
    }
    _contentScope.dispose();
    super.dispose();
  }

  /// Console filter GAMES opens with (from a system on HOME).
  String? _gamesConsole;

  void goHome() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    select(LauncherSection.home);
    _focusContent();
  }

  /// Shows [section] with the focus in its content (from HOME's quick actions).
  void _openSection(LauncherSection section) {
    select(section);
    _focusContent();
  }

  /// Opens GAMES showing [consoleId]'s games (all games when null).
  void openGames([String? consoleId]) {
    setState(() {
      _gamesConsole = consoleId;
      _section = LauncherSection.games;
    });
    _focusContent();
  }

  /// Opens the side menu: focus moves to the current section's entry.
  void openMenu() => _navNodes[_section.index].requestFocus();

  /// Moves focus into the content (e.g. the game launcher) after the next
  /// frame, so a newly shown section is built first.
  void _focusContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _contentScope.hasFocus) return;
      // The last focused game if it still exists, else the first one.
      final prev = _contentScope.focusedChild;
      if (prev != null && prev.context != null && prev.canRequestFocus && prev != _contentScope) {
        prev.requestFocus();
        return;
      }
      _contentScope.traversalDescendants
          .where((n) => n.canRequestFocus && !n.skipTraversal)
          .firstOrNull
          ?.requestFocus();
    });
    // Nothing else may schedule a frame (e.g. BACK on the menu of the
    // section already shown), so ask for one.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void select(LauncherSection s, {bool focusNav = false}) {
    if (_section != s) {
      setState(() {
        _section = s;
        // From the menu, GAMES shows every game.
        if (s == LauncherSection.games) _gamesConsole = null;
      });
    }
    if (focusNav) _navNodes[s.index].requestFocus();
  }

  Widget _content() => switch (_section) {
    LauncherSection.home => GameHomeScreen(
      onOpenMenu: openMenu,
      onOpenConsole: openGames,
      nav: HomeNavigation(
        addGames: () => _openSection(LauncherSection.addGames),
        emulators: () => _openSection(LauncherSection.emulators),
        settings: () => _openSection(LauncherSection.settings),
        openMenu: openMenu,
      ),
    ),
    LauncherSection.games => MyGamesScreen(key: ValueKey(_gamesConsole), initialConsole: _gamesConsole),
    LauncherSection.addGames => const DownloadsScreen(),
    LauncherSection.emulators => const EmulatorsScreen(),
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
        // BACK on the menu returns to the games on HOME.
        if (_contentScope.hasFocus) {
          _navNodes[_section.index].requestFocus();
        } else {
          select(LauncherSection.home);
          _focusContent();
        }
      },
      child: LayoutBuilder(
        builder: (context, box) {
          // Phones held upright (and other narrow screens): bottom navigation.
          // TVs, tablets and phones in landscape: the side menu.
          final bottomNav = box.maxWidth < 720;
          final content = Column(
            children: [
              const _StatusBar(),
              Expanded(
                child: FocusScope(
                  node: _contentScope,
                  child: KeyedSubtree(key: ValueKey(_section), child: _content()),
                ),
              ),
            ],
          );
          if (bottomNav) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: DecoratedBox(
                decoration: palette.decoration,
                child: SafeArea(bottom: false, child: content),
              ),
              bottomNavigationBar: NavigationBar(
                key: const ValueKey('bottom-nav'),
                backgroundColor: palette.surface,
                indicatorColor: palette.accent.withValues(alpha: 0.4),
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: _section.index,
                onDestinationSelected: (i) => _openSection(LauncherSection.values[i]),
                destinations: [
                  for (final s in LauncherSection.values)
                    NavigationDestination(icon: Icon(s.icon), label: s.shortLabel, tooltip: s.label),
                ],
              ),
            );
          }
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: DecoratedBox(
              decoration: palette.decoration,
              child: SafeArea(
                child: Row(
                  children: [
                    Focus(
                      canRequestFocus: false,
                      skipTraversal: true,
                      onFocusChange: (f) => setState(() => _railFocused = f),
                      child: _NavRail(
                        nodes: _navNodes,
                        selected: _section,
                        onSelect: (s) => select(s),
                        // On HOME the menu shrinks to icons until it has focus.
                        collapsed: _section == LauncherSection.home && !_railFocused,
                        autofocusHome: false,
                      ),
                    ),
                    Expanded(child: content),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.nodes,
    required this.selected,
    required this.onSelect,
    this.collapsed = false,
    this.autofocusHome = true,
  });
  final List<FocusNode> nodes;
  final LauncherSection selected;
  final ValueChanged<LauncherSection> onSelect;
  final bool collapsed;
  final bool autofocusHome;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final animate = MotionSettings.maybeOf(context)?.animate ?? true;
    return AnimatedContainer(
      duration: animate ? const Duration(milliseconds: 160) : Duration.zero,
      width: collapsed ? 64 : 196,
      color: palette.surface.withValues(alpha: collapsed ? 0.55 : 0.85),
      child: LayoutBuilder(
        builder: (context, c) {
          // Icons only while narrow (collapsed, or animating).
          final compact = c.maxWidth < 150;
          return compact ? _compact(context, palette) : _full(context, palette);
        },
      ),
    );
  }

  Widget _compact(BuildContext context, GameboxPalette palette) => FocusTraversalGroup(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 18, 0, 14),
          child: Image.asset('assets/images/gamebox_logo.png', width: 30, height: 30, cacheWidth: 60, cacheHeight: 60),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final s in LauncherSection.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: TvFocusable(
                    focusNode: nodes[s.index],
                    autofocus: autofocusHome && s == LauncherSection.home,
                    scale: 1.0,
                    borderRadius: 10,
                    color: s == selected ? palette.accent.withValues(alpha: 0.28) : Colors.transparent,
                    onFocus: (f) {
                      if (f) onSelect(s);
                    },
                    onSelect: () {
                      onSelect(s);
                      FocusScope.of(context).focusInDirection(TraversalDirection.right);
                    },
                    semanticLabel: s.label,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(s.icon, size: 20, color: s == selected ? palette.focus : Colors.white54),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _full(BuildContext context, GameboxPalette palette) => FocusTraversalGroup(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
          child: Row(
            children: [
              Image.asset('assets/images/gamebox_logo.png', width: 30, height: 30, cacheWidth: 60, cacheHeight: 60),
              const SizedBox(width: 8),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('GAMEBOX', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
              ),
            ],
          ),
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
                    autofocus: autofocusHome && s == LauncherSection.home,
                    scale: 1.0,
                    borderRadius: 10,
                    color: s == selected ? palette.accent.withValues(alpha: 0.28) : Colors.transparent,
                    onFocus: (f) {
                      if (f) onSelect(s);
                    },
                    onSelect: () {
                      onSelect(s);
                      FocusScope.of(context).focusInDirection(TraversalDirection.right);
                    },
                    semanticLabel: s.label,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(s.icon, size: 20, color: s == selected ? palette.focus : Colors.white70),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            s.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: s == selected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
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
    // Narrow screens (phones upright): no hardware tier chip, so the
    // controller and network status and the clock fit.
    final narrow = MediaQuery.sizeOf(context).width < 520;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 12 : 24, 12, narrow ? 12 : 24, 0),
      child: Row(
        children: [
          if (!narrow)
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
          Flexible(
            child: ValueListenableBuilder<List<InputDeviceInfo>>(
              valueListenable: s.controllers.devices,
              builder: (_, list, _) {
                final n = list.where((d) => d.isGameController).length;
                return StatusChip(
                  n == 0 ? 'No controller' : '$n controller${n == 1 ? '' : 's'}',
                  color: n == 0 ? Colors.white54 : palette.success,
                  icon: Icons.gamepad_rounded,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ValueListenableBuilder<ConnectivityStatus>(
              valueListenable: s.connectivity.status,
              builder: (_, c, _) => StatusChip(
                c.isOnline ? 'Online' : (c.connected ? 'No internet' : 'Offline'),
                color: c.isOnline ? palette.success : Colors.white54,
                icon: c.isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
