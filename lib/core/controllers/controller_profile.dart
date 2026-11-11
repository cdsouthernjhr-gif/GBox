/// Controller profile model: button bindings, analog calibration, dead zone,
/// trigger threshold and vibration. Pure Dart, unit-tested.
///
/// Key codes are Android `KeyEvent.KEYCODE_*` values; axes are Android
/// `MotionEvent.AXIS_*` values.
library;

import 'dart:convert';

/// Android key codes used by GAMEBOX (stable public API constants).
abstract final class AndroidKey {
  static const back = 4;
  static const dpadUp = 19;
  static const dpadDown = 20;
  static const dpadLeft = 21;
  static const dpadRight = 22;
  static const dpadCenter = 23;
  static const buttonA = 96;
  static const buttonB = 97;
  static const buttonX = 99;
  static const buttonY = 100;
  static const buttonL1 = 102;
  static const buttonR1 = 103;
  static const buttonL2 = 104;
  static const buttonR2 = 105;
  static const buttonThumbL = 106;
  static const buttonThumbR = 107;
  static const buttonStart = 108;
  static const buttonSelect = 109;
  static const buttonMode = 110;
}

abstract final class AndroidAxis {
  static const x = 0;
  static const y = 1;
  static const z = 11;
  static const rz = 14;
  static const hatX = 15;
  static const hatY = 16;
  static const lTrigger = 17;
  static const rTrigger = 18;
  static const gas = 22;
  static const brake = 23;

  static const names = {
    'X': x, 'Y': y, 'Z': z, 'RZ': rz, 'HAT_X': hatX, 'HAT_Y': hatY,
    'LTRIGGER': lTrigger, 'RTRIGGER': rTrigger, 'GAS': gas, 'BRAKE': brake,
    'RX': 12, 'RY': 13,
  };
}

/// Logical buttons of a standard gamepad (Android/Xbox layout: A = bottom).
enum PadAction {
  a('A', AndroidKey.buttonA),
  b('B', AndroidKey.buttonB),
  x('X', AndroidKey.buttonX),
  y('Y', AndroidKey.buttonY),
  l1('L1', AndroidKey.buttonL1),
  r1('R1', AndroidKey.buttonR1),
  l2('L2', AndroidKey.buttonL2),
  r2('R2', AndroidKey.buttonR2),
  start('START', AndroidKey.buttonStart),
  select('SELECT', AndroidKey.buttonSelect),
  dpadUp('D-PAD UP', AndroidKey.dpadUp),
  dpadDown('D-PAD DOWN', AndroidKey.dpadDown),
  dpadLeft('D-PAD LEFT', AndroidKey.dpadLeft),
  dpadRight('D-PAD RIGHT', AndroidKey.dpadRight),
  l3('L3 (left stick press)', AndroidKey.buttonThumbL),
  r3('R3 (right stick press)', AndroidKey.buttonThumbR);

  const PadAction(this.label, this.standardKeyCode);
  final String label;

  /// Key code Android/GAMEBOX expects for this action.
  final int standardKeyCode;
}

/// A physical input bound to an action: a key, or an axis pushed in a
/// direction (+1/-1), e.g. analog triggers or a hat-switch D-pad.
class Binding {
  const Binding.key(int this.keyCode) : axis = null, direction = null;
  const Binding.axis(int this.axis, int this.direction) : keyCode = null;

  final int? keyCode;
  final int? axis;
  final int? direction;

  bool get isKey => keyCode != null;

  Map<String, Object?> toJson() => isKey ? {'key': keyCode} : {'axis': axis, 'dir': direction};

  static Binding? fromJson(Map<String, dynamic> m) {
    if (m['key'] is int) return Binding.key(m['key'] as int);
    if (m['axis'] is int && m['dir'] is int) return Binding.axis(m['axis'] as int, m['dir'] as int);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is Binding && other.keyCode == keyCode && other.axis == axis && other.direction == direction;

  @override
  int get hashCode => Object.hash(keyCode, axis, direction);

  @override
  String toString() => isKey ? 'key $keyCode' : 'axis $axis ${direction! > 0 ? '+' : '-'}';
}

/// Calibration of one axis: resting centre and observed extremes.
class AxisCalibration {
  const AxisCalibration({required this.center, required this.min, required this.max});
  final double center;
  final double min;
  final double max;

  /// Maps a raw value to -1..1 relative to the centre, applying [deadZone]
  /// (fraction of travel) and rescaling so output is continuous at the edge
  /// of the dead zone.
  double apply(double raw, double deadZone) {
    final span = raw >= center ? (max - center) : (center - min);
    if (span <= 1e-6) return 0;
    var v = ((raw - center) / span).clamp(-1.0, 1.0);
    final mag = v.abs();
    if (mag <= deadZone) return 0;
    return v.sign * ((mag - deadZone) / (1 - deadZone));
  }

