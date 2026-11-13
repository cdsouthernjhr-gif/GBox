import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/system_services.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Where the GAMEBOX folder lives, with the choice between the app folder
/// and a public folder picked by the user.
class LibraryLocationSection extends StatelessWidget {
  const LibraryLocationSection({super.key});

  Future<void> _choose(BuildContext context) async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = await s.gateway.pickDirectory();
      if (uri == null) return;
      final failed = await s.location.choose(uri);
      messenger.showSnackBar(SnackBar(
        content: Text(failed.isEmpty
            ? 'GAMEBOX folders created in ${await s.location.describe()}'
            : 'Some folders could not be created: ${failed.take(3).join('; ')}'),
      ));
      unawaited(s.library.scanAll());
    } on PlatformException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.code == 'saf_unavailable'
            ? 'This device has no system folder picker, so only the app folder can be used.'
            : 'Folder picker failed: ${e.message}'),
      ));
    }
  }

  Future<void> _useAppStorage(BuildContext context) async {
    final s = servicesOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Use the app folder?'),
        content: const Text('New downloads will go to the app folder. Games already in your public folder stay '
            'there and stay in the library; nothing is moved or deleted.'),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Use app folder')),
        ],
      ),
    );
    if (ok == true) await s.location.useAppStorage();
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return ValueListenableBuilder<SettingsState>(
      valueListenable: s.settings.state,
      builder: (context, st, _) {
        final public = st.libraryLocation != null;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('GAMEBOX library location',
              subtitle: 'Downloads are moved into Games/<console>/ here. Saves/ and BIOS/ folders are prepared too.'),
          FutureBuilder<String>(
            future: s.location.describe(),
            builder: (_, snap) => Row(children: [
              Icon(public ? Icons.folder_shared_rounded : Icons.folder_special_rounded, color: palette.focus),
              const SizedBox(width: 10),
              Expanded(
                child: Text(snap.data ?? '…',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5), overflow: TextOverflow.ellipsis),
              ),
              StatusChip(public ? 'Public folder' : 'App folder', color: public ? palette.success : palette.warning),
            ]),
          ),
          const SizedBox(height: 6),
          Text(
            public
                ? 'Kept if GAMEBOX is uninstalled, and readable by emulators such as RetroArch.'
                : 'Recommended: choose a public folder. The app folder is deleted when GAMEBOX is uninstalled, and '
                    'on Android 11+ RetroArch cannot read it and emulators cannot write saves into it.',
            style: const TextStyle(color: Colors.white60, fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 8, children: [
            TvButton(
              label: public ? 'Choose another folder' : 'Choose public folder…',
              icon: Icons.drive_folder_upload_rounded,
              primary: !public,
              onPressed: () => _choose(context),
            ),
            if (public)
              TvButton(label: 'Use app folder', icon: Icons.folder_special_rounded, onPressed: () => _useAppStorage(context)),
            TvButton(
              label: 'Create missing folders',
              icon: Icons.create_new_folder_rounded,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final failed = await s.location.ensureStructure();
                messenger.showSnackBar(SnackBar(
                    content: Text(failed.isEmpty ? 'All GAMEBOX folders are in place' : 'Failed: ${failed.take(3).join('; ')}')));
              },
            ),
          ]),
          if (!public)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'In the folder picker, open Internal storage (or a USB drive / SD card), create a folder named '
                'GAMEBOX and select it.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
        ]);
      },
    );
  }
}

/// Suggested save folder per emulator, with how to point the emulator at it.
class EmulatorSaveFoldersSection extends StatelessWidget {
  const EmulatorSaveFoldersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return ValueListenableBuilder<List<EmulatorInstallation>?>(
      valueListenable: s.emulators.installations,
      builder: (context, inst, _) => ValueListenableBuilder<SettingsState>(
        valueListenable: s.settings.state,
        builder: (context, st, _) {
          final installed = {for (final i in inst ?? const <EmulatorInstallation>[]) if (i.isInstalled) i.emulator.id};
          final registered = {for (final f in st.saveFolders) f.uri};
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              'Emulator save folders',
              subtitle: 'GAMEBOX cannot change where an emulator saves. Point each emulator at its folder below '
                  'once; GAMEBOX then finds, backs up and restores those saves.',
              trailing: TvButton(
                label: 'Register for installed emulators',
                icon: Icons.playlist_add_check_rounded,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final n = await s.location.registerSaveFolders();
                  messenger.showSnackBar(SnackBar(content: Text('$n save folder(s) registered')));
                },
              ),
            ),
            for (final l in saveLayouts)
              FutureBuilder<String>(
                future: s.location.saveFolderUri(l),
                builder: (context, snap) {
                  final emu = knownEmulators.where((e) => e.id == l.emulatorId).firstOrNull;
                  final isRegistered = snap.hasData && registered.contains(snap.data);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TvFocusable(
                      scale: 1.01,
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text(emu?.name ?? l.emulatorId, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          StatusChip(installed.contains(l.emulatorId) ? 'Installed' : 'Not installed',
                              color: installed.contains(l.emulatorId) ? palette.success : Colors.white38),
                          const SizedBox(width: 6),
                          if (isRegistered) StatusChip('Registered', color: palette.success),
                        ]),
                        Text(l.dirs.map((d) => 'GAMEBOX/$d').join('   '),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70)),
                        Text(l.howTo, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                      ]),
                    ),
                  );
                },
              ),
          ]);
        },
      ),
    );
  }
}

/// BIOS folders per console with which expected files are present.
class BiosSection extends StatefulWidget {
  const BiosSection({super.key});

  @override
  State<BiosSection> createState() => _BiosSectionState();
}

class _BiosSectionState extends State<BiosSection> {
  Future<List<BiosStatus>>? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _status ??= servicesOf(context).location.biosStatus();
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        'BIOS',
        subtitle: 'GAMEBOX never provides BIOS files. Dump them from your own console, put them in GAMEBOX/BIOS/'
            '<console>/ and choose that folder in the emulator. For RetroArch, set Settings → Directory → '
            'System/BIOS to GAMEBOX/$retroArchBiosDir and copy the files there.',
        trailing: TvButton(
          label: 'Check again',
          icon: Icons.refresh_rounded,
          onPressed: () => setState(() => _status = s.location.biosStatus()),
        ),
      ),
      FutureBuilder<List<BiosStatus>>(
        future: _status,
        builder: (context, snap) => Column(children: [
          for (final b in snap.data ?? const <BiosStatus>[])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TvFocusable(
                scale: 1.01,
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text('${consoleById(b.info.consoleId)?.name}  ·  GAMEBOX/${b.info.dir}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    StatusChip(
                      b.ready ? 'Found' : (b.info.required ? 'Needed' : 'Optional'),
                      color: b.ready ? palette.success : (b.info.required ? palette.warning : Colors.white38),
                    ),
                  ]),
                  Text(b.info.note, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  if (b.info.anyDump)
                    Text(b.present.isEmpty ? 'No file yet.' : 'Files: ${b.present.join(', ')}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  for (final f in b.info.files)
                    Text('${b.has(f.name) ? '✓' : '·'} ${f.name}  (${f.region}; ${f.usedBy})',
                        style: TextStyle(
                            fontFamily: 'monospace', fontSize: 12, color: b.has(f.name) ? palette.success : Colors.white54)),
                ]),
              ),
            ),
        ]),
      ),
    ]);
  }
}
