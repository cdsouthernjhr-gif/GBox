import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/controllers/controller_profile.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/hardware_profile.dart';
import '../../shared/widgets/tv_widgets.dart';

/// Shared frame for the setup screens.
class _SetupFrame extends StatelessWidget {
  const _SetupFrame({required this.title, required this.subtitle, required this.child, required this.onBack});
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        // Only system BACK (blocked pop) is handled; programmatic pops have
        // already happened (didPop) and must not trigger a second pop.
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBack();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: DecoratedBox(
            decoration: GameboxPalette.of(context).decoration,
            child: SafeArea(child: PageFrame(title: title, subtitle: subtitle, child: child)),
          ),
        ),
      );
}

/// Button-mapping wizard. While capturing, nothing on screen is focusable:
/// every press of the controller being mapped is a binding. BACK on another
/// device (TV remote) skips a step; BACK that follows a key press of the
/// mapped pad within 300 ms is Android's B→BACK fallback and is ignored.
class MappingWizardScreen extends StatefulWidget {
  const MappingWizardScreen({super.key, required this.device});
  final InputDeviceInfo device;

  @override
  State<MappingWizardScreen> createState() => _MappingWizardScreenState();
}

class _MappingWizardScreenState extends State<MappingWizardScreen> {
  static const _axisSteps = {
    PadAction.l2, PadAction.r2, PadAction.dpadUp, PadAction.dpadDown, PadAction.dpadLeft, PadAction.dpadRight,
  };
  static const _dpadAxes = {'HAT_X', 'HAT_Y'};
  static const _triggerAxes = {'LTRIGGER', 'RTRIGGER', 'GAS', 'BRAKE', 'Z', 'RZ'};

  StreamSubscription<RawInputEvent>? _sub;
  final Map<PadAction, Binding> _bindings = {};
  int _step = 0;
  bool _done = false;
  DateTime _lastDeviceKey = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _acceptAfter = DateTime.fromMillisecondsSinceEpoch(0);
  Map<String, double>? _baseline;

  PadAction get _action => PadAction.values[_step];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub ??= servicesOf(context).gateway.rawInput().listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _bind(Binding b) {
    setState(() {
      _bindings[_action] = b;
      _advance();
    });
  }

  void _advance() {
    _acceptAfter = DateTime.now().add(const Duration(milliseconds: 350));
    _baseline = null;
    if (_step + 1 >= PadAction.values.length) {
      _done = true;
      _sub?.cancel();
      _sub = null;
    } else {
      _step++;
    }
  }

  void _onEvent(RawInputEvent e) {
    if (_done || e.deviceId != widget.device.id) return;
    final now = DateTime.now();
    if (e.type == 'key') {
      _lastDeviceKey = now;
      if (e.isDown != true || now.isBefore(_acceptAfter) || e.keyCode == null) return;
      _bind(Binding.key(e.keyCode!));
      return;
    }
    // Axis input only for triggers and D-pad steps.
    if (!_axisSteps.contains(_action)) return;
    final allowed = _action == PadAction.l2 || _action == PadAction.r2 ? _triggerAxes : _dpadAxes;
    final base = _baseline ??= Map.of(e.axes);
    if (now.isBefore(_acceptAfter)) return;
    for (final entry in e.axes.entries) {
      if (!allowed.contains(entry.key)) continue;
      final delta = entry.value - (base[entry.key] ?? 0);
      final axisId = AndroidAxis.names[entry.key];
      if (delta.abs() > 0.6 && axisId != null) {
        _bind(Binding.axis(axisId, delta > 0 ? 1 : -1));
        return;
      }
    }
  }

  void _onBack() {
    if (_done) {
      Navigator.of(context).pop();
      return;
    }
    if (DateTime.now().difference(_lastDeviceKey) < const Duration(milliseconds: 300)) return;
    setState(_advance); // skip this action
  }

  Future<void> _save() async {
    final s = servicesOf(context);
    final base = s.controllerConfig.profileFor(widget.device);
    await s.controllerConfig.save(base.copyWith(bindings: Map.of(_bindings)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mapping saved for ${widget.device.name}. It applies inside GAMEBOX now.')));
    Navigator.of(context).pop();
  }

  String _describe(Binding b) {
    if (b.isKey) return 'key ${b.keyCode}';
    final name = AndroidAxis.names.entries.where((e) => e.value == b.axis).map((e) => e.key).firstOrNull ?? '${b.axis}';
    return 'axis $name ${b.direction! > 0 ? '+' : '−'}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = GameboxPalette.of(context);
    final t = Theme.of(context).textTheme;
    final conflicts = ControllerProfile(name: '', bindings: _bindings).conflicts();
    return _SetupFrame(
      title: 'Map buttons — ${widget.device.name}',
      subtitle: _done
          ? 'Review and save'
          : 'Press the button on THIS controller · BACK on the remote skips · step ${_step + 1}/${PadAction.values.length}',
      onBack: _onBack,
      child: _done
          ? ListView(children: [
              for (final a in PadAction.values)
                InfoRow(a.label, _bindings[a] == null ? 'not mapped (Android default)' : _describe(_bindings[a]!)),
              for (final (a, b) in conflicts)
                Text('Warning: ${a.label} and ${b.label} use the same input.',
                    style: TextStyle(color: palette.warning)),
              const SizedBox(height: 14),
              Wrap(spacing: 10, children: [
                TvButton(label: 'Save mapping', primary: true, autofocus: true, onPressed: _save),
                TvButton(
                  label: 'Start again',
                  onPressed: () => setState(() {
                    _bindings.clear();
                    _step = 0;
                    _done = false;
                    _acceptAfter = DateTime.now().add(const Duration(milliseconds: 500));
                    _sub ??= servicesOf(context).gateway.rawInput().listen(_onEvent);
                  }),
                ),
                TvButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop()),
              ]),
            ])
          : ExcludeFocus(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Press', style: t.titleLarge?.copyWith(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Text(_action.label, style: t.displaySmall?.copyWith(color: palette.focus)),
                  const SizedBox(height: 16),
                  if (_axisSteps.contains(_action))
                    const Text('Analog triggers and hat-switch D-pads are detected too.',
                        style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: _step / PadAction.values.length),
                ]),
              ),
            ),
    );
  }
}

