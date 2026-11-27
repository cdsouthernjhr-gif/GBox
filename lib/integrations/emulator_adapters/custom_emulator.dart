/// Emulators the user adds by hand (EMULATORS → Add emulator): any
/// installed app, the consoles it plays and how GAMEBOX hands it a game.
/// Stored as JSON in the settings; launched like the built-in recipes.
library;

import 'dart:convert';

import '../../core/constants/console_catalog.dart';
import 'emulator_adapter.dart';
import 'recipe_launcher.dart';

enum CustomLaunchMethod {
  /// The game as a content URI with ACTION_VIEW ("Open with"), which most
  /// emulators accept.
  openFile('Open the game file (recommended)'),

  /// The game's path (or a content URI) in a named extra.
  pathExtra('Game path in an extra (advanced)'),

  /// Only starts the app; the game is chosen inside the emulator.
  appOnly('Open the app only (choose the game in the emulator)');

  const CustomLaunchMethod(this.label);
  final String label;
}

class CustomEmulator {
  const CustomEmulator({
    required this.packageName,
    required this.name,
    required this.consoleIds,
    this.method = CustomLaunchMethod.openFile,
    this.extraKey,
  });

  final String packageName;
  final String name;
  final Set<String> consoleIds;
  final CustomLaunchMethod method;

  /// Extra name for [CustomLaunchMethod.pathExtra].
  final String? extraKey;

  /// Emulator id used for launch profiles and play history.
  String get id => idFor(packageName);
  static String idFor(String packageName) => 'custom:$packageName';

  Map<String, Object?> toJson() => {
    'package': packageName,
    'name': name,
    'consoles': consoleIds.toList()..sort(),
    'method': method.name,
    if (extraKey != null) 'extra': extraKey,
  };

  static CustomEmulator? fromJson(Object? j) {
    if (j is! Map) return null;
    final pkg = j['package'], name = j['name'], consoles = j['consoles'];
    if (pkg is! String || !_package.hasMatch(pkg) || name is! String || name.trim().isEmpty || consoles is! List) {
      return null;
    }
    final ids = {
      for (final c in consoles)
        if (c is String && consoleById(c) != null) c,
    };
    if (ids.isEmpty) return null;
    final method = CustomLaunchMethod.values.asNameMap()[j['method']] ?? CustomLaunchMethod.openFile;
    final extra = j['extra'];
    if (method == CustomLaunchMethod.pathExtra && (extra is! String || extra.trim().isEmpty)) return null;
    return CustomEmulator(
      packageName: pkg,
      name: name.trim(),
      consoleIds: ids,
      method: method,
      extraKey: method == CustomLaunchMethod.pathExtra ? (extra as String).trim() : null,
    );
  }

  static final _package = RegExp(r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$');

  static List<CustomEmulator> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return [for (final e in jsonDecode(raw) as List) ?fromJson(e)];
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<CustomEmulator> list) => jsonEncode([for (final e in list) e.toJson()]);
}

/// Launches games in a [CustomEmulator].
class CustomLauncher extends RecipeLauncher {
  CustomLauncher(this.custom)
    : super(
        emulatorId: custom.id,
        consoleIds: custom.consoleIds,
        recipe: switch (custom.method) {
          CustomLaunchMethod.openFile => const LaunchRecipe(
            action: 'android.intent.action.VIEW',
            categories: ['android.intent.category.DEFAULT'],
            handoff: FileHandoff.contentData,
            mimeType: 'application/octet-stream',
            genericViewFallback: false,
          ),
          CustomLaunchMethod.pathExtra || CustomLaunchMethod.appOnly => LaunchRecipe(
            action: 'android.intent.action.VIEW',
            handoff: FileHandoff.pathExtra,
            extraKey: custom.extraKey ?? 'path',
            genericViewFallback: false,
          ),
        },
        limitations: const [
          'Added by you: GAMEBOX does not know this emulator, so whether it opens the game depends on the app.',
        ],
      );

  final CustomEmulator custom;

  @override
  KnownEmulator get emulator => KnownEmulator(
    id: custom.id,
    name: custom.name,
    packageIds: [custom.packageName],
    consoleIds: custom.consoleIds.toList(),
    license: 'Unknown (added by you)',
  );

  @override
  String get launchMechanism => switch (custom.method) {
    CustomLaunchMethod.openFile => 'VIEW intent with the game as content URI data (added by you)',
    CustomLaunchMethod.pathExtra => 'VIEW intent with "${custom.extraKey}" extra (added by you)',
    CustomLaunchMethod.appOnly => 'Opens the app only (added by you)',
  };

  @override
  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options) {
    if (custom.method != CustomLaunchMethod.appOnly) return super.plan(target, env, options);
    if (!supports(target.consoleId)) return LaunchBlocked(['${custom.name} is not set up for this console.']);
    return LaunchReady(
      IntentSpec(
        packageName: env.installedPackage,
        action: 'android.intent.action.MAIN',
        categories: const ['android.intent.category.LAUNCHER'],
        flags: const ['newTask'],
      ),
      notes: ['Choose ${target.title ?? 'the game'} inside ${custom.name}.'],
    );
  }
}
