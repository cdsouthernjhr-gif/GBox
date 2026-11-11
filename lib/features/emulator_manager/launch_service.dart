import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/device/device_intelligence_service.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/rom_path_resolver.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/services/system_services.dart';
import '../../domain/entities/performance_tier.dart';
import '../../integrations/emulator_adapters/emulator_adapter.dart';
import '../../integrations/emulator_adapters/launcher_registry.dart';

class LaunchChoice {
  const LaunchChoice({required this.adapter, required this.installedPackage, required this.options});
  final GameLauncherAdapter adapter;

  /// Null when the emulator is not installed.
  final String? installedPackage;
  final List<LaunchOption> options;
  bool get installed => installedPackage != null;
}

class LaunchOutcome {
  const LaunchOutcome.started({required this.emulatorName, this.notes = const []}) : ok = true, reasons = const [];
  const LaunchOutcome.blocked(this.reasons, {this.emulatorName}) : ok = false, notes = const [];
  final bool ok;
  final String? emulatorName;
  final List<String> reasons;
  final List<String> notes;
}

/// Launches games through external emulator apps and records play history.
/// Works offline; never downloads or modifies emulators.
class LaunchService {
  LaunchService({
    required this._gateway,
    required this._db,
    required this._emulators,
    required this._device,
    this._beforeLaunch,
  });

  final PlatformGateway _gateway;
  final AppDatabase _db;
  final EmulatorDetectionService _emulators;
  final DeviceIntelligenceService _device;

  /// Frees caches before handing the device to the emulator (spec Part 17).
  final void Function()? _beforeLaunch;

  int? _activeSession;
  int? get activeSession => _activeSession;
  (int, String)? _activeGame;

  /// Set when the user returns from a game: (gameId, emulatorId). The UI
  /// uses it to ask how the game ran (optional local compatibility result).
  final ValueNotifier<(int, String)?> finishedSession = ValueNotifier(null);

  Future<List<LaunchChoice>> choicesFor(String consoleId) async {
    if (_emulators.installations.value == null) await _emulators.detect();
    final installs = _emulators.installations.value ?? const [];
    return [
      for (final a in launchersForConsole(consoleId))
        LaunchChoice(
          adapter: a,
          installedPackage: installs.where((i) => i.emulator.id == a.emulatorId).firstOrNull?.installedPackage,
          options: a.options(consoleId),
        ),
    ];
  }

  /// [emulatorId]/[options] override the console default. With [remember]
  /// the choice becomes the console default.
  Future<LaunchOutcome> play(
    int gameId, {
    String? emulatorId,
    Map<String, String>? options,
    bool remember = false,
  }) async {
    final game = await _db.gameById(gameId);
    final files = await _db.filesForGame(gameId);
    if (files.isEmpty) return const LaunchOutcome.blocked(['No file is recorded for this game.']);
    final primary = files.firstWhere((f) => f.isPrimary, orElse: () => files.first);
    if (!primary.fileExists) {
      return const LaunchOutcome.blocked([
        'The game file is missing. Reconnect the storage it was on, or rescan your folders.',
      ]);
    }

    // Emulator selection: explicit → console default → first installed.
    await _emulators.detect();
    final choices = await choicesFor(game.consoleId);
    if (choices.isEmpty) {
      return const LaunchOutcome.blocked(['GAMEBOX cannot launch games for this console yet.']);
    }
    LaunchChoice? choice;
    var opts = options ?? <String, String>{};
    if (emulatorId != null) {
      choice = choices.where((c) => c.adapter.emulatorId == emulatorId).firstOrNull;
    } else {
      final profile = await _db.defaultLaunchProfile(game.consoleId);
      if (profile != null) {
        choice = choices.where((c) => c.adapter.emulatorId == profile.emulatorId && c.installed).firstOrNull;
        if (choice != null && options == null) {
          try {
            opts = Map<String, String>.from(jsonDecode(profile.settingsJson) as Map);
          } catch (_) {}
        }
      }
      choice ??= choices.where((c) => c.installed).firstOrNull;
    }
    if (choice == null || !choice.installed) {
      final names = choices.map((c) => c.adapter.emulator.name).join(' or ');
      return LaunchOutcome.blocked([
        emulatorId == null
            ? 'No compatible emulator is installed. Install $names from its official source, then try again.'
            : '${choice?.adapter.emulator.name ?? emulatorId} is not installed.',
      ]);
    }

    final path = resolveFilesystemPath(primary.uri);
    String? content;
    if (primary.uri.startsWith('content://')) {
      content = primary.uri;
    } else if (path != null) {
      try {
        content = await _gateway.shareableUri(path);
      } catch (_) {}
    }
    final target = LaunchTarget(
      consoleId: game.consoleId,
      originalUri: primary.uri,
      extension: primary.extension,
      filesystemPath: path,
      contentUri: content,
    );
    // Unknown SDK → assume the stricter Android 11+ storage rules.
    final profile = _device.state.value.profile;
    final env = LaunchEnvironment(
      installedPackage: choice.installedPackage!,
      sdkInt: profile?.sdkInt ?? 30,
      supportsArm64: profile == null || profile.supportedAbis.isEmpty || profile.supportsArm64,
    );
    final name = choice.adapter.emulator.name;
    final plan = choice.adapter.plan(target, env, opts);
    switch (plan) {
      case LaunchBlocked(:final reasons):
        return LaunchOutcome.blocked(reasons, emulatorName: name);
      case LaunchReady(:final spec, notes: final adapterNotes):
        final notes = [...adapterNotes, ?_performanceWarning(game.consoleId, choice.adapter)];
        _beforeLaunch?.call();
        final r = await _gateway.launchIntent(spec.toMap());
        if (r['ok'] != true) {
          AppLogger.instance.warn('Launch via $name failed: ${r['code']} ${r['error']}');
          return LaunchOutcome.blocked(['$name could not be started: ${r['error'] ?? 'unknown error'}'],
              emulatorName: name);
        }
        if (remember) await _db.setDefaultLaunchProfile(game.consoleId, choice.adapter.emulatorId, opts);
        await onReturned(); // close any session left open
        _activeSession = await _db.startPlaySession(gameId, choice.adapter.emulatorId, DateTime.now());
        _activeGame = (gameId, choice.adapter.emulatorId);
        AppLogger.instance.info('Launched game $gameId with $name (${env.installedPackage})');
        return LaunchOutcome.started(emulatorName: name, notes: notes);
    }
  }

  /// Hardware-based warning when this device is below the estimated tier for
  /// the console (never blocks; the estimate is not a measurement).
  String? _performanceWarning(String consoleId, GameLauncherAdapter adapter) {
    final st = _device.state.value;
    final console = consoleById(consoleId);
    if (st.profile == null || st.classification == null || console == null) return null;
    final e = _device.classifier.estimate(st.profile!, st.classification!, console, emulator: adapter.emulator);
    return switch (e.rating) {
      CompatibilityRating.limited =>
        'This device is below the estimated requirement for ${console.name}; games may run slowly.',
      CompatibilityRating.unsupported => 'Hardware check: ${e.reasons.join(' ')} The game may not start.',
      _ => null,
    };
  }

  /// Called when GAMEBOX returns to the foreground.
  Future<void> onReturned() async {
    final s = _activeSession;
    if (s == null) return;
    _activeSession = null;
    await _db.endPlaySession(s, DateTime.now());
    final g = _activeGame;
    _activeGame = null;
    if (g != null) finishedSession.value = g;
  }
}