  Map<String, double> toJson() => {'c': center, 'min': min, 'max': max};

  static AxisCalibration fromJson(Map<String, dynamic> m) => AxisCalibration(
        center: (m['c'] as num).toDouble(),
        min: (m['min'] as num).toDouble(),
        max: (m['max'] as num).toDouble(),
      );
}

const defaultDeadZone = 0.20;
const defaultTriggerThreshold = 0.50;

class ControllerProfile {
  const ControllerProfile({
    this.id,
    required this.name,
    this.descriptor,
    this.consoleId,
    this.deadZone = defaultDeadZone,
    this.triggerThreshold = defaultTriggerThreshold,
    this.vibration = true,
    this.bindings = const {},
    this.calibration = const {},
  });

  final int? id;
  final String name;

  /// InputDevice descriptor; null = universal profile for any controller.
  final String? descriptor;

  /// null = all consoles.
  final String? consoleId;
  final double deadZone;
  final double triggerThreshold;
  final bool vibration;
  final Map<PadAction, Binding> bindings;

  /// Keyed by axis name (e.g. `X`, `RZ`).
  final Map<String, AxisCalibration> calibration;

  ControllerProfile copyWith({
    String? name,
    double? deadZone,
    double? triggerThreshold,
    bool? vibration,
    Map<PadAction, Binding>? bindings,
    Map<String, AxisCalibration>? calibration,
  }) =>
      ControllerProfile(
        id: id,
        name: name ?? this.name,
        descriptor: descriptor,
        consoleId: consoleId,
        deadZone: deadZone ?? this.deadZone,
        triggerThreshold: triggerThreshold ?? this.triggerThreshold,
        vibration: vibration ?? this.vibration,
        bindings: bindings ?? this.bindings,
        calibration: calibration ?? this.calibration,
      );

  String calibrationJson() => jsonEncode({for (final e in calibration.entries) e.key: e.value.toJson()});

  static Map<String, AxisCalibration> parseCalibration(String? json) {
    if (json == null || json.isEmpty) return const {};
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return {for (final e in m.entries) e.key: AxisCalibration.fromJson(e.value as Map<String, dynamic>)};
    } catch (_) {
      return const {};
    }
  }

  /// Physical key code → standard key code, for buttons the user mapped to a
  /// different action than Android reports. Identity entries are omitted.
  /// Keys used by more than one action keep the first action (enum order).
  Map<int, int> keyRemap() {
    final out = <int, int>{};
    for (final action in PadAction.values) {
      final b = bindings[action];
      if (b == null || !b.isKey) continue;
      if (out.containsKey(b.keyCode)) continue;
      if (b.keyCode != action.standardKeyCode) out[b.keyCode!] = action.standardKeyCode;
    }
    // A physical key that now means another action must not keep its old
    // meaning: if X was remapped to A, the old A key is left as-is unless
    // the user bound it elsewhere (handled above).
    return out;
  }

  /// Actions bound to the same physical input (shown as warnings).
  List<(PadAction, PadAction)> conflicts() {
    final seen = <Binding, PadAction>{};
    final out = <(PadAction, PadAction)>[];
    for (final a in PadAction.values) {
      final b = bindings[a];
      if (b == null) continue;
      final prev = seen[b];
      if (prev != null) {
        out.add((prev, a));
      } else {
        seen[b] = a;
      }
    }
    return out;
  }
}

/// Player slot: explicit 1–4, or null = automatic (Android order).
String playerLabel(int? p) => p == null ? 'Player: Auto' : 'Player $p';

int? nextPlayer(int? p) => switch (p) { null => 1, 1 => 2, 2 => 3, 3 => 4, _ => null };

/// Suggests a dead zone from stick noise observed while the user does not
/// touch the controller: twice the largest resting wobble (as a fraction of
/// the axis half-range), plus a small margin, clamped to 0.05–0.50.
/// [restRange] maps axis name → (min, max) seen at rest; [fullRange] maps
/// axis name → (min, max) seen while moving.
double suggestDeadZone(Map<String, (double, double)> restRange, Map<String, (double, double)> fullRange) {
  var worst = 0.0;
  for (final e in restRange.entries) {
    final full = fullRange[e.key];
    final half = full == null ? 1.0 : ((full.$2 - full.$1) / 2).abs();
    if (half < 1e-6) continue;
    final wobble = ((e.value.$2 - e.value.$1) / 2).abs() / half;
    if (wobble > worst) worst = wobble;
  }
  return (worst * 2 + 0.05).clamp(0.05, 0.50);
}

/// Stick and trigger axes worth calibrating (Android names).
const calibratableAxes = ['X', 'Y', 'Z', 'RZ', 'RX', 'RY', 'LTRIGGER', 'RTRIGGER', 'GAS', 'BRAKE'];
