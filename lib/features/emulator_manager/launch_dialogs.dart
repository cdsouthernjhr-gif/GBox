import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/constants/emulator_links.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/tv_widgets.dart';
import 'launch_service.dart';

/// Launches with the console default (or the first installed emulator).
Future<void> playGame(BuildContext context, GameRow game) async {
  final s = servicesOf(context);
  final outcome = await s.launcher.play(game.id);
  if (!context.mounted) return;
  await _report(context, outcome, game);
}

/// Lets the user pick the emulator and its options for this launch.
Future<void> playGameWith(BuildContext context, GameRow game) async {
  final s = servicesOf(context);
  final choices = await s.launcher.choicesFor(game.consoleId);
  if (!context.mounted) return;
  final picked = await showDialog<(String, Map<String, String>, bool)>(
    context: context,
    builder: (_) => LaunchChooserDialog(consoleId: game.consoleId, choices: choices),
  );
  if (picked == null || !context.mounted) return;
  final outcome = await s.launcher.play(game.id, emulatorId: picked.$1, options: picked.$2, remember: picked.$3);
  if (!context.mounted) return;
  await _report(context, outcome, game);
}

Future<void> _report(BuildContext context, LaunchOutcome o, GameRow game) async {
  if (!o.ok && o.missingEmulators.isNotEmpty) {
    await showGetEmulatorDialog(context, game.consoleId, o.missingEmulators);
    return;
  }
  if (o.ok) {
    final notes = o.notes.isEmpty ? '' : ' ${o.notes.join(' ')}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text('Starting ${game.title} in ${o.emulatorName}.$notes'),
    ));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(o.emulatorName == null ? 'Cannot start the game' : 'Cannot start with ${o.emulatorName}'),
      content: Text(o.reasons.join('\n\n')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
        TextButton(
          autofocus: true,
          onPressed: () {
            Navigator.pop(c);
            playGameWith(context, game);
          },
          child: const Text('Choose emulator…'),
        ),
      ],
    ),
  );
}

class LaunchChooserDialog extends StatefulWidget {
  const LaunchChooserDialog({super.key, required this.consoleId, required this.choices});
  final String consoleId;
  final List<LaunchChoice> choices;

  @override
  State<LaunchChooserDialog> createState() => _LaunchChooserDialogState();
}

class _LaunchChooserDialogState extends State<LaunchChooserDialog> {
  LaunchChoice? _choice;
  final Map<String, String> _options = {};
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    _select(widget.choices.where((c) => c.installed).firstOrNull);
  }

  void _select(LaunchChoice? c) {
    _choice = c;
    _options
      ..clear()
      ..addAll({for (final o in c?.options ?? const []) o.key: o.defaultValue});
  }

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final console = consoleById(widget.consoleId)?.name ?? widget.consoleId;
    final c = _choice;
    return AlertDialog(
      title: Text('Play $console game with…'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.choices.isEmpty) const Text('GAMEBOX cannot launch games for this console yet.'),
            for (final ch in widget.choices)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TvFocusable(
                  scale: 1.01,
                  autofocus: ch == c,
                  color: ch == c ? palette.accent.withValues(alpha: 0.3) : null,
                  padding: const EdgeInsets.all(10),
                  onSelect: ch.installed ? () => setState(() => _select(ch)) : null,
                  child: Row(children: [
                    Icon(ch.installed ? Icons.check_circle_rounded : Icons.cancel_outlined,
                        color: ch.installed ? palette.success : Colors.white38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ch.adapter.emulator.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          ch.installed ? 'Installed (${ch.installedPackage})' : 'Not installed',
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                      ]),
                    ),
                    if (!ch.adapter.verifiedOnDevice)
                      const StatusChip('Experimental', color: Colors.orangeAccent),
                  ]),
                ),
              ),
            if (c != null)
              for (final o in c.options) ...[
                const SizedBox(height: 6),
                Text(o.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final e in o.values.entries)
                    TvFocusable(
                      borderRadius: 20,
                      color: _options[o.key] == e.key ? palette.accent : null,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      onSelect: () => setState(() => _options[o.key] = e.key),
                      child: Text(e.value, style: const TextStyle(fontSize: 12.5)),
                    ),
                ]),
              ],
            const SizedBox(height: 10),
            TvFocusable(
              scale: 1.0,
              color: Colors.transparent,
              padding: const EdgeInsets.all(6),
              onSelect: () => setState(() => _remember = !_remember),
              child: Row(children: [
                Icon(_remember ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded),
                const SizedBox(width: 8),
                Text('Use as default for $console'),
              ]),
            ),
            const SizedBox(height: 6),
            const Text(
              'Experimental: the launch method follows the emulator\'s documented interface but has not yet '
              'been verified on a TV box. Please report results.',
              style: TextStyle(fontSize: 11.5, color: Colors.white54),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: c == null ? null : () => Navigator.pop(context, (c.adapter.emulatorId, Map.of(_options), _remember)),
          child: const Text('Play'),
        ),
      ],
    );
  }
}

