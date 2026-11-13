import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/online/archive_guard.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/saves/save_classifier.dart';
import '../../core/services/platform_gateway.dart';
import '../../data/repositories/settings_repository.dart';

class SaveScanResult {
  const SaveScanResult({this.found = 0, this.matched = 0, this.unmatched = const [], this.unavailable = const []});
  final int found;
  final int matched;

  /// Save files that could not be linked to exactly one game.
  final List<String> unmatched;

  /// Folders that could not be read (storage disconnected / access revoked).
  final List<String> unavailable;
}

class RestoreResult {
  const RestoreResult({required this.ok, this.message});
  final bool ok;
  final String? message;
}

/// Save Manager (Phase 7). Emulators keep saves in their own folders;
/// the user registers those folders (Storage Access Framework, with write
/// access for restore). GAMEBOX then finds save files, links them to games,
/// and backs them up / restores / exports them. It never converts saves
/// between emulators: states only work in the emulator (and usually the
/// version) that created them.
class SaveService {
  SaveService({
    required this._gateway,
    required this._db,
    required this._settings,
    required this._gameboxRoot,
  });

  final PlatformGateway _gateway;
  final AppDatabase _db;
  final SettingsRepository _settings;

  /// `<app folder>/GAMEBOX` on the primary volume.
  final Future<String> Function() _gameboxRoot;

  final ValueNotifier<SaveScanResult?> lastScan = ValueNotifier(null);

  static String _stamp(DateTime t) =>
      '${t.year}${_pad2(t.month)}${_pad2(t.day)}-${_pad2(t.hour)}${_pad2(t.minute)}${_pad2(t.second)}';
  static String _pad2(int v) => v.toString().padLeft(2, '0');

  Future<void> addFolder(String uri, String? emulatorId) async {
    final list = [..._settings.state.value.saveFolders.where((f) => f.uri != uri), SaveFolder(uri, emulatorId)];
    await _settings.set(SettingsKeys.saveFolders, SaveFolder.encodeList(list));
  }

