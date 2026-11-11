import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../rom_manager/rom_library_service.dart';
import 'library_screens.dart';

/// My Games: offline library with search, console filter, favourites/missing
/// filters, sorting, folder scan and manual import.
class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _console;
  bool _favoritesOnly = false;
  bool _missingOnly = false;
  GameSort? _sort;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _sortKey(GameSort s) => switch (s) {
        GameSort.title => 'title',
        GameSort.recentlyPlayed => 'recentlyPlayed',
        GameSort.recentlyAdded => 'recentlyAdded',
      };

  String _sortLabel(GameSort s) => switch (s) {
        GameSort.title => 'Sort: Title',
        GameSort.recentlyPlayed => 'Sort: Recently played',
        GameSort.recentlyAdded => 'Sort: Recently added',
      };

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final sort = _sort ?? s.settings.state.value.gameSort;
    return PageFrame(
      title: 'My Games',
      subtitle: 'Your local library — available offline',
      actions: [
        TvButton(label: 'Import files', icon: Icons.file_open_rounded, onPressed: () => importFiles(context)),
        ValueListenableBuilder<ScanProgress>(
          valueListenable: s.library.progress,
          builder: (_, p, _) => TvButton(
            label: p.running ? 'Scanning…' : 'Scan folders',
            icon: Icons.manage_search_rounded,
            onPressed: p.running ? null : () => s.library.scanAll(),
          ),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search games',
                filled: true,
                fillColor: GameboxPalette.of(context).card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(width: 10),
          _Chip(label: _sortLabel(sort), onSelect: () {
            final next = GameSort.values[(sort.index + 1) % GameSort.values.length];
            setState(() => _sort = next);
            s.settings.set(SettingsKeys.gameSort, next.name);
          }),
          _Chip(
            label: 'Favourites',
            selected: _favoritesOnly,
            onSelect: () => setState(() => _favoritesOnly = !_favoritesOnly),
          ),
          _Chip(
            label: 'Missing',
            selected: _missingOnly,
            onSelect: () => setState(() => _missingOnly = !_missingOnly),
          ),
        ]),
        const SizedBox(height: 8),
        StreamBuilder<Map<String, int>>(
          stream: s.db.watchGameCountsByConsole(),
          builder: (context, snap) {
            final counts = snap.data ?? const {};
            if (counts.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 46,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _Chip(
                  label: 'All (${counts.values.fold(0, (a, b) => a + b)})',
                  selected: _console == null,
                  onSelect: () => setState(() => _console = null),
                ),
                for (final c in consoleCatalog)
                  if (counts[c.id] != null)
                    _Chip(
                      label: '${c.name} (${counts[c.id]})',
                      selected: _console == c.id,
                      onSelect: () => setState(() => _console = c.id),
                    ),
              ]),
            );
          },
        ),
        const ScanStatusBanner(),
        Expanded(
          child: GameGrid(
            stream: s.db.watchLibrary(
              query: _query,
              consoleId: _console,
              favoritesOnly: _favoritesOnly,
              missingOnly: _missingOnly,
              sort: _sortKey(sort),
            ),
            empty: EmptyState(
              icon: Icons.sports_esports_outlined,
              title: _query.isNotEmpty || _favoritesOnly || _missingOnly || _console != null
                  ? 'No games match'
                  : 'No games in your library yet',
              message: 'Copy legally owned games into the GAMEBOX/Games/<console> folders '
                  '(see STORAGE), register your own folders, or use "Import files".',
            ),
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onSelect, this.selected = false});
  final String label;
  final VoidCallback onSelect;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 6),
        child: TvFocusable(
          borderRadius: 24,
          scale: 1.05,
          color: selected ? GameboxPalette.of(context).accent : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          onSelect: onSelect,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      );
}

