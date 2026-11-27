import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/constants/console_catalog.dart';
import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/console_detector.dart';
import '../../core/rom/rom_header_validator.dart';
import '../../core/rom/scan_planner.dart';
import '../../core/rom/title_normalizer.dart';
import '../../core/storage/gamebox_layout.dart';
import '../storage_manager/library_location_service.dart';
import 'rom_library_service.dart';
import '../../core/rom/console_mismatch.dart';

export '../../core/rom/console_mismatch.dart' show discConsoleFromHeader;

/// One game found on the device by [RomSearchService].
class RomSearchHit {
  RomSearchHit({required this.files, required this.primary, this.consoleId, this.candidates = const [], this.how = ''});

  /// All files of the game (e.g. a .cue and its .bin tracks).
  final List<ScannedEntry> files;
  final ScannedEntry primary;

  /// Detected console, or null when the user must choose ([candidates]).
  String? consoleId;
  final List<String> candidates;

  /// How the console was recognised (shown to the user).
  final String how;

  String get title => normalizeTitle(primary.name).title;
  int get totalSize => files.fold(0, (a, f) => a + (f.size ?? 0));

  /// Folder the file is in, relative to its storage root.
  String get folder => primary.dirSegments.isEmpty ? '/' : primary.dirSegments.join('/');
}

class RomSearchResult {
  const RomSearchResult({
    this.hits = const [],
    this.alreadyInLibrary = 0,
    this.foldersSearched = 0,
    this.truncated = false,
    this.needsAccess = false,
  });
  final List<RomSearchHit> hits;
  final int alreadyInLibrary;
  final int foldersSearched;
  final bool truncated;

  /// Searching needs "All files access" / the storage permission.
  final bool needsAccess;

  int get unidentified => hits.where((h) => h.consoleId == null).length;
}

class RomSearchProgress {
  const RomSearchProgress({this.running = false, this.folder = '', this.found = 0});
  final bool running;
  final String folder;
  final int found;
}

class OrganiseResult {
  const OrganiseResult({this.placed = 0, this.imported = 0, this.failed = const []});
  final int placed;
  final int imported;
  final List<String> failed;
}

/// Finds ROM files anywhere on the device's shared storage (internal, SD,
/// USB) and sorts them into `ROMs/<system>/`, where GAMEBOX, RetroArch and
/// other emulators find them.
///
/// Recognition, most reliable first: file header (NES, GB, GBA, N64, Mega
/// Drive, PSP/PS2/GameCube/Wii discs, …), a unique extension, the folder
/// name. Nothing is guessed: unidentified files are listed for the user.
class RomSearchService {
  RomSearchService({required this._db, required this._library, required this._location});

  final AppDatabase _db;
  final RomLibraryService _library;
  final LibraryLocationService _location;

  final ValueNotifier<RomSearchProgress> progress = ValueNotifier(const RomSearchProgress());
  final ValueNotifier<RomSearchResult?> last = ValueNotifier(null);
  bool _cancel = false;

  /// Folders never searched: app data, media, emulator data and BIOS.
  static const _skipTop = {'android', 'dcim', 'pictures', 'movies', 'music', 'alarms', 'ringtones',
      'notifications', 'podcasts', 'audiobooks', 'recordings', 'lost.dir'};
  static const _skipAnywhere = {'system', 'saves', 'states', 'thumbnails', 'cores', 'assets', 'cheats',
      'shaders', 'overlays', 'playlists', 'database', 'autoconfig', 'logs', 'screenshots', 'memcards',
      'savedata', 'ppsspp_state', 'cache', '.thumbnails'};

  /// Smallest plausible ROM (avoids icons, configs, …).
  static const minSize = 8 * 1024;

  void cancel() => _cancel = true;

