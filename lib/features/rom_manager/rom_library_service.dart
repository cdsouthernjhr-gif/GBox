import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/console_detector.dart';
import '../../core/rom/rom_header_validator.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/services/platform_gateway.dart';
import '../../data/repositories/settings_repository.dart';

/// Files up to this size are hashed automatically after import (cartridge
/// ROMs). Larger disc images are hashed on demand ("Verify file").
const autoHashLimitBytes = 16 * 1024 * 1024;

enum RootKind { appFolder, safTree }

class LibraryRoot {
  const LibraryRoot(this.uri, this.kind, this.label);
  final String uri;
  final RootKind kind;
  final String label;
}

class RootScanResult {
  const RootScanResult({
    required this.root,
    this.available = true,
    this.filesSeen = 0,
    this.imported = 0,
    this.alreadyKnown = 0,
    this.missing = 0,
    this.unresolved = const [],
    this.truncated = false,
    this.error,
  });
  final LibraryRoot root;

  /// False when the folder's storage is disconnected or access was revoked.
  /// Files of an unavailable root are NOT marked missing.
  final bool available;
  final int filesSeen;
  final int imported;
  final int alreadyKnown;
  final int missing;
  final List<ScannedEntry> unresolved;
  final bool truncated;
  final String? error;
}

class ScanProgress {
  const ScanProgress({
    this.running = false,
    this.stage = '',
    this.current,
    this.imported = 0,
    this.results = const [],
    this.finishedAt,
  });
  final bool running;
  final String stage;
  final String? current;
  final int imported;
  final List<RootScanResult> results;
  final DateTime? finishedAt;

  int get totalImported => results.fold(0, (a, r) => a + r.imported);
  int get totalMissing => results.fold(0, (a, r) => a + r.missing);
  int get totalUnresolved => results.fold(0, (a, r) => a + r.unresolved.length);
}

class VerifyResult {
  const VerifyResult({required this.file, required this.header, this.hashError, this.duplicates = const []});
  final GameFileRow file;
  final HeaderCheck header;
  final String? hashError;
  final List<GameFileRow> duplicates;
}

class ManualImportResult {
  const ManualImportResult({this.imported = 0, this.alreadyKnown = 0, this.needsConsole = const []});
  final int imported;
  final int alreadyKnown;

  /// Picked files whose console could not be detected; the UI asks the user.
  final List<ScannedEntry> needsConsole;
}

/// ROM Manager (Phase 2): scanning, import, duplicate/missing detection,
/// integrity verification, local artwork and safe deletion.
///
/// Games are only ever *referenced*: files are never copied, moved,
/// extracted or executed.
class RomLibraryService {
  RomLibraryService({
    required this._gateway,
    required this._db,
    required this._settings,
    required this._appRoots,
    required this._artworkDir,
    ConsoleDetector? detector,
  }) : detector = detector ?? ConsoleDetector();

  final PlatformGateway _gateway;
  final AppDatabase _db;
  final SettingsRepository _settings;
  final Future<List<String>> Function() _appRoots;
  final Future<String> Function() _artworkDir;
  final ConsoleDetector detector;

  final ValueNotifier<ScanProgress> progress = ValueNotifier(const ScanProgress());
  Future<void>? _running;

  Set<String> get _scanExtensions => {...detector.scannableExtensions, ...imageExtensions};

  /// Creates the recommended GAMEBOX folder layout inside each app-specific
  /// storage directory (no permission needed) and returns the GAMEBOX roots.
  Future<List<String>> ensureAppFolders() async {
    final roots = <String>[];
    for (final base in await _appRoots()) {
      final root = '$base/GAMEBOX';
      try {
        for (final sub in [
          for (final c in consoleCatalog) 'Games/${c.folderName}',
          'Artwork/Covers', 'Artwork/Screenshots', 'Artwork/Backgrounds',
          'Saves', 'Backups', 'Downloads',
        ]) {
          await Directory('$root/$sub').create(recursive: true);
        }
        roots.add(root);
      } catch (e) {
        AppLogger.instance.warn('Cannot create GAMEBOX folders in $base: $e');
      }
    }
    return roots;
  }

