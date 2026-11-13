import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/online/archive_guard.dart';
import '../../core/online/catalog.dart';
import '../../core/online/download_engine.dart';
import '../../core/online/url_safety.dart';
import '../../core/rom/scan_planner.dart' show imageExtensions;
import '../../core/rom/title_normalizer.dart';
import '../../core/services/platform_gateway.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/rom/scan_planner.dart' show ScannedEntry, planScan;
import '../../core/storage/gamebox_layout.dart';
import '../rom_manager/rom_library_service.dart';
import '../storage_manager/library_location_service.dart';

class ImportOutcome {
  const ImportOutcome({this.gameIds = const [], this.needsConsole = false, this.error});
  final List<int> gameIds;
  final bool needsConsole;
  final String? error;
}

/// Download Manager (Phase 5): persistent queue processed one item at a time.
///
/// Waits while offline, pauses while a game is running (setting), retries
/// network errors up to 3 times with back-off, records history, and can
/// import finished files into the library (ZIPs are validated and extracted
/// first). Downloads are never executed.
class DownloadService {
  DownloadService({
    required this._db,
    required this._engine,
    required this._library,
    required this._settings,
    required this._connectivity,
    required this._downloadsDir,
    this.retryBaseDelay = const Duration(seconds: 2),
    this._location,
  });

  /// When set, imported downloads are moved into `Games/<CONSOLE>/` of the
  /// library location (app folder or the user's public GAMEBOX folder).
  final LibraryLocationService? _location;

  final AppDatabase _db;
  final DownloadEngine _engine;
  final RomLibraryService _library;
  final SettingsRepository _settings;
  final ValueListenable<ConnectivityStatus> _connectivity;
  final Future<String> Function() _downloadsDir;
  final Duration retryBaseDelay;

  /// Test hook: awaited after each queue check (with the row found, or null).
  @visibleForTesting
  Future<void> Function(DownloadQueueRow? next)? afterQueueCheck;

  static const maxRetries = 3;

  /// Live progress of the active download (id → progress).
  final ValueNotifier<Map<int, DownloadProgress>> live = ValueNotifier(const {});
  int? _activeId;
  CancelToken? _token;
  bool _gameplayPause = false;
  bool _running = false;
  Future<void>? _loop;

  int? get activeId => _activeId;

  Future<void> initialize() async {
    // Downloads interrupted by an app restart resume from their .part file.
    await _db.customStatement("UPDATE download_queue SET status = 'queued' WHERE status = 'downloading'");
    _connectivity.addListener(_onConnectivity);
    kick();
  }

  void dispose() {
    _connectivity.removeListener(_onConnectivity);
    _token?.stop(StopReason.pause);
  }

  void _onConnectivity() {
    if (_connectivity.value.isOnline) kick();
  }

  Set<String> get _allowedExtensions => downloadableExtensions(_library.detector.scannableExtensions);

  /// Adds a download. Throws [ArgumentError] with a user-facing message.
  Future<int> enqueue({
    required String url,
    String? name,
    int? sourceId,
    String? consoleId,
    String? expectedSha256,
    CatalogEntry? entry,
  }) async {
    final check = validateUrl(url, allowHttp: _engine.httpAllowed);
    if (!check.ok) throw ArgumentError(check.error);
    final sha = (expectedSha256 ?? entry?.sha256)?.trim().toLowerCase();
    if (sha != null && sha.isNotEmpty && !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
      throw ArgumentError('SHA-256 must be 64 hexadecimal characters');
    }
    final now = DateTime.now();
    final id = await _db.into(_db.downloadQueue).insert(DownloadQueueCompanion.insert(
          sourceId: Value(sourceId),
          name: name ?? entry?.title ?? fileNameForUrl(check.uri!),
          url: check.uri.toString(),
          destination: await _downloadsDir(),
          totalBytes: Value(entry?.size),
          status: 'queued',
          expectedHash: Value(sha == null || sha.isEmpty ? null : sha),
          hashAlgorithm: Value(sha == null || sha.isEmpty ? null : 'sha256'),
          createdAt: now,
          updatedAt: now,
          consoleId: Value(consoleId ?? entry?.consoleId),
          catalogJson: Value(entry == null ? null : jsonEncode(entry.toJson())),
        ));
    kick();
    return id;
  }

