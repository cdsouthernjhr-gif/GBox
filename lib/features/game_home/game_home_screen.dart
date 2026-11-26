import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../emulator_manager/launch_dialogs.dart';
import '../game_library/game_detail_screen.dart';
import '../game_library/library_screens.dart' show GeneratedCover, consoleColor;
import '../setup/rom_search_screen.dart';
import '../source_manager/find_online_screen.dart';
import '../setup/setup_screen.dart';

/// One horizontal row of the game launcher.
class GameRowData {
  const GameRowData({required this.title, required this.games});
  final String title;
  final List<GameWithStatus> games;
}

/// Rows of games on HOME: continue playing, favourites, recently added.
/// Every game of a console is under GAMES (a system tile opens it).
List<GameRowData> buildGameRows({required List<GameWithStatus> all, int recentLimit = 15}) {
  final rows = <GameRowData>[];
  final played = all.where((g) => g.game.lastPlayedAt != null).toList()
    ..sort((a, b) => b.game.lastPlayedAt!.compareTo(a.game.lastPlayedAt!));
  if (played.isNotEmpty) rows.add(GameRowData(title: 'Continue playing', games: played.take(recentLimit).toList()));
  final favs = all.where((g) => g.isFavorite).toList()..sort((a, b) => a.game.sortTitle.compareTo(b.game.sortTitle));
  if (favs.isNotEmpty) rows.add(GameRowData(title: 'Favourites', games: favs));
  final added = [...all]
    ..sort((a, b) {
      final c = b.game.addedAt.compareTo(a.game.addedAt);
      return c != 0 ? c : a.game.sortTitle.compareTo(b.game.sortTitle);
    });
  if (added.isNotEmpty) rows.add(GameRowData(title: 'Recently added', games: added.take(recentLimit).toList()));
  return rows;
}

/// Consoles with games and how many, in [order].
List<(String, int)> buildSystems({required List<GameWithStatus> all, required RowOrder order}) {
  final count = <String, int>{};
  final last = <String, DateTime>{};
  for (final g in all) {
    final c = g.game.consoleId;
    count[c] = (count[c] ?? 0) + 1;
    final p = g.game.lastPlayedAt;
    if (p != null && (last[c] == null || p.isAfter(last[c]!))) last[c] = p;
  }
  String name(String id) => consoleById(id)?.name ?? id;
  final ids = count.keys.toList()
    ..sort(switch (order) {
      RowOrder.mostGames => (a, b) {
        final c = count[b]!.compareTo(count[a]!);
        return c != 0 ? c : name(a).compareTo(name(b));
      },
      RowOrder.recentlyPlayed => (a, b) {
        final zero = DateTime.fromMillisecondsSinceEpoch(0);
        final c = (last[b] ?? zero).compareTo(last[a] ?? zero);
        return c != 0 ? c : name(a).compareTo(name(b));
      },
      RowOrder.alphabetical => (a, b) => name(a).compareTo(name(b)),
    });
  return [for (final id in ids) (id, count[id]!)];
}

