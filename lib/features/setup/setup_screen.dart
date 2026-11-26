import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/services/system_services.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';
import '../../integrations/retroarch/retroarch_launcher.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../emulator_manager/retroarch_playlist_service.dart';
import '../storage_manager/library_location_service.dart';
import 'rom_search_screen.dart';

/// Opens the setup wizard.
Future<void> openSetup(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetupScreen()));

/// Setup wizard and health check in one page: each step shows whether it is
/// done and the single action that completes it.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  String? _accessNote;
  int? _appFolderGames;
  PlaylistResult? _playlists;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appFolderGames == null) unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Android's "All files access" screen.
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final s = servicesOf(context);
    final before = s.location.access.value.granted;
    await s.location.refreshAccess();
    if (s.location.isPublic) await s.location.ensureStructure();
    if (!before && s.location.access.value.granted) {
      await s.location.registerSaveFolders();
      unawaited(s.library.scanAll());
    }
    final n = await s.migration.countAppFolderGames();
    if (mounted) setState(() => _appFolderGames = n);
  }

  Future<void> _requestAccess() async {
    final s = servicesOf(context);
    final r = await s.location.requestAccess();
    if (!mounted) return;
    setState(() => _accessNote = r == 'unavailable'
        ? 'This device has no "All files access" screen. Use one of the alternatives below.'
        : 'Turn on "Allow access to manage all files" for GAMEBOX, then come back.');
  }

  Future<void> _chooseFolder() async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = await s.gateway.pickDirectory();
      if (uri == null) return;
      final failed = await s.location.choose(uri);
      messenger.showSnackBar(SnackBar(content: Text(failed.isEmpty ? 'Folders created' : 'Failed: ${failed.first}')));
      unawaited(s.library.scanAll());
      await _refresh();
    } on PlatformException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Folder picker failed: ${e.message}')));
    }
  }

  Future<void> _migrate() async {
    final s = servicesOf(context);
    setState(() => _busy = true);
    final r = await s.migration.moveAppFolderGamesToRoms();
    s.refreshPlaylistsSoon();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${r.games} game(s) moved to ROMs${r.failed.isEmpty ? '' : ' · ${r.failed.length} failed: ${r.failed.first}'}')));
    await _refresh();
  }

  Future<void> _writePlaylists() async {
    final r = await servicesOf(context).playlists.writeAll();
    if (mounted) setState(() => _playlists = r);
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          title: 'Set up GAMEBOX',
          subtitle: 'Three steps so GAMEBOX, RetroArch and other emulators find your games in one place.',
          actions: [
            TvButton(
              label: 'Done',
              icon: Icons.check_rounded,
              primary: true,
              onPressed: () async {
                await s.settings.set(SettingsKeys.setupCompleted, true);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
          child: ValueListenableBuilder<StorageAccessStatus>(
            valueListenable: s.location.access,
            builder: (context, access, _) => ValueListenableBuilder<SettingsState>(
              valueListenable: s.settings.state,
              builder: (context, st, _) => ListView(children: [
                _step1(access),
                _step2(),
                _step3(),
                _step4(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required int n, required String title, required bool done, required List<Widget> children}) {
    final palette = GameboxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? palette.success : palette.warning, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? palette.success : palette.warning),
            const SizedBox(width: 8),
            Expanded(child: Text('$n. $title', style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 6),
          ...children,
        ]),
      ),
    );
  }

  static const _muted = TextStyle(color: Colors.white60, fontSize: 12.5);

  Widget _step1(StorageAccessStatus access) {
    final s = servicesOf(context);
    final mode = s.location.mode;
    return _card(n: 1, title: 'Allow storage access', done: mode != LocationMode.app, children: [
      Text(
        access.granted
            ? 'Access granted. Games go to Internal storage/ROMs, which RetroArch and other emulators can read.'
            : mode == LocationMode.tree
                ? 'Using the folder you picked.'
                : access.allFilesMode
                    ? 'Android needs "All files access" for GAMEBOX so it can keep games in a shared ROMs folder '
                        'and find ROMs anywhere on the device. GAMEBOX never deletes files without asking.'
                    : 'Allow storage access so GAMEBOX can keep games in a shared ROMs folder.',
        style: _muted,
      ),
      if (_accessNote != null && !access.granted) Text(_accessNote!, style: const TextStyle(color: Colors.orangeAccent)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, runSpacing: 8, children: [
        if (!access.granted)
          TvButton(label: 'Allow access', icon: Icons.lock_open_rounded, primary: true, autofocus: true, onPressed: _requestAccess),
        if (!access.granted) TvButton(label: 'Check again', icon: Icons.refresh_rounded, onPressed: _refresh),
        TvButton(
          label: mode == LocationMode.tree ? 'Choose another folder' : 'Use a USB/SD folder instead…',
          icon: Icons.usb_rounded,
          onPressed: _chooseFolder,
        ),
        if (mode == LocationMode.tree)
          TvButton(label: 'Use internal storage', onPressed: () async {
            await s.location.useDefault();
            await _refresh();
          }),
      ]),
      if (!access.granted && access.allFilesMode && (!access.settingsAvailable || _accessNote != null))
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: SelectableText(
            'No "All files access" screen on this device? From a computer:\n'
            '  adb shell appops set --uid com.gamebox.console MANAGE_EXTERNAL_STORAGE allow',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70),
          ),
        ),
    ]);
  }

  Widget _step2() {
    final s = servicesOf(context);
    final public = s.location.isPublic;
    final pending = _appFolderGames ?? 0;
    return _card(n: 2, title: 'Put your games in ROMs/', done: public && pending == 0, children: [
      FutureBuilder<String>(
        future: s.location.describe(romsDir),
        builder: (_, snap) => Text(
          public
              ? 'Game folder: ${snap.data ?? '…'}/<system>  (nes, snes, gb, gba, psx, n64, psp, …). '
                  'Downloads are sorted in automatically.'
              : 'Finish step 1 first.',
          style: _muted,
        ),
      ),
      if (public && pending > 0)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('$pending game(s) are still in GAMEBOX\'s app folder, which RetroArch cannot read.',
              style: const TextStyle(color: Colors.orangeAccent)),
        ),
      const SizedBox(height: 8),
      Wrap(spacing: 10, runSpacing: 8, children: [
        TvButton(
          label: 'Find ROMs on this device',
          icon: Icons.travel_explore_rounded,
          primary: public && pending == 0,
          onPressed: public
              ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RomSearchScreen())).then((_) => _refresh())
              : null,
        ),
        if (public && pending > 0)
          TvButton(
            label: _busy ? 'Moving…' : 'Move $pending game(s) to ROMs',
            icon: Icons.drive_file_move_rounded,
            primary: true,
            onPressed: _busy ? null : _migrate,
          ),
      ]),
    ]);
  }

  Widget _step3() {
    final s = servicesOf(context);
    return ValueListenableBuilder<List<EmulatorInstallation>?>(
      valueListenable: s.emulators.installations,
      builder: (context, inst, _) {
        final ra = inst?.where((i) => i.emulator.id == 'retroarch' && i.isInstalled).firstOrNull;
        final others = [for (final i in inst ?? const <EmulatorInstallation>[]) if (i.isInstalled && i.emulator.id != 'retroarch') i.emulator.name];
        return _card(n: 3, title: 'Get RetroArch ready', done: ra != null && (_playlists?.playlists ?? 0) > 0, children: [
          if (ra == null)
            const Text('RetroArch is not installed. Install it from the Play Store or retroarch.com, then come back. '
                'Other emulators work too.', style: _muted)
          else ...[
            const Text('In RetroArch, once:', style: _muted),
            Text(
              '• Main Menu → Online Updater → Core Downloader: install the cores you need, e.g. '
              '${[for (final c in const ['nes', 'snes', 'gba', 'megadrive', 'ps1']) retroArchCores[c]!.values.first].join(', ')}.\n'
              '• Allow storage access when RetroArch asks.\n'
              '• Your games then appear under "GAMEBOX - <console>" playlists (written by GAMEBOX below). '
              'If they don\'t: Settings → Directory → Playlists → choose GAMEBOX/Playlists, or use '
              'Import Content → Scan Directory → ROMs.',
              style: _muted,
            ),
          ],
          if (others.isNotEmpty) Text('Also installed: ${others.join(', ')}.', style: _muted),
          if (_playlists != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _playlists!.note ??
                    '${_playlists!.playlists} playlist(s) with ${_playlists!.games} game(s) written to '
                        '${_playlists!.dirs.join(' and ')}'
                        '${_playlists!.unreadable > 0 ? ' · ${_playlists!.unreadable} game(s) skipped: not readable by RetroArch' : ''}',
                style: TextStyle(color: _playlists!.note == null ? GameboxPalette.of(context).success : Colors.orangeAccent),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 8, children: [
            TvButton(
              label: 'Write RetroArch playlists',
              icon: Icons.playlist_add_rounded,
              onPressed: s.location.isPublic ? _writePlaylists : null,
            ),
            if (ra != null)
              TvButton(
                label: 'Open RetroArch',
                icon: Icons.open_in_new_rounded,
                onPressed: () => s.gateway.launchApp(ra.installedPackage!),
              ),
          ]),
        ]);
      },
    );
  }

  Widget _step4() {
    final s = servicesOf(context);
    return FutureBuilder<List<BiosStatus>>(
      future: s.location.biosStatus(),
      builder: (context, snap) {
        final needed = [for (final b in snap.data ?? const <BiosStatus>[]) if (b.info.required && !b.ready) b];
        return _card(n: 4, title: 'Optional: BIOS and save folders', done: needed.isEmpty, children: [
          Text(
            needed.isEmpty
                ? 'Nothing required is missing for the consoles GAMEBOX checks.'
                : 'Needed for ${needed.map((b) => consoleById(b.info.consoleId)!.name).join(', ')}: put your own BIOS '
                    'dumps in GAMEBOX/BIOS/<console>/ (SETTINGS → Storage → BIOS lists the file names). Only needed for those consoles.',
            style: _muted,
          ),
          const Text('Saves: point each emulator at GAMEBOX/Saves/<emulator> (SETTINGS → Storage → Emulator save folders) so '
              'GAMEBOX can back them up.', style: _muted),
        ]);
      },
    );
  }
}

/// Dashboard card shown until setup is completed.
class SetupBanner extends StatelessWidget {
  const SetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return ValueListenableBuilder<SettingsState>(
      valueListenable: s.settings.state,
      builder: (context, st, _) {
        if (st.setupCompleted) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TvFocusable(
            scale: 1.01,
            padding: const EdgeInsets.all(14),
            onSelect: () => openSetup(context),
            child: const Row(children: [
              Icon(Icons.rocket_launch_rounded),
              SizedBox(width: 12),
              Expanded(
                child: Text('Set up GAMEBOX: allow storage, put games in ROMs/, get RetroArch ready (3 steps)',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Text('Open', style: TextStyle(color: Colors.white60)),
            ]),
          ),
        );
      },
    );
  }
}