  bool _kickPending = false;

  /// Starts the worker, or — if it is already running — makes it check the
  /// queue once more when it finishes, so an item added while the worker was
  /// winding down is never left waiting.
  void kick() {
    if (_running) {
      _kickPending = true;
      return;
    }
    _running = true;
    _kickPending = false;
    _loop = _process().whenComplete(() {
      _running = false;
      if (_kickPending) kick();
    });
  }

  /// Completes when the queue is idle (used by tests).
  Future<void> idle() async {
    while (_loop != null) {
      final l = _loop!;
      await l;
      if (identical(l, _loop) && !_running) break;
    }
  }

  Future<void> _process() async {
    while (true) {
      if (_gameplayPause || !_connectivity.value.isOnline) return;
      final row = await _db.nextQueuedDownload();
      await afterQueueCheck?.call(row);
      if (row == null) return;
      await _run(row);
    }
  }

  Future<void> _run(DownloadQueueRow row) async {
    _activeId = row.id;
    final token = _token = CancelToken();
    await _db.updateDownload(row.id, const DownloadQueueCompanion(status: Value('downloading'), errorMessage: Value(null)));
    var lastDb = DateTime.fromMillisecondsSinceEpoch(0);
    final maxGb = _settings.state.value.downloadMaxGb;
    final outcome = await _engine.download(
      DownloadRequest(
        url: Uri.parse(row.url),
        destDir: row.destination,
        destinationPath: row.filePath,
        allowedExtensions: _allowedExtensions,
        expectedSha256: row.expectedHash,
        expectedSize: row.catalogJson == null ? null : row.totalBytes,
        // 0 = no limit (free space is still checked).
        maxBytes: maxGb <= 0 ? 1 << 62 : maxGb * 1024 * 1024 * 1024,
      ),
      token: token,
      onDestination: (path) =>
          _db.updateDownload(row.id, DownloadQueueCompanion(filePath: Value(path), name: Value(_nameOf(row, path)))),
      onProgress: (p) {
        live.value = {row.id: p};
        final now = DateTime.now();
        if (now.difference(lastDb).inMilliseconds >= 1000) {
          lastDb = now;
          _db.updateDownload(row.id, DownloadQueueCompanion(downloadedBytes: Value(p.received), totalBytes: Value(p.total)));
        }
      },
    );
    _activeId = null;
    _token = null;
    live.value = const {};
    await _finish(row, outcome, token);
  }

  String _nameOf(DownloadQueueRow row, String path) =>
      row.catalogJson != null ? row.name : path.split('/').last;

  Future<void> _finish(DownloadQueueRow row, DownloadOutcome o, CancelToken token) async {
    switch (o.kind) {
      case OutcomeKind.completed:
        await _db.updateDownload(row.id, DownloadQueueCompanion(
          status: const Value('completed'),
          filePath: Value(o.path),
          totalBytes: Value(o.size),
          downloadedBytes: Value(o.size ?? 0),
          sha256: Value(o.sha256),
          errorMessage: const Value(null),
        ));
        await _history(row, 'completed', path: o.path, size: o.size, sha: o.sha256);
        AppLogger.instance.info('Download completed: ${o.path}');
        final fresh = await _db.downloadById(row.id);
        // With a library location, files whose console can be detected (or
        // ZIPs of one console) are sorted in as well; otherwise only files
        // whose console is known.
        if (_settings.state.value.autoImportDownloads && (fresh.consoleId != null || _location != null)) {
          try {
            await importIntoLibrary(row.id);
          } catch (e, s) {
            AppLogger.instance.error('Importing download ${row.id} failed', e, s);
          }
        }
      case OutcomeKind.paused:
        // A gameplay pause re-queues so the download continues afterwards.
        await _db.updateDownload(row.id, DownloadQueueCompanion(
            status: Value(_gameplayPause ? 'queued' : 'paused'), filePath: Value(o.path)));
      case OutcomeKind.cancelled:
        await _db.updateDownload(row.id, const DownloadQueueCompanion(status: Value('cancelled')));
        await _history(row, 'cancelled');
      case OutcomeKind.networkError:
        final retries = row.retries + 1;
        if (retries <= maxRetries) {
          await _db.updateDownload(row.id, DownloadQueueCompanion(
            status: const Value('queued'),
            retries: Value(retries),
            filePath: Value(o.path),
            errorMessage: Value('${o.error} (retry $retries/$maxRetries)'),
          ));
          await Future<void>.delayed(retryBaseDelay * (1 << (retries - 1)));
        } else {
          await _db.updateDownload(row.id, DownloadQueueCompanion(
              status: const Value('failed'), filePath: Value(o.path), errorMessage: Value(o.error)));
          await _history(row, 'failed', error: o.error);
        }
      case OutcomeKind.failed:
        await _db.updateDownload(row.id, DownloadQueueCompanion(
            status: const Value('failed'), filePath: Value(o.path), errorMessage: Value(o.error)));
        await _history(row, 'failed', error: o.error);
    }
  }

