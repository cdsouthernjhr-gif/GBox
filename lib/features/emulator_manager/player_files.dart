import 'dart:io';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/online/archive_guard.dart';
import '../../core/rom/console_detector.dart' show archiveGameConsoles;
import '../../core/rom/rom_path_resolver.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/services/platform_gateway.dart';
import '../../core/storage/gamebox_layout.dart';
import '../../integrations/builtin/builtin_player_launcher.dart';

/// Files and folders the built-in player needs for one game.
class PlayerPreparation {
  const PlayerPreparation({this.romPath, this.systemDir, this.savesDir, this.problem});
  final String? romPath;
  final String? systemDir;
  final String? savesDir;
  final String? problem;
}

/// Gives the built-in player a game file it can open by path:
/// * a path GAMEBOX can read (shared storage with access, its app folder);
/// * otherwise a copy in the cache (games in picked SAF folders), with all
///   files of the game (e.g. the .bin tracks of a .cue);
/// * ZIP archives are extracted (the cores don't open archives).
/// Also picks the BIOS folder (`GAMEBOX/BIOS/<CONSOLE>`) and the save folder
/// (`GAMEBOX/Saves/GAMEBOX/<system>`).
class PlayerFiles {
  PlayerFiles({required this._gateway, required this._cacheDir, required this._dataBase});

  final PlatformGateway _gateway;

  /// Temporary folder for copies/extractions (cleared per launch).
  final Future<String> Function() _cacheDir;

  /// Local base whose `GAMEBOX/` holds BIOS and saves.
  final Future<String> Function() _dataBase;

  static Future<bool> _readable(String path) async {
    try {
      final f = await File(path).open();
      await f.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<PlayerPreparation> prepare(GameRow game, List<GameFileRow> files) async {
    final primary = files.firstWhere((f) => f.isPrimary, orElse: () => files.first);
    final cacheRoot = '${await _cacheDir()}/player';
    final work = Directory('$cacheRoot/${game.id}');
    try {
      // Only the current game's copy is kept.
      final root = Directory(cacheRoot);
      if (await root.exists()) {
        await for (final e in root.list()) {
          if (e.path != work.path) await e.delete(recursive: true);
        }
      }

      String? path = primary.uri.startsWith('content://') ? resolveFilesystemPath(primary.uri) : primary.uri;
      if (path == null || !await _readable(path)) {
        // Copy every file of the game, keeping their names (cue → bin).
        await work.create(recursive: true);
        String? copied;
        for (final f in files) {
          final name = f.displayPath.split('/').last;
          final dest = '${work.path}/$name';
          if (!await File(dest).exists()) await _gateway.copyToLocal(f.uri, dest);
          if (identical(f, primary) || f.id == primary.id) copied = dest;
        }
        path = copied;
      }
      if (path == null) return const PlayerPreparation(problem: 'GAMEBOX could not read the game file.');

      final ext = extensionOf(path);
      // Arcade romsets are read as archives by the core (never extracted).
      if (archiveGameConsoles.contains(game.consoleId)) {
        final bios = biosInfo.where((b) => b.consoleId == game.consoleId).firstOrNull;
        final base = await _dataBase();
        final system = '$base/${bios?.dir ?? '$dataDir/BIOS/ARCADE'}';
        final saves = '$base/$dataDir/Saves/GAMEBOX/${gamesDirFor(game.consoleId).split('/').last}';
        await Directory(system).create(recursive: true);
        await Directory(saves).create(recursive: true);
        return PlayerPreparation(romPath: path, systemDir: system, savesDir: saves);
      }
      if (ext == '7z') {
        return const PlayerPreparation(
            problem: '.7z archives are not supported by the built-in player. Extract the game, or use "Play with…".');
      }
      if (ext == 'zip') {
        final dest = '${work.path}/unzipped';
        final r = await extractZip(path, dest);
        if (!r.ok) return PlayerPreparation(problem: 'The ZIP archive was rejected: ${r.error}');
        final wanted = builtInExtensions[game.consoleId] ?? const <String>{};
        final inside = r.files.where((f) => wanted.contains(extensionOf(f))).toList()
          // Prefer descriptors (.cue/.m3u) over track files.
          ..sort((a, b) => _rank(extensionOf(a)).compareTo(_rank(extensionOf(b))));
        if (inside.isEmpty) return const PlayerPreparation(problem: 'The ZIP archive contains no game file for this console.');
        path = inside.first;
      }

      final base = await _dataBase();
      final console = consoleById(game.consoleId);
      final bios = biosInfo.where((b) => b.consoleId == game.consoleId).firstOrNull;
      final system = bios != null ? '$base/${bios.dir}' : '$base/$dataDir/BIOS/${console?.folderName ?? game.consoleId}';
      final saves = '$base/$dataDir/Saves/GAMEBOX/${gamesDirFor(game.consoleId).split('/').last}';
      await Directory(system).create(recursive: true);
      await Directory(saves).create(recursive: true);
      return PlayerPreparation(romPath: path, systemDir: system, savesDir: saves);
    } catch (e, s) {
      AppLogger.instance.error('Preparing ${game.title} for the built-in player failed', e, s);
      return PlayerPreparation(problem: 'GAMEBOX could not prepare the game: $e');
    }
  }

  static int _rank(String ext) => switch (ext) { 'm3u' => 0, 'cue' || 'ccd' || 'toc' => 1, _ => 2 };
}
