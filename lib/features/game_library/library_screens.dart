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
        : GeneratedCover(title: g.title, consoleId: g.consoleId);

    return SizedBox(
      width: width,
      child: TvFocusable(
        semanticLabel: g.title,
        onSelect: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: g.id))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Artwork takes whatever height the cell leaves after the caption.
          Expanded(
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
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(g.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium?.copyWith(height: 1.2)),
              Text(console?.name ?? g.consoleId,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: Colors.white70)),
              Text('Last played: ${formatRelative(g.lastPlayedAt)}',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(color: Colors.white54)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Artwork for games without a cover: console colour and the title.
class GeneratedCover extends StatelessWidget {
  const GeneratedCover({super.key, required this.title, required this.consoleId});
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

class GameGrid extends StatelessWidget {
  const GameGrid({super.key, required this.stream, required this.empty});
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