/// Analog calibration: 3 s at rest (centre + noise), then 10 s of full
/// movement (range). Timed, so no button press is needed while sampling.
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key, required this.device});
  final InputDeviceInfo device;

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

enum _CalPhase { rest, move, done }

class _CalibrationScreenState extends State<CalibrationScreen> {
  StreamSubscription<RawInputEvent>? _sub;
  Timer? _timer;
  _CalPhase _phase = _CalPhase.rest;
  int _remaining = 3;
  final Map<String, List<double>> _rest = {};
  final Map<String, (double, double)> _range = {};
  Map<String, double> _live = const {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return;
    _sub = servicesOf(context).gateway.rawInput().listen(_onEvent);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(RawInputEvent e) {
    if (e.deviceId != widget.device.id || e.type != 'motion') return;
    for (final entry in e.axes.entries) {
      if (!calibratableAxes.contains(entry.key)) continue;
      final v = entry.value;
      if (_phase == _CalPhase.rest) _rest.putIfAbsent(entry.key, () => []).add(v);
      final r = _range[entry.key];
      _range[entry.key] = r == null ? (v, v) : (v < r.$1 ? v : r.$1, v > r.$2 ? v : r.$2);
    }
    if (mounted) setState(() => _live = e.axes);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _remaining--;
      if (_remaining > 0) return;
      if (_phase == _CalPhase.rest) {
        _phase = _CalPhase.move;
        _remaining = 10;
      } else if (_phase == _CalPhase.move) {
        _phase = _CalPhase.done;
        _timer?.cancel();
        _sub?.cancel();
      }
    });
  }

  Map<String, AxisCalibration> _result() {
    final out = <String, AxisCalibration>{};
    for (final axis in _range.keys) {
      final rest = _rest[axis];
      final center = rest == null || rest.isEmpty ? 0.0 : rest.reduce((a, b) => a + b) / rest.length;
      final r = _range[axis]!;
      if ((r.$2 - r.$1) < 0.2) continue; // axis never moved: keep defaults
      out[axis] = AxisCalibration(center: center, min: r.$1, max: r.$2);
    }
    return out;
  }

  double _suggested() => suggestDeadZone({
        for (final e in _rest.entries)
          if (e.value.isNotEmpty)
            e.key: (e.value.reduce((a, b) => a < b ? a : b), e.value.reduce((a, b) => a > b ? a : b)),
      }, _range);

  Future<void> _save() async {
    final s = servicesOf(context);
    final base = s.controllerConfig.profileFor(widget.device);
    final dz = _suggested();
    await s.controllerConfig.save(base.copyWith(calibration: _result(), deadZone: dz));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calibration saved. Dead zone set to ${(dz * 100).round()}%.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final palette = GameboxPalette.of(context);
    final instruction = switch (_phase) {
      _CalPhase.rest => 'Put the controller down. Do not touch the sticks or triggers… $_remaining',
      _CalPhase.move => 'Rotate both sticks in full circles and press both triggers fully… $_remaining',
      _CalPhase.done => 'Calibration complete',
    };
    return _SetupFrame(
      title: 'Calibrate — ${widget.device.name}',
      subtitle: instruction,
      onBack: () => Navigator.of(context).pop(),
      child: _phase != _CalPhase.done
          ? ExcludeFocus(
              child: ListView(children: [
                Text(instruction, style: t.titleLarge?.copyWith(color: palette.focus)),
                const SizedBox(height: 14),
                if (_live.isEmpty)
                  const Text('Waiting for analog input from this controller…', style: TextStyle(color: Colors.white54)),
                for (final e in _live.entries)
                  if (calibratableAxes.contains(e.key))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        SizedBox(width: 90, child: Text(e.key)),
                        Expanded(child: LinearProgressIndicator(value: ((e.value + 1) / 2).clamp(0.0, 1.0), minHeight: 8)),
                        SizedBox(width: 56, child: Text(e.value.toStringAsFixed(2), textAlign: TextAlign.right)),
                      ]),
                    ),
              ]),
            )
          : ListView(children: [
              if (_result().isEmpty)
                const Text('No analog movement was detected. This controller may be digital-only.',
                    style: TextStyle(color: Colors.orangeAccent)),
              for (final e in _result().entries)
                InfoRow(e.key,
                    'centre ${e.value.center.toStringAsFixed(3)} · range ${e.value.min.toStringAsFixed(2)} … ${e.value.max.toStringAsFixed(2)}'),
              InfoRow('Suggested dead zone', '${(_suggested() * 100).round()}%'),
              const SizedBox(height: 14),
              Wrap(spacing: 10, children: [
                TvButton(
                    label: 'Save calibration', primary: true, autofocus: true, onPressed: _result().isEmpty ? null : _save),
                TvButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop()),
              ]),
            ]),
    );
  }
}