  Future<List<LibraryRoot>> roots() async {
    final list = <LibraryRoot>[
      for (final r in await ensureAppFolders()) LibraryRoot(r, RootKind.appFolder, r),
      for (final t in _settings.state.value.romFolders) LibraryRoot(t, RootKind.safTree, _treeLabel(t)),
    ];
    return list;
  }

  static String _treeLabel(String uri) {
    final decoded = Uri.decodeComponent(uri);
    final i = decoded.indexOf('/tree/');
    return i >= 0 ? decoded.substring(i + 6) : decoded;
  }

  /// Scans every root. Concurrent calls share the running scan.
  Future<void> scanAll() => _running ??= _scanAll().whenComplete(() => _running = null);

  Future<void> _scanAll() async {
    final results = <RootScanResult>[];
    progress.value = const ScanProgress(running: true, stage: 'Preparing');
    try {
      for (final root in await roots()) {
        progress.value = ScanProgress(
            running: true, stage: 'Scanning', current: root.label, results: List.of(results),
            imported: results.fold(0, (a, r) => a + r.imported));
        results.add(await _scanRoot(root));
      }
      progress.value = ScanProgress(running: true, stage: 'Verifying files', results: List.of(results));
      await verifyPending();
    } catch (e, s) {
      AppLogger.instance.error('Library scan failed', e, s);
    } finally {
      progress.value = ScanProgress(results: results, finishedAt: DateTime.now());
      AppLogger.instance.info('Library scan: ${progress.value.totalImported} imported, '
          '${progress.value.totalMissing} missing, ${progress.value.totalUnresolved} unresolved');
    }
  }

