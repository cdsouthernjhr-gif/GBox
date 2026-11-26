import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/device/device_intelligence_service.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/console_mismatch.dart';
import '../../core/rom/rom_path_resolver.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/services/system_services.dart';
import '../../domain/entities/performance_tier.dart';
import 'player_files.dart';
import '../../integrations/builtin/builtin_player_launcher.dart';
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
  const LaunchOutcome.started({required this.emulatorName, this.notes = const []})
      : ok = true,
        reasons = const [],
        missingEmulators = const [],
        wrongConsole = null;
  const LaunchOutcome.blocked(this.reasons, {this.emulatorName, this.missingEmulators = const [], this.wrongConsole})
      : ok = false,
        notes = const [];
  final bool ok;

  /// The console the game file really belongs to, when it is filed under
  /// another one (the UI offers to move it or get that console's emulator).
  final String? wrongConsole;

  /// Emulators that could play the game but aren't installed (the UI offers
  /// where to get them).
  final List<String> missingEmulators;
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
    this.playerFiles,
    this.touchControls,
  });

  /// Prepares files for the built-in player (null in tests that don't use it).
  PlayerFiles? playerFiles;

  /// Built-in player settings for a core: on-screen controls (auto | on |
  /// off) and display filter (PlayerShader.wire).
  String Function(String core)? touchControls;
  String Function(String core)? playerShader;

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

  /// Set when the built-in player stopped unexpectedly (shown by the UI).
  final ValueNotifier<PlayerCrash?> playerCrash = ValueNotifier(null);

  /// Set to the game id when the built-in player could not open the game
  /// (the UI offers other emulators).
  final ValueNotifier<int?> playerCouldNotOpen = ValueNotifier(null);

  /// The console [game]'s file belongs to when it is not the game's console
  /// (from the file header); null when it matches or can't be told.
  Future<String?> wrongConsoleOf(GameRow game, GameFileRow primary) async {
    try {
      final bytes = await _gateway.readBytes(primary.uri, length: consoleCheckBytes);
      return otherConsoleFromHeader(game.consoleId, primary.extension, bytes);
    } catch (_) {
      return null;
    }
  }

  /// Looks for a crash of the built-in player (after GAMEBOX restarts, or on
  /// return from a game). Returns true when one was found.
  Future<bool> checkPlayerCrash() async {
    Map<String, dynamic>? r;
    try {
      r = await _gateway.playerCrashReport();
    } catch (_) {
      return false;
    }
    if (r == null) return false;
    final crash = PlayerCrash(
      core: '${r['core'] ?? ''}',
      game: '${r['rom'] ?? ''}'.split('/').last,
      frames: (r['frames'] as num?)?.toInt() ?? 0,
      message: '${r['message'] ?? ''}',
      log: '${r['log'] ?? ''}',
    );
    AppLogger.instance.error('Built-in player stopped unexpectedly: ${crash.details}');
    playerCrash.value = crash;
    return true;
  }

  Future<List<LaunchChoice>> choicesFor(String consoleId) async {
    if (_emulators.installations.value == null) await _emulators.detect();
    final installs = _emulators.installations.value ?? const [];
    return [
      for (final a in launchersForConsole(consoleId))
        LaunchChoice(
          adapter: a,
          installedPackage: a.builtIn
              ? (builtInSupportsDevice(consoleId, _device.state.value.profile?.supportedAbis ?? const [])
                  ? gameboxPackage
                  : null)
              : installs.where((i) => i.emulator.id == a.emulatorId).firstOrNull?.installedPackage,
          options: a.options(consoleId),
        ),
    ];
  }

  /// [emulatorId]/[options] override the console default. With [remember]
  /// the choice becomes the console default. Unless [checkConsole] is false,
  /// a game whose file belongs to another console is not started.
  Future<LaunchOutcome> play(
    int gameId, {
    String? emulatorId,
    Map<String, String>? options,
    bool remember = false,
    bool checkConsole = true,
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
    if (checkConsole) {
      final other = await wrongConsoleOf(game, primary);
      if (other != null) {
        return LaunchOutcome.blocked([
          'This file looks like a ${consoleById(other)?.name ?? other} game, but it is in the '
              '${consoleById(game.consoleId)?.name ?? game.consoleId} list. '
              'Each emulator only plays games of its own console.',
        ], wrongConsole: other);
      }
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
      return LaunchOutcome.blocked(
        [
          emulatorId == null
              ? 'No compatible emulator is installed. Install $names from its official source, then try again.'
              : '${choice?.adapter.emulator.name ?? emulatorId} is not installed.',
        ],
        missingEmulators: emulatorId != null
            ? [emulatorId]
            : [for (final c in choices) if (!c.installed) c.adapter.emulatorId],
      );
    }

    // Built-in player: a file GAMEBOX can read, plus BIOS and save folders.
    PlayerPreparation? prep;
    if (choice.adapter.builtIn) {
      final pf = playerFiles;
      prep = pf == null
          ? PlayerPreparation(romPath: resolveFilesystemPath(primary.uri))
          : await pf.prepare(game, files);
      if (prep.problem != null) return LaunchOutcome.blocked([prep.problem!], emulatorName: choice.adapter.emulator.name);
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
      localPath: prep?.romPath,
      title: game.title,
    );
    // Unknown SDK → assume the stricter Android 11+ storage rules.
    final profile = _device.state.value.profile;
    final env = LaunchEnvironment(
      installedPackage: choice.installedPackage!,
      sdkInt: profile?.sdkInt ?? 30,
      supportsArm64: profile == null || profile.supportedAbis.isEmpty || profile.supportsArm64,
      systemDir: prep?.systemDir,
      savesDir: prep?.savesDir,
      touchControls: touchControls?.call(builtInCores[game.consoleId] ?? '') ?? 'auto',
      shader: playerShader?.call(builtInCores[game.consoleId] ?? '') ?? 'default',
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
    // A crash of the built-in player replaces the "how did it run?" question.
    if (g != null && g.$2 == builtInPlayerId && await checkPlayerCrash()) return;
    // So does a game the built-in player could not open.
    if (g != null && g.$2 == builtInPlayerId) {
      try {
        final st = await _gateway.playerStatus();
        if (st['state'] == 'error' && st['errorKind'] == 'load_game') {
          playerCouldNotOpen.value = g.$1;
          return;
        }
      } catch (_) {}
    }
    if (g != null) finishedSession.value = g;
  }
}

/// The built-in player stopped unexpectedly.
class PlayerCrash {
  const PlayerCrash({required this.core, required this.game, required this.frames, required this.message, required this.log});
  final String core;
  final String game;

  /// Frames shown before it stopped (0: it never started).
  final int frames;
  final String message;
  final String log;

  /// Text for the user to send to the developer.
  String get details => [
        'GAMEBOX built-in player stopped unexpectedly',
        'Core: $core',
        'Game: $game',
        'Frames shown: $frames',
        if (message.isNotEmpty) 'Error: $message',
        if (log.isNotEmpty) '--- log ---\n$log',
      ].join('\n');
}

