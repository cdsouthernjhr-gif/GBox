import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../../core/storage/gamebox_layout.dart';
import '../rom_manager/rom_search_service.dart';

/// Finds ROMs anywhere on the device and sorts them into `ROMs/<system>/`.
class RomSearchScreen extends StatefulWidget {
  const RomSearchScreen({super.key});

  @override
  State<RomSearchScreen> createState() => _RomSearchScreenState();
}

class _RomSearchScreenState extends State<RomSearchScreen> {
  final _selected = <RomSearchHit>{};
  bool _move = false;
  bool _busy = false;
  String? _message;

  Future<void> _search() async {
    final s = servicesOf(context);
    setState(() {
      _selected.clear();
      _message = null;
    });
    final r = await s.romSearch.search();
    if (!mounted) return;
    setState(() => _selected.addAll(r.hits.where((h) => h.consoleId != null)));
  }

  Future<void> _organise() async {
    final s = servicesOf(context);
    final list = _selected.where((h) => h.consoleId != null).toList();
    if (list.isEmpty) return;
    final summary = OrganiseSummary.of(list);
    final free = await s.location.freeSpace();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => _SummaryDialog(summary: summary, freeBytes: free, move: _move),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await s.romSearch.organise(list, move: _move);
    s.refreshPlaylistsSoon();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _selected.removeAll(list);
      _message = '${r.placed} game(s) ${_move ? 'moved' : 'copied'} into ROMs and added to the library'
          '${r.failed.isEmpty ? '' : ' · ${r.failed.length} failed: ${r.failed.first}'}';
    });
  }

  Future<void> _chooseConsole(RomSearchHit h) async {
    final ids = h.candidates.isNotEmpty ? h.candidates : [for (final c in allConsoles) c.id];
    final picked = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text('Which console is "${h.primary.name}"?'),
        children: [
          for (final (i, id) in ids.indexed)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, id),
              child: Text(consoleById(id)!.name, style: TextStyle(fontWeight: i == 0 ? FontWeight.w700 : null)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() {
      h.consoleId = picked;
      _selected.add(h);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          title: 'Find ROMs on this device',
          subtitle: 'Searches internal storage, SD cards and USB drives (Download, WhatsApp, Telegram, …) and '
              'sorts games into ROMs/<system>/ for GAMEBOX, RetroArch and other emulators.',
          actions: [
            ValueListenableBuilder<RomSearchProgress>(
              valueListenable: s.romSearch.progress,
              builder: (_, p, _) => TvButton(
                label: p.running ? 'Stop' : 'Search',
                icon: p.running ? Icons.stop_rounded : Icons.travel_explore_rounded,
                autofocus: true,
                primary: !p.running,
                onPressed: p.running ? s.romSearch.cancel : _search,
              ),
            ),
            TvButton(label: 'Back', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop()),
          ],
          child: ValueListenableBuilder<RomSearchProgress>(
            valueListenable: s.romSearch.progress,
            builder: (context, p, _) {
              if (p.running) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text('Searching… ${p.found} possible game files', style: const TextStyle(color: Colors.white70)),
                  Text(p.folder, style: const TextStyle(color: Colors.white38, fontSize: 12), overflow: TextOverflow.ellipsis),
                ]);
              }
              return ValueListenableBuilder<RomSearchResult?>(
                valueListenable: s.romSearch.last,
                builder: (context, r, _) {
                  if (r == null) {
                    return const Text('Press Search. Nothing is moved until you choose.',
                        style: TextStyle(color: Colors.white60));
                  }
                  if (r.needsAccess) {
                    return const Text(
                        'Searching the device needs storage access. Open the setup wizard (SETTINGS → Storage → Setup wizard) '
                        'and allow "All files access" for GAMEBOX.',
                        style: TextStyle(color: Colors.orangeAccent));
                  }
                  final ready = r.hits.where((h) => h.consoleId != null).toList();
                  final unknown = r.hits.where((h) => h.consoleId == null).toList();
                  final groups = groupHitsByConsole(ready);
                  final chosen = OrganiseSummary.of(_selected);
                  return ListView(children: [
                    Text(
                      '${r.hits.length} new game(s) found in ${r.foldersSearched} folders · '
                      '${r.alreadyInLibrary} already in the library'
                      '${r.truncated ? ' · search stopped early' : ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (_message != null) Text(_message!, style: TextStyle(color: palette.success)),
                    if (chosen.games > 0)
                      Text(
                        'Selected: ${chosen.games} game(s), ${formatBytes(chosen.bytes)} in '
                        '${chosen.perConsole.length} console folder(s)',
                        key: const ValueKey('search-selection'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 8),
                    Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      TvButton(
                        label: _busy ? 'Working…' : '${_move ? 'Move' : 'Copy'} ${chosen.games} to ROMs…',
                        icon: Icons.drive_file_move_rounded,
                        primary: true,
                        onPressed: _busy || chosen.games == 0 ? null : _organise,
                      ),
                      TvButton(
                        label: _move ? 'Mode: move (original removed)' : 'Mode: copy (original kept)',
                        icon: Icons.swap_horiz_rounded,
                        onPressed: () => setState(() => _move = !_move),
                      ),
                      TvButton(
                        label: 'Select all identified',
                        onPressed: () => setState(() => _selected.addAll(ready)),
                      ),
                      TvButton(label: 'Select none', onPressed: () => setState(_selected.clear)),
                    ]),
                    // One section per console, with its destination folder.
                    for (final (console, hits) in groups) ...[
                      SectionHeader(
                        '${consoleById(console)?.name ?? console} · ${hits.length}',
                        subtitle: '→ ${gamesDirFor(console)}/   '
                            '(${hits.where(_selected.contains).length} selected)',
                        trailing: Wrap(spacing: 8, children: [
                          TvButton(
                            label: 'All',
                            onPressed: () => setState(() => _selected.addAll(hits)),
                          ),
                          TvButton(
                            label: 'None',
                            onPressed: () => setState(() => _selected.removeAll(hits)),
                          ),
                        ]),
                      ),
                      for (final h in hits) _hitTile(h, palette),
                    ],
                    if (unknown.isNotEmpty)
                      SectionHeader('Needs a console (${unknown.length})',
                          subtitle: 'The file type fits several consoles. Select a file to choose its console.'),
                    for (final h in unknown) _hitTile(h, palette),
                  ]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hitTile(RomSearchHit h, GameboxPalette palette) {
    final selected = _selected.contains(h);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TvFocusable(
        scale: 1.01,
        padding: const EdgeInsets.all(10),
        onSelect: () {
          if (h.consoleId == null) {
            _chooseConsole(h);
          } else {
            setState(() => selected ? _selected.remove(h) : _selected.add(h));
          }
        },
        onLongPress: () => _chooseConsole(h),
        child: Row(children: [
          Icon(h.consoleId == null
              ? Icons.help_outline_rounded
              : (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.title, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              Text(
                '${h.primary.name}${h.files.length > 1 ? ' + ${h.files.length - 1} file(s)' : ''} · '
                '${formatBytes(h.totalSize)} · ${h.folder}',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          if (h.consoleId != null)
            StatusChip('${consoleById(h.consoleId!)!.name}${h.how.isEmpty ? '' : ' · ${h.how}'}', color: palette.success)
          else
            StatusChip('Choose console', color: palette.warning),
        ]),
      ),
    );
  }
}

/// What will be copied or moved, per console, and whether it fits.
class _SummaryDialog extends StatelessWidget {
  const _SummaryDialog({required this.summary, required this.freeBytes, required this.move});
  final OrganiseSummary summary;
  final int? freeBytes;
  final bool move;

  @override
  Widget build(BuildContext context) {
    final fits = summary.fits(freeBytes, move: move);
    final rows = summary.perConsole.entries.toList()..sort((a, b) => b.value.$1.compareTo(a.value.$1));
    return AlertDialog(
      title: Text('${move ? 'Move' : 'Copy'} ${summary.games} game(s) to ROMs?'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final e in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Expanded(child: Text('${consoleById(e.key)?.name ?? e.key}: ${e.value.$1} game(s)')),
                  Text('${formatBytes(e.value.$2)}  →  ${gamesDirFor(e.key)}/',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70)),
                ]),
              ),
            const Divider(),
            Text('Total: ${formatBytes(summary.bytes)}'),
            Text(freeBytes == null ? 'Free space: unknown' : 'Free space: ${formatBytes(freeBytes)}'),
            Text(
              move
                  ? 'The original files are moved (removed from where they are now).'
                  : 'The original files are kept; copies go into the ROMs folders.',
              style: const TextStyle(color: Colors.white60, fontSize: 12.5),
            ),
            if (!fits)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Not enough free space for these copies. Select fewer games, or use Move.',
                    style: TextStyle(color: Colors.orangeAccent)),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(autofocus: true, onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: fits ? () => Navigator.pop(context, true) : null,
          child: Text(move ? 'Move' : 'Copy'),
        ),
      ],
    );
  }
}

