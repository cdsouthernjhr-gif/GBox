import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/online/catalog.dart';
import '../../core/online/download_engine.dart';
import '../../core/online/url_safety.dart';
import '../../core/utilities/formatters.dart';

/// Source types from spec Part 12 and the connector that handles each.
enum SourceType {
  directUrl('direct_url', 'Direct download URL', 'direct_url'),
  homebrewRepo('homebrew_repo', 'Authorised homebrew repository', 'gamebox_catalog'),
  publicDomainRepo('public_domain_repo', 'Public-domain game repository', 'gamebox_catalog'),
  authorizedDistribution('authorized_distribution', 'Authorised distribution (file link)', 'direct_url'),
  personalCloud('personal_cloud', 'Personal cloud storage (shared file link)', 'direct_url'),
  userHosting('user_hosting', 'Your own file hosting', 'direct_url'),
  customHttpApi('custom_http_api', 'Custom HTTP API (GAMEBOX catalogue JSON)', 'gamebox_catalog');

  const SourceType(this.dbValue, this.label, this.connectorId);
  final String dbValue;
  final String label;
  final String connectorId;

  bool get isCatalog => connectorId == 'gamebox_catalog';

  static SourceType fromDb(String v) => values.firstWhere((t) => t.dbValue == v, orElse: () => directUrl);
}

class BrowseResult {
  const BrowseResult({this.name, this.entries = const [], this.rejected = const [], this.error});
  final String? name;
  final List<CatalogEntry> entries;
  final List<String> rejected;
  final String? error;
}

/// Online Source Manager (Phase 5). Sources are added by the user; GAMEBOX
/// ships none. Only direct file links and the documented GAMEBOX catalogue
/// format are supported — websites are never scraped, and sources needing a
/// login are not supported (authentication is never bypassed).
class SourceService {
  SourceService(this._db, this._engine);
  final AppDatabase _db;
  final DownloadEngine _engine;

  /// Throws [ArgumentError] with a user-facing message.
  Future<int> add({
    required String name,
    required String url,
    required SourceType type,
    String? category,
    String? description,
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Enter a name');
    final check = validateUrl(url, allowHttp: _engine.httpAllowed);
    if (!check.ok) throw ArgumentError(check.error);
    return _db.addSource(GameSourcesCompanion.insert(
      name: name.trim(),
      url: check.uri.toString(),
      type: type.dbValue,
      category: Value(category?.trim().isEmpty ?? true ? null : category!.trim()),
      description: Value(description?.trim().isEmpty ?? true ? null : description!.trim()),
      connectorId: Value(type.connectorId),
    ));
  }

  /// Checks reachability (and, for catalogues, validity). Stores the status.
  Future<String> check(int id) async {
    final s = await _db.sourceById(id);
    final type = SourceType.fromDb(s.type);
    final probe = await _engine.probe(Uri.parse(s.url));
    String status;
    if (!probe.ok) {
      status = probe.error ?? 'Unreachable (HTTP ${probe.statusCode})';
    } else if (type.isCatalog) {
      final b = await browse(id);
      status = b.error ?? 'Online · ${b.entries.length} games'
          '${b.rejected.isEmpty ? '' : ' (${b.rejected.length} entries rejected)'}';
    } else if (probe.contentType == 'text/html') {
      status = 'This is a web page, not a direct file link';
    } else {
      status = 'Online · ${probe.size == null ? 'size unknown' : formatBytes(probe.size)}';
    }
    await _db.updateSourceStatus(id, status);
    return status;
  }

  Future<BrowseResult> browse(int id) async {
    final s = await _db.sourceById(id);
    if (!SourceType.fromDb(s.type).isCatalog) {
      return const BrowseResult(error: 'This source is a single file link; use Download.');
    }
    try {
      final body = await _engine.fetchText(Uri.parse(s.url));
      final r = parseCatalog(body, allowHttp: _engine.httpAllowed);
      return BrowseResult(name: r.name, entries: r.entries, rejected: r.rejected, error: r.error);
    } catch (e) {
      return BrowseResult(error: 'Could not load the catalogue: $e');
    }
  }

  Future<void> remove(int id) => _db.deleteSource(id);
}
