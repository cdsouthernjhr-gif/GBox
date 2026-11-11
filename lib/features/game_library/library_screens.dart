import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
import 'game_detail_screen.dart';

Color consoleColor(String consoleId) {
  const colors = [
    Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF3949AB), Color(0xFF039BE5),
    Color(0xFF00897B), Color(0xFF7CB342), Color(0xFFFDD835), Color(0xFFFB8C00),
  ];
  return colors[consoleId.codeUnits.fold<int>(0, (a, b) => a + b) % colors.length];
}

/// Game card: artwork, title, console, last played, favourite and play action.
class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.entry, this.coverPath, this.width = 170});
  final GameWithStatus entry;
  final String? coverPath;
  final double width;

  @override
  Widget build(BuildContext context) {
    final g = entry.game;
    final console = consoleById(g.consoleId);
    final t = Theme.of(context).textTheme;
    final cover = coverPath != null && File(coverPath!).existsSync()
        ? Image.file(File(coverPath!), fit: BoxFit.cover, cacheWidth: (width * 2).round())
        : _GeneratedCover(title: g.title, consoleId: g.consoleId);

    return SizedBox(
      width: width,
      child: TvFocusable(
        semanticLabel: g.title,
        onSelect: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: g.id))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(fit: StackFit.expand, children: [
                cover,
                if (entry.isFavorite)
                  const Positioned(
                      top: 6, right: 6, child: Icon(Icons.star_rounded, color: Colors.amber, size: 22)),
                if (g.isMissing)
                  const Positioned(
                      top: 6, left: 6, child: StatusChip('MISSING', color: Colors.orangeAccent)),
                Positioned(
                  bottom: 6, right: 6,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.play_arrow_rounded,
                        size: 20, color: GameboxPalette.of(context).focus),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium),
              Text(console?.name ?? g.consoleId,
                  style: t.bodySmall?.copyWith(color: Colors.white70)),
              Text('Last played: ${formatRelative(g.lastPlayedAt)}',
                  style: t.bodySmall?.copyWith(color: Colors.white54)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GeneratedCover extends StatelessWidget {
  const _GeneratedCover({required this.title, required this.consoleId});
  final String title;
  final String consoleId;

  @override
  Widget build(BuildContext context) {
    final c = consoleColor(consoleId);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withValues(alpha: 0.85), Color.lerp(c, Colors.black, 0.7)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(title,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

/// Horizontal row of game cards fed by a database stream.
class GameCardRow extends StatelessWidget {
  const GameCardRow({super.key, required this.title, required this.stream, required this.emptyMessage});
  final String title;
  final Stream<List<GameWithStatus>> stream;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final db = servicesOf(context).db;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title),
      StreamBuilder<Map<int, String>>(
        stream: db.watchCoverPaths(),
        builder: (context, covers) => StreamBuilder<List<GameWithStatus>>(
          stream: stream,
          builder: (context, snap) {
            final games = snap.data ?? const [];
            if (games.isEmpty) {
              return Container(
                height: 64,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: GameboxPalette.of(context).card.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emptyMessage, style: const TextStyle(color: Colors.white60)),
              );
            }
            return SizedBox(
              height: 236,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                itemCount: games.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) =>
                    GameCard(entry: games[i], coverPath: covers.data?[games[i].game.id]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid({required this.stream, required this.empty});
  final Stream<List<GameWithStatus>> stream;
  final Widget empty;

  @override
  Widget build(BuildContext context) {
    final db = servicesOf(context).db;
    return StreamBuilder<Map<int, String>>(
      stream: db.watchCoverPaths(),
      builder: (context, covers) => StreamBuilder<List<GameWithStatus>>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final games = snap.data!;
          if (games.isEmpty) return empty;
          return GridView.builder(
            padding: const EdgeInsets.all(6),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 190,
              mainAxisExtent: 222,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: games.length,
            itemBuilder: (_, i) => GameCard(
              entry: games[i],
              coverPath: covers.data?[games[i].game.id],
              width: 190,
            ),
          );
        },
      ),
    );
  }
}

const _importNote = 'ROM import and folder scanning arrive in Phase 2. '
    'You can already register your game folders under STORAGE.';

class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  String? _console;

  @override
  Widget build(BuildContext context) {
    final db = servicesOf(context).db;
    return PageFrame(
      title: 'My Games',
      subtitle: 'Your local library — available offline',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StreamBuilder<Map<String, int>>(
          stream: db.watchGameCountsByConsole(),
          builder: (context, snap) {
            final counts = snap.data ?? const {};
            if (counts.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 48,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _filterChip(context, null, 'All (${counts.values.fold(0, (a, b) => a + b)})'),
                for (final e in counts.entries)
                  _filterChip(context, e.key, '${consoleById(e.key)?.name ?? e.key} (${e.value})'),
              ]),
            );
          },
        ),
        Expanded(
          child: _GameGrid(
            stream: db.watchAllGames(consoleId: _console),
            empty: const EmptyState(
              icon: Icons.sports_esports_outlined,
              title: 'No games in your library yet',
              message: _importNote,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _filterChip(BuildContext context, String? id, String label) => Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: TvFocusable(
          borderRadius: 24,
          color: _console == id ? GameboxPalette.of(context).accent : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          onSelect: () => setState(() => _console = id),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      );
}

class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Recently Played',
        child: _GameGrid(
          stream: servicesOf(context).db.watchRecentlyPlayed(limit: 60),
          empty: const EmptyState(
            icon: Icons.history_rounded,
            title: 'Nothing played yet',
            message: 'Games you launch through GAMEBOX will appear here. '
                'Game launching starts in Phase 3.',
          ),
        ),
      );
}

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Favourites',
        child: _GameGrid(
          stream: servicesOf(context).db.watchFavorites(),
          empty: const EmptyState(
            icon: Icons.star_outline_rounded,
            title: 'No favourites yet',
            message: 'Open a game and choose "Add to favourites".',
          ),
        ),
      );
}
