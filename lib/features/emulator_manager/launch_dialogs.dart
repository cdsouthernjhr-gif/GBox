import 'package:flutter/material.dart';

import '../../core/constants/console_catalog.dart';
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
