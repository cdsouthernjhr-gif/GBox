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
  });

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
    );
  }
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
