import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/online/download_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../source_manager/sources_view.dart';
import 'download_service.dart';

/// Download dashboard (Phase 5) with the Online Source Manager as a second
/// view. Only legally authorised content; nothing is ever executed.
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _sources = false;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: _sources ? 'Game sources' : 'Downloads',
      subtitle: 'Authorised downloads only — files are never executed',
      actions: [
        TvButton(
          label: _sources ? 'Show downloads' : 'Sources',
          icon: _sources ? Icons.download_rounded : Icons.public_rounded,
          onPressed: () => setState(() => _sources = !_sources),
        ),
        if (_sources)
          TvButton(label: 'Add source', icon: Icons.add_link_rounded, onPressed: () => showAddSourceDialog(context))
        else
          TvButton(label: 'Add download', icon: Icons.add_rounded, onPressed: () => showAddDownloadDialog(context)),
      ],
      child: _sources ? const SourcesView() : const _QueueView(),
    );
  }
}

class _QueueView extends StatelessWidget {
  const _QueueView();

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return StreamBuilder<List<DownloadQueueRow>>(
      stream: s.db.watchDownloadQueue(),
      builder: (context, snap) {
        final items = snap.data ?? const [];
        return ListView(children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: EmptyState(
                icon: Icons.download_outlined,
                title: 'No downloads',
                message: 'Add a direct HTTPS file link you are allowed to download, or add a homebrew / '
                    'public-domain catalogue under Sources.',
              ),
            ),
          for (final d in items) _DownloadTile(d),
          const SizedBox(height: 16),
          const SectionHeader('History'),
          StreamBuilder<List<DownloadHistoryRow>>(
            stream: s.db.watchDownloadHistory(limit: 20),
            builder: (context, h) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if ((h.data ?? const []).isEmpty) const Text('No history yet.', style: TextStyle(color: Colors.white54)),
              for (final r in h.data ?? const <DownloadHistoryRow>[])
                InfoRow(formatDateTime(r.finishedAt),
                    '${r.status.toUpperCase()} · ${r.name}${r.errorMessage != null ? ' · ${r.errorMessage}' : ''}'),
            ]),
          ),
        ]);
      },
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile(this.d);
  final DownloadQueueRow d;

  Color _statusColor(BuildContext context) {
    final p = GameboxPalette.of(context);
    return switch (d.status) {
      'completed' => p.success,
      'downloading' => p.focus,
      'failed' => p.danger,
      'paused' || 'cancelled' => Colors.white54,
      _ => p.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final t = Theme.of(context).textTheme;
    void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: GameboxPalette.of(context).card, borderRadius: BorderRadius.circular(12)),
        child: ValueListenableBuilder<Map<int, DownloadProgress>>(
          valueListenable: s.downloads.live,
          builder: (context, live, _) {
            final p = live[d.id];
            final received = p?.received ?? d.downloadedBytes;
            final total = p?.total ?? d.totalBytes;
            final fraction = total == null || total == 0 ? null : received / total;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(d.name, style: t.titleMedium),
                StatusChip(d.status.toUpperCase(), color: _statusColor(context)),
                if (d.consoleId != null) StatusChip(consoleById(d.consoleId!)?.name ?? d.consoleId!, color: Colors.white54),
                if (d.importedGameId != null) const StatusChip('IN LIBRARY', color: Colors.greenAccent),
              ]),
              const SizedBox(height: 6),
              if (d.status == 'downloading' || d.status == 'paused' || d.status == 'queued')
                LinearProgressIndicator(value: d.status == 'queued' && received == 0 ? null : fraction, minHeight: 6),
              const SizedBox(height: 4),
              Text(
                [
                  '${formatBytes(received)} / ${total == null ? 'size unknown' : formatBytes(total)}',
                  if (p != null && p.bytesPerSecond > 0) '${formatBytes(p.bytesPerSecond.round())}/s',
                  if (p?.eta != null) '${p!.eta!.inMinutes}m ${p.eta!.inSeconds % 60}s left',
                  if (d.expectedHash != null) 'SHA-256 checked',
                ].join(' · '),
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text('From ${Uri.parse(d.url).host} → ${d.filePath ?? d.destination}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.white54), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (d.errorMessage != null)
                Text(d.errorMessage!, style: TextStyle(fontSize: 12, color: GameboxPalette.of(context).danger)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (d.status == 'downloading' || d.status == 'queued')
                  TvButton(label: 'Pause', onPressed: () => s.downloads.pause(d.id)),
                if (d.status == 'paused') TvButton(label: 'Resume', onPressed: () => s.downloads.resume(d.id)),
                if (d.status == 'downloading' || d.status == 'queued' || d.status == 'paused')
                  TvButton(label: 'Cancel', onPressed: () => s.downloads.cancel(d.id)),
                if (d.status == 'failed') TvButton(label: 'Retry', onPressed: () => s.downloads.retry(d.id)),
                if (d.status == 'completed' && d.importedGameId == null)
                  TvButton(
                    label: 'Import into library',
                    primary: true,
                    onPressed: () async {
                      var r = await s.downloads.importIntoLibrary(d.id);
                      if (r.needsConsole && context.mounted) {
                        final console = await chooseConsoleForFile(context, d.filePath ?? d.name);
                        if (console == null) return;
                        r = await s.downloads.importIntoLibrary(d.id, consoleId: console);
                      }
                      snack(r.error ?? (r.gameIds.isEmpty ? 'Nothing to import' : '${r.gameIds.length} game(s) added'));
                    },
                  ),
                if (d.status == 'completed' && d.filePath != null)
                  TvButton(
                    label: 'Show location',
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('File location'),
                        content: SelectableText('${d.filePath}\n\nSHA-256: ${d.sha256 ?? 'n/a'}'),
                        actions: [TextButton(autofocus: true, onPressed: () => Navigator.pop(c), child: const Text('Close'))],
                      ),
                    ),
                  ),
                if (d.status != 'downloading')
                  TvButton(
                    label: d.status == 'completed' ? 'Delete file' : 'Remove',
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(d.status == 'completed' ? 'Delete downloaded file?' : 'Remove from list?'),
                          content: Text(d.importedGameId != null
                              ? 'The game will become "missing" in your library.'
                              : 'This cannot be undone.'),
                          actions: [
                            TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) await s.downloads.remove(d.id);
                    },
                  ),
              ]),
            ]);
          },
        ),
      ),
    );
  }
}

