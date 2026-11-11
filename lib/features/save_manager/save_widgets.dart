import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/saves/save_classifier.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';

SaveKind _kind(String s) => SaveKind.values.firstWhere((k) => k.name == s, orElse: () => SaveKind.native);

/// Saves of one game, with backup / restore / export (game page).
class GameSavesSection extends StatelessWidget {
  const GameSavesSection({super.key, required this.gameId});
  final int gameId;

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    return StreamBuilder<List<SaveStateRow>>(
      stream: s.db.watchSavesForGame(gameId),
      builder: (context, snap) {
        final saves = snap.data ?? const [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('Saves',
              subtitle: 'Save states only work in the emulator (and usually the version) that created them.'),
          if (saves.isEmpty)
            const Text('No save files found. Register your emulator save folders under STORAGE → Save folders.',
                style: TextStyle(color: Colors.white60)),
          for (final sv in saves)
            InfoRow(
              '${_kind(sv.kind).label}${sv.slot != null && sv.slot! >= 0 ? ' · slot ${sv.slot}' : sv.slot == -1 ? ' · auto' : ''}',
              '${sv.relativePath ?? sv.path} · ${formatBytes(sv.sizeBytes)} · ${formatDateTime(sv.createdAt)}'
              '${sv.emulatorId != null ? ' · ${knownEmulators.where((e) => e.id == sv.emulatorId).firstOrNull?.name ?? sv.emulatorId}' : ''}',
            ),
          if (saves.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              TvButton(
                label: 'Back up saves',
                icon: Icons.backup_rounded,
                onPressed: () async => snack('${await s.saves.backupGame(gameId)} file(s) backed up'),
              ),
              TvButton(
                label: 'Restore…',
                icon: Icons.settings_backup_restore_rounded,
                onPressed: () => _restoreDialog(context, gameId),
              ),
              TvButton(
                label: 'Export saves',
                icon: Icons.ios_share_rounded,
                onPressed: () async {
                  final path = await s.saves.exportGame(gameId);
                  snack(path == null ? 'No saves to export' : 'Exported to $path');
                },
              ),
            ]),
          ],
        ]);
      },
    );
  }
}

Future<void> _restoreDialog(BuildContext context, int gameId) {
  final s = servicesOf(context);
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Restore a backup'),
      content: SizedBox(
        width: 560,
        height: 360,
        child: StreamBuilder<List<SaveBackupRow>>(
          stream: s.db.watchBackupsForGame(gameId),
          builder: (context, snap) {
            final list = snap.data ?? const [];
            if (list.isEmpty) return const Text('No backups yet.');
            return ListView(children: [
              const Text('The current save is copied to a new backup first, so a restore can be undone.',
                  style: TextStyle(fontSize: 12, color: Colors.white60)),
              for (final (i, b) in list.indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TvFocusable(
                    autofocus: i == 0,
                    scale: 1.01,
                    padding: const EdgeInsets.all(10),
                    onSelect: () async {
                      final r = await s.saves.restore(b.id);
                      if (c.mounted) Navigator.pop(c);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(r.ok ? 'Save restored' : r.message ?? 'Restore failed')));
                      }
                    },
                    child: Text(
                      '${formatDateTime(b.createdAt)} · ${b.backupPath.split('/').last} · ${formatBytes(b.sizeBytes)}'
                      '${b.note != null ? ' · ${b.note}' : ''}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
            ]);
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
    ),
  );
}

/// Registered save folders (Storage screen).
class SaveFoldersSection extends StatelessWidget {
  const SaveFoldersSection({super.key});

  Future<void> _add(BuildContext context) async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = await s.gateway.pickDirectory();
      if (uri == null || !context.mounted) return;
      final emulator = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Which emulator uses this save folder?'),
          content: SizedBox(
            width: 480,
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (i, e) in knownEmulators.indexed)
                TvButton(label: e.name, autofocus: i == 0, onPressed: () => Navigator.pop(c, e.id)),
            ]),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c, ''), child: const Text('Not sure'))],
        ),
      );
      await s.saves.addFolder(uri, emulator == null || emulator.isEmpty ? null : emulator);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final r = await s.saves.scan();
      messenger.showSnackBar(SnackBar(content: Text('${r.matched} save file(s) linked to games')));
    } on PlatformException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Folder picker unavailable: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return ValueListenableBuilder<SettingsState>(
      valueListenable: s.settings.state,
      builder: (context, st, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('Save folders',
            subtitle: 'Folders where your emulators keep saves (e.g. RetroArch/saves, PPSSPP/PSP/SAVEDATA). '
                'Grant access once; GAMEBOX can then back up and restore saves.'),
        for (final f in st.saveFolders)
          InfoRow(
              f.emulatorId == null ? 'Unknown emulator' : knownEmulators.where((e) => e.id == f.emulatorId).firstOrNull?.name ?? f.emulatorId!,
              Uri.decodeComponent(f.uri).split('/tree/').last),
        ValueListenableBuilder(
          valueListenable: s.saves.lastScan,
          builder: (context, r, _) => r == null
              ? const SizedBox.shrink()
              : Text(
                  'Last scan: ${r.found} save files, ${r.matched} linked to games'
                  '${r.unmatched.isEmpty ? '' : ', ${r.unmatched.length} not matched'}'
                  '${r.unavailable.isEmpty ? '' : ', ${r.unavailable.length} folder(s) unavailable'}',
                  style: TextStyle(fontSize: 12, color: GameboxPalette.of(context).muted),
                ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          TvButton(label: 'Add save folder', icon: Icons.create_new_folder_rounded, onPressed: () => _add(context)),
          if (st.saveFolders.isNotEmpty) ...[
            TvButton(label: 'Scan saves', onPressed: () => s.saves.scan()),
            TvButton(
              label: 'Back up all saves',
              onPressed: () async {
                final n = await s.saves.backupAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$n file(s) backed up')));
                }
              },
            ),
            for (final f in st.saveFolders)
              TvButton(
                label: 'Remove ${Uri.decodeComponent(f.uri).split('/').last}',
                onPressed: () => s.saves.removeFolder(f.uri),
              ),
          ],
        ]),
      ]),
    );
  }
}
