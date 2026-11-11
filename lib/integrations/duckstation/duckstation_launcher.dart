/// DuckStation (PlayStation) launcher, external-app strategy.
///
/// Launch interface: activity
/// `com.github.stenzek.duckstation.EmulationActivity` with the string extra
/// `bootPath`, which accepts a file path or a Storage Access Framework
/// content URI. GAMEBOX prefers the content URI and grants read access for
/// this launch only, so files in GAMEBOX folders and SAF folders work without
/// DuckStation needing broad storage access.
library;

import '../emulator_adapters/emulator_adapter.dart';

class DuckStationLauncher extends GameLauncherAdapter {
  static const activity = 'com.github.stenzek.duckstation.EmulationActivity';

  @override
  String get emulatorId => 'duckstation';

  @override
  Set<String> get consoleIds => const {'ps1'};

  @override
  bool get verifiedOnDevice => false;

  @override
  String get launchMechanism => 'EmulationActivity with bootPath extra (content URI with read grant, or path)';

  @override
  List<String> get knownLimitations => const [
        'A PS1 BIOS dump must be configured inside DuckStation by the user.',
        'Licence terms for DuckStation have changed over time; GAMEBOX only launches a user-installed copy.',
      ];

  @override
  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options) {
    if (target.consoleId != 'ps1') return const LaunchBlocked(['DuckStation only runs PlayStation games.']);
    final content = target.contentUri;
    final boot = content ?? target.filesystemPath;
    if (boot == null) {
      return const LaunchBlocked(['GAMEBOX could not obtain a path or shareable link for this file.']);
    }
    return LaunchReady(IntentSpec(
      packageName: env.installedPackage,
      className: activity,
      action: 'android.intent.action.MAIN',
      categories: const ['android.intent.category.DEFAULT'],
      extras: {'bootPath': boot},
      flags: const ['newTask', 'clearTask', 'clearTop'],
      grantReadUris: [?content],
    ));
  }
}