  Future<void> _history(DownloadQueueRow row, String status, {String? path, int? size, String? sha, String? error}) =>
      _db.into(_db.downloadHistory).insert(DownloadHistoryCompanion.insert(
            sourceId: Value(row.sourceId),
            name: row.name,
            url: row.url,
            destination: path ?? row.filePath ?? row.destination,
            sizeBytes: Value(size),
            sha256: Value(sha),
            status: status,
            errorMessage: Value(error),
            finishedAt: DateTime.now(),
          ));

  Future<void> pause(int id) async {
    if (_activeId == id) {
      _token?.stop(StopReason.pause);
    } else {
      await _db.updateDownload(id, const DownloadQueueCompanion(status: Value('paused')));
    }
  }

  Future<void> resume(int id) async {
    await _db.updateDownload(id, const DownloadQueueCompanion(status: Value('queued'), errorMessage: Value(null)));
    kick();
  }

  Future<void> retry(int id) async {
    await _db.updateDownload(id, const DownloadQueueCompanion(
        status: Value('queued'), retries: Value(0), errorMessage: Value(null)));
    kick();
  }

  Future<void> cancel(int id) async {
    if (_activeId == id) {
      _token?.stop(StopReason.cancel);
      return;
    }
    final row = await _db.downloadById(id);
    if (row.filePath != null) await _deleteQuietly('${row.filePath}.part');
    await _db.updateDownload(id, const DownloadQueueCompanion(status: Value('cancelled')));
    await _history(row, 'cancelled');
  }

