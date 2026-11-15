import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/services/system_services.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../setup/rom_search_screen.dart';
import '../setup/setup_screen.dart';
import 'library_location_service.dart';

/// Where games and GAMEBOX data live, with shortcuts to the setup wizard
/// and the ROM search.
class LibraryLocationSection extends StatelessWidget {
  const LibraryLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    return ValueListenableBuilder<StorageAccessStatus>(
      valueListenable: s.location.access,
      builder: (context, access, _) => ValueListenableBuilder<SettingsState>(
        valueListenable: s.settings.state,
        builder: (context, st, _) {
          final mode = s.location.mode;
          final public = s.location.isPublic;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader('Game folder (ROMs)',
                subtitle: 'Games live in ROMs/<system>/ (nes, snes, gba, psx, …), shared with RetroArch and other '
                    'emulators. GAMEBOX data lives next to it in GAMEBOX/.'),
            FutureBuilder<String>(
              future: s.location.describe(romsDir),
              builder: (_, snap) => Row(children: [
                Icon(public ? Icons.folder_shared_rounded : Icons.folder_special_rounded, color: palette.focus),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(snap.data ?? '…',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5), overflow: TextOverflow.ellipsis),
                ),
                StatusChip(
                  switch (mode) {
                    LocationMode.device => 'Shared storage',
                    LocationMode.tree => 'Picked folder',
                    LocationMode.app => 'App folder only',
                  },
                  color: public ? palette.success : palette.warning,
                ),
              ]),
            ),
            if (!public)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'RetroArch and other emulators cannot read the app folder, and it is deleted with GAMEBOX. '
                  'Open the setup wizard and allow storage access.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12.5),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 8, children: [
              TvButton(
                label: 'Setup wizard',
                icon: Icons.rocket_launch_rounded,
                primary: !public,
                onPressed: () => openSetup(context),
              ),
              TvButton(
                label: 'Find ROMs on this device',
                icon: Icons.travel_explore_rounded,
                onPressed: public
                    ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RomSearchScreen()))
                    : null,
              ),
              TvButton(
                label: 'Create missing folders',
                icon: Icons.create_new_folder_rounded,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final failed = await s.location.ensureStructure();
                  messenger.showSnackBar(SnackBar(
                      content: Text(failed.isEmpty ? 'All folders are in place' : 'Failed: ${failed.take(3).join('; ')}')));
                },
              ),
            ]),
          ]);
        },
      ),
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
                        Text(l.dirs.join('   '),
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
            'System/BIOS to $retroArchBiosDir and copy the files there.',
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
                      child: Text('${consoleById(b.info.consoleId)?.name}  ·  ${b.info.dir}',
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