/// Progress of the running scan, or a summary of the last one.
class ScanStatusBanner extends StatelessWidget {
  const ScanStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return ValueListenableBuilder<ScanProgress>(
      valueListenable: s.library.progress,
      builder: (context, p, _) {
        if (!p.running && p.finishedAt == null) return const SizedBox.shrink();
        final unavailable = p.results.where((r) => !r.available).toList();
        final text = p.running
            ? '${p.stage}${p.current != null ? ': ${p.current}' : ''}…'
            : 'Last scan ${formatRelative(p.finishedAt)}: ${p.totalImported} added, '
                '${p.totalMissing} missing, ${p.totalUnresolved} not recognised'
                '${unavailable.isEmpty ? '' : ', ${unavailable.length} folder(s) unavailable'}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TvFocusable(
            scale: 1.0,
            color: palette.surface,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onSelect: p.running ? null : () => showScanDetails(context, p),
            child: Row(children: [
              if (p.running)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(Icons.info_outline_rounded, size: 18, color: palette.focus),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5))),
              if (!p.running) const Text('Details', style: TextStyle(fontSize: 12, color: Colors.white54)),
            ]),
          ),
        );
      },
    );
  }
}

void showScanDetails(BuildContext context, ScanProgress p) {
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Library scan'),
      content: SizedBox(
        width: 560,
        child: ListView(shrinkWrap: true, children: [
          for (final r in p.results) ...[
            Text(r.root.label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              r.available
                  ? '${r.filesSeen} files · ${r.imported} added · ${r.alreadyKnown} already in library · '
                      '${r.missing} missing${r.truncated ? ' · stopped at file limit' : ''}'
                  : 'Unavailable: ${r.error ?? 'unknown reason'} (files were not marked missing)',
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
            if (r.unresolved.isNotEmpty)
              Text(
                'Not recognised (put them in a console folder, or use Import files and choose '
                'the console): ${r.unresolved.take(8).map((u) => u.displayPath).join(', ')}'
                '${r.unresolved.length > 8 ? ' … (+${r.unresolved.length - 8})' : ''}',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
            const SizedBox(height: 10),
          ],
        ]),
      ),
      actions: [TextButton(autofocus: true, onPressed: () => Navigator.pop(c), child: const Text('Close'))],
    ),
  );
}

/// Manual ROM import via the system file picker.
Future<void> importFiles(BuildContext context) async {
  final s = servicesOf(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final uris = await s.gateway.pickFiles();
    if (uris.isEmpty) return;
    final r = await s.library.importPicked(uris);
    var imported = r.imported;
    if (r.needsConsole.isNotEmpty && context.mounted) {
      final consoleId = await chooseConsole(context, r.needsConsole);
      if (consoleId != null) imported += await s.library.importWithConsole(r.needsConsole, consoleId);
    }
    messenger.showSnackBar(SnackBar(
        content: Text('$imported game(s) added'
            '${r.alreadyKnown > 0 ? ', ${r.alreadyKnown} already in library' : ''}.')));
  } on PlatformException catch (e) {
    messenger.showSnackBar(SnackBar(
        content: Text(e.code == 'saf_unavailable'
            ? 'This device has no system file picker. Copy games into the GAMEBOX/Games folders instead (see STORAGE).'
            : 'Import failed: ${e.message}')));
  }
}

Future<String?> chooseConsole(BuildContext context, List<ScannedEntry> files) {
  final ext = files.map((f) => f.extension).toSet();
  final candidates = consoleCatalog.where((c) => c.extensions.any(ext.contains)).toList();
  final list = candidates.isEmpty ? consoleCatalog : candidates;
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Which console are these for?'),
      content: SizedBox(
        width: 480,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(files.take(4).map((f) => f.name).join('\n') + (files.length > 4 ? '\n…' : ''),
              style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (i, con) in list.indexed)
              TvButton(label: con.name, autofocus: i == 0, onPressed: () => Navigator.pop(c, con.id)),
          ]),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Skip'))],
    ),
  );
}

/// Used by tests and the game detail page.
String headerLabel(GameFileRow f) => switch (f.headerStatus) {
      'valid' => 'Header OK',
      'invalid' => 'Header INVALID',
      'notChecked' => 'Header not checkable',
      _ => 'Not verified yet',
    };