  /// Adds several folders in one settings write (consecutive [addFolder]
  /// calls could overwrite each other before the settings stream updates).
  Future<void> addFolders(List<SaveFolder> folders) async {
    if (folders.isEmpty) return;
    final uris = {for (final f in folders) f.uri};
    final list = [..._settings.state.value.saveFolders.where((f) => !uris.contains(f.uri)), ...folders];
    await _settings.set(SettingsKeys.saveFolders, SaveFolder.encodeList(list));
    for (var i = 0; i < 50; i++) {
      final now = {for (final f in _settings.state.value.saveFolders) f.uri};
      if (now.containsAll(uris)) break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> removeFolder(String uri) async {
    await _settings.set(
        SettingsKeys.saveFolders, SaveFolder.encodeList(_settings.state.value.saveFolders.where((f) => f.uri != uri).toList()));
    await _db.replaceSavesInFolder(uri, const []);
  }

  Future<Map<int, List<String>>> _candidates() async {
    final games = await _db.select(_db.games).get();
    final files = await _db.select(_db.gameFiles).get();
    final map = {for (final g in games) g.id: <String>[g.title]};
    for (final f in files) {
      map[f.gameId]?.add(f.displayPath.split('/').last);
    }
    return map;
  }

  /// Scans every registered save folder [folders] (defaults to settings).
  Future<SaveScanResult> scan({List<SaveFolder>? folders}) async {
    final list = folders ?? _settings.state.value.saveFolders;
    final candidates = await _candidates();
    var found = 0, matched = 0;
    final unmatched = <String>[];
    final unavailable = <String>[];
    for (final folder in list) {
      List<ScannedEntry> entries;
      try {
        if (folder.uri.startsWith('content://')) {
          // `<tree>#<sub-folder>`: a folder inside the public GAMEBOX folder.
          final hash = folder.uri.indexOf('#');
          final tree = hash < 0 ? folder.uri : folder.uri.substring(0, hash);
          final sub = hash < 0 ? null : folder.uri.substring(hash + 1);
          if (!await _gateway.treeAccessible(tree)) {
            unavailable.add(folder.uri);
            continue;
          }
          final r = await _gateway.scanTree(tree, saveScanExtensions, maxDepth: 6, maxFiles: 5000, subPath: sub);
          entries = ((r['files'] as List?) ?? const [])
              .map((e) => ScannedEntry.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          final dir = Directory(folder.uri);
          if (!await dir.exists()) {
            unavailable.add(folder.uri);
            continue;
          }
          entries = [
            await for (final e in dir.list(recursive: true, followLinks: false))
              if (e is File && saveScanExtensions.contains(extensionOf(e.path)))
                ScannedEntry(
                  uri: e.path,
                  name: e.uri.pathSegments.last,
                  dirSegments: e.parent.path.substring(dir.path.length).split('/').where((s) => s.isNotEmpty).toList(),
                  size: await e.length(),
                  lastModified: (await e.lastModified()).millisecondsSinceEpoch,
                ),
          ];
        }
      } catch (e, s) {
        AppLogger.instance.error('Save folder scan failed', e, s);
        unavailable.add(folder.uri);
        continue;
      }
      final rows = <SaveStatesCompanion>[];
      for (final e in entries) {
        final info = classifySave(e.name);
        if (info == null) continue;
        found++;
        final gameId = matchSaveToGame(e.name, candidates);
        if (gameId == null) {
          unmatched.add(e.displayPath);
          continue;
        }
        matched++;
        rows.add(SaveStatesCompanion.insert(
          gameId: gameId,
          emulatorId: Value(folder.emulatorId),
          kind: info.kind.name,
          slot: Value(info.slot),
          path: e.uri,
          sizeBytes: Value(e.size),
          createdAt: e.lastModified == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(e.lastModified!),
          folderUri: Value(folder.uri),
          relativePath: Value(e.displayPath),
          lastModified: Value(e.lastModified),
        ));
      }
      await _db.replaceSavesInFolder(folder.uri, rows);
    }
    final r = SaveScanResult(found: found, matched: matched, unmatched: unmatched, unavailable: unavailable);
    lastScan.value = r;
    return r;
  }

  Future<String> _backupDir() async => '${await _gameboxRoot()}/Backups/saves';

  int _backupSeq = 0;

  /// A new, never-reused folder per backup run. Backups are never
  /// overwritten — a safety copy taken during a restore must not replace the
  /// backup being restored.
  Future<String> _newBackupFolder() async {
    final now = DateTime.now();
    final root = await _backupDir();
    while (true) {
      final dir = '$root/${_stamp(now)}-${now.millisecond.toString().padLeft(3, '0')}-${_backupSeq++}';
      if (!await Directory(dir).exists()) return dir;
    }
  }

  Future<int> _backupRows(List<SaveStateRow> saves, {String? note}) async {
    final base = await _newBackupFolder();
    var n = 0;
    for (final s in saves) {
      final rel = sanitizeRelative(s.relativePath ?? s.path.split('/').last);
      final dest = '$base/${s.gameId}/${s.emulatorId ?? 'unknown'}/$rel';
      if (await File(dest).exists()) continue; // never overwrite a backup
      try {
        final size = await _gateway.copyToLocal(s.path, dest);
        await _db.into(_db.saveBackups).insert(SaveBackupsCompanion.insert(
              gameId: Value(s.gameId),
              saveStateId: Value(s.id),
              backupPath: dest,
              sizeBytes: Value(size),
              note: Value(note),
              createdAt: DateTime.now(),
            ));
        n++;
      } catch (e, st) {
        AppLogger.instance.error('Backing up ${s.path} failed', e, st);
      }
    }
    return n;
  }

  /// Backs up all known save files of a game. Returns files copied.
  Future<int> backupGame(int gameId, {String? note}) async =>
      _backupRows((await _db.allSaves()).where((s) => s.gameId == gameId).toList(), note: note);

  Future<int> backupAll({String? note}) async => _backupRows(await _db.allSaves(), note: note);

  /// Restores one backup over the original save file. The current file is
  /// copied to a safety backup first, so a restore can always be undone.
  Future<RestoreResult> restore(int backupId) async {
    final b = await (_db.select(_db.saveBackups)..where((x) => x.id.equals(backupId))).getSingleOrNull();
    if (b == null) return const RestoreResult(ok: false, message: 'Backup not found');
    if (!await File(b.backupPath).exists()) {
      return const RestoreResult(ok: false, message: 'The backup file no longer exists');
    }
    final save = b.saveStateId == null
        ? null
        : await (_db.select(_db.saveStates)..where((s) => s.id.equals(b.saveStateId!))).getSingleOrNull();
    if (save == null) {
      return const RestoreResult(
          ok: false, message: 'The original save file is no longer known. Rescan save folders, then try again.');
    }
    final safety = await _backupRows([save], note: 'Automatic copy before restore');
    if (safety == 0) {
      return const RestoreResult(
          ok: false, message: 'Could not read the current save to protect it, so nothing was restored.');
    }
    try {
      await _gateway.copyFromLocal(b.backupPath, save.path);
      return const RestoreResult(ok: true);
    } catch (e) {
      return RestoreResult(
          ok: false,
          message: 'Could not write the save file ($e). Re-register the save folder to grant write access.');
    }
  }

  /// ZIP of the game's current save files in GAMEBOX/Exports. Returns path.
  Future<String?> exportGame(int gameId) async {
    final saves = (await _db.allSaves()).where((s) => s.gameId == gameId).toList();
    if (saves.isEmpty) return null;
    final game = await _db.gameById(gameId);
    final tmp = await Directory.systemTemp.createTemp('gamebox_export');
    try {
      final archive = Archive();
      for (final s in saves) {
        final rel = sanitizeRelative(s.relativePath ?? s.path.split('/').last);
        final local = '${tmp.path}/${archive.length}';
        await _gateway.copyToLocal(s.path, local);
        archive.add(ArchiveFile.bytes(rel, await File(local).readAsBytes()));
      }
      final out = File('${await _gameboxRoot()}/Exports/${sanitizeFileNameStem(game.title)}_saves_${_stamp(DateTime.now())}.zip');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(ZipEncoder().encode(archive));
      return out.path;
    } finally {
      await tmp.delete(recursive: true);
    }
  }

  /// Imports a save ZIP (as exported by GAMEBOX): entries overwrite known
  /// save files with the same relative path, after a safety backup. Unknown
  /// entries are reported, never written to arbitrary locations.
  Future<RestoreResult> importZip(String zipPath) async {
    final tmp = await Directory.systemTemp.createTemp('gamebox_import');
    try {
      final r = await extractZip(zipPath, tmp.path, limits: const ArchiveLimits(maxEntries: 500, maxTotalBytes: 512 * 1024 * 1024));
      if (!r.ok) return RestoreResult(ok: false, message: r.error);
      final saves = await _db.allSaves();
      var written = 0;
      final skipped = <String>[];
      for (final f in r.files) {
        final rel = f.substring(tmp.path.length + 1);
        final target = saves.where((s) => (s.relativePath ?? '') == rel).firstOrNull ??
            saves.where((s) => (s.relativePath ?? s.path).split('/').last == rel.split('/').last).firstOrNull;
        if (target == null) {
          skipped.add(rel);
          continue;
        }
        await _backupRows([target], note: 'Automatic copy before import');
        await _gateway.copyFromLocal(f, target.path);
        written++;
      }
      return RestoreResult(
        ok: written > 0,
        message: '$written save file(s) imported'
            '${skipped.isEmpty ? '' : '; not matched to a known save file: ${skipped.join(', ')}'}',
      );
    } finally {
      await tmp.delete(recursive: true);
    }
  }
}

/// Safe relative path inside a backup folder.
String sanitizeRelative(String rel) =>
    safeEntryPath(rel) ?? rel.replaceAll(RegExp(r'[/\\]'), '_').replaceAll('..', '_');

String sanitizeFileNameStem(String s) {
  final t = s.replaceAll(RegExp(r'[^A-Za-z0-9 _\-]'), '').trim().replaceAll(RegExp(r'\s+'), '_');
  return t.isEmpty ? 'game' : t;
}
