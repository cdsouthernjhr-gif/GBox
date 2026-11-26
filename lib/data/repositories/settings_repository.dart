import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';

enum AppThemeId { darkGaming, retroArcade, minimal, wallpaper }

extension AppThemeIdLabel on AppThemeId {
  String get label => switch (this) {
        AppThemeId.darkGaming => 'Dark Gaming',
        AppThemeId.retroArcade => 'Retro Arcade',
        AppThemeId.minimal => 'Minimal',
        AppThemeId.wallpaper => 'Custom Wallpaper',
      };
}

enum LowMemoryMode { auto, on, off }

enum GameSort { title, recentlyPlayed, recentlyAdded }

/// Immutable snapshot of user settings, persisted in the `app_settings` table.
class SettingsState {
  const SettingsState({
    this.theme = AppThemeId.darkGaming,
    this.wallpaperPreset = 0,
    this.animations = true,
    this.sounds = false,
    this.rescanOnStartup = true,
    this.lowMemoryMode = LowMemoryMode.auto,
    this.imageCacheMb = 48,
    this.gameSort = GameSort.title,
    this.defaultConsoleId,
    this.romFolders = const [],
    this.autoScan = true,
    this.stickNavigation = true,
    this.pauseDownloadsWhilePlaying = true,
    this.autoImportDownloads = true,
    this.downloadMaxGb = 8,
    this.allowHttpDownloads = false,
    this.libraryLocation,
    this.setupCompleted = false,
    this.homeStyle = HomeStyle.games,
    this.rowOrder = RowOrder.mostGames,
    this.playerTouch = PlayerTouch.auto,
    this.saveFolders = const [],
    this.accentColor,
    this.wallpaperImagePath,
    this.playerCores = const {},
  });

  /// Built-in player settings per core: `player.core.<core>.<name>` → value.
  final Map<String, String> playerCores;

  /// Display filter of [core]'s games (see [PlayerShader]).
  PlayerShader shaderFor(String core) =>
      PlayerShader.values.asNameMap()[playerCores[SettingsKeys.playerCore(core, 'shader')]] ?? PlayerShader.standard;

  /// On-screen controls for [core]: its own choice, else the general one.
  PlayerTouch touchFor(String core) =>
      PlayerTouch.values.asNameMap()[playerCores[SettingsKeys.playerCore(core, 'touch')]] ?? playerTouch;

  /// Whether [core] has its own on-screen controls choice.
  bool hasOwnTouch(String core) => playerCores.containsKey(SettingsKeys.playerCore(core, 'touch'));

  /// Registered emulator save folders.
  final List<SaveFolder> saveFolders;

  /// Custom accent colour (ARGB) or null for the theme default.
  final int? accentColor;

  /// Cached custom wallpaper image (Custom Wallpaper theme).
  final String? wallpaperImagePath;

  /// Downloads must not interfere with gameplay (spec Part 13).
  final bool pauseDownloadsWhilePlaying;

  /// Import finished downloads whose console is known.
  final bool autoImportDownloads;

  /// Largest single download allowed.
  final int downloadMaxGb;

  /// Accept plain http:// sources and downloads (unencrypted).
  final bool allowHttpDownloads;

  /// SAF tree URI of a user-chosen public GAMEBOX folder, or null for the
  /// app-specific folder (`Android/data/com.gamebox.console/files/GAMEBOX`).
  final String? libraryLocation;

  /// The setup wizard was finished (or skipped) once.
  final bool setupCompleted;

  /// What HOME shows: the game launcher (rows per console) or the dashboard.
  final HomeStyle homeStyle;

  /// Order of the console rows on the game launcher.
  final RowOrder rowOrder;

  /// On-screen controls of the built-in player.
  final PlayerTouch playerTouch;

  /// Left stick / hat navigates the launcher using each controller's dead zone.
  final bool stickNavigation;

  /// Rescan game folders at startup and when storage is connected.
  final bool autoScan;

  final AppThemeId theme;
  final int wallpaperPreset;
  final bool animations;
  final bool sounds;
  final bool rescanOnStartup;
  final LowMemoryMode lowMemoryMode;
  final int imageCacheMb;
  final GameSort gameSort;
  final String? defaultConsoleId;

  /// Storage Access Framework tree URIs registered as ROM folders.
  final List<String> romFolders;

  static T _enum<T extends Enum>(List<T> values, String? name, T fallback) =>
      values.firstWhere((v) => v.name == name, orElse: () => fallback);

