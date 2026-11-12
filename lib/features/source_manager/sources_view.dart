import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/online/catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
import 'source_service.dart';

class SourcesView extends StatelessWidget {
  const SourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return StreamBuilder<List<GameSourceRow>>(
      stream: s.db.watchSources(),
      builder: (context, snap) {
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.public_off_rounded,
            title: 'No sources',
            message: 'GAMEBOX includes no game sources. Add a homebrew or public-domain catalogue '
                '(GAMEBOX catalogue format), or a direct link to a file you are allowed to download. '
                'Websites are never scraped and logins are not supported.',
          );
        }
        return ListView(children: [for (final src in list) _SourceTile(src)]);
      },
    );
  }
}

class _SourceTile extends StatefulWidget {
  const _SourceTile(this.src);
  final GameSourceRow src;

  @override
  State<_SourceTile> createState() => _SourceTileState();
}

class _SourceTileState extends State<_SourceTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() f) async {
    setState(() => _busy = true);
    try {
      await f();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final src = widget.src;
    final type = SourceType.fromDb(src.type);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: GameboxPalette.of(context).card, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(src.name, style: t.titleMedium),
            StatusChip(type.label, color: Colors.white54),
            if (src.category != null) StatusChip(src.category!, color: Colors.white38),
          ]),
          Text(src.url, style: const TextStyle(fontSize: 12, color: Colors.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (src.description != null) Text(src.description!, style: const TextStyle(fontSize: 12.5)),
          Text(
            'Status: ${src.connectionStatus}${src.lastCheckedAt != null ? ' · checked ${formatRelative(src.lastCheckedAt)}' : ''}',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            TvButton(label: _busy ? 'Checking…' : 'Check connection', onPressed: _busy ? null : () => _run(() => s.sources.check(src.id))),
            if (type.isCatalog)
              TvButton(
                label: 'Browse games',
                primary: true,
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                          final r = await s.sources.browse(src.id);
                          if (context.mounted) await _showCatalog(context, src, r);
                        }),
              )
            else
              TvButton(
                label: 'Download file',
                primary: true,
                onPressed: () async {
                  try {
                    await s.downloads.enqueue(url: src.url, sourceId: src.id, name: src.name);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to downloads')));
                    }
                  } on ArgumentError catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.message}')));
                    }
                  }
                },
              ),
            TvButton(label: 'Delete source', onPressed: () => s.sources.remove(src.id)),
          ]),
        ]),
      ),
    );
  }
}

Future<void> _showCatalog(BuildContext context, GameSourceRow src, BrowseResult r) {
  final s = servicesOf(context);
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(r.name ?? src.name),
      content: SizedBox(
        width: 640,
        height: 420,
        child: r.error != null
            ? Text(r.error!, style: const TextStyle(color: Colors.redAccent))
            : ListView(children: [
                if (r.rejected.isNotEmpty)
                  Text('${r.rejected.length} entries hidden (insecure link, invalid checksum or unknown console).',
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                for (final (i, CatalogEntry e) in r.entries.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TvFocusable(
                      autofocus: i == 0,
                      scale: 1.01,
                      padding: const EdgeInsets.all(10),
                      onSelect: () async {
                        if (!e.licenseStated && !await _confirmUnlicensed(c, e)) return;
                        await s.downloads.enqueue(url: e.url.toString(), sourceId: src.id, entry: e);
                        if (c.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Downloading ${e.title}')));
                        }
                      },
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          '${consoleById(e.consoleId)?.name} · ${e.licenseStated ? 'Licence: ${e.license}' : 'Licence not stated'} · '
                          '${e.size == null ? 'size unknown' : formatBytes(e.size)}'
                          '${e.sha256 != null ? ' · SHA-256 verified' : ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        if (e.description != null)
                          Text(e.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      ]),
                    ),
                  ),
              ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
    ),
  );
}

/// Entries whose catalogue states no licence need the user's own
/// confirmation before downloading: GAMEBOX cannot verify the right to
/// download them.
Future<bool> _confirmUnlicensed(BuildContext context, CatalogEntry e) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('${e.title}: licence not stated'),
      content: const SizedBox(
        width: 520,
        child: Text('This catalogue does not say under which licence this game is distributed, so GAMEBOX '
            'cannot tell whether downloading it is allowed.\n\n'
            'Only continue if you own it, the developer offers it as a free download, or it is otherwise '
            'legal for you to download.'),
      ),
      actions: [
        TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('I am allowed, download')),
      ],
    ),
  );
  return ok == true;
}

Future<void> showAddSourceDialog(BuildContext context) async {
  final s = servicesOf(context);
  final name = TextEditingController();
  final url = TextEditingController();
  final desc = TextEditingController();
  var type = SourceType.homebrewRepo;
  var confirmed = false;
  String? error;
  await showDialog<void>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: const Text('Add game source'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: url, decoration: const InputDecoration(labelText: 'URL (https://…)')),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description (optional)')),
              const SizedBox(height: 10),
              TvButton(
                label: 'Type: ${type.label}',
                onPressed: () => setState(() => type = SourceType.values[(type.index + 1) % SourceType.values.length]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  type.isCatalog
                      ? 'The URL must return a GAMEBOX catalogue (JSON). Entries without a licence are shown as "Licence not stated".'
                      : 'The URL must point directly to one file (not a web page).',
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
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
                  const Expanded(child: Text('I am allowed to download the games this source offers.')),
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
              try {
                final id = await s.sources.add(
                    name: name.text, url: url.text, type: type, confirmedAuthorized: confirmed, description: desc.text);
                if (c.mounted) Navigator.pop(c);
                await s.sources.check(id);
              } on ArgumentError catch (e) {
                setState(() => error = '${e.message}');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
  name.dispose();
  url.dispose();
  desc.dispose();
}
