/// Identifies the console of a ROM from its extension and folder names.
///
/// Extensions shared between systems (`iso`, `bin`, `chd`, `cue`, archives…)
/// are only resolved when a parent folder names the console. GAMEBOX never
/// guesses: an unresolved file is reported, not imported.
library;

import '../constants/console_catalog.dart';
import 'title_normalizer.dart';

/// Folder names (lower-case, alphanumerics only) recognised per console.
/// Includes common layouts used by other frontends (EmulationStation, etc.).
const Map<String, List<String>> consoleFolderAliases = {
  'nes': ['nes', 'famicom', 'fc', 'nintendo', 'nintendoentertainmentsystem', 'fds'],
  'snes': ['snes', 'superfamicom', 'sfc', 'supernintendo', 'supernes'],
  'sms': ['sms', 'mastersystem', 'segamastersystem'],
  'neogeo': ['neogeo', 'neo', 'neogeoaes', 'neogeomvs', 'snkneogeo'],
  'atari2600': ['atari2600', 'a2600', 'vcs', 'atarivcs'],
  'atari7800': ['atari7800', 'a7800'],
  'atarilynx': ['atarilynx', 'lynx'],
  'arcade': ['arcade', 'fbneo', 'fba', 'finalburnneo', 'mame', 'cps1', 'cps2', 'cps3'],
  'megadrive': ['megadrive', 'genesis', 'md', 'segagenesis', 'segamegadrive'],
  'gb': ['gb', 'gameboy'],
  'gbc': ['gbc', 'gameboycolor', 'gameboycolour'],
  'gba': ['gba', 'gameboyadvance'],
  'ps1': ['ps1', 'psx', 'psone', 'playstation', 'playstation1', 'sonyplaystation'],
  'n64': ['n64', 'nintendo64'],
  'saturn': ['saturn', 'segasaturn', 'ss'],
  'nds': ['nds', 'ds', 'nintendods'],
  'psp': ['psp', 'playstationportable'],
  'dreamcast': ['dreamcast', 'dc', 'segadreamcast'],
  'gamecube': ['gamecube', 'gc', 'ngc', 'nintendogamecube'],
  'ps2': ['ps2', 'playstation2'],
  'wii': ['wii', 'nintendowii'],
};

/// Archive formats accepted only when the folder identifies a cartridge-era
/// console (most emulators for those systems can open them directly).
const archiveExtensions = {'zip', '7z'};
const _archiveConsoles = {
  'nes', 'snes', 'sms', 'megadrive', 'gb', 'gbc', 'gba', 'n64', 'neogeo', 'arcade', 'atari2600', 'atari7800', 'atarilynx',
};

/// Consoles whose games *are* archives (arcade romsets): played as they are.
const archiveGameConsoles = {'neogeo', 'arcade'};

/// BIOS and device sets that sit next to arcade games but aren't games.
const arcadeBiosSets = {
  'neogeo', 'pgm', 'skns', 'decocass', 'isgsm', 'nmk004', 'ym2608', 'cchip', 'bubsys', 'midssio',
  'namcoc69', 'namcoc70', 'namcoc75', 'qsound', 'spec128', 'msx', 'coleco', 'channelf',
};

/// Descriptor files that reference other files of a disc image.
const descriptorExtensions = {'cue', 'gdi', 'ccd', 'mds', 'm3u'};

/// Track/data files that are never games on their own when a descriptor is
/// present in the same folder.
const companionExtensions = {'bin', 'raw', 'img', 'sub', 'mdf', 'ecm'};

enum DetectionMethod { uniqueExtension, folder }

class ConsoleMatch {
  const ConsoleMatch(this.consoleId, this.method);
  final String consoleId;
  final DetectionMethod method;
}

class ConsoleDetector {
  ConsoleDetector({List<ConsoleDefinition>? catalog}) {
    catalog ??= allConsoles;
    for (final c in catalog) {
      for (final e in c.extensions) {
        _byExtension.putIfAbsent(e, () => {}).add(c.id);
      }
      _known.add(c.id);
      _aliases[normalizeFolder(c.folderName)] = c.id;
      if (c.category == ConsoleCategory.other) _userIds.add(c.id);
    }
    consoleFolderAliases.forEach((id, aliases) {
      if (!_known.contains(id)) return;
      for (final a in aliases) {
        _aliases.putIfAbsent(a, () => id);
      }
    });
  }

  final Map<String, Set<String>> _byExtension = {};
  final Map<String, String> _aliases = {};
  final Set<String> _known = {};

  /// Systems added by the user.
  final Set<String> _userIds = {};

  static String normalizeFolder(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// All extensions worth reporting from a scan (ROMs + archives + companions).
  Set<String> get scannableExtensions => {..._byExtension.keys, ...archiveExtensions, ...companionExtensions};

  bool isKnownExtension(String ext) => _byExtension.containsKey(ext) || archiveExtensions.contains(ext);

  /// Console named by the closest folder in [dirSegments] (outermost first).
  String? consoleFromFolders(List<String> dirSegments) {
    for (final seg in dirSegments.reversed) {
      final id = _aliases[normalizeFolder(seg)];
      if (id != null) return id;
    }
    return null;
  }

  ConsoleMatch? detect(String fileName, List<String> dirSegments) {
    final ext = extensionOf(fileName);
    final folderConsole = consoleFromFolders(dirSegments);

    if (archiveExtensions.contains(ext)) {
      // Cartridge-era consoles, or a system added by the user that lists
      // the archive type (e.g. arcade sets as .zip).
      final ok =
          folderConsole != null &&
          (_archiveConsoles.contains(folderConsole) ||
              (_userIds.contains(folderConsole) && (_byExtension[ext]?.contains(folderConsole) ?? false)));
      return ok ? ConsoleMatch(folderConsole, DetectionMethod.folder) : null;
    }
    final candidates = _byExtension[ext];
    if (candidates == null || candidates.isEmpty) return null;

    // The folder wins when it names one of the consoles that accepts this
    // extension (e.g. `.iso` inside `PSP/`).
    if (folderConsole != null && candidates.contains(folderConsole)) {
      return ConsoleMatch(folderConsole, DetectionMethod.folder);
    }
    if (candidates.length == 1) {
      return ConsoleMatch(candidates.first, DetectionMethod.uniqueExtension);
    }
    // Systems added by the user never make a known console's file type
    // ambiguous: outside their folder they don't count.
    final known = candidates.where((c) => !_userIds.contains(c)).toList();
    if (known.length == 1) return ConsoleMatch(known.first, DetectionMethod.uniqueExtension);
    return null;
  }
}