  factory SettingsState.fromMap(Map<String, String> m) {
    const d = SettingsState();
    List<String> folders = const [];
    try {
      final raw = m[SettingsKeys.romFolders];
      if (raw != null) folders = (jsonDecode(raw) as List).cast<String>();
    } catch (_) {}
    return SettingsState(
      theme: _enum(AppThemeId.values, m[SettingsKeys.theme], d.theme),
      wallpaperPreset:
          int.tryParse(m[SettingsKeys.wallpaperPreset] ?? '') ?? d.wallpaperPreset,
      animations: (m[SettingsKeys.animations] ?? '${d.animations}') == 'true',
      sounds: (m[SettingsKeys.sounds] ?? '${d.sounds}') == 'true',
      rescanOnStartup:
          (m[SettingsKeys.rescanOnStartup] ?? '${d.rescanOnStartup}') == 'true',
      lowMemoryMode:
          _enum(LowMemoryMode.values, m[SettingsKeys.lowMemoryMode], d.lowMemoryMode),
      imageCacheMb: int.tryParse(m[SettingsKeys.imageCacheMb] ?? '') ?? d.imageCacheMb,
      gameSort: _enum(GameSort.values, m[SettingsKeys.gameSort], d.gameSort),
      defaultConsoleId: (m[SettingsKeys.defaultConsole]?.isEmpty ?? true)
          ? null
          : m[SettingsKeys.defaultConsole],
      romFolders: folders,
      autoScan: (m[SettingsKeys.autoScan] ?? 'true') == 'true',
      stickNavigation: (m[SettingsKeys.stickNavigation] ?? 'true') == 'true',
      pauseDownloadsWhilePlaying: (m[SettingsKeys.pauseDownloadsWhilePlaying] ?? 'true') == 'true',
      autoImportDownloads: (m[SettingsKeys.autoImportDownloads] ?? 'true') == 'true',
      downloadMaxGb: int.tryParse(m[SettingsKeys.downloadMaxGb] ?? '') ?? 8,
      allowHttpDownloads: (m[SettingsKeys.allowHttpDownloads] ?? 'false') == 'true',
      libraryLocation: (m[SettingsKeys.libraryLocation]?.isEmpty ?? true) ? null : m[SettingsKeys.libraryLocation],
      setupCompleted: (m[SettingsKeys.setupCompleted] ?? 'false') == 'true',
      homeStyle: HomeStyle.values.asNameMap()[m[SettingsKeys.homeStyle]] ?? HomeStyle.games,
      rowOrder: RowOrder.values.asNameMap()[m[SettingsKeys.rowOrder]] ?? RowOrder.mostGames,
      playerTouch: PlayerTouch.values.asNameMap()[m[SettingsKeys.playerTouch]] ?? PlayerTouch.auto,
      saveFolders: SaveFolder.decodeList(m[SettingsKeys.saveFolders]),
      accentColor: int.tryParse(m[SettingsKeys.accentColor] ?? ''),
      wallpaperImagePath: (m[SettingsKeys.wallpaperImage]?.isEmpty ?? true) ? null : m[SettingsKeys.wallpaperImage],
      playerCores: {
        for (final e in m.entries)
          if (e.key.startsWith(SettingsKeys.playerCorePrefix) && e.value.isNotEmpty) e.key: e.value,
      },
    );
  }
}

class SaveFolder {
  const SaveFolder(this.uri, this.emulatorId);
  final String uri;
  final String? emulatorId;

  Map<String, Object?> toJson() => {'uri': uri, 'emulator': emulatorId};

  static List<SaveFolder> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          SaveFolder((e as Map)['uri'] as String, e['emulator'] as String?),
      ];
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<SaveFolder> list) => jsonEncode([for (final f in list) f.toJson()]);
}

abstract final class SettingsKeys {
  static const theme = 'general.theme';
  static const wallpaperPreset = 'general.wallpaper_preset';
  static const animations = 'general.animations';
  static const sounds = 'general.sounds';
  static const rescanOnStartup = 'startup.rescan_hardware';
  static const lowMemoryMode = 'performance.low_memory_mode';
  static const imageCacheMb = 'performance.image_cache_mb';
  static const gameSort = 'gaming.sort';
  static const defaultConsole = 'gaming.default_console';
  static const romFolders = 'storage.rom_folders';
  static const autoScan = 'gaming.auto_scan';
  static const stickNavigation = 'controller.stick_navigation';
  static const pauseDownloadsWhilePlaying = 'downloads.pause_while_playing';
  static const autoImportDownloads = 'downloads.auto_import';
  static const downloadMaxGb = 'downloads.max_size_gb';
  static const allowHttpDownloads = 'downloads.allow_http';
  static const libraryLocation = 'storage.library_location';
  static const setupCompleted = 'setup.completed';
  static const homeStyle = 'launcher.home_style';
  static const rowOrder = 'launcher.row_order';
  static const playerTouch = 'player.touch_controls';
  static const saveFolders = 'saves.folders';
  static const accentColor = 'theme.accent_color';
  static const wallpaperImage = 'theme.wallpaper_image';
  static const playerCorePrefix = 'player.core.';
  static String playerCore(String core, String name) => '$playerCorePrefix$core.$name';
}

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  final ValueNotifier<SettingsState> state = ValueNotifier(const SettingsState());
  StreamSubscription<Map<String, String>>? _sub;

  Future<void> initialize() async {
    final completer = Completer<void>();
    _sub = _db.watchSettings().listen((m) {
      state.value = SettingsState.fromMap(m);
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  Future<void> set(String key, Object value) => _db.setSetting(key, '$value');

  Future<void> setRomFolders(List<String> uris) =>
      _db.setSetting(SettingsKeys.romFolders, jsonEncode(uris));

  void dispose() => _sub?.cancel();
}

enum HomeStyle {
  /// Game launcher: rows of games per console, opens straight on a game.
  games,

  /// Dashboard with device status and summary rows (before 0.11.0).
  dashboard,
}

enum RowOrder { mostGames, recentlyPlayed, alphabetical }

/// Built-in player on-screen controls: automatic (phones without a
/// controller), always, never.
enum PlayerTouch { auto, on, off }

/// Built-in player display filter (LibretroDroid shaders). [wire] is the
/// value sent to the player.
enum PlayerShader {
  standard('default', 'Standard'),
  sharp('sharp', 'Sharp pixels'),
  crt('crt', 'CRT TV (scanlines)'),
  lcd('lcd', 'LCD (handheld screen)'),
  smooth('smooth', 'Smooth (upscaled edges)');

  const PlayerShader(this.wire, this.label);
  final String wire;
  final String label;
}

