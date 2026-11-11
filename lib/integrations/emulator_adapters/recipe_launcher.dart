/// Data-driven launcher for standalone emulator apps (Phase 6).
///
/// Each emulator is described by a [LaunchRecipe]: which activity/action to
/// use and how the game file is handed over. Recipes follow the launch
/// interfaces used by established Android frontends; none has been executed
/// on a device by GAMEBOX yet ([verifiedOnDevice] is false).
///
/// Robustness: when the game can be shared as a content URI, a generic
/// `ACTION_VIEW` intent to the same package is added as a fallback. The
/// native layer tries it only if the specific activity is not found (e.g. a
/// different app version), so a renamed activity degrades gracefully.
library;

import '../../core/rom/rom_path_resolver.dart';
import 'emulator_adapter.dart';

enum FileHandoff {
  /// Content URI as intent data (`-d`), read grant attached.
  contentData,

  /// Content URI (preferred, granted) or path, in a string extra.
  contentOrPathExtra,

  /// Filesystem path in a string extra (emulator reads the file itself).
  pathExtra,
}

class LaunchRecipe {
  const LaunchRecipe({
    required this.handoff,
    this.className,
    this.action,
    this.categories = const [],
    this.extraKey,
    this.mimeType,
    this.genericViewFallback = true,
  });

  /// Fully-qualified activity, or null to let Android resolve it in the
  /// package.
  final String? className;
  final String? action;
  final List<String> categories;
  final FileHandoff handoff;

  /// Extra name for [FileHandoff.contentOrPathExtra] / [FileHandoff.pathExtra].
  final String? extraKey;
  final String? mimeType;
  final bool genericViewFallback;
}

class RecipeLauncher extends GameLauncherAdapter {
  RecipeLauncher({
    required this.emulatorId,
    required this.consoleIds,
    required this.recipe,
    this.requiresArm64 = false,
    this.limitations = const [],
  });

  @override
  final String emulatorId;
  @override
  final Set<String> consoleIds;
  final LaunchRecipe recipe;
  final bool requiresArm64;
  final List<String> limitations;

  @override
  bool get verifiedOnDevice => false;

  @override
  String get launchMechanism {
    final target = recipe.className ?? '${recipe.action ?? 'VIEW'} intent';
    return switch (recipe.handoff) {
      FileHandoff.contentData => '$target with the game as content URI data',
      FileHandoff.contentOrPathExtra => '$target with "${recipe.extraKey}" extra (content URI or path)',
      FileHandoff.pathExtra => '$target with "${recipe.extraKey}" extra (file path)',
    };
  }

  @override
  List<String> get knownLimitations => [
        if (requiresArm64) 'Requires a 64-bit (arm64-v8a) Android build.',
        ...limitations,
      ];

  static const _view = 'android.intent.action.VIEW';

  @override
  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options) {
    if (!supports(target.consoleId)) return LaunchBlocked(['${emulator.name} does not run this console.']);
    if (requiresArm64 && !env.supportsArm64) {
      return LaunchBlocked(['${emulator.name} needs a 64-bit Android build (arm64-v8a); this device runs 32-bit Android.']);
    }
    final content = target.contentUri;
    final path = target.filesystemPath;
    const noLink = 'GAMEBOX could not create a shareable link for this file. Keep the game on internal storage in '
        'the GAMEBOX folders, or register its folder under STORAGE.';

    String? data;
    final extras = <String, String>{};
    switch (recipe.handoff) {
      case FileHandoff.contentData:
        if (content == null) return const LaunchBlocked([noLink]);
        data = content;
      case FileHandoff.contentOrPathExtra:
        final v = content ?? path;
        if (v == null) return const LaunchBlocked([noLink]);
        extras[recipe.extraKey!] = v;
      case FileHandoff.pathExtra:
        if (path == null) {
          return LaunchBlocked(['${emulator.name} needs a file path, but this file has none (added from Downloads '
              'or a cloud picker). Register the game folder under STORAGE.']);
        }
        if (env.sdkInt >= 30 && isAppPrivateExternalPath(path)) {
          return LaunchBlocked(['On Android 11 and newer, ${emulator.name} cannot read files inside "Android/data" '
              '(including the GAMEBOX folders). Move the game to a normal folder and register it under STORAGE.']);
        }
        extras[recipe.extraKey!] = path;
    }

    final grants = [?content];
    final usesContent = data != null || extras.values.contains(content);
    final fallbacks = <IntentSpec>[
      if (recipe.genericViewFallback && content != null && (recipe.className != null || recipe.action != _view))
        IntentSpec(
          packageName: env.installedPackage,
          action: _view,
          categories: const ['android.intent.category.DEFAULT'],
          data: content,
          mimeType: recipe.mimeType ?? 'application/octet-stream',
          flags: const ['newTask', 'clearTop'],
          grantReadUris: grants,
        ),
    ];
    return LaunchReady(IntentSpec(
      packageName: env.installedPackage,
      className: recipe.className,
      action: recipe.action,
      categories: recipe.categories,
      data: data,
      mimeType: data == null ? null : recipe.mimeType,
      extras: extras,
      flags: const ['newTask', 'clearTask', 'clearTop'],
      grantReadUris: usesContent ? grants : const [],
      fallbacks: fallbacks,
    ));
  }
}
