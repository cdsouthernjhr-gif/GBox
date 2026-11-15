import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../shared/widgets/tv_widgets.dart';
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
    final ids = h.candidates.isNotEmpty ? h.candidates : [for (final c in consoleCatalog) c.id];
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
                        'Searching the device needs storage access. Open the setup wizard (STORAGE → Setup wizard) '
                        'and allow "All files access" for GAMEBOX.',
                        style: TextStyle(color: Colors.orangeAccent));
                  }
                  final ready = r.hits.where((h) => h.consoleId != null).toList();
                  final unknown = r.hits.where((h) => h.consoleId == null).toList();
                  return ListView(children: [
                    Text(
                      '${r.hits.length} new game(s) found in ${r.foldersSearched} folders · '
                      '${r.alreadyInLibrary} already in the library'
                      '${r.truncated ? ' · search stopped early' : ''}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (_message != null) Text(_message!, style: TextStyle(color: palette.success)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      TvButton(
                        label: _busy
                            ? 'Working…'
                            : '${_move ? 'Move' : 'Copy'} ${_selected.where((h) => h.consoleId != null).length} to ROMs',
                        icon: Icons.drive_file_move_rounded,
                        primary: true,
                        onPressed: _busy || _selected.isEmpty ? null : _organise,
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
                    if (ready.isNotEmpty) SectionHeader('Identified (${ready.length})'),
                    for (final h in ready) _hitTile(h, palette),
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