  Future<RootScanResult> _scanRoot(LibraryRoot root) async {
    List<ScannedEntry> entries;
    var truncated = false;
    try {
      if (root.kind == RootKind.safTree) {
        if (!await _gateway.treeAccessible(root.uri)) {
          return RootScanResult(root: root, available: false, error: 'Storage disconnected or access revoked');
        }
        final r = await _gateway.scanTree(root.uri, _scanExtensions);
        entries = ((r['files'] as List?) ?? const [])
            .map((e) => ScannedEntry.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        truncated = r['truncated'] == true;
      } else {
        final dir = Directory(root.uri);
        if (!await dir.exists()) return RootScanResult(root: root, available: false, error: 'Folder not found');
        entries = await _listDirectory(dir);
      }
    } catch (e, s) {
      AppLogger.instance.error('Scanning ${root.label} failed', e, s);
      return RootScanResult(root: root, available: false, error: '$e');
    }

    final plan = planScan(entries, detector);
    final seen = {for (final e in entries) e.uri};
    final known = {for (final f in await _db.filesUnderRoot(root.uri)) f.uri: f};
    var imported = 0, alreadyKnown = 0;

    for (final g in plan.games) {
      if (known.containsKey(g.primary.uri) || await _db.fileByUri(g.primary.uri) != null) {
        alreadyKnown++;
        continue;
      }
      await _importPlanned(g, rootUri: root.uri);
      imported++;
    }

    // Missing detection: only for roots we could read.
    final missingIds = [for (final f in known.values) if (!seen.contains(f.uri)) f.id];
    final presentIds = [for (final f in known.values) if (seen.contains(f.uri) && !f.fileExists) f.id];
    await _db.setFilesExist(missingIds, false);
    await _db.setFilesExist(presentIds, true);

    return RootScanResult(
      root: root,
      filesSeen: entries.length,
      imported: imported,
      alreadyKnown: alreadyKnown,
      missing: missingIds.length,
      unresolved: plan.unresolved,
      truncated: truncated,
    );
  }

  Future<List<ScannedEntry>> _listDirectory(Directory root, {int maxDepth = 8}) async {
    final out = <ScannedEntry>[];
    final exts = _scanExtensions;
    Future<void> walk(Directory d, List<String> segs) async {
      await for (final e in d.list(followLinks: false)) {
        final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
        if (name.startsWith('.')) continue;
        if (e is Directory) {
          if (segs.length < maxDepth) await walk(e, [...segs, name]);
        } else if (e is File && exts.contains(extensionOf(name))) {
          final st = await e.stat();
          out.add(ScannedEntry(
            uri: e.path, name: name, dirSegments: segs,
            size: st.size, lastModified: st.modified.millisecondsSinceEpoch,
          ));
        }
      }
    }

    await walk(root, const []);
    return out;
  }

  Future<int> _importPlanned(PlannedGame g, {String? rootUri}) async {
    final now = DateTime.now();
    final id = await _db.insertGameWithFiles(
      GamesCompanion.insert(
        title: g.title.title,
        sortTitle: g.title.sortTitle,
        consoleId: g.consoleId,
        addedAt: now,
        regions: Value(g.title.regions.isEmpty ? null : g.title.regions.join(', ')),
      ),
      [
        for (final f in g.files)
          GameFilesCompanion.insert(
            gameId: 0, // replaced in insertGameWithFiles
            uri: f.uri,
            displayPath: f.displayPath,
            extension: f.extension,
            sizeBytes: Value(f.size),
            rootUri: Value(rootUri),
            lastModified: Value(f.lastModified),
            isPrimary: Value(identical(f, g.primary)),
            discNumber: Value(normalizeTitle(f.name).disc),
            lastVerifiedAt: Value(now),
          ),
      ],
    );
    final cover = g.cover;
    if (cover != null) await importCover(id, cover.uri);
    return id;
  }

  /// Copies (downscaled) an image as the game's cover. Returns false if the
  /// image could not be decoded.
  Future<bool> importCover(int gameId, String imageUri) async {
    try {
      final dir = await _artworkDir();
      final path = await _gateway.importImage(
          imageUri, '$dir/cover_${gameId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (path == null) return false;
      await _db.setCover(gameId, path);
      return true;
    } catch (e, s) {
      AppLogger.instance.error('Cover import failed', e, s);
      return false;
    }
  }

  /// Header check + hash for files never verified (hash only for small files).
  Future<void> verifyPending() async {
    final pending = await _db.filesPendingVerification();
    for (final f in pending) {
      await verifyFile(f, hash: (f.sizeBytes ?? autoHashLimitBytes + 1) <= autoHashLimitBytes);
    }
  }

  /// Integrity verification of one file: header signature, then (optionally)
  /// a full SHA-1/CRC32 hash used for duplicate detection.
  Future<VerifyResult> verifyFile(GameFileRow file, {bool hash = true}) async {
    final game = await _db.gameById(file.gameId);
    HeaderCheck header;
    try {
      final bytes = await _gateway.readBytes(file.uri, length: romHeaderBytes);
      header = validateRomHeader(game.consoleId, file.extension, bytes);
    } catch (e) {
      header = HeaderCheck(HeaderStatus.invalid, 'Could not read file: $e');
    }
    String? hashError;
    Map<String, dynamic>? h;
    if (hash) {
      try {
        h = await _gateway.hashFile(file.uri);
      } catch (e) {
        hashError = '$e';
      }
    }
    await _db.updateFileVerification(
      file.id,
      sha1: h?['sha1'] as String?,
      crc32: h?['crc32'] as String?,
      size: (h?['size'] as num?)?.toInt(),
      headerStatus: header.status.name,
      headerDetail: header.detail,
    );
    final updated = await _db.fileById(file.id);
    return VerifyResult(
      file: updated,
      header: header,
      hashError: hashError,
      duplicates: await _db.duplicatesOf(updated),
    );
  }

  /// Manual import of picked files. Files whose console cannot be detected
  /// are returned so the user can choose; nothing is guessed.
  Future<ManualImportResult> importPicked(List<String> uris) async {
    if (uris.isEmpty) return const ManualImportResult();
    final described = await _gateway.describeFiles(uris);
    final entries = [
      for (final d in described)
        ScannedEntry(
          uri: d['uri'] as String,
          name: d['name'] as String,
          dirSegments: _dirHintFromUri(d['uri'] as String),
          size: (d['size'] as num?)?.toInt(),
        ),
    ];
    final plan = planScan(entries, detector);
    var imported = 0, known = 0;
    for (final g in plan.games) {
      if (await _db.fileByUri(g.primary.uri) != null) {
        known++;
        continue;
      }
      await _importPlanned(g);
      imported++;
    }
    await verifyPending();
    return ManualImportResult(imported: imported, alreadyKnown: known, needsConsole: plan.unresolved);
  }

  /// Imports files for which the user chose the console explicitly.
  Future<int> importWithConsole(List<ScannedEntry> entries, String consoleId) async {
    var n = 0;
    for (final e in entries) {
      if (await _db.fileByUri(e.uri) != null) continue;
      final info = normalizeTitle(e.name);
      await _importPlanned(PlannedGame(consoleId: consoleId, title: info, primary: e, files: [e]));
      n++;
    }
    await verifyPending();
    return n;
  }

  /// Imports local files (e.g. completed downloads or extracted archives).
  /// [root] gives folder hints relative to it; [consoleId] is used for files
  /// whose console cannot be detected. Returns the ids of the games created
  /// or already present for these files.
  Future<List<int>> importLocalFiles(List<String> paths, {String? root, String? consoleId}) async {
    final entries = <ScannedEntry>[];
    for (final path in paths) {
      final f = File(path);
      if (!await f.exists()) continue;
      final name = f.uri.pathSegments.last;
      var dirs = const <String>[];
      if (root != null && path.startsWith('$root/')) {
        final rel = path.substring(root.length + 1).split('/');
        dirs = rel.sublist(0, rel.length - 1);
      }
      final st = await f.stat();
      entries.add(ScannedEntry(
          uri: path, name: name, dirSegments: dirs, size: st.size, lastModified: st.modified.millisecondsSinceEpoch));
    }
    final plan = planScan(entries, detector);
    final ids = <int>[];
    Future<void> add(PlannedGame g) async {
      final known = await _db.fileByUri(g.primary.uri);
      ids.add(known?.gameId ?? await _importPlanned(g));
    }

    for (final g in plan.games) {
      // A console chosen explicitly (e.g. from a catalogue) wins over
      // extension detection only when the extension is valid for it.
      if (consoleId != null && g.consoleId != consoleId &&
          (consoleById(consoleId)?.extensions.contains(g.primary.extension) ?? false)) {
        await add(PlannedGame(consoleId: consoleId, title: g.title, primary: g.primary, files: g.files, cover: g.cover));
      } else {
        await add(g);
      }
    }
    if (consoleId != null) {
      for (final e in plan.unresolved) {
        await add(PlannedGame(consoleId: consoleId, title: normalizeTitle(e.name), primary: e, files: [e]));
      }
    }
    await verifyPending();
    return ids;
  }

  /// External-storage document ids often contain the path
  /// (`primary:ROMs/SNES/game.sfc`); use its folders as a console hint.
  static List<String> _dirHintFromUri(String uri) {
    final decoded = Uri.decodeComponent(uri);
    final colon = decoded.lastIndexOf(':');
    final path = colon >= 0 ? decoded.substring(colon + 1) : decoded;
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return parts.length > 1 ? parts.sublist(0, parts.length - 1) : const [];
  }

  /// Rechecks every library file's presence (e.g. after storage changes).
  Future<int> refreshMissing() async {
    final files = await _db.select(_db.gameFiles).get();
    if (files.isEmpty) return 0;
    final exists = await _gateway.existsMany([for (final f in files) f.uri]);
    final missing = <int>[], present = <int>[];
    for (var i = 0; i < files.length && i < exists.length; i++) {
      (exists[i] ? present : missing).add(files[i].id);
    }
    await _db.setFilesExist(missing, false);
    await _db.setFilesExist(present, true);
    return missing.length;
  }

  /// Deletes the game's files from storage, then removes it from the library.
  /// Callers must obtain explicit user confirmation first.
  Future<List<String>> deleteGameAndFiles(int gameId) async {
    final failed = <String>[];
    for (final f in await _db.filesForGame(gameId)) {
      if (!await _gateway.deleteFile(f.uri)) failed.add(f.displayPath);
    }
    if (failed.isEmpty) await _db.removeGameFromLibrary(gameId);
    return failed;
  }
}