  /// Searches [roots] (default: every volume's public root).
  Future<RomSearchResult> search({List<String>? roots, int maxDepth = 12, int maxFiles = 30000}) async {
    _cancel = false;
    final access = _location.access.value;
    final searchRoots = roots ?? (access.granted ? await _location.publicVolumeRoots() : const <String>[]);
    if (searchRoots.isEmpty) {
      return last.value = const RomSearchResult(needsAccess: true);
    }
    progress.value = const RomSearchProgress(running: true);
    final detector = _library.detector;
    final exts = detector.scannableExtensions;
    final entries = <ScannedEntry>[];
    var folders = 0;
    var truncated = false;
    final romsRoots = {for (final r in await _location.localScanRoots()) r};

    Future<void> walk(Directory d, List<String> segs) async {
      if (_cancel || truncated) return;
      folders++;
      if (folders % 25 == 0) progress.value = RomSearchProgress(running: true, folder: d.path, found: entries.length);
      List<FileSystemEntity> children;
      try {
        children = await d.list(followLinks: false).toList();
      } catch (_) {
        return; // unreadable folder
      }
      for (final e in children) {
        final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
        final lower = name.toLowerCase();
        if (name.startsWith('.')) continue;
        if (e is Directory) {
          if (segs.isEmpty && _skipTop.contains(lower)) continue;
          if (_skipAnywhere.contains(lower) || lower == 'bios') continue;
          if (romsRoots.contains(e.path)) continue; // already the library
          if (isNonGameFolder([...segs, name])) continue;
          if (segs.length < maxDepth) await walk(e, [...segs, name]);
        } else if (e is File && exts.contains(extensionOf(name))) {
          if (entries.length >= maxFiles) {
            truncated = true;
            return;
          }
          final st = await e.stat();
          entries.add(ScannedEntry(
              uri: e.path, name: name, dirSegments: segs, size: st.size, lastModified: st.modified.millisecondsSinceEpoch));
        }
      }
    }

    try {
      for (final r in searchRoots) {
        final d = Directory(r);
        if (await d.exists()) await walk(d, const []);
      }
      final plan = planScan(entries, detector);
      final hits = <RomSearchHit>[];
      var known = 0;
      // A file already copied into the library (same name and size) counts as
      // known, so the original in Download doesn't show up again.
      final library = {
        for (final f in await _db.select(_db.gameFiles).get()) '${f.displayPath.split('/').last.toLowerCase()}|${f.sizeBytes}',
      };
      bool inLibrary(ScannedEntry e) => library.contains('${e.name.toLowerCase()}|${e.size}');
      for (final g in plan.games) {
        if (inLibrary(g.primary) || await _db.fileByUri(g.primary.uri) != null) {
          known++;
          continue;
        }
        final files = await _withTracks(g.files, entries);
        if ((g.primary.size ?? minSize) < minSize && files.length == 1) continue;
        final byHeader = await _headerConsole(g.primary);
        final consoleId = byHeader ?? g.consoleId;
        hits.add(RomSearchHit(
          files: files,
          primary: g.primary,
          consoleId: consoleId,
          how: byHeader != null ? 'file header' : (g.primary.dirSegments.isEmpty ? 'file type' : 'file type / folder'),
        ));
      }
      for (final e in plan.unresolved) {
        if (inLibrary(e) || await _db.fileByUri(e.uri) != null) {
          known++;
          continue;
        }
        final ext = e.extension;
        // Archives and track files without a recognisable folder are far too
        // common (downloads, backups); only keep them when a header says so.
        final byHeader = await _headerConsole(e);
        if (byHeader == null && (archiveExtensions.contains(ext) || companionExtensions.contains(ext))) continue;
        if ((e.size ?? minSize) < minSize) continue;
        final candidates = [for (final c in allConsoles) if (c.extensions.contains(ext)) c.id];
        hits.add(RomSearchHit(
          files: [e],
          primary: e,
          consoleId: byHeader,
          candidates: candidates,
          how: byHeader != null ? 'file header' : '',
        ));
      }
      hits.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return last.value = RomSearchResult(
          hits: hits, alreadyInLibrary: known, foldersSearched: folders, truncated: truncated || _cancel);
    } catch (e, s) {
      AppLogger.instance.error('ROM search failed', e, s);
      return last.value = RomSearchResult(foldersSearched: folders, truncated: true);
    } finally {
      progress.value = const RomSearchProgress();
    }
  }

  /// A disc descriptor (.cue/.gdi/.ccd/.mds) plus the track files it uses,
  /// so copying the game copies a playable set.
  static Future<List<ScannedEntry>> _withTracks(List<ScannedEntry> files, List<ScannedEntry> all) async {
    final out = [...files];
    for (final f in files) {
      if (!const {'cue', 'gdi', 'ccd', 'mds'}.contains(f.extension)) continue;
      final sameDir = [for (final e in all) if (e.dirKey == f.dirKey && e.uri != f.uri) e];
      final stem = stripExtension(f.name).toLowerCase();
      Set<String> referenced = {};
      try {
        final text = await File(f.uri).readAsString();
        referenced = {
          for (final m in RegExp(r'FILE\s+"([^"]+)"', caseSensitive: false).allMatches(text)) m.group(1)!.toLowerCase(),
          // .gdi lines: <track> <lba> <type> <sector size> <file> <offset>
          for (final line in text.split('\n'))
            if (RegExp(r'^\s*\d+\s+\d+\s+\d+\s+\d+\s+(\S+)').firstMatch(line) case final m?) m.group(1)!.toLowerCase(),
        };
      } catch (_) {}
      for (final e in sameDir) {
        final n = e.name.toLowerCase();
        final isTrack = referenced.contains(n) ||
            (referenced.isEmpty && companionExtensions.contains(e.extension) && n.startsWith(stem));
        if (isTrack && !out.contains(e)) out.add(e);
      }
    }
    return out;
  }