/// Game launcher: opens straight on the games. A large panel shows the
/// focused game; below, continue playing, the systems (with their emulator
/// and number of games), favourites and recently added. D-pad left/right
/// moves within a row, up/down between rows. OK/A plays, Y favourites,
/// Menu/X opens options, left on the first item opens the side menu.
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key, required this.onOpenMenu, required this.onOpenConsole});

  /// Shows the side menu (focus moves to it).
  final VoidCallback onOpenMenu;

  /// Opens GAMES for a console.
  final ValueChanged<String> onOpenConsole;

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final ValueNotifier<GameWithStatus?> _focused = ValueNotifier(null);

  /// Emulator each system plays with ("Built-in", an app name, or null when
  /// none is installed), looked up once per HOME visit.
  final Map<String, Future<String?>> _status = {};

  Future<String?> _emulatorStatus(String consoleId) => _status[consoleId] ??= () async {
    final s = servicesOf(context);
    try {
      final choices = await s.launcher.choicesFor(consoleId);
      final profile = await s.db.defaultLaunchProfile(consoleId);
      final c =
          choices.where((c) => c.installed && c.adapter.emulatorId == profile?.emulatorId).firstOrNull ??
          choices.where((c) => c.installed).firstOrNull;
      if (c == null) return null;
      return c.adapter.builtIn ? 'Built-in player' : c.adapter.emulator.name;
    } catch (_) {
      return null;
    }
  }();

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  Future<void> _options(GameWithStatus g) async {
    final s = servicesOf(context);
    final action = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(g.game.title),
        children: [
          for (final (key, label, icon) in [
            ('play', 'Play', Icons.play_arrow_rounded),
            ('with', 'Play with…', Icons.tune_rounded),
            ('fav', g.isFavorite ? 'Remove from favourites' : 'Add to favourites', Icons.star_rounded),
            ('info', 'Game details, saves, files', Icons.info_outline_rounded),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, key),
              child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)]),
            ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'play':
        await playGame(context, g.game);
      case 'with':
        await playGameWith(context, g.game);
      case 'fav':
        await s.db.setFavorite(g.game.id, !g.isFavorite);
      case 'info':
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: g.game.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return KeyedSubtree(
      key: const ValueKey('game-home'),
      child: StreamBuilder<Map<int, String>>(
        stream: s.db.watchCoverPaths(),
        builder: (context, coversSnap) => StreamBuilder<List<GameWithStatus>>(
          stream: s.db.watchAllGames(),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final all = snap.data!;
            if (all.isEmpty) return _EmptyLibrary(onOpenMenu: widget.onOpenMenu);
            final covers = coversSnap.data ?? const <int, String>{};
            return ValueListenableBuilder<SettingsState>(
              valueListenable: s.settings.state,
              builder: (context, st, _) {
                final rows = buildGameRows(all: all);
                final systems = buildSystems(all: all, order: st.rowOrder);
                // The first row of games (continue playing, else recently
                // added) has the focus; the systems come right below it.
                const afterContinue = 1;
                Widget gameRow(int r) => _GameRow(
                  key: ValueKey('row-${rows[r].title}'),
                  data: rows[r],
                  covers: covers,
                  autofocusFirst: r == 0 && afterContinue == 1,
                  onFocusGame: (g) => _focused.value = g,
                  onOpenMenu: widget.onOpenMenu,
                  onOptions: _options,
                );
                final items = <Widget>[
                  for (var r = 0; r < afterContinue; r++) gameRow(r),
                  _SystemsRow(
                    key: const ValueKey('row-systems'),
                    systems: systems,
                    autofocusFirst: afterContinue == 0,
                    status: _emulatorStatus,
                    onOpen: widget.onOpenConsole,
                    onOpenMenu: widget.onOpenMenu,
                  ),
                  for (var r = afterContinue; r < rows.length; r++) gameRow(r),
                ];
                // Keep the panel in sync with the library (first game, or the
                // focused game after e.g. a favourite toggle). Updated after
                // this frame: listeners must not rebuild during build.
                final current = _focused.value;
                final want = current == null
                    ? rows.first.games.first
                    : all.where((g) => g.game.id == current.game.id).firstOrNull ?? rows.first.games.first;
                if (want != current) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _focused.value == current) _focused.value = want;
                  });
                }
                return LayoutBuilder(
                  builder: (context, box) => Stack(
                    children: [
                      Positioned.fill(
                        child: _Backdrop(focused: _focused, covers: covers),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The focused game's cover is shown large; the rows below
                          // keep small cards so more games fit.
                          _Hero(focused: _focused, covers: covers, height: (box.maxHeight * 0.42).clamp(140.0, 340.0)),
                          Expanded(
                            child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: items),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// The focused game's artwork, dimmed, behind everything.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.focused, required this.covers});
  final ValueNotifier<GameWithStatus?> focused;
  final Map<int, String> covers;

  @override
  Widget build(BuildContext context) {
    final animate = MotionSettings.maybeOf(context)?.animate ?? true;
    return ValueListenableBuilder<GameWithStatus?>(
      valueListenable: focused,
      builder: (context, g, _) {
        final path = g == null ? null : covers[g.game.id];
        final Widget layer;
        if (path != null && File(path).existsSync()) {
          final img = Image.file(File(path), fit: BoxFit.cover, cacheWidth: 720, gaplessPlayback: true);
          // The cover as wallpaper, lightly softened, darkened towards the
          // text and the rows so they stay readable.
          layer = Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.6,
                // Blur only when animations are on (low-memory mode turns them off).
                child: animate ? ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), child: img) : img,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.45, 1.0],
                    colors: [Color(0x55000000), Color(0x88000000), Color(0xE6000000)],
                  ),
                ),
              ),
            ],
          );
        } else if (g != null) {
          final c = consoleColor(g.game.consoleId);
          layer = DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.withValues(alpha: 0.30), Colors.transparent],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          );
        } else {
          layer = const SizedBox.shrink();
        }
        return AnimatedSwitcher(
          duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
          child: KeyedSubtree(
            key: ValueKey(g?.game.id),
            child: SizedBox.expand(child: layer),
          ),
        );
      },
    );
  }
}

