/// Turns ROM file names into display titles.
///
/// `Legend of Zelda, The - A Link to the Past (USA) [!].sfc`
///   → title `The Legend of Zelda - A Link to the Past`, regions `[USA]`.
library;

class TitleInfo {
  const TitleInfo({
    required this.title,
    required this.sortTitle,
    this.regions = const [],
    this.disc,
    this.tags = const [],
  });

  final String title;

  /// Lower-case, leading article removed — used for ordering and matching.
  final String sortTitle;
  final List<String> regions;

  /// Disc number for multi-disc games, if present in the name.
  final int? disc;

  /// Remaining bracketed tags, e.g. `Rev 1`, `!`, `Beta`.
  final List<String> tags;

  /// Title without disc information, used to group multi-disc sets.
  String get matchKey => normalizeForMatch(title);
}

const _regionWords = {
  'usa', 'us', 'europe', 'eu', 'japan', 'jp', 'jpn', 'world', 'australia',
  'brazil', 'canada', 'china', 'france', 'germany', 'italy', 'korea',
  'netherlands', 'spain', 'sweden', 'asia', 'uk', 'en', 'fr', 'de', 'es', 'it',
};

String stripExtension(String name) {
  final dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}

String extensionOf(String name) {
  final dot = name.lastIndexOf('.');
  return dot > 0 && dot < name.length - 1 ? name.substring(dot + 1).toLowerCase() : '';
}

/// Lower-case alphanumerics only; used to match titles to artwork files.
String normalizeForMatch(String s) {
  var t = s.toLowerCase();
  t = t.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), ' ');
  t = t.replaceAll('&', ' and ');
  t = t.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  if (t.startsWith('the ')) t = t.substring(4);
  t = t.replaceAll(RegExp(r'\bthe$'), '').trim();
  return t.replaceAll(' ', '');
}

TitleInfo normalizeTitle(String fileName) {
  var base = stripExtension(fileName);
  final regions = <String>[];
  final tags = <String>[];
  int? disc;

  for (final m in RegExp(r'\(([^)]*)\)|\[([^\]]*)\]').allMatches(base)) {
    final inner = (m.group(1) ?? m.group(2) ?? '').trim();
    if (inner.isEmpty) continue;
    final discMatch = RegExp(r'^(?:disc|disk|cd)\s*(\d+)', caseSensitive: false).firstMatch(inner);
    if (discMatch != null) {
      disc = int.parse(discMatch.group(1)!);
      continue;
    }
    final parts = inner.split(RegExp(r'\s*,\s*'));
    if (m.group(1) != null && parts.every((p) => _regionWords.contains(p.toLowerCase()))) {
      regions.addAll(parts);
    } else {
      tags.add(inner);
    }
  }

  var title = base.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), ' ');
  // Underscores are almost always word separators in ROM names. Dots are only
  // treated as separators when the name has no spaces (e.g. Super.Mario.World).
  title = title.replaceAll('_', ' ');
  if (!title.contains(' ')) title = title.replaceAll('.', ' ');
  title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Trailing " -" left over after removing tags.
  title = title.replaceAll(RegExp(r'[\s\-]+$'), '').trim();

  // "Legend of Zelda, The - Subtitle" → "The Legend of Zelda - Subtitle"
  final article = RegExp(r'^(.*?), (The|A|An)(\b.*)$').firstMatch(title);
  if (article != null) {
    title = '${article.group(2)} ${article.group(1)}${article.group(3)}';
  }
  if (title.isEmpty) title = base.trim().isEmpty ? fileName : base.trim();

  var sort = title.toLowerCase();
  for (final a in const ['the ', 'a ', 'an ']) {
    if (sort.startsWith(a) && sort.length > a.length) {
      sort = sort.substring(a.length);
      break;
    }
  }
  return TitleInfo(title: title, sortTitle: sort, regions: regions, disc: disc, tags: tags);
}
