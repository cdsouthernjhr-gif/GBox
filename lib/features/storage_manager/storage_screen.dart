import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utilities/formatters.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../shared/widgets/tv_widgets.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  Future<void> _addFolder(BuildContext context) async {
    final s = servicesOf(context);
    try {
      final uri = await s.gateway.pickDirectory();
      if (uri == null) return;
      final current = s.settings.state.value.romFolders;
      if (!current.contains(uri)) await s.settings.setRomFolders([...current, uri]);
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'saf_unavailable'
            ? 'This device has no system folder picker (Storage Access Framework). '
                'See KNOWN_LIMITATIONS.md for alternatives.'
            : 'Folder picker failed: ${e.message}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Storage',
      subtitle: 'Internal storage, USB drives and SD cards',
      actions: [
        TvButton(label: 'Add game folder', icon: Icons.create_new_folder_rounded,
            onPressed: () => _addFolder(context)),
        TvButton(label: 'Rescan', icon: Icons.refresh_rounded, onPressed: () => s.storage.refresh()),
      ],
      child: ListView(children: [
        const SectionHeader('Storage devices'),
        ValueListenableBuilder<List<StorageVolumeInfo>>(
          valueListenable: s.storage.volumes,
          builder: (context, vols, _) {
            if (vols.isEmpty) {
              return const Text('Scanning storage…', style: TextStyle(color: Colors.white60));
            }
            return Wrap(spacing: 12, runSpacing: 12, children: [for (final v in vols) _VolumeCard(v)]);
          },
        ),
        const SizedBox(height: 18),
        const SectionHeader('Registered game folders',
            subtitle: 'Access is granted through Android\'s folder picker and kept across reboots.'),
        ValueListenableBuilder<SettingsState>(
          valueListenable: s.settings.state,
          builder: (context, st, _) {
            if (st.romFolders.isEmpty) {
              return const Text('No folders registered yet. Use "Add game folder".',
                  style: TextStyle(color: Colors.white60));
            }
            return Column(children: [
              for (final uri in st.romFolders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TvFocusable(
                    scale: 1.01,
                    padding: const EdgeInsets.all(12),
                    onSelect: () => _confirmRemove(context, uri),
                    child: Row(children: [
                      const Icon(Icons.folder_rounded),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_prettyTreeUri(uri), overflow: TextOverflow.ellipsis)),
                      const Text('Select to remove', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                  ),
                ),
            ]);
          },
        ),
        const SizedBox(height: 18),
        const SectionHeader('Recommended folder layout'),
        Text(
          'GAMEBOX/\n'
          '  Games/  ${consoleCatalog.map((c) => c.folderName).join('/  ')}/\n'
          '  Artwork/  Covers/  Screenshots/  Backgrounds/\n'
          '  Saves/  Backups/  Downloads/',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: Colors.white70),
        ),
      ]),
    );
  }

  Future<void> _confirmRemove(BuildContext context, String uri) async {
    final s = servicesOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove folder?'),
        content: const Text('GAMEBOX stops using this folder. No files are deleted.'),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    await s.gateway.releaseDirectory(uri);
    await s.settings.setRomFolders(s.settings.state.value.romFolders.where((u) => u != uri).toList());
  }
}

String _prettyTreeUri(String uri) {
  final decoded = Uri.decodeComponent(uri);
  final idx = decoded.indexOf('/tree/');
  return idx >= 0 ? decoded.substring(idx + 6) : decoded;
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard(this.v);
  final StorageVolumeInfo v;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final t = Theme.of(context).textTheme;
    final total = v.totalBytes, avail = v.availableBytes;
    final used = (total != null && avail != null && total > 0) ? (total - avail) / total : null;
    final icon = switch (v.kind) {
      StorageKind.internal => Icons.phone_android_rounded,
      StorageKind.sdCard => Icons.sd_card_rounded,
      StorageKind.usb => Icons.usb_rounded,
      StorageKind.unknown => Icons.storage_rounded,
    };
    return SizedBox(
      width: 300,
      child: TvFocusable(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: palette.focus),
            const SizedBox(width: 8),
            Expanded(child: Text(v.description, style: t.titleMedium, overflow: TextOverflow.ellipsis)),
            StatusChip(v.isMounted ? 'Connected' : v.state,
                color: v.isMounted ? palette.success : palette.warning),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: used, minHeight: 8, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          Text('${formatBytes(avail)} free of ${formatBytes(total)}',
              style: t.bodySmall?.copyWith(color: Colors.white70)),
          Text(
            '${v.isRemovable ? 'Removable' : 'Built-in'} · ${v.kind == StorageKind.unknown ? 'Type UNKNOWN' : v.kind.name}'
            '${v.path != null ? ' · ${v.path}' : ''}',
            style: t.bodySmall?.copyWith(color: Colors.white54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
    );
  }
}