/// Large panel with the focused game.
class _Hero extends StatelessWidget {
  const _Hero({required this.focused, required this.covers, required this.height});
  final ValueNotifier<GameWithStatus?> focused;
  final Map<int, String> covers;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final palette = GameboxPalette.of(context);
    return SizedBox(
      height: height,
      child: ValueListenableBuilder<GameWithStatus?>(
        valueListenable: focused,
        builder: (context, g, _) {
          if (g == null) return const SizedBox.shrink();
          final game = g.game;
          final path = covers[game.id];
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  key: const ValueKey('hero-cover'),
                  aspectRatio: 3 / 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 6))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: path != null && File(path).existsSync()
                          ? Image.file(File(path), fit: BoxFit.cover, cacheWidth: 480, gaplessPlayback: true)
                          : GeneratedCover(title: game.title, consoleId: game.consoleId),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        game.title,
                        key: const ValueKey('hero-title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          consoleById(game.consoleId)?.name ?? game.consoleId,
                          game.lastPlayedAt == null ? 'Not played yet' : 'Played ${formatRelative(game.lastPlayedAt)}',
                          if (game.playCount > 0) '${game.playCount}× played',
                          if (game.isMissing) 'FILE MISSING',
                        ].join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium?.copyWith(color: game.isMissing ? Colors.orangeAccent : Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          StatusChip('OK / A  Play', color: palette.focus, icon: Icons.play_arrow_rounded),
                          StatusChip(
                            g.isFavorite ? 'Y  Unfavourite' : 'Y  Favourite',
                            color: Colors.amber,
                            icon: Icons.star_rounded,
                          ),
                          const StatusChip('Menu / X  Options', color: Colors.white70, icon: Icons.more_horiz_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({
    super.key,
    required this.data,
    required this.covers,
    required this.autofocusFirst,
    required this.onFocusGame,
    required this.onOpenMenu,
    required this.onOptions,
  });
  final GameRowData data;
  final Map<int, String> covers;
  final bool autofocusFirst;
  final ValueChanged<GameWithStatus> onFocusGame;
  final VoidCallback onOpenMenu;
  final ValueChanged<GameWithStatus> onOptions;

  static const cardWidth = 84.0;
  static const cardHeight = 112.0;

  @override
  Widget build(BuildContext context) {
    final accent = GameboxPalette.of(context).focus;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(data.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text('${data.games.length}', style: const TextStyle(color: Colors.white54)),
            ],
          ),
          SizedBox(
            height: cardHeight + 20,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              itemCount: data.games.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _HomeCard(
                entry: data.games[i],
                coverPath: covers[data.games[i].game.id],
                autofocus: autofocusFirst && i == 0,
                firstInRow: i == 0,
                onFocus: onFocusGame,
                onOpenMenu: onOpenMenu,
                onOptions: onOptions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The consoles that have games: name, number of games and the emulator
/// they play with. Selecting one opens its games under GAMES.
class _SystemsRow extends StatelessWidget {
  const _SystemsRow({
    super.key,
    required this.systems,
    required this.autofocusFirst,
    required this.status,
    required this.onOpen,
    required this.onOpenMenu,
  });
  final List<(String, int)> systems;
  final bool autofocusFirst;
  final Future<String?> Function(String consoleId) status;
  final ValueChanged<String> onOpen;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: GameboxPalette.of(context).focus,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('My systems', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text('${systems.length}', style: const TextStyle(color: Colors.white54)),
            ],
          ),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              itemCount: systems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final (id, count) = systems[i];
                return _SystemTile(
                  consoleId: id,
                  games: count,
                  status: status(id),
                  autofocus: autofocusFirst && i == 0,
                  firstInRow: i == 0,
                  onOpen: () => onOpen(id),
                  onOpenMenu: onOpenMenu,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemTile extends StatelessWidget {
  const _SystemTile({
    required this.consoleId,
    required this.games,
    required this.status,
    required this.autofocus,
    required this.firstInRow,
    required this.onOpen,
    required this.onOpenMenu,
  });
  final String consoleId;
  final int games;
  final Future<String?> status;
  final bool autofocus;
  final bool firstInRow;
  final VoidCallback onOpen;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final color = consoleColor(consoleId);
    final name = consoleById(consoleId)?.name ?? consoleId;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final k = event.logicalKey;
        if ((k == LogicalKeyboardKey.arrowLeft && firstInRow) || k == LogicalKeyboardKey.gameButtonStart) {
          onOpenMenu();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: 168,
        child: TvFocusable(
          autofocus: autofocus,
          scale: 1.06,
          borderRadius: 10,
          semanticLabel: '$name, $games games',
          color: color.withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onSelect: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$games',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(games == 1 ? '1 game' : '$games games', style: const TextStyle(fontSize: 11, color: Colors.white60)),
              FutureBuilder<String?>(
                future: status,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Text('…', style: TextStyle(fontSize: 11, color: Colors.white38));
                  }
                  final emu = snap.data;
                  return Row(
                    children: [
                      Icon(
                        emu == null ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                        size: 12,
                        color: emu == null ? Colors.orangeAccent : Colors.greenAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          emu ?? 'Needs an emulator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: emu == null ? Colors.orangeAccent : Colors.white70),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.entry,
    required this.coverPath,
    required this.autofocus,
    required this.firstInRow,
    required this.onFocus,
    required this.onOpenMenu,
    required this.onOptions,
  });
  final GameWithStatus entry;
  final String? coverPath;
  final bool autofocus;
  final bool firstInRow;
  final ValueChanged<GameWithStatus> onFocus;
  final VoidCallback onOpenMenu;
  final ValueChanged<GameWithStatus> onOptions;

  @override
  Widget build(BuildContext context) {
    final g = entry.game;
    final s = servicesOf(context);
    final path = coverPath;
    final cover = path != null && File(path).existsSync()
        ? Image.file(File(path), fit: BoxFit.cover, cacheWidth: 180)
        : GeneratedCover(title: g.title, consoleId: g.consoleId);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final k = event.logicalKey;
        if ((k == LogicalKeyboardKey.arrowLeft && firstInRow) || k == LogicalKeyboardKey.gameButtonStart) {
          onOpenMenu();
          return KeyEventResult.handled;
        }
        if (k == LogicalKeyboardKey.gameButtonY || k == LogicalKeyboardKey.keyF) {
          s.db.setFavorite(g.id, !entry.isFavorite);
          return KeyEventResult.handled;
        }
        if (k == LogicalKeyboardKey.gameButtonX ||
            k == LogicalKeyboardKey.contextMenu ||
            k == LogicalKeyboardKey.keyI) {
          onOptions(entry);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      // A mouse over a card shows that game's cover large and as wallpaper,
      // before it is chosen.
      child: MouseRegion(
        onEnter: (_) => onFocus(entry),
        child: SizedBox(
          width: _GameRow.cardWidth,
          height: _GameRow.cardHeight,
          child: TvFocusable(
            autofocus: autofocus,
            scale: 1.15,
            borderRadius: 10,
            semanticLabel: g.title,
            onFocus: (f) {
              if (f) onFocus(entry);
            },
            onSelect: () => playGame(context, g),
            onLongPress: () => onOptions(entry),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cover,
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 14, 5, 4),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                      child: Text(
                        g.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, height: 1.1),
                      ),
                    ),
                  ),
                  if (entry.isFavorite)
                    const Positioned(top: 3, right: 3, child: Icon(Icons.star_rounded, color: Colors.amber, size: 15)),
                  if (g.isMissing)
                    const Positioned(
                      top: 3,
                      left: 3,
                      child: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 15),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown until the library has games: straight to setup or the ROM search.
class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onOpenMenu});
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.contextMenu ||
                event.logicalKey == LogicalKeyboardKey.gameButtonStart)) {
          onOpenMenu();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        // Scrolls on small screens (or while the menu takes width).
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_esports_rounded, size: 56, color: Colors.white54),
                const SizedBox(height: 10),
                Text('No games yet', style: t.headlineSmall),
                const SizedBox(height: 6),
                const Text(
                  'Let GAMEBOX find the games already on this device, or set it up step by step. '
                  'Games you add appear here, one row per console.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _LeftOpensMenu(
                      onOpenMenu: onOpenMenu,
                      child: TvButton(
                        label: 'Set up GAMEBOX',
                        icon: Icons.rocket_launch_rounded,
                        primary: true,
                        autofocus: true,
                        onPressed: () => openSetup(context),
                      ),
                    ),
                    TvButton(
                      label: 'Find ROMs on this device',
                      icon: Icons.travel_explore_rounded,
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RomSearchScreen())),
                    ),
                    TvButton(
                      label: 'Find games online',
                      icon: Icons.public_rounded,
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FindOnlineScreen())),
                    ),
                    TvButton(label: 'Menu', icon: Icons.menu_rounded, onPressed: onOpenMenu),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftOpensMenu extends StatelessWidget {
  const _LeftOpensMenu({required this.onOpenMenu, required this.child});
  final VoidCallback onOpenMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        onOpenMenu();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: child,
  );
}
