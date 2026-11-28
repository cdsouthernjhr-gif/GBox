import 'dart:convert';
import 'dart:io';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/rom_path_resolver.dart';
import '../../core/storage/gamebox_layout.dart';
import '../storage_manager/library_location_service.dart';

/// libretro database names (thumbnail folders) per console.
const retroArchDbNames = <String, String>{
  'nes': 'Nintendo - Nintendo Entertainment System',
  'snes': 'Nintendo - Super Nintendo Entertainment System',
  'sms': 'Sega - Master System - Mark III',
  'neogeo': 'SNK - Neo Geo',
  'arcade': 'FBNeo - Arcade Games',
  'megadrive': 'Sega - Mega Drive - Genesis',
  'gb': 'Nintendo - Game Boy',
  'gbc': 'Nintendo - Game Boy Color',
  'gba': 'Nintendo - Game Boy Advance',
  'ps1': 'Sony - PlayStation',
  'n64': 'Nintendo - Nintendo 64',
  'saturn': 'Sega - Saturn',
  'nds': 'Nintendo - Nintendo DS',
  'psp': 'Sony - PlayStation Portable',
  'dreamcast': 'Sega - Dreamcast',
  'gamecube': 'Nintendo - GameCube',
  'ps2': 'Sony - PlayStation 2',
  'wii': 'Nintendo - Wii',
};

class PlaylistResult {
  const PlaylistResult({this.playlists = 0, this.games = 0, this.unreadable = 0, this.dirs = const [], this.note});
  final int playlists;
  final int games;

  /// Games RetroArch can't open by path (app folder, no path).
  final int unreadable;
  final List<String> dirs;
  final String? note;
}

/// Writes RetroArch playlists (`.lpl`, JSON format of RetroArch 1.7.6+) for
/// the library, so the games appear in RetroArch's own menu. Files are named
/// `GAMEBOX - <console>.lpl` and never replace playlists RetroArch made.
/// Entries use RetroArch's "DETECT" core, so RetroArch offers the installed
/// cores the first time a game is started.
class RetroArchPlaylistService {
  RetroArchPlaylistService(this._db, this._location);
  final AppDatabase _db;
  final LibraryLocationService _location;

  static String fileNameFor(String consoleId) => 'GAMEBOX - ${consoleById(consoleId)!.name}.lpl';

  /// Folders playlists are written to: GAMEBOX/Playlists, plus RetroArch's
  /// own playlists folder when it exists on shared storage.
  Future<List<String>> targetDirs() async {
    final a = _location.access.value;
    if (!a.granted || a.publicRoot == null) {
      // Without storage access only the app folder could be written, which
      // RetroArch can't read.
      return const [];
    }
    final base = await _location.localBase() ?? a.publicRoot!;
    return [
      '$base/$playlistsDir',
      if (await Directory('${a.publicRoot}/RetroArch/playlists').exists()) '${a.publicRoot}/RetroArch/playlists',
    ];
  }

  /// Builds the playlist JSON for [items] (path, label) of one console.
  static String playlistJson(String consoleId, List<(String path, String label)> items) {
    final db = '${retroArchDbNames[consoleId]}.lpl';
    return const JsonEncoder.withIndent('  ').convert({
      'version': '1.5',
      'default_core_path': '',
      'default_core_name': '',
      'label_display_mode': 0,
      'right_thumbnail_mode': 0,
      'left_thumbnail_mode': 0,
      'sort_mode': 0,
      'items': [
        for (final (path, label) in items)
          {'path': path, 'label': label, 'core_path': 'DETECT', 'core_name': 'DETECT', 'crc32': 'DETECT', 'db_name': db},
      ],
    });
  }

  Future<PlaylistResult> writeAll() async {
    final dirs = await targetDirs();
    if (dirs.isEmpty) {
      return const PlaylistResult(note: 'Allow storage access first, so RetroArch can read the playlists.');
    }
    final games = {for (final g in await _db.select(_db.games).get()) g.id: g};
    final byConsole = <String, List<(String, String)>>{};
    var unreadable = 0;
    for (final f in await _db.select(_db.gameFiles).get()) {
      if (!f.isPrimary || !f.fileExists) continue;
      final g = games[f.gameId];
      if (g == null || !retroArchDbNames.containsKey(g.consoleId)) continue;
      final path = f.uri.startsWith('content://') ? resolveFilesystemPath(f.uri) : f.uri;
      if (path == null || isAppPrivateExternalPath(path)) {
        unreadable++;
        continue;
      }
      (byConsole[g.consoleId] ??= []).add((path, g.title));
    }
    var playlists = 0, count = 0;
    final written = <String>[];
    for (final dir in dirs) {
      try {
        await Directory(dir).create(recursive: true);
        for (final c in retroArchDbNames.keys) {
          final file = File('$dir/${fileNameFor(c)}');
          final items = (byConsole[c] ?? [])..sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
          if (items.isEmpty) {
            if (await file.exists()) await file.delete(); // our own, now empty
            continue;
          }
          await file.writeAsString(playlistJson(c, items));
          if (dir == dirs.first) {
            playlists++;
            count += items.length;
          }
        }
        written.add(dir);
      } catch (e, s) {
        AppLogger.instance.error('Writing RetroArch playlists to $dir failed', e, s);
      }
    }
    return PlaylistResult(playlists: playlists, games: count, unreadable: unreadable, dirs: written);
  }
}
