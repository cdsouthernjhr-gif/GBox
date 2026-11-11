/// Universal Emulator Adapter contract (spec Part 9).
///
/// Adapters are pure: given what is installed and where the game file is,
/// they produce an [IntentSpec] (an Android intent described as data) or the
/// reasons the game cannot be launched. The native layer only executes the
/// spec. This keeps every launch rule unit-testable and keeps the UI away from
/// emulator internals.
///
/// Every adapter states [verifiedOnDevice]. An adapter built from an
/// emulator's documented launch interface but not yet executed on real
/// hardware reports `false` and the UI labels it "experimental".
library;

import '../../core/constants/console_catalog.dart';

/// Android intent described as data; executed by `gamebox/emulator` channel.
class IntentSpec {
  const IntentSpec({
    required this.packageName,
    this.className,
    this.action,
    this.categories = const [],
    this.data,
    this.mimeType,
    this.extras = const {},
    this.flags = const [],
    this.grantReadUris = const [],
    this.fallbacks = const [],
  });

  final String packageName;

  /// Fully-qualified activity class, or null to let Android resolve it.
  final String? className;
  final String? action;
  final List<String> categories;
  final String? data;
  final String? mimeType;
  final Map<String, String> extras;

  /// Names: newTask, clearTask, clearTop, noHistory.
  final List<String> flags;

  /// content:// URIs GAMEBOX holds read access to and passes on to the
  /// emulator for this launch only (FLAG_GRANT_READ_URI_PERMISSION).
  final List<String> grantReadUris;

  /// Tried in order by the native layer only if this intent's activity is
  /// not found.
  final List<IntentSpec> fallbacks;

  Map<String, Object?> toMap() => {
        'package': packageName,
        'className': className,
        'action': action,
        'categories': categories,
        'data': data,
        'mimeType': mimeType,
        'extras': extras,
        'flags': flags,
        'grantReadUris': grantReadUris,
        'fallbacks': [for (final f in fallbacks) f.toMap()],
      };
}

/// Where the game file is, in every form the platform could provide.
class LaunchTarget {
  const LaunchTarget({
    required this.consoleId,
    required this.originalUri,
    required this.extension,
    this.filesystemPath,
    this.contentUri,
  });

  final String consoleId;

  /// URI/path stored in the library.
  final String originalUri;
  final String extension;

  /// Real path, if one could be derived.
  final String? filesystemPath;

  /// content:// URI GAMEBOX may grant to the emulator, if any.
  final String? contentUri;
}

class LaunchEnvironment {
  const LaunchEnvironment({required this.installedPackage, required this.sdkInt, this.supportsArm64 = true});

  /// Package of the installed emulator build being used.
  final String installedPackage;
  final int sdkInt;

  /// From the hardware profile; true when unknown (the emulator then reports
  /// incompatibility itself).
  final bool supportsArm64;
}

/// A user-selectable option, e.g. a RetroArch core.
class LaunchOption {
  const LaunchOption({required this.key, required this.label, required this.values, required this.defaultValue});
  final String key;
  final String label;

  /// value → human label
  final Map<String, String> values;
  final String defaultValue;
}

sealed class LaunchPlan {
  const LaunchPlan();
}

class LaunchReady extends LaunchPlan {
  const LaunchReady(this.spec, {this.notes = const []});
  final IntentSpec spec;
  final List<String> notes;
}

class LaunchBlocked extends LaunchPlan {
  const LaunchBlocked(this.reasons);
  final List<String> reasons;
}

abstract class GameLauncherAdapter {
  /// Matches [KnownEmulator.id] in the catalogue.
  String get emulatorId;
  Set<String> get consoleIds;

  /// True only after a successful launch on real hardware has been recorded
  /// in docs/EMULATOR_INTEGRATION.md.
  bool get verifiedOnDevice;

  /// How the game file is handed over, for display.
  String get launchMechanism;
  List<String> get knownLimitations;

  List<LaunchOption> options(String consoleId) => const [];

  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options);

  KnownEmulator get emulator => knownEmulators.firstWhere((e) => e.id == emulatorId);

  bool supports(String consoleId) => consoleIds.contains(consoleId);
}
