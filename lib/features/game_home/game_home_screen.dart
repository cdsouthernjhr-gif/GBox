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
import '../setup/setup_screen.dart';

/// One horizontal row of the game launcher.
class GameRowData {
  const GameRowData({required this.title, required this.games, this.consoleId});
  final String title;
  final List<GameWithStatus> games;

  /// Set for console rows (used for the accent colour).
  final String? consoleId;
}

/// Builds the launcher rows: continue playing, favourites, recently added,
/// then one row per console that has games, in [order].
List<GameRowData> buildGameRows({
  required List<GameWithStatus> all,
  required RowOrder order,
  int recentLimit = 15,
}) {
  final rows = <GameRowData>[];
  final played = all.where((g) => g.game.lastPlayedAt != null).toList()
    ..sort((a, b) => b.game.lastPlayedAt!.compareTo(a.game.lastPlayedAt!));
  if (played.isNotEmpty) rows.add(GameRowData(title: 'Continue playing', games: played.take(recentLimit).toList()));
  final favs = all.where((g) => g.isFavorite).toList();
  if (favs.isNotEmpty) rows.add(GameRowData(title: 'Favourites', games: favs));

  final byConsole = <String, List<GameWithStatus>>{};
  for (final g in all) {
    (byConsole[g.game.consoleId] ??= []).add(g);
  }
  for (final list in byConsole.values) {
    list.sort((a, b) => a.game.sortTitle.compareTo(b.game.sortTitle));
  }
  DateTime lastPlayed(List<GameWithStatus> l) => l
      .map((g) => g.game.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
      .reduce((a, b) => a.isAfter(b) ? a : b);
  String name(String id) => consoleById(id)?.name ?? id;
  final consoles = byConsole.keys.toList()
    ..sort(switch (order) {
      RowOrder.mostGames => (a, b) {
          final c = byConsole[b]!.length.compareTo(byConsole[a]!.length);
          return c != 0 ? c : name(a).compareTo(name(b));
        },
      RowOrder.recentlyPlayed => (a, b) {
          final c = lastPlayed(byConsole[b]!).compareTo(lastPlayed(byConsole[a]!));
          return c != 0 ? c : name(a).compareTo(name(b));
        },
      RowOrder.alphabetical => (a, b) => name(a).compareTo(name(b)),
    });
  for (final c in consoles) {
    rows.add(GameRowData(title: name(c), games: byConsole[c]!, consoleId: c));
  }
  return rows;
}

/// Game launcher: opens straight on the games. A large panel shows the
/// focused game; below, one horizontal row per console (plus continue
/// playing and favourites). D-pad left/right moves within a row, up/down
/// between rows. OK/A plays, Y favourites, Menu/X opens options, left on the
/// first game (or Menu on an empty library) opens the side menu.
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key, required this.onOpenMenu});

  /// Shows the side menu (focus moves to it).
  final VoidCallback onOpenMenu;

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final ValueNotifier<GameWithStatus?> _focused = ValueNotifier(null);

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
                final rows = buildGameRows(all: all, order: st.rowOrder);
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
                return Stack(children: [
                  Positioned.fill(child: _Backdrop(focused: _focused, covers: covers)),
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _Hero(focused: _focused, covers: covers),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: rows.length,
                        itemBuilder: (context, r) => _GameRow(
                          key: ValueKey('row-${rows[r].title}'),
                          data: rows[r],
                          covers: covers,
                          autofocusFirst: r == 0,
                          onFocusGame: (g) => _focused.value = g,
                          onOpenMenu: widget.onOpenMenu,
                          onOptions: _options,
                        ),
                      ),
                    ),
                  ]),
                ]);
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
          final img = Image.file(File(path), fit: BoxFit.cover, cacheWidth: 480, gaplessPlayback: true);
          layer = Opacity(
            opacity: 0.28,
            // Blur only when animations are on (low-memory mode turns them off).
            child: animate ? ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: img) : img,
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
          duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
          child: KeyedSubtree(key: ValueKey(g?.game.id), child: SizedBox.expand(child: layer)),
        );
      },
    );
  }
}

/// Large panel with the focused game.
class _Hero extends StatelessWidget {
  const _Hero({required this.focused, required this.covers});
  final ValueNotifier<GameWithStatus?> focused;
  final Map<int, String> covers;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final palette = GameboxPalette.of(context);
    return SizedBox(
      height: 150,
      child: ValueListenableBuilder<GameWithStatus?>(
        valueListenable: focused,
        builder: (context, g, _) {
          if (g == null) return const SizedBox.shrink();
          final game = g.game;
          final path = covers[game.id];
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: path != null && File(path).existsSync()
                      ? Image.file(File(path), fit: BoxFit.cover, cacheWidth: 200, gaplessPlayback: true)
                      : GeneratedCover(title: game.title, consoleId: game.consoleId),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(game.title,
                        key: const ValueKey('hero-title'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
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
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      StatusChip('OK / A  Play', color: palette.focus, icon: Icons.play_arrow_rounded),
                      StatusChip(g.isFavorite ? 'Y  Unfavourite' : 'Y  Favourite',
                          color: Colors.amber, icon: Icons.star_rounded),
                      const StatusChip('Menu / X  Options', color: Colors.white70, icon: Icons.more_horiz_rounded),
                    ]),
                  ],
                ),
              ),
            ]),
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

  static const cardWidth = 116.0;
  static const cardHeight = 156.0;

  @override
  Widget build(BuildContext context) {
    final accent = data.consoleId == null ? GameboxPalette.of(context).focus : consoleColor(data.consoleId!);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(data.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text('${data.games.length}', style: const TextStyle(color: Colors.white54)),
        ]),
        SizedBox(
          height: cardHeight + 20,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            itemCount: data.games.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
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
      ]),
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
        ? Image.file(File(path), fit: BoxFit.cover, cacheWidth: 240)
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
        if (k == LogicalKeyboardKey.gameButtonX || k == LogicalKeyboardKey.contextMenu || k == LogicalKeyboardKey.keyI) {
          onOptions(entry);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: _GameRow.cardWidth,
        height: _GameRow.cardHeight,
        child: TvFocusable(
          autofocus: autofocus,
          scale: 1.1,
          borderRadius: 12,
          semanticLabel: g.title,
          onFocus: (f) {
            if (f) onFocus(entry);
          },
          onSelect: () => playGame(context, g),
          onLongPress: () => onOptions(entry),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(fit: StackFit.expand, children: [
              cover,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(g.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.15)),
                ),
              ),
              if (entry.isFavorite)
                const Positioned(top: 5, right: 5, child: Icon(Icons.star_rounded, color: Colors.amber, size: 20)),
              if (g.isMissing)
                const Positioned(top: 5, left: 5, child: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20)),
            ]),
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
            (event.logicalKey == LogicalKeyboardKey.contextMenu || event.logicalKey == LogicalKeyboardKey.gameButtonStart)) {
          onOpenMenu();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 10, children: [
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
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RomSearchScreen())),
              ),
              TvButton(label: 'Menu', icon: Icons.menu_rounded, onPressed: onOpenMenu),
            ]),
          ]),
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
