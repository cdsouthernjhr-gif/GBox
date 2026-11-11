import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../shared/widgets/tv_widgets.dart';

class ControllersScreen extends StatelessWidget {
  const ControllersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    return PageFrame(
      title: 'Controllers',
      subtitle: 'Detected through Android InputDevice APIs',
      actions: [
        TvButton(
          label: 'Test input',
          icon: Icons.sports_esports_rounded,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ControllerTestScreen())),
        ),
        TvButton(label: 'Refresh', icon: Icons.refresh_rounded, onPressed: () => s.controllers.refresh()),
      ],
      child: ValueListenableBuilder<List<InputDeviceInfo>>(
        valueListenable: s.controllers.devices,
        builder: (context, all, _) {
          final pads = all.where((d) => d.isGameController).toList();
          final other = all.where((d) => !d.isGameController).toList();
          return ListView(children: [
            SectionHeader('Game controllers (${pads.length})',
                subtitle: 'Android assigns player numbers; per-console mapping and profiles '
                    'arrive in Phase 4.'),
            if (pads.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No gamepad detected. Pair a Bluetooth controller in Android settings or plug in '
                  'a USB / 2.4 GHz receiver — it will appear here automatically.',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            for (final d in pads) _DeviceTile(d),
            const SizedBox(height: 14),
            SectionHeader('Other input devices (${other.length})'),
            for (final d in other) _DeviceTile(d),
          ]);
        },
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile(this.d);
  final InputDeviceInfo d;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final palette = GameboxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TvFocusable(
        scale: 1.01,
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            d.isGameController
                ? Icons.gamepad_rounded
                : d.classes.contains('keyboard')
                    ? Icons.keyboard_rounded
                    : d.classes.contains('mouse')
                        ? Icons.mouse_rounded
                        : Icons.settings_remote_rounded,
            size: 32,
            color: d.isGameController ? palette.success : Colors.white60,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(d.name, style: t.titleMedium, overflow: TextOverflow.ellipsis)),
                if (d.controllerNumber != null) ...[
                  const SizedBox(width: 8),
                  StatusChip('Player ${d.controllerNumber}', color: palette.focus),
                ],
              ]),
              const SizedBox(height: 4),
              Text(
                'VID:PID ${d.vendorProductLabel} · ${d.connectionHint} · '
                'Types: ${d.classes.isEmpty ? 'UNKNOWN' : d.classes.join(', ')} · '
                'Vibration: ${d.hasVibrator ? 'yes' : 'not reported'}',
                style: t.bodySmall?.copyWith(color: Colors.white60),
              ),
              if (d.isGameController) ...[
                const SizedBox(height: 4),
                Text('Buttons: ${d.buttons.isEmpty ? 'not reported' : d.buttons.join(' ')}',
                    style: t.bodySmall?.copyWith(color: Colors.white70)),
                Text('Axes: ${d.axes.isEmpty ? 'none reported' : d.axes.join(' ')}',
                    style: t.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Live input tester: shows raw key and axis events per device, straight from
/// Android's KeyEvent/MotionEvent pipeline. Press BACK twice quickly to exit.
class ControllerTestScreen extends StatefulWidget {
  const ControllerTestScreen({super.key});

  @override
  State<ControllerTestScreen> createState() => _ControllerTestScreenState();
}

class _ControllerTestScreenState extends State<ControllerTestScreen> {
  StreamSubscription<RawInputEvent>? _sub;
  final Map<int, Set<String>> _pressed = {};
  final Map<int, Map<String, double>> _axes = {};
  final List<String> _log = [];
  DateTime? _lastBack;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;
    try {
      _sub = servicesOf(context).gateway.rawInput().listen(_onEvent,
          onError: (Object e) => setState(() => _error = '$e'));
    } catch (e) {
      _error = '$e';
    }
  }

  void _onEvent(RawInputEvent e) {
    setState(() {
      if (e.type == 'key') {
        final set = _pressed.putIfAbsent(e.deviceId, () => {});
        if (e.isDown == true) {
          set.add(e.keyName ?? '${e.keyCode}');
        } else {
          set.remove(e.keyName ?? '${e.keyCode}');
        }
        _log.insert(0, 'device ${e.deviceId}: ${e.keyName} ${e.isDown == true ? 'DOWN' : 'UP'}');
        if (_log.length > 14) _log.removeLast();
      } else {
        _axes[e.deviceId] = e.axes;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = servicesOf(context);
    final palette = GameboxPalette.of(context);
    final names = {for (final d in s.controllers.devices.value) d.id: d.name};
    final ids = {..._pressed.keys, ..._axes.keys}.toList()..sort();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Every controller button must be testable, so a single BACK (often
        // mapped to button B) does not leave the screen.
        final now = DateTime.now();
        if (_lastBack != null && now.difference(_lastBack!) < const Duration(milliseconds: 800)) {
          Navigator.of(context).pop();
        }
        _lastBack = now;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: palette.background),
          child: SafeArea(
            child: Focus(
              autofocus: true,
              child: PageFrame(
                title: 'Controller test',
                subtitle: 'Press buttons and move sticks. Press BACK twice quickly to exit.',
                child: _error != null
                    ? EmptyState(icon: Icons.error_outline, title: 'Input stream unavailable', message: _error!)
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          flex: 3,
                          child: ids.isEmpty
                              ? const EmptyState(
                                  icon: Icons.gamepad_outlined,
                                  title: 'Waiting for input…',
                                  message: 'Events from every connected input device are shown here.')
                              : ListView(children: [
                                  for (final id in ids)
                                    _DeviceLive(
                                      name: names[id] ?? 'Device $id',
                                      pressed: _pressed[id] ?? const {},
                                      axes: _axes[id] ?? const {},
                                    ),
                                ]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: palette.card, borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('EVENT LOG', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              for (final l in _log)
                                Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                            ]),
                          ),
                        ),
                      ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceLive extends StatelessWidget {
  const _DeviceLive({required this.name, required this.pressed, required this.axes});
  final String name;
  final Set<String> pressed;
  final Map<String, double> axes;

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (pressed.isEmpty) const Text('No buttons held', style: TextStyle(color: Colors.white54)),
          for (final b in pressed) StatusChip(b, color: palette.focus),
        ]),
        if (axes.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final e in axes.entries)
            Row(children: [
              SizedBox(width: 90, child: Text(e.key, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: LinearProgressIndicator(
                  value: ((e.value + 1) / 2).clamp(0.0, 1.0),
                  minHeight: 8,
                ),
              ),
              SizedBox(
                  width: 56,
                  child: Text(e.value.toStringAsFixed(2),
                      textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
            ]),
        ],
      ]),
    );
  }
}
