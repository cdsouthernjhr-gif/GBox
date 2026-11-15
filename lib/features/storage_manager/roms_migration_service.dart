import 'dart:io';

import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/rom_path_resolver.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/storage/gamebox_layout.dart';
import 'library_location_service.dart';

class MigrationResult {
  const MigrationResult({this.games = 0, this.files = 0, this.failed = const []});
  final int games;
  final int files;
  final List<String> failed;
}

/// Moves games kept in GAMEBOX's app folder (`Android/data/…`, the default
/// before 0.10.0: `GAMEBOX/Games/<CONSOLE>` and `GAMEBOX/Downloads`) into
/// the shared `ROMs/<system>/` folder, where RetroArch and other emulators
/// can read them. Library entries are updated in place, so play history,
/// favourites, artwork and saves stay linked to the game.
class RomsMigrationService {
  RomsMigrationService(this._db, this._location);
  final AppDatabase _db;
  final LibraryLocationService _location;

  Future<Map<int, List<GameFileRow>>> _appFolderGames() async {
    final out = <int, List<GameFileRow>>{};
    for (final f in await _db.select(_db.gameFiles).get()) {
      if (f.uri.startsWith('content://') || !isAppPrivateExternalPath(f.uri)) continue;
      if (!await File(f.uri).exists()) continue;
      (out[f.gameId] ??= []).add(f);
    }
    return out;
  }

  /// Games other emulators can't read because they're in the app folder.
  Future<int> countAppFolderGames() async => (await _appFolderGames()).length;

  /// Moves every app-folder game into `ROMs/<system>/` of the current
  /// location. Only meaningful when the location is public.
  Future<MigrationResult> moveAppFolderGamesToRoms() async {
    if (!_location.isPublic) {
      return const MigrationResult(failed: ['Allow storage access or choose a folder first.']);
    }
    var games = 0, files = 0;
    final failed = <String>[];
    final base = await _location.localBase();
    final tree = _location.treeUri;
    for (final entry in (await _appFolderGames()).entries) {
      try {
        final game = await _db.gameById(entry.key);
        final list = entry.value;
        final primary = list.firstWhere((f) => f.isPrimary, orElse: () => list.first);
        final primaryName = primary.uri.split('/').last;
        final rel = list.length > 1 ? '${gamesDirFor(game.consoleId)}/${stripExtension(primaryName)}' : gamesDirFor(game.consoleId);
        for (final f in list) {
          final placed = await _location.place(f.uri, rel);
          final segs = [...placed.dirSegments, placed.name];
          await _db.moveFile(
            f.id,
            uri: placed.location,
            // Relative to the scan root: the tree itself, or <base>/ROMs.
            displayPath: tree != null ? segs.join('/') : segs.skip(1).join('/'),
            rootUri: tree ?? '$base/$romsDir',
          );
          files++;
        }
        games++;
      } catch (e, s) {
        AppLogger.instance.error('Moving game ${entry.key} failed', e, s);
        failed.add('${entry.value.first.uri.split('/').last}: $e');
      }
    }
    return MigrationResult(games: games, files: files, failed: failed);
  }
}
