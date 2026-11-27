/// Systems the user adds by hand when GAMEBOX doesn't list them (e.g. Neo
/// Geo, arcade, Atari): a name, a folder under `ROMs/` and the file types.
/// Stored as JSON in the settings; GAMEBOX has no hardware estimate for them.
library;

import 'dart:convert';

import '../../domain/entities/performance_tier.dart';
import '../rom/console_detector.dart' show consoleFolderAliases;
import '../storage/gamebox_layout.dart' show romFolderNames;
import 'console_catalog.dart';

class CustomConsole {
  const CustomConsole({required this.id, required this.name, required this.folder, required this.extensions});

  /// `user_<folder>`: never the id of a console GAMEBOX knows.
  final String id;
  final String name;

  /// Folder under `ROMs/` (lower case letters, digits, "_" and "-").
  final String folder;

  /// Lower-case file extensions without dot.
  final List<String> extensions;

  static String idFor(String folder) => 'user_$folder';

  ConsoleDefinition toDefinition() => ConsoleDefinition(
    id: id,
    name: name,
    manufacturer: 'Added by you',
    category: ConsoleCategory.other,
    folderName: folder,
    extensions: extensions,
    minTier: PerformanceTier.entry,
    recommendedTier: PerformanceTier.entry,
    plannedPhase: 0,
    notes: 'Added by you: GAMEBOX has no hardware estimate for this system.',
  );

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'folder': folder, 'extensions': extensions};

  static final _folder = RegExp(r'^[a-z0-9][a-z0-9_-]{0,31}$');
  static final _ext = RegExp(r'^[a-z0-9]{1,8}$');

  /// Suggested folder for a name: "Neo Geo" → "neogeo".
  static String folderFor(String name) {
    final f = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return f.length > 32 ? f.substring(0, 32) : f;
  }

  /// Extensions typed by the user: ".zip, NEO 7z" → [zip, neo, 7z].
  static List<String> parseExtensions(String text) => {
        for (final e in text.toLowerCase().split(RegExp(r'[\s,;]+')))
          if (e.replaceAll('.', '').isNotEmpty) e.replaceAll('.', ''),
      }.toList();

  /// Why [name]/[folder]/[extensions] can't be saved, or null. [others] are
  /// the user's other systems (when editing, without this one).
  static String? problem(String name, String folder, List<String> extensions, List<CustomConsole> others) {
    if (name.trim().isEmpty) return 'Give the system a name.';
    if (!_folder.hasMatch(folder)) return 'Folder: lower-case letters, digits, "_" or "-" (up to 32).';
    if (extensions.isEmpty) return 'Type at least one file type (e.g. zip).';
    final bad = extensions.where((e) => !_ext.hasMatch(e)).toList();
    if (bad.isNotEmpty) return 'Not a file type: ${bad.join(', ')}';
    final known = {
      for (final c in consoleCatalog) c.folderName.toLowerCase(),
      ...romFolderNames.values,
      // Folder names other frontends use for known consoles (e.g. "gc", "md").
      for (final l in consoleFolderAliases.values) ...l,
      for (final o in others) o.folder,
    };
    if (known.contains(folder)) return 'ROMs/$folder is already used by another system.';
    final names = {for (final c in consoleCatalog) c.name.toLowerCase(), for (final o in others) o.name.toLowerCase()};
    if (names.contains(name.trim().toLowerCase())) return 'There is already a system called "${name.trim()}".';
    return null;
  }

  static CustomConsole? fromJson(Object? j) {
    if (j is! Map) return null;
    final name = j['name'], folder = j['folder'], exts = j['extensions'];
    if (name is! String || folder is! String || exts is! List) return null;
    final e = [
      for (final x in exts)
        if (x is String && _ext.hasMatch(x)) x,
    ];
    if (name.trim().isEmpty || !_folder.hasMatch(folder) || e.isEmpty) return null;
    return CustomConsole(id: idFor(folder), name: name.trim(), folder: folder, extensions: e);
  }

  static List<CustomConsole> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final out = <CustomConsole>[];
      for (final j in jsonDecode(raw) as List) {
        final c = fromJson(j);
        if (c != null && out.every((o) => o.folder != c.folder)) out.add(c);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<CustomConsole> list) => jsonEncode([for (final c in list) c.toJson()]);
}