  /// Console identified from the file's own header, or null.
  Future<String?> _headerConsole(ScannedEntry e) async {
    final ext = e.extension;
    final candidates = [for (final c in allConsoles) if (c.extensions.contains(ext)) c.id];
    if (candidates.isEmpty) return null;
    Uint8List bytes;
    try {
      final raf = await File(e.uri).open();
      try {
        bytes = await raf.read(romHeaderBytes + 0x10000);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return null;
    }
    final disc = discConsoleFromHeader(ext, bytes);
    if (disc != null && candidates.contains(disc)) return disc;
    for (final c in candidates) {
      if (validateRomHeader(c, ext, bytes).status == HeaderStatus.valid) {
        // A header check only counts when it is specific to one console of
        // the candidates (e.g. ISO 9660 alone fits PSP and PS2).
        final others = candidates.where((o) => o != c && validateRomHeader(o, ext, bytes).status == HeaderStatus.valid);
        if (others.isEmpty) return c;
      }
    }
    return null;
  }

  /// Copies (or with [move], moves) [hits] into `ROMs/<system>/` and adds
  /// them to the library. Hits without a console are skipped.
  Future<OrganiseResult> organise(List<RomSearchHit> hits, {bool move = false}) async {
    var placed = 0, imported = 0;
    final failed = <String>[];
    for (final h in hits) {
      final console = h.consoleId;
      if (console == null) continue;
      try {
        final multi = h.files.length > 1;
        final rel = multi ? '${gamesDirFor(console)}/${stripExtension(h.primary.name)}' : gamesDirFor(console);
        final out = <PlacedFile>[];
        for (final f in h.files) {
          out.add(await _location.place(f.uri, rel, copy: !move));
        }
        placed++;
        final docs = out.where((p) => p.isDocument).toList();
        final ids = docs.isNotEmpty
            ? await _library.importDocuments([for (final p in docs) p.toEntry()], treeUri: _location.treeUri!, consoleId: console)
            : await _library.importLocalFiles([for (final p in out) p.location], consoleId: console);
        imported += ids.length;
      } catch (e, s) {
        AppLogger.instance.error('Organising ${h.primary.uri} failed', e, s);
        failed.add('${h.primary.name}: $e');
      }
    }
    final r = last.value;
    if (r != null) {
      final done = {for (final h in hits) if (h.consoleId != null && !failed.any((f) => f.startsWith(h.primary.name))) h};
      last.value = RomSearchResult(
          hits: r.hits.where((h) => !done.contains(h)).toList(),
          alreadyInLibrary: r.alreadyInLibrary + done.length,
          foldersSearched: r.foldersSearched,
          truncated: r.truncated);
    }
    return OrganiseResult(placed: placed, imported: imported, failed: failed);
  }
}

/// Identified hits grouped by console, biggest group first (then by name).
List<(String, List<RomSearchHit>)> groupHitsByConsole(Iterable<RomSearchHit> hits) {
  final groups = <String, List<RomSearchHit>>{};
  for (final h in hits) {
    final c = h.consoleId;
    if (c != null) (groups[c] ??= []).add(h);
  }
  String name(String id) => consoleById(id)?.name ?? id;
  final keys = groups.keys.toList()
    ..sort((a, b) {
      final n = groups[b]!.length.compareTo(groups[a]!.length);
      return n != 0 ? n : name(a).compareTo(name(b));
    });
  return [for (final k in keys) (k, groups[k]!)];
}

/// What a copy/move of the selected hits will do, per console.
class OrganiseSummary {
  const OrganiseSummary(this.perConsole);

  /// console id → (games, bytes)
  final Map<String, (int, int)> perConsole;

  int get games => perConsole.values.fold(0, (a, v) => a + v.$1);
  int get bytes => perConsole.values.fold(0, (a, v) => a + v.$2);

  factory OrganiseSummary.of(Iterable<RomSearchHit> hits) {
    final m = <String, (int, int)>{};
    for (final h in hits) {
      final c = h.consoleId;
      if (c == null) continue;
      final (g, b) = m[c] ?? (0, 0);
      m[c] = (g + 1, b + h.totalSize);
    }
    return OrganiseSummary(m);
  }

  /// Margin kept free on the device (50 MB), like downloads.
  static const margin = 50 * 1024 * 1024;

  /// A copy needs the space; a move on the same storage does not.
  bool fits(int? freeBytes, {required bool move}) => move || freeBytes == null || bytes + margin <= freeBytes;
}