/// Explains that the built-in player stopped, with details to copy and send.
Future<void> showPlayerCrashDialog(BuildContext context, PlayerCrash crash) => showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('The game stopped unexpectedly'),
        content: SizedBox(
          width: 640,
          height: 360,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              crash.frames == 0
                  ? 'The built-in player closed before showing the game (${crash.game}). '
                      'Please copy the details below and send them to the developer, so it can be fixed. '
                      'Meanwhile you can try "Play with…" and another emulator.'
                  : 'The built-in player closed while playing ${crash.game}. '
                      'Please copy the details below and send them to the developer.',
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black38,
                child: SingleChildScrollView(
                  child: SelectableText(crash.details,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white70)),
                ),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
          TextButton(
            autofocus: true,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: crash.details));
              if (c.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details copied')));
                Navigator.pop(c);
              }
            },
            child: const Text('Copy details'),
          ),
        ],
      ),
    );

/// Where to get emulators for [consoleId]: Play Store and official site.
/// After installing one, return to GAMEBOX and press Play again (installed
/// emulators are detected on every launch).
Future<void> showGetEmulatorDialog(BuildContext context, String consoleId, List<String> emulatorIds, {String? title}) =>
    showDialog<void>(
      context: context,
      builder: (c) {
        final console = consoleById(consoleId)?.name ?? consoleId;
        return AlertDialog(
          title: Text(title ?? 'Get an emulator for $console'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title != null
                    ? 'Install it from its official source, then come back to GAMEBOX.'
                    : 'No emulator that plays $console games is installed. Install one from its official source, '
                        'then come back and press Play again.'),
                const SizedBox(height: 12),
                for (final id in emulatorIds) _EmulatorGetRow(emulatorId: id),
              ]),
            ),
          ),
          actions: [TextButton(autofocus: true, onPressed: () => Navigator.pop(c), child: const Text('Close'))],
        );
      },
    );

class _EmulatorGetRow extends StatelessWidget {
  const _EmulatorGetRow({required this.emulatorId});
  final String emulatorId;

  Future<void> _open(BuildContext context, List<String?> urls) async {
    final s = servicesOf(context);
    final messenger = ScaffoldMessenger.of(context);
    for (final u in urls) {
      if (u != null && await s.gateway.openUrl(u)) return;
    }
    messenger.showSnackBar(const SnackBar(
        content: Text('No app on this device can open the link (no Play Store or web browser).')));
  }

  @override
  Widget build(BuildContext context) {
    final emu = knownEmulators.where((e) => e.id == emulatorId).firstOrNull;
    final links = emulatorLinks[emulatorId];
    if (emu == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emu.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (links?.note != null) Text(links!.note!, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (links?.playPackage != null)
            TvButton(
              label: 'Play Store',
              icon: Icons.shop_rounded,
              onPressed: () => _open(context, [links!.playStoreApp, links.playStoreWeb]),
            ),
          if (links?.site != null)
            TvButton(
              label: 'Official site',
              icon: Icons.open_in_new_rounded,
              onPressed: () => _open(context, [links!.site]),
            ),
        ]),
      ]),
    );
  }
}

