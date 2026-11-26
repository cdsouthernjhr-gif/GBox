/// Box art from libretro-thumbnails, the cover collection RetroArch uses:
/// `<server>/<libretro database name>/Named_Boxarts/<game name>.png`.
/// Names follow the No-Intro / Redump naming ("Crash Bandicoot (USA)"), so
/// GAMEBOX tries the file name, the title and the title with common regions.
/// Only PNG images are accepted; nothing else is downloaded or run.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../core/database/app_database.dart';
import '../../core/errors/app_logger.dart';
import '../../core/rom/title_normalizer.dart';
import '../emulator_manager/retroarch_playlist_service.dart' show retroArchDbNames;
import '../rom_manager/rom_library_service.dart';

/// Characters libretro replaces with "_" in thumbnail file names.
String libretroThumbnailName(String name) => name.replaceAll(RegExp(r'[&*/:`<>?\\|"]'), '_');

/// Names to try, best first: the file name (often already the exact
/// No-Intro/Redump name), the same without [tags] and disc numbers, the
/// title with its known regions, then the title with common regions.
List<String> coverNameCandidates({required String title, String? fileStem, String? regions}) {
  final out = <String>[];
  void add(String? n) {
    final v = n?.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (v != null && v.isNotEmpty && !out.contains(v)) out.add(v);
  }

  if (fileStem != null) {
    add(fileStem);
    final noTags = fileStem.replaceAll(RegExp(r'\s*\[[^\]]*\]'), '');
    add(noTags);
    add(noTags.replaceAll(RegExp(r'\s*\((Disc|Disk|CD)\s*\d+[^)]*\)', caseSensitive: false), ''));
  }
  if (regions != null && regions.trim().isNotEmpty) add('$title (${regions.trim()})');
  for (final r in const ['USA', 'Europe', 'USA, Europe', 'World', 'Japan']) {
    add('$title ($r)');
  }
  add(title);
  return out.take(12).toList();
}

/// Where covers come from: the libretro server, then the same collection on
/// GitHub (used when the server can't be reached).
List<Uri> coverUrls(String consoleId, String name) {
  final db = retroArchDbNames[consoleId];
  if (db == null) return const [];
  final file = Uri.encodeComponent('${libretroThumbnailName(name)}.png');
  return [
    Uri.parse('https://thumbnails.libretro.com/${Uri.encodeComponent(db)}/Named_Boxarts/$file'),
    Uri.parse('https://raw.githubusercontent.com/libretro-thumbnails/'
        '${Uri.encodeComponent(db.replaceAll(' ', '_'))}/master/Named_Boxarts/$file'),
  ];
}

/// Result of a GET: the body for 200, null for "not there" (404 etc.).
/// Throws when the server can't be reached.
typedef CoverFetcher = Future<Uint8List?> Function(Uri url);

class CoverSearch {
  const CoverSearch({required this.found, required this.tried, this.name, this.error});
  final bool found;

  /// The name that matched.
  final String? name;
  final List<String> tried;

  /// Why nothing could be checked (no connection), else null.
  final String? error;
}

bool _isPng(Uint8List b) =>
    b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47 && b[4] == 0x0D && b[5] == 0x0A;

class CoverArtService {
  CoverArtService({required this._db, required this._library, CoverFetcher? fetch, Future<Directory> Function()? tempDir})
      : _fetch = fetch ?? _httpGet,
        _tempDir = tempDir ?? (() async => Directory.systemTemp);

  final AppDatabase _db;
  final RomLibraryService _library;
  final CoverFetcher _fetch;
  final Future<Directory> Function() _tempDir;

  /// Largest cover accepted.
  static const maxBytes = 8 * 1024 * 1024;

  /// Whether covers exist for [consoleId].
  static bool supports(String consoleId) => retroArchDbNames.containsKey(consoleId);

  /// Finds and saves [game]'s cover. With [name], only that name is tried.
  Future<CoverSearch> download(GameRow game, {String? name}) async {
    final names = name != null
        ? [name.trim()]
        : coverNameCandidates(title: game.title, fileStem: await _fileStem(game.id), regions: game.regions);
    if (!supports(game.consoleId)) {
      return CoverSearch(found: false, tried: names, error: 'No cover collection for this console.');
    }
    final tried = <String>[];
    // Server index: move to the next server only when one can't be reached
    // (they hold the same covers, so a "not found" is final).
    var server = 0;
    String? lastError;
    for (final n in names) {
      tried.add(n);
      while (true) {
        final urls = coverUrls(game.consoleId, n);
        if (server >= urls.length) {
          return CoverSearch(found: false, tried: tried, error: lastError ?? 'No connection.');
        }
        Uint8List? body;
        try {
          body = await _fetch(urls[server]);
        } catch (e) {
          lastError = 'Could not reach the cover server ($e).';
          server++;
          continue;
        }
        if (body != null && body.length <= maxBytes && _isPng(body)) {
          return await _save(game, body)
              ? CoverSearch(found: true, tried: tried, name: n)
              : CoverSearch(found: false, tried: tried, error: 'The downloaded image could not be read.');
        }
        break;
      }
    }
    return CoverSearch(found: false, tried: tried);
  }

  Future<String?> _fileStem(int gameId) async {
    final files = await _db.filesForGame(gameId);
    if (files.isEmpty) return null;
    final primary = files.firstWhere((f) => f.isPrimary, orElse: () => files.first);
    final name = primary.displayPath.split('/').last;
    return stripExtension(name);
  }

  Future<bool> _save(GameRow game, Uint8List png) async {
    final dir = await _tempDir();
    final f = File('${dir.path}/gamebox_cover_${game.id}_${DateTime.now().microsecondsSinceEpoch}.png');
    try {
      await f.writeAsBytes(png, flush: true);
      return await _library.importCover(game.id, f.path);
    } catch (e, s) {
      AppLogger.instance.error('Saving downloaded cover failed', e, s);
      return false;
    } finally {
      try {
        await f.delete();
      } catch (_) {}
    }
  }

  static Future<Uint8List?> _httpGet(Uri url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..userAgent = 'GAMEBOX';
    try {
      final req = await client.getUrl(url).timeout(const Duration(seconds: 15));
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        await res.drain<void>();
        return null;
      }
      // Too big: the connection is closed without reading it.
      if (res.contentLength > maxBytes) return null;
      final b = BytesBuilder(copy: false);
      await for (final chunk in res.timeout(const Duration(seconds: 30))) {
        b.add(chunk);
        if (b.length > maxBytes) return null;
      }
      return b.takeBytes();
    } finally {
      client.close(force: true);
    }
  }
}
