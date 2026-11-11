/// GAMEBOX catalogue format (connector `gamebox_catalog`), used by homebrew,
/// public-domain and authorised repositories that want to list games for
/// GAMEBOX. Documented in docs/ONLINE_SOURCES.md.
///
/// ```json
/// {
///   "format": "gamebox-catalog", "version": 1, "name": "Example Homebrew",
///   "games": [{
///     "title": "Demo", "console": "nes", "url": "https://…/demo.nes",
///     "license": "CC-BY-4.0", "size": 40976, "sha256": "…",
///     "description": "…", "developer": "…", "year": "2024",
///     "cover": "https://…/demo.png"
///   }]
/// }
/// ```
///
/// Every entry MUST state a licence; entries without one are rejected, so
/// only distribution the publisher explicitly authorises is offered.
library;

import 'dart:convert';

import '../constants/console_catalog.dart';
import 'url_safety.dart';

class CatalogEntry {
  const CatalogEntry({
    required this.title,
    required this.consoleId,
    required this.url,
    required this.license,
    this.size,
    this.sha256,
    this.description,
    this.developer,
    this.year,
    this.coverUrl,
  });

  final String title;
  final String consoleId;
  final Uri url;
  final String license;
  final int? size;
  final String? sha256;
  final String? description;
  final String? developer;
  final String? year;
  final Uri? coverUrl;

  Map<String, Object?> toJson() => {
        'title': title,
        'console': consoleId,
        'url': url.toString(),
        'license': license,
        'size': size,
        'sha256': sha256,
        'description': description,
        'developer': developer,
        'year': year,
        'cover': coverUrl?.toString(),
      };
}

class CatalogParseResult {
  const CatalogParseResult({this.name, this.entries = const [], this.rejected = const [], this.error});
  final String? name;
  final List<CatalogEntry> entries;

  /// Human-readable reasons for skipped entries.
  final List<String> rejected;
  final String? error;
}

CatalogParseResult parseCatalog(String body, {bool allowHttp = false}) {
  Object? json;
  try {
    json = jsonDecode(body);
  } catch (_) {
    return const CatalogParseResult(error: 'Not a GAMEBOX catalogue (invalid JSON)');
  }
  if (json is! Map || json['format'] != 'gamebox-catalog') {
    return const CatalogParseResult(error: 'Not a GAMEBOX catalogue ("format" must be "gamebox-catalog")');
  }
  if (json['version'] != 1) return CatalogParseResult(error: 'Unsupported catalogue version ${json['version']}');
  final games = json['games'];
  if (games is! List) return const CatalogParseResult(error: 'Catalogue has no "games" list');

  String? str(Map m, String k) {
    final v = m[k];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  final entries = <CatalogEntry>[];
  final rejected = <String>[];
  for (final (i, raw) in games.indexed) {
    if (raw is! Map) {
      rejected.add('#${i + 1}: not an object');
      continue;
    }
    final title = str(raw, 'title') ?? '#${i + 1}';
    final license = str(raw, 'license');
    if (license == null) {
      rejected.add('$title: no licence stated');
      continue;
    }
    final console = str(raw, 'console');
    if (console == null || consoleById(console) == null) {
      rejected.add('$title: unknown console "${raw['console']}"');
      continue;
    }
    final url = validateUrl(str(raw, 'url') ?? '', allowHttp: allowHttp);
    if (!url.ok) {
      rejected.add('$title: ${url.error}');
      continue;
    }
    final sha = str(raw, 'sha256')?.toLowerCase();
    if (sha != null && !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
      rejected.add('$title: invalid sha256');
      continue;
    }
    final cover = str(raw, 'cover');
    final coverCheck = cover == null ? null : validateUrl(cover, allowHttp: allowHttp);
    entries.add(CatalogEntry(
      title: title,
      consoleId: console,
      url: url.uri!,
      license: license,
      size: (raw['size'] is int && (raw['size'] as int) > 0) ? raw['size'] as int : null,
      sha256: sha,
      description: str(raw, 'description'),
      developer: str(raw, 'developer'),
      year: str(raw, 'year'),
      coverUrl: coverCheck?.ok == true ? coverCheck!.uri : null,
    ));
  }
  final name = json['name'];
  return CatalogParseResult(name: name is String ? name : null, entries: entries, rejected: rejected);
}