  /// Deletes the downloaded file (and partial file) and removes the entry.
  Future<void> remove(int id) async {
    if (_activeId == id) _token?.stop(StopReason.cancel);
    final row = await _db.downloadById(id);
    final path = row.filePath;
    if (path != null && path.startsWith('content://')) {
      await _location?.delete(path);
    } else if (path != null) {
      await _deleteQuietly(path);
      await _deleteQuietly('$path.part');
    }
    await _db.deleteDownload(id);
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  void pauseForGameplay() {
    if (!_settings.state.value.pauseDownloadsWhilePlaying) return;
    _gameplayPause = true;
    _token?.stop(StopReason.pause);
  }

  void resumeAfterGameplay() {
    if (!_gameplayPause) return;
    _gameplayPause = false;
    kick();
  }

  /// Imports a completed download. ZIP archives are inspected and extracted
  /// into a folder next to the file first. [consoleId] overrides detection.
  Future<ImportOutcome> importIntoLibrary(int id, {String? consoleId}) async {
    final row = await _db.downloadById(id);
    final path = row.filePath;
    if (path != null && path.startsWith('content://') && row.importedGameId != null) {
      return ImportOutcome(gameIds: [row.importedGameId!]); // already placed and imported
    }
    if (row.status != 'completed' || path == null || !await File(path).exists()) {
      return const ImportOutcome(error: 'The download is not complete or the file was removed.');
    }
    var console = consoleId ?? row.consoleId;
    final location = _location;

    if (extensionOf(path) == '7z') {
      return const ImportOutcome(error: '.7z archives cannot be extracted by GAMEBOX. Some emulators open them directly.');
    }

    if (extensionOf(path) == 'zip') {
      final dir = '${stripExtension(path)}_files';
      final r = await extractZip(path, dir);
      if (!r.ok) return ImportOutcome(error: 'Archive rejected: ${r.error}');
      // One console for the whole archive: the chosen/catalogue console, or
      // the one every game inside was detected as.
      console ??= _singleConsole(r.files, dir);
      if (location != null && console != null) {
        final stem = stripExtension(path).split('/').last;
        final placed = await location.placeFolder(dir, '${gamesDirFor(console)}/$stem');
        await _deleteQuietly(path);
        return _importPlaced(row, placed, console);
      }
      // Mixed or unknown consoles: import where it was extracted.
      return _finishImport(row, await _library.importLocalFiles(r.files, root: dir, consoleId: console), console);
    }

    console ??= _library.detector.detect(path.split('/').last, const [])?.consoleId;
    if (location != null && console != null) {
      final placed = await location.place(path, gamesDirFor(console));
      return _importPlaced(row, [placed], console);
    }
    return _finishImport(row, await _library.importLocalFiles([path], consoleId: console), console);
  }

  String? _singleConsole(List<String> files, String root) {
    final entries = [
      for (final f in files)
        () {
          final rel = f.substring(root.length + 1).split('/');
          return ScannedEntry(uri: f, name: rel.last, dirSegments: rel.sublist(0, rel.length - 1));
        }(),
    ];
    final plan = planScan(entries, _library.detector);
    final consoles = {for (final g in plan.games) g.consoleId};
    return plan.unresolved.isEmpty && consoles.length == 1 ? consoles.single : null;
  }

  Future<ImportOutcome> _importPlaced(DownloadQueueRow row, List<PlacedFile> placed, String console) async {
    final location = _location!;
    final docs = placed.where((p) => p.isDocument).toList();
    final ids = docs.isNotEmpty
        ? await _library.importDocuments([for (final p in docs) p.toEntry()], treeUri: location.treeUri!, consoleId: console)
        : await _library.importLocalFiles([for (final p in placed) p.location], consoleId: console);
    // Point the download entry at the file's new home.
    await _db.updateDownload(row.id, DownloadQueueCompanion(filePath: Value(placed.first.location)));
    return _finishImport(row, ids, console);
  }

  Future<ImportOutcome> _finishImport(DownloadQueueRow row, List<int> ids, String? console) async {
    if (ids.isEmpty) return ImportOutcome(needsConsole: console == null);
    await _db.updateDownload(row.id, DownloadQueueCompanion(importedGameId: Value(ids.first), consoleId: Value(console)));
    if (row.catalogJson != null) await _applyCatalogMetadata(ids.first, row);
    return ImportOutcome(gameIds: ids);
  }

  Future<void> _applyCatalogMetadata(int gameId, DownloadQueueRow row) async {
    try {
      final m = jsonDecode(row.catalogJson!) as Map<String, dynamic>;
      final meta = await _db.metadataForGame(gameId);
      if (meta?.editedManually != true) {
        final title = m['title'] as String?;
        if (title != null && title.isNotEmpty) {
          await (_db.update(_db.games)..where((g) => g.id.equals(gameId))).write(
              GamesCompanion(title: Value(title), sortTitle: Value(normalizeTitle('$title.x').sortTitle)));
        }
        final licence = m['license'] as String?;
        final desc = m['description'] as String?;
        await _db.saveProviderMetadata(
          gameId,
          provider: 'catalog',
          providerId: row.url,
          description: [?desc, licence != null ? 'Licence: $licence' : 'Licence not stated by the source'].join('\n\n'),
          developer: m['developer'] as String?,
          releaseDate: m['year'] as String?,
        );
      }
      final cover = m['cover'] as String?;
      if (cover != null) {
        final tmp = await Directory.systemTemp.createTemp('gamebox_cover');
        try {
          final o = await _engine.download(DownloadRequest(
            url: Uri.parse(cover),
            destDir: tmp.path,
            allowedExtensions: imageExtensions,
            maxBytes: 10 * 1024 * 1024,
          ));
          if (o.ok) await _library.importCover(gameId, o.path!);
        } finally {
          await tmp.delete(recursive: true).catchError((_) => tmp);
        }
      }
    } catch (e, s) {
      AppLogger.instance.error('Applying catalogue metadata failed', e, s);
    }
  }

  /// Consoles a file extension could belong to (for the import chooser).
  static List<ConsoleDefinition> consolesForFile(String path) {
    final ext = extensionOf(path);
    final list = consoleCatalog.where((c) => c.extensions.contains(ext)).toList();
    return list.isEmpty ? consoleCatalog : list;
  }
}
