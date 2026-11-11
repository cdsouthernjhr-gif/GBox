/// Universal Emulator Adapter contract (spec Part 9).
///
/// The UI talks to adapters only through the emulator manager, never to
/// emulator internals. Phase 1 ships the contract plus a generic external-app
/// adapter that can detect and open an installed emulator. Per-emulator game
/// launching (each emulator documents different intents/extras) is added in
/// Phase 3 as one adapter class per emulator, after execution testing.
library;

import '../../core/constants/console_catalog.dart';
import '../../core/services/platform_gateway.dart';

enum InstallStatus { installed, notInstalled, unknown }

class LaunchResult {
  const LaunchResult.success() : ok = true, error = null;
  const LaunchResult.failure(this.error) : ok = false;
  final bool ok;
  final String? error;
}

abstract class EmulatorAdapter {
  String get emulatorName;
  List<String> get consoleIds;
  IntegrationStrategy get strategy;
  String? get installedVersion;
  InstallStatus get installStatus;
  int? get minAndroidSdk;
  List<String> get supportedAbis;
  List<String> supportedExtensions(String consoleId);
  String get launchMechanism;
  bool get supportsSaveStates;
  bool get supportsControllers;
  List<String> get knownLimitations;

  /// Re-checks installation status.
  Future<InstallStatus> refresh();

  /// Opens the emulator app itself (its own UI).
  Future<LaunchResult> openEmulator();

  /// Launches a specific game. Adapters that have not been execution-tested
  /// must return a failure instead of guessing an intent.
  Future<LaunchResult> launchGame({required String gameUri, required String consoleId});
}

/// Generic adapter for a user-installed external emulator app.
class ExternalAppAdapter implements EmulatorAdapter {
  ExternalAppAdapter(this.emulator, this._gateway);

  final KnownEmulator emulator;
  final PlatformGateway _gateway;
  String? _package;
  String? _version;
  InstallStatus _status = InstallStatus.unknown;

  @override
  String get emulatorName => emulator.name;
  @override
  List<String> get consoleIds => emulator.consoleIds;
  @override
  IntegrationStrategy get strategy => emulator.strategy;
  @override
  String? get installedVersion => _version;
  @override
  InstallStatus get installStatus => _status;
  @override
  int? get minAndroidSdk => emulator.minSdk;
  @override
  List<String> get supportedAbis =>
      emulator.requiresArm64 ? const ['arm64-v8a'] : const ['armeabi-v7a', 'arm64-v8a'];
  @override
  List<String> supportedExtensions(String consoleId) =>
      consoleById(consoleId)?.extensions ?? const [];
  @override
  String get launchMechanism => 'Android launch intent (package ${_package ?? emulator.packageIds.first})';
  @override
  bool get supportsSaveStates => true;
  @override
  bool get supportsControllers => true;
  @override
  List<String> get knownLimitations => [
        'Direct game launch not yet implemented for this emulator (Phase 3).',
        if (emulator.notes != null) emulator.notes!,
      ];

  @override
  Future<InstallStatus> refresh() async {
    final versions = await _gateway.installedVersions(emulator.packageIds);
    _package = emulator.packageIds.where(versions.containsKey).firstOrNull;
    _version = _package == null ? null : versions[_package];
    _status = _package == null ? InstallStatus.notInstalled : InstallStatus.installed;
    return _status;
  }

  @override
  Future<LaunchResult> openEmulator() async {
    if (_status == InstallStatus.unknown) await refresh();
    final pkg = _package;
    if (pkg == null) return const LaunchResult.failure('Emulator is not installed');
    final ok = await _gateway.launchApp(pkg);
    return ok
        ? const LaunchResult.success()
        : const LaunchResult.failure('Android could not start the emulator');
  }

  @override
  Future<LaunchResult> launchGame({required String gameUri, required String consoleId}) async =>
      const LaunchResult.failure(
          'Game launching for this emulator is planned for Phase 3 and has not been tested yet.');
}
