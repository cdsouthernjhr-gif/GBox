import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Dedicated game information page.
class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.gameId});
  final int gameId;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: palette.background),
        child: SafeArea(
          child: StreamBuilder<GameWithStatus?>(
            stream: s.db.watchGame(gameId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final entry = snap.data;
              if (entry == null) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Game not found',
                  message: 'It may have been removed from the library.',
                  action: TvButton(
                      label: 'Back', autofocus: true, onPressed: () => Navigator.pop(context)),
                );
              }
              return _Body(entry: entry);
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entry});
  final GameWithStatus entry;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final g = entry.game;
    final console = consoleById(g.consoleId);
    final t = Theme.of(context).textTheme;
    final dev = s.device.state.value;
    final estimate = (console != null && dev.profile != null && dev.classification != null)
        ? s.device.classifier.estimate(dev.profile!, dev.classification!, console)
        : null;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(children: [
        Text(g.title, style: t.displaySmall),
        const SizedBox(height: 4),
        Text('${console?.name ?? g.consoleId} · Added ${formatDateTime(g.addedAt)} · '
            'Played ${g.playCount}× · Last played ${formatRelative(g.lastPlayedAt)}',
            style: t.bodyLarge?.copyWith(color: Colors.white70)),
        const SizedBox(height: 18),
        Wrap(spacing: 12, runSpacing: 12, children: [
          // Play stays disabled until an execution-tested emulator adapter
          // exists (Phase 3). No fake launch.
          const TvButton(label: 'Play (Phase 3)', icon: Icons.play_arrow_rounded, onPressed: null),
          TvButton(
            autofocus: true,
            label: entry.isFavorite ? 'Remove favourite' : 'Add to favourites',
            icon: entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            onPressed: () => s.db.setFavorite(g.id, !entry.isFavorite),
          ),
          TvButton(
            label: 'Remove from library',
            icon: Icons.playlist_remove_rounded,
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Remove from library?'),
                  content: const Text(
                      'The game is removed from GAMEBOX only. The original file stays on your storage.'),
                  actions: [
                    TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await s.db.removeGameFromLibrary(g.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ]),
        const SizedBox(height: 22),
        if (estimate != null) ...[
          const SectionHeader('Compatibility on this device'),
          Row(children: [
            StatusChip(estimate.rating.label, color: _ratingColor(context, estimate.rating)),
            const SizedBox(width: 10),
            Expanded(child: Text('${estimate.evidence.label}. ${estimate.reasons.join(' ')}',
                style: t.bodyMedium?.copyWith(color: Colors.white70))),
          ]),
          const SizedBox(height: 18),
        ],
        FutureBuilder(
          future: Future.wait([s.db.metadataForGame(g.id), s.db.filesForGame(g.id)]),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final meta = snap.data![0] as GameMetadataRow?;
            final files = snap.data![1] as List<GameFileRow>;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader('Information'),
              InfoRow('Developer', meta?.developer),
              InfoRow('Publisher', meta?.publisher),
              InfoRow('Release date', meta?.releaseDate),
              InfoRow('Genre', meta?.genre),
              InfoRow('Players', meta?.players),
              if (meta?.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(meta!.description!, style: t.bodyLarge),
                ),
              const SizedBox(height: 18),
              const SectionHeader('Files'),
              if (files.isEmpty) const Text('No files recorded.', style: TextStyle(color: Colors.white60)),
              for (final f in files)
                InfoRow(f.fileExists ? 'File' : 'File (MISSING)',
                    '${f.displayPath} · ${formatBytes(f.sizeBytes)}${f.sha1 != null ? ' · SHA-1 ${f.sha1}' : ''}'),
            ]);
          },
        ),
      ]),
    );
  }
}

Color _ratingColor(BuildContext context, CompatibilityRating r) {
  final p = GameboxPalette.of(context);
  return switch (r) {
    CompatibilityRating.excellent => p.success,
    CompatibilityRating.good => const Color(0xFF64DD17),
    CompatibilityRating.limited => p.warning,
    CompatibilityRating.unsupported => p.danger,
    CompatibilityRating.notTested => Colors.white60,
  };
}

Color ratingColor(BuildContext context, CompatibilityRating r) => _ratingColor(context, r);