Future<String?> chooseConsoleForFile(BuildContext context, String path) {
  final list = DownloadService.consolesForFile(path);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Which console is this game for?'),
      content: SizedBox(
        width: 480,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (i, con) in list.indexed)
            TvButton(label: con.name, autofocus: i == 0, onPressed: () => Navigator.pop(c, con.id)),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel'))],
    ),
  );
}

Future<void> showAddDownloadDialog(BuildContext context) async {
  final s = servicesOf(context);
  final url = TextEditingController();
  final sha = TextEditingController();
  String? console;
  var confirmed = false;
  String? error;
  await showDialog<void>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: const Text('Add download'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: url,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Direct file link (https://…)'),
              ),
              TextField(
                controller: sha,
                decoration: const InputDecoration(labelText: 'Expected SHA-256 (optional, recommended)'),
              ),
              const SizedBox(height: 10),
              TvButton(
                label: 'Console: ${console == null ? 'Detect automatically' : consoleById(console!)!.name}',
                onPressed: () => setState(() {
                  final ids = [null, ...consoleCatalog.map((e) => e.id)];
                  console = ids[(ids.indexOf(console) + 1) % ids.length];
                }),
              ),
              const SizedBox(height: 8),
              TvFocusable(
                scale: 1.0,
                color: Colors.transparent,
                padding: const EdgeInsets.all(6),
                onSelect: () => setState(() => confirmed = !confirmed),
                child: Row(children: [
                  Icon(confirmed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('I own this file or it is licensed to me / freely distributable (homebrew, public domain).'),
                  ),
                ]),
              ),
              if (error != null) Text(error!, style: const TextStyle(color: Colors.redAccent)),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (!confirmed) {
                setState(() => error = 'Please confirm you are allowed to download this file.');
                return;
              }
              try {
                await s.downloads.enqueue(url: url.text, consoleId: console, expectedSha256: sha.text.isEmpty ? null : sha.text);
                if (c.mounted) Navigator.pop(c);
              } on ArgumentError catch (e) {
                setState(() => error = '${e.message}');
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    ),
  );
  url.dispose();
  sha.dispose();
}
