/// Box art from libretro-thumbnails, the cover collection RetroArch uses:
/// `<server>/<libretro database name>/Named_Boxarts/<game name>.png`.
/// Names follow the No-Intro / Redump naming ("Crash Bandicoot (USA)"), so
/// GAMEBOX tries the file name, the title and the title with common regions.
/// When no name matches exactly, the console's cover list is fetched once and
/// the title is matched loosely (ignoring regions, punctuation and case).
/// Only PNG images are accepted; nothing else is downloaded or run.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

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

/// Key for loose title matching: no regions/tags, no punctuation, lower
/// case, "The" moved back to the front ("Legend of Zelda, The").
String coverMatchKey(String name) {
  var n = name.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
  n = n.replaceAll(RegExp(r'\s*[\(\[][^\)\]]*[\)\]]'), '');
  final the = RegExp(r'^(.*), (The|A|An)\b(.*)$', caseSensitive: false).firstMatch(n);
  if (the != null) n = '${the.group(2)} ${the.group(1)}${the.group(3)}';
  // libretro writes "&" as "_": both are dropped like other punctuation.
  n = n.toLowerCase();
  return n.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

/// The best cover in [available] (file names) for [title]: same match key,
/// preferring USA/World/Europe releases and avoiding betas and demos.
String? bestCoverMatch(String title, Iterable<String> available) {
  final key = coverMatchKey(title);
  if (key.isEmpty) return null;
  final hits = [for (final a in available) if (a.toLowerCase().endsWith('.png') && coverMatchKey(a) == key) a];
  if (hits.isEmpty) return null;
  int rank(String n) {
    var r = 0;
    if (RegExp(r'\((Beta|Proto|Demo|Sample|Kiosk|Pirate|Unl)', caseSensitive: false).hasMatch(n)) r += 100;
    const regions = ['USA', 'World', 'Europe', 'Japan'];
    final i = regions.indexWhere((x) => n.contains(x));
    r += i < 0 ? 10 : i;
    return r * 1000 + n.length;
  }

  hits.sort((a, b) => rank(a).compareTo(rank(b)));
  return hits.first.substring(0, hits.first.length - 4);
}

class CoverSearch {
  const CoverSearch({required this.found, required this.tried, this.name, this.error});
  final bool found;

  /// The name that matched.
  final String? name;
  final List<String> tried;

  /// Why nothing could be checked or saved, else null.
  final String? error;
}

bool _isPng(Uint8List b) =>
    b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47 && b[4] == 0x0D && b[5] == 0x0A;

class CoverArtService {
  CoverArtService({required this._db, required this._library, CoverFetcher? fetch, Future<Directory> Function()? tempDir})
      : _fetch = fetch ?? _httpGet,
        // The app's own cache folder: Directory.systemTemp is not writable
        // by apps on Android.
        _tempDir = tempDir ?? getTemporaryDirectory;

  final AppDatabase _db;
  final RomLibraryService _library;
  final CoverFetcher _fetch;
  final Future<Directory> Function() _tempDir;

  /// Cover file names per console (from the collection's listing).
  final Map<String, List<String>> _lists = {};

  /// Largest cover accepted.
  static const maxBytes = 8 * 1024 * 1024;

  /// Whether covers exist for [consoleId].
  static bool supports(String consoleId) => retroArchDbNames.containsKey(consoleId);

  /// Finds and saves [game]'s cover. With [name], that name is tried (and
  /// matched loosely when it isn't exact).
  Future<CoverSearch> download(GameRow game, {String? name}) async {
    final names = name != null
        ? [name.trim()]
        : coverNameCandidates(title: game.title, fileStem: await _fileStem(game.id), regions: game.regions);
    if (!supports(game.consoleId)) {
      return CoverSearch(found: false, tried: names, error: 'No cover collection for this console.');
    }
    final tried = <String>[];
    // Server index: the next server is used when one can't be reached or
    // answers with something that isn't a PNG (they hold the same covers, so
    // a plain "not found" is final).
    var server = 0;
    final errors = <String>[];

    Future<Uint8List?> get(String n) async {
      while (true) {
        final urls = coverUrls(game.consoleId, n);
        if (server >= urls.length) return null;
        try {
          final body = await _fetch(urls[server]);
          if (body == null) return null;
          if (body.length <= maxBytes && _isPng(body)) return body;
          errors.add('${urls[server].host}: not an image');
        } catch (e) {
          errors.add('${urls[server].host}: $e');
          AppLogger.instance.warn('Cover server ${urls[server].host} failed: $e');
        }
        server++;
      }
    }

    Future<CoverSearch> save(String n, Uint8List png) async {
      final problem = await _save(game, png);
      return problem == null
          ? CoverSearch(found: true, tried: tried, name: n)
          : CoverSearch(found: false, tried: tried, error: problem);
    }

    for (final n in names) {
      tried.add(n);
      final png = await get(n);
      if (png != null) return save(n, png);
      if (server >= 2) break;
    }
    // Loose match against the console's list of covers.
    final list = await _coverList(game.consoleId, errors);
    if (list != null) {
      for (final t in [...names, game.title]) {
        final match = bestCoverMatch(t, list);
        if (match == null || tried.contains(match)) continue;
        tried.add(match);
        if (server >= 2) server = 1; // the list came from GitHub: it is reachable
        final png = await get(match);
        if (png != null) return save(match, png);
        break;
      }
      return CoverSearch(found: false, tried: tried);
    }
    if (server >= 2) {
      return CoverSearch(
          found: false,
          tried: tried,
          error: 'Could not reach the cover servers. Check the Internet connection.\n${errors.join('\n')}');
    }
    return CoverSearch(found: false, tried: tried);
  }

  /// File names in the console's Named_Boxarts folder (GitHub copy of the
  /// collection: two small API requests), cached; null if unavailable.
  Future<List<String>?> _coverList(String consoleId, List<String> errors) async {
    final cached = _lists[consoleId];
    if (cached != null) return cached;
    final repo = Uri.encodeComponent(retroArchDbNames[consoleId]!.replaceAll(' ', '_'));
    try {
      final root = await _fetch(Uri.parse('https://api.github.com/repos/libretro-thumbnails/$repo/git/trees/master'));
      if (root == null) return null;
      final sha = ((jsonDecode(utf8.decode(root)) as Map)['tree'] as List)
          .cast<Map>()
          .firstWhere((e) => e['path'] == 'Named_Boxarts', orElse: () => const {})['sha'];
      if (sha is! String) return null;
      final dir = await _fetch(Uri.parse('https://api.github.com/repos/libretro-thumbnails/$repo/git/trees/$sha'));
      if (dir == null) return null;
      final names = [
        for (final e in ((jsonDecode(utf8.decode(dir)) as Map)['tree'] as List).cast<Map>())
          if (e['type'] == 'blob' && e['path'] is String) e['path'] as String,
      ];
      return _lists[consoleId] = names;
    } catch (e) {
      errors.add('api.github.com: $e');
      AppLogger.instance.warn('Cover list for $consoleId failed: $e');
      return null;
    }
  }

  Future<String?> _fileStem(int gameId) async {
    final files = await _db.filesForGame(gameId);
    if (files.isEmpty) return null;
    final primary = files.firstWhere((f) => f.isPrimary, orElse: () => files.first);
    final name = primary.displayPath.split('/').last;
    return stripExtension(name);
  }

  /// Saves [png] as the cover; returns why it failed, or null.
  Future<String?> _save(GameRow game, Uint8List png) async {
    File? f;
    try {
      final dir = await _tempDir();
      f = File('${dir.path}/gamebox_cover_${game.id}_${DateTime.now().microsecondsSinceEpoch}.png');
      await f.writeAsBytes(png, flush: true);
      return await _library.importCover(game.id, f.path) ? null : 'The downloaded image could not be read.';
    } catch (e, s) {
      AppLogger.instance.error('Saving downloaded cover failed', e, s);
      return 'The cover was downloaded but could not be saved: $e';
    } finally {
      try {
        await f?.delete();
      } catch (_) {}
    }
  }

  static Future<Uint8List?> _httpGet(Uri url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..userAgent = 'GAMEBOX';
    try {
      final req = await client.getUrl(url).timeout(const Duration(seconds: 15));
      if (url.host == 'api.github.com') req.headers.set('Accept', 'application/vnd.github+json');
      final res = await req.close().timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        await res.drain<void>().timeout(const Duration(seconds: 5), onTimeout: () {});
        // Rate limits and server errors are failures, not "not found".
        if (res.statusCode == 403 || res.statusCode == 429 || res.statusCode >= 500) {
          throw HttpException('HTTP ${res.statusCode}', uri: url);
        }
        return null;
      }
      // Covers are small; cover lists (JSON) can be a few MB.
      const limit = 24 * 1024 * 1024;
      if (res.contentLength > limit) return null;
      final b = BytesBuilder(copy: false);
      await for (final chunk in res.timeout(const Duration(seconds: 60))) {
        b.add(chunk);
        if (b.length > limit) return null;
      }
      return b.takeBytes();
    } finally {
      client.close(force: true);
    }
  }
}
