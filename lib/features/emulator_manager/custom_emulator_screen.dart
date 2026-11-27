import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../integrations/emulator_adapters/custom_emulator.dart';
import '../../shared/widgets/tv_widgets.dart';
import '../console_manager/custom_console_dialog.dart';

/// Add an emulator by hand: pick an installed app, then name it, choose the
/// consoles it plays and how GAMEBOX hands it a game. With [existing], edits
/// (or removes) that emulator.
class CustomEmulatorScreen extends StatefulWidget {
  const CustomEmulatorScreen({super.key, this.existing});
  final CustomEmulator? existing;

  @override
  State<CustomEmulatorScreen> createState() => _CustomEmulatorScreenState();
}

class _CustomEmulatorScreenState extends State<CustomEmulatorScreen> {
  InstalledApp? _app;
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _extra = TextEditingController(text: widget.existing?.extraKey);
  final _search = TextEditingController();
  late final Set<String> _consoles = {...?widget.existing?.consoleIds};
  late CustomLaunchMethod _method = widget.existing?.method ?? CustomLaunchMethod.openFile;
  Future<List<InstalledApp>>? _apps;
  String? _error;

  bool get _editing => widget.existing != null;
  String? get _package => widget.existing?.packageName ?? _app?.packageName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apps ??= servicesOf(context).gateway.listApps();
  }

  @override
  void dispose() {
    _name.dispose();
    _extra.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = servicesOf(context);
    final pkg = _package;
    final name = _name.text.trim();
    final extra = _extra.text.trim();
    final problem = pkg == null
        ? 'Choose the emulator app.'
        : name.isEmpty
        ? 'Give the emulator a name.'
        : _consoles.isEmpty
        ? 'Choose at least one console it plays.'
        : _method == CustomLaunchMethod.pathExtra && !RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(extra)
        ? 'Type the extra name from the emulator\'s documentation (letters, digits, "_" and ".").'
        : null;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final e = CustomEmulator(
      packageName: pkg!,
      name: name,
      consoleIds: {..._consoles},
      method: _method,
      extraKey: _method == CustomLaunchMethod.pathExtra ? extra : null,
    );
    final list = [
      for (final o in s.settings.state.value.customEmulators)
        if (o.packageName != pkg) o,
      e,
    ];
    await s.settings.setCustomEmulators(list);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addSystem() async {
    final id = await showCustomConsoleDialog(context);
    if (id == null) return;
    // The new system is registered when the settings update.
    for (var i = 0; i < 40 && consoleById(id) == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (mounted) setState(() => _consoles.add(id));
  }

  Future<void> _remove() async {
    final s = servicesOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Remove ${widget.existing!.name}?'),
        content: const Text('GAMEBOX stops offering it for your games. The app itself is not uninstalled.'),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    await s.settings.setCustomEmulators([
      for (final o in s.settings.state.value.customEmulators)
        if (o.packageName != widget.existing!.packageName) o,
    ]);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final picking = !_editing && _app == null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: palette.decoration,
        child: SafeArea(
          child: PageFrame(
            title: _editing ? 'Edit emulator' : (picking ? 'Add an emulator: choose the app' : 'Add an emulator'),
            subtitle: picking
                ? 'Any emulator installed on this device. Install it first from its official source.'
                : 'App: $_package',
            actions: [
              TvButton(
                label: picking || _editing ? 'Back' : 'Choose another app',
                icon: Icons.arrow_back_rounded,
                autofocus: !picking,
                onPressed: () => picking || _editing ? Navigator.pop(context) : setState(() => _app = null),
              ),
              if (!picking) TvButton(label: 'Save', icon: Icons.check_rounded, primary: true, onPressed: _save),
              if (_editing) TvButton(label: 'Remove', icon: Icons.delete_outline_rounded, onPressed: _remove),
            ],
            child: picking ? _picker(context) : _form(context, palette),
          ),
        ),
      ),
    );
  }

  Widget _picker(BuildContext context) {
    final s = servicesOf(context);
    final added = {for (final e in s.settings.state.value.customEmulators) e.packageName};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('app-search'),
          controller: _search,
          autofocus: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search apps'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<InstalledApp>>(
            future: _apps,
            builder: (context, snap) {
              if (snap.hasError) return Text('Could not list apps: ${snap.error}');
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final q = _search.text.trim().toLowerCase();
              final apps = [
                for (final a in snap.data!)
                  if (a.packageName != gameboxPackage &&
                      (q.isEmpty || a.label.toLowerCase().contains(q) || a.packageName.toLowerCase().contains(q)))
                    a,
              ]..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
              if (apps.isEmpty) return const Text('No app matches.', style: TextStyle(color: Colors.white60));
              return ListView.separated(
                itemCount: apps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final a = apps[i];
                  return TvFocusable(
                    scale: 1.01,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    onSelect: () => setState(() {
                      _app = a;
                      if (_name.text.trim().isEmpty) _name.text = a.label;
                    }),
                    child: Row(
                      children: [
                        const Icon(Icons.android_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(a.packageName, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                            ],
                          ),
                        ),
                        if (added.contains(a.packageName)) const StatusChip('Already added', color: Colors.white54),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context, GameboxPalette palette) {
    Widget chip(String label, bool selected, VoidCallback onSelect) => TvFocusable(
      borderRadius: 20,
      color: selected ? palette.accent : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      onSelect: onSelect,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_rounded, size: 16)),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
    return ListView(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _error!,
              key: const ValueKey('custom-error'),
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          ),
        TextField(
          key: const ValueKey('custom-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name shown in GAMEBOX'),
        ),
        const SizedBox(height: 14),
        const SectionHeader('Consoles it plays'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in allConsoles)
              chip(
                c.name,
                _consoles.contains(c.id),
                () => setState(() {
                  if (!_consoles.remove(c.id)) _consoles.add(c.id);
                }),
              ),
            // A system GAMEBOX doesn't list.
            TvFocusable(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              onSelect: _addSystem,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.add_rounded, size: 16), SizedBox(width: 4), Text('Other system…', style: TextStyle(fontSize: 13))],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const SectionHeader('How GAMEBOX starts a game'),
        for (final m in CustomLaunchMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TvFocusable(
              scale: 1.01,
              color: _method == m ? palette.accent.withValues(alpha: 0.3) : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              onSelect: () => setState(() => _method = m),
              child: Row(
                children: [
                  Icon(_method == m ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(m.label)),
                ],
              ),
            ),
          ),
        if (_method == CustomLaunchMethod.pathExtra)
          TextField(
            key: const ValueKey('custom-extra'),
            controller: _extra,
            decoration: const InputDecoration(
              labelText: 'Extra name',
              hintText: 'From the emulator\'s documentation, e.g. ROM_PATH',
            ),
          ),
        const SizedBox(height: 10),
        const Text(
          'GAMEBOX does not know this emulator, so it cannot promise the game opens: that depends on the app. '
          '"Open the game file" works with most emulators that open files from a file manager. '
          'If the emulator opens without the game, edit it and choose "Open the app only".',
          style: TextStyle(fontSize: 12.5, color: Colors.white60),
        ),
      ],
    );
  }
}
