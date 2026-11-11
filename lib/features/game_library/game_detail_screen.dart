import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../domain/entities/performance_tier.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../emulator_manager/launch_dialogs.dart';
import 'my_games_screen.dart' show headerLabel;

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
                  action: TvButton(label: 'Back', autofocus: true, onPressed: () => Navigator.pop(context)),
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

class _Body extends StatefulWidget {
  const _Body({required this.entry});
  final GameWithStatus entry;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  // Bumped to reload files/metadata after an action.
  int _rev = 0;
  bool _busy = false;

  GameRow get g => widget.entry.game;

  void _snack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() => _run(() async {
        final s = servicesOf(context);
        final files = await s.db.filesForGame(g.id);
        final lines = <String>[];
        for (final f in files) {
          final r = await s.library.verifyFile(f);
          lines.add('${f.displayPath.split('/').last}: ${r.header.detail}'
              '${r.file.sha1 != null ? '\nSHA-1 ${r.file.sha1}  CRC32 ${r.file.crc32}' : ''}'
              '${r.hashError != null ? '\nHash failed: ${r.hashError}' : ''}'
              '${r.duplicates.isNotEmpty ? '\nDuplicate of: ${r.duplicates.map((d) => d.displayPath).join(', ')}' : ''}');
        }
        setState(() => _rev++);
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('File verification'),
            content: SingleChildScrollView(child: Text(lines.join('\n\n'), style: const TextStyle(fontSize: 13))),
            actions: [TextButton(autofocus: true, onPressed: () => Navigator.pop(c), child: const Text('Close'))],
          ),
        );
      });

  Future<void> _setCover() => _run(() async {
        final s = servicesOf(context);
        try {
          final uri = await s.gateway.pickImage();
          if (uri == null) return;
          final ok = await s.library.importCover(g.id, uri);
          _snack(ok ? 'Artwork updated' : 'That file could not be read as an image');
        } on PlatformException catch (e) {
          _snack(e.code == 'saf_unavailable'
              ? 'No system file picker on this device. Put a matching image next to the game or in GAMEBOX/Artwork/Covers.'
              : 'Could not pick image: ${e.message}');
        }
      });

  Future<void> _edit() async {
    final s = servicesOf(context);
    final meta = await s.db.metadataForGame(g.id);
    if (!mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (c) => _EditDialog(game: g, meta: meta),
    );
    if (saved == true) setState(() => _rev++);
  }

  Future<void> _delete() async {
    final s = servicesOf(context);
    final files = await s.db.filesForGame(g.id);
    if (!mounted) return;
    Future<bool?> confirm(String title, String body, String yes) => showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(c, true), child: Text(yes, style: const TextStyle(color: Colors.redAccent))),
            ],
          ),
        );
    final first = await confirm(
      'Delete game files?',
      'This permanently deletes ${files.length} file(s) from your storage:\n'
          '${files.map((f) => f.displayPath).join('\n')}\n\nTo keep the files, use "Remove from library" instead.',
      'Delete files',
    );
    if (first != true || !mounted) return;
    final second = await confirm('Are you sure?', 'This cannot be undone.', 'Yes, delete permanently');
    if (second != true) return;
    final failed = await s.library.deleteGameAndFiles(g.id);
    if (failed.isEmpty) {
      if (mounted) Navigator.pop(context);
      _snack('Game files deleted');
    } else {
      _snack('Could not delete: ${failed.join(', ')} (no write access?). The game was kept in the library.');
    }
  }

  Future<void> _removeFromLibrary() async {
    final s = servicesOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove from library?'),
        content: const Text(
            'The game is removed from GAMEBOX only. The original file stays on your storage '
            '(it will be added again by the next folder scan unless you move it).'),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await s.db.removeGameFromLibrary(g.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final console = consoleById(g.consoleId);
    final t = Theme.of(context).textTheme;
    final dev = s.device.state.value;
    final estimate = (console != null && dev.profile != null && dev.classification != null)
        ? s.device.classifier.estimate(dev.profile!, dev.classification!, console)
        : null;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StreamBuilder<Map<int, String>>(
            stream: s.db.watchCoverPaths(),
            builder: (context, snap) {
              final path = snap.data?[g.id];
              return Container(
                width: 180,
                height: 240,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: GameboxPalette.of(context).card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: path != null && File(path).existsSync()
                    ? Image.file(File(path), fit: BoxFit.cover, cacheWidth: 360)
                    : const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.white30)),
              );
            },
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.title, style: t.displaySmall),
              const SizedBox(height: 4),
              Text(
                '${console?.name ?? g.consoleId}${g.regions != null ? ' · ${g.regions}' : ''} · '
                'Added ${formatDateTime(g.addedAt)} · Played ${g.playCount}× · '
                'Last played ${formatRelative(g.lastPlayedAt)}',
                style: t.bodyLarge?.copyWith(color: Colors.white70),
              ),
              if (g.isMissing)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: StatusChip('FILE MISSING — reconnect its storage or rescan', color: Colors.orangeAccent),
                ),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: [
                TvButton(
                  autofocus: true,
                  primary: true,
                  label: 'Play',
                  icon: Icons.play_arrow_rounded,
                  onPressed: g.isMissing || _busy ? null : () => playGame(context, g),
                ),
                TvButton(
                  label: 'Play with…',
                  icon: Icons.tune_rounded,
                  onPressed: g.isMissing || _busy ? null : () => playGameWith(context, g),
                ),
                TvButton(
                  label: widget.entry.isFavorite ? 'Remove favourite' : 'Add to favourites',
                  icon: widget.entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  onPressed: () => s.db.setFavorite(g.id, !widget.entry.isFavorite),
                ),
                TvButton(label: 'Verify file', icon: Icons.verified_rounded, onPressed: _busy ? null : _verify),
                TvButton(label: 'Choose artwork', icon: Icons.image_rounded, onPressed: _busy ? null : _setCover),
                TvButton(label: 'Edit info', icon: Icons.edit_rounded, onPressed: _edit),
                TvButton(label: 'Remove from library', icon: Icons.playlist_remove_rounded, onPressed: _removeFromLibrary),
                TvButton(label: 'Delete files…', icon: Icons.delete_forever_rounded, onPressed: _delete),
              ]),
              if (_busy) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator()),
            ]),
          ),
        ]),
        const SizedBox(height: 22),
        if (estimate != null) ...[
          const SectionHeader('Compatibility on this device'),
          Row(children: [
            StatusChip(estimate.rating.label, color: ratingColor(context, estimate.rating)),
            const SizedBox(width: 10),
            Expanded(
                child: Text('${estimate.evidence.label}. ${estimate.reasons.join(' ')}',
                    style: t.bodyMedium?.copyWith(color: Colors.white70))),
          ]),
          const SizedBox(height: 18),
        ],
        FutureBuilder(
          key: ValueKey(_rev),
          future: Future.wait([s.db.metadataForGame(g.id), s.db.filesForGame(g.id)]),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final meta = snap.data![0] as GameMetadataRow?;
            final files = snap.data![1] as List<GameFileRow>;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionHeader('Information',
                  subtitle: meta?.editedManually == true ? 'Edited manually' : 'Online metadata arrives in Phase 5'),
              InfoRow('Developer', meta?.developer),
              InfoRow('Publisher', meta?.publisher),
              InfoRow('Release date', meta?.releaseDate),
              InfoRow('Genre', meta?.genre),
              if (meta?.description != null)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text(meta!.description!, style: t.bodyLarge)),
              const SizedBox(height: 18),
              const SectionHeader('Files'),
              if (files.isEmpty) const Text('No files recorded.', style: TextStyle(color: Colors.white60)),
              for (final f in files)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${f.isPrimary ? '' : 'Disc ${f.discNumber ?? '?'} · '}${f.displayPath}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: f.fileExists ? Colors.white : Colors.orangeAccent)),
                    Text(
                      '${formatBytes(f.sizeBytes)} · ${headerLabel(f)}'
                      '${f.headerDetail != null ? ' (${f.headerDetail})' : ''}'
                      '${f.sha1 != null ? ' · SHA-1 ${f.sha1}' : ''}'
                      '${f.fileExists ? '' : ' · MISSING'}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ]),
                ),
            ]);
          },
        ),
      ]),
    );
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.game, this.meta});
  final GameRow game;
  final GameMetadataRow? meta;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final title = TextEditingController(text: widget.game.title);
  late final developer = TextEditingController(text: widget.meta?.developer);
  late final publisher = TextEditingController(text: widget.meta?.publisher);
  late final release = TextEditingController(text: widget.meta?.releaseDate);
  late final genre = TextEditingController(text: widget.meta?.genre);
  late final description = TextEditingController(text: widget.meta?.description);

  @override
  void dispose() {
    for (final c in [title, developer, publisher, release, genre, description]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, TextEditingController c, {bool autofocus = false, int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: c,
          autofocus: autofocus,
          maxLines: lines,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return AlertDialog(
      title: const Text('Edit game info'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field('Title', title, autofocus: true),
            _field('Developer', developer),
            _field('Publisher', publisher),
            _field('Release date / year', release),
            _field('Genre', genre),
            _field('Description', description, lines: 3),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            final t = title.text.trim();
            if (t.isEmpty) return;
            await s.db.saveManualMetadata(
              widget.game.id,
              title: t,
              sortTitle: normalizeTitle('$t.x').sortTitle,
              developer: developer.text,
              publisher: publisher.text,
              releaseDate: release.text,
              genre: genre.text,
              description: description.text,
            );
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Color ratingColor(BuildContext context, CompatibilityRating r) {
  final p = GameboxPalette.of(context);
  return switch (r) {
    CompatibilityRating.excellent => p.success,
    CompatibilityRating.good => const Color(0xFF64DD17),
    CompatibilityRating.limited => p.warning,
    CompatibilityRating.unsupported => p.danger,
    CompatibilityRating.notTested => Colors.white60,
  };
}
