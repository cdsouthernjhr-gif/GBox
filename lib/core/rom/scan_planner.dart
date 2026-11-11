/// Turns a flat list of scanned files into games to import.
///
/// Rules:
/// * a file is a game only if its console can be identified (extension or
///   folder) — see [ConsoleDetector];
/// * track files (`.bin`, `.raw`, …) are dropped when a descriptor (`.cue`,
///   `.gdi`, `.ccd`, `.mds`, `.m3u`) exists in the same folder;
/// * multi-disc sets (`(Disc 1)`, `(Disc 2)`) in the same folder become one
///   game; an `.m3u` playlist becomes the primary file when present;
/// * images in the scanned tree whose name matches a game become its local
///   cover artwork.
library;

import 'console_detector.dart';
import 'title_normalizer.dart';

const imageExtensions = {'png', 'jpg', 'jpeg', 'webp'};

class ScannedEntry {
  const ScannedEntry({
    required this.uri,
    required this.name,
    required this.dirSegments,
    this.size,
    this.lastModified,
  });

  /// SAF document URI or absolute file path.
  final String uri;
  final String name;

  /// Folder names from the scan root down to the file's folder.
  final List<String> dirSegments;
  final int? size;
  final int? lastModified;

  String get extension => extensionOf(name);
  String get dirKey => dirSegments.join('/');
  String get displayPath => [...dirSegments, name].join('/');

  factory ScannedEntry.fromMap(Map<String, dynamic> m) => ScannedEntry(
        uri: m['uri'] as String,
        name: m['name'] as String,
        dirSegments: ((m['dir'] as List?) ?? const []).cast<String>(),
        size: (m['size'] as num?)?.toInt(),
        lastModified: (m['lastModified'] as num?)?.toInt(),
      );
}

class PlannedGame {
  PlannedGame({required this.consoleId, required this.title, required this.primary, required this.files, this.cover});
  final String consoleId;
  final TitleInfo title;
  final ScannedEntry primary;

  /// All files of the game, primary first.
  final List<ScannedEntry> files;
  ScannedEntry? cover;

  int get totalSize => files.fold(0, (a, f) => a + (f.size ?? 0));
}

class ScanPlan {
  const ScanPlan({required this.games, required this.unresolved, required this.skippedCompanions});
  final List<PlannedGame> games;

  /// Files with a ROM-like extension whose console could not be identified.
  final List<ScannedEntry> unresolved;
  final int skippedCompanions;
}

ScanPlan planScan(List<ScannedEntry> entries, ConsoleDetector detector) {
  final dirsWithDescriptor = <String>{
    for (final e in entries)
      if (descriptorExtensions.contains(e.extension)) e.dirKey,
  };

  final images = <String, List<ScannedEntry>>{};
  final unresolved = <ScannedEntry>[];
  var skipped = 0;
  // key: console|dir|matchKey → files (for multi-disc grouping)
  final discGroups = <String, List<(ScannedEntry, TitleInfo, String)>>{};
  final singles = <PlannedGame>[];

  for (final e in entries) {
    final ext = e.extension;
    if (imageExtensions.contains(ext)) {
      images.putIfAbsent(normalizeForMatch(stripExtension(e.name)), () => []).add(e);
      continue;
    }
    if (companionExtensions.contains(ext) && dirsWithDescriptor.contains(e.dirKey)) {
      skipped++;
      continue;
    }
    final match = detector.detect(e.name, e.dirSegments);
    if (match == null) {
      if (detector.isKnownExtension(ext) || descriptorExtensions.contains(ext)) unresolved.add(e);
      continue;
    }
    final info = normalizeTitle(e.name);
    if (info.disc != null || ext == 'm3u') {
      final key = '${match.consoleId}|${e.dirKey}|${info.matchKey}';
      discGroups.putIfAbsent(key, () => []).add((e, info, match.consoleId));
    } else {
      singles.add(PlannedGame(consoleId: match.consoleId, title: info, primary: e, files: [e]));
    }
  }

  final grouped = <PlannedGame>[];
  for (final group in discGroups.values) {
    final m3u = group.where((g) => g.$1.extension == 'm3u').firstOrNull;
    final discs = group.where((g) => g.$1.extension != 'm3u').toList()
      ..sort((a, b) => (a.$2.disc ?? 0).compareTo(b.$2.disc ?? 0));
    final primary = m3u ?? discs.first;
    grouped.add(PlannedGame(
      consoleId: primary.$3,
      title: primary.$2,
      primary: primary.$1,
      files: [primary.$1, ...discs.where((d) => d != primary).map((d) => d.$1)],
    ));
  }

  final games = [...singles, ...grouped];
  for (final g in games) {
    final candidates = images[g.title.matchKey] ?? images[normalizeForMatch(stripExtension(g.primary.name))];
    if (candidates == null || candidates.isEmpty) continue;
    // Prefer an image in the game's console folder tree, else the first one.
    g.cover = candidates.firstWhere(
      (i) => detector.consoleFromFolders(i.dirSegments) == g.consoleId,
      orElse: () => candidates.first,
    );
  }
  games.sort((a, b) => a.title.sortTitle.compareTo(b.title.sortTitle));
  return ScanPlan(games: games, unresolved: unresolved, skippedCompanions: skipped);
}
