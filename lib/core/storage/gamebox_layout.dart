/// The GAMEBOX folder layout, shared by the app-storage location
/// (`Android/data/com.gamebox.console/files/GAMEBOX`) and a user-chosen
/// public folder (Storage Access Framework tree).
///
/// ```
/// GAMEBOX/
///   Games/<CONSOLE>/          downloads land here, sorted by console
///   Artwork/Covers|Screenshots|Backgrounds
///   Saves/<Emulator>/...      suggested save folders, one per emulator
///   BIOS/<CONSOLE>/, BIOS/RetroArch/   user-supplied BIOS dumps (none bundled)
///   Backups/  Downloads/  Exports/
/// ```
library;

import '../constants/console_catalog.dart';

/// Relative path of a console's game folder.
String gamesDirFor(String consoleId) => 'Games/${consoleById(consoleId)!.folderName}';

/// Suggested save folder(s) for an emulator, and how to point the emulator
/// at them. Menu names are given only where they are well known; other
/// emulators get generic advice, because their settings differ by version.
class SaveLayout {
  const SaveLayout({required this.emulatorId, required this.dirs, required this.howTo, this.specific = false});
  final String emulatorId;

  /// Relative to the GAMEBOX root. The first entry is registered with the
  /// Save Manager (sub-folders are scanned too).
  final List<String> dirs;
  final String howTo;

  /// True when [howTo] names actual menu entries.
  final bool specific;

  String get root => dirs.first.split('/').take(2).join('/');
}

const _generic = 'Open the emulator\'s settings and look for a save, memory-card or data folder option. '
    'If there is one, choose this folder. If not, the emulator keeps saves in its own folder; '
    'register that folder under Saves instead.';

const saveLayouts = <SaveLayout>[
  SaveLayout(
    emulatorId: 'retroarch',
    dirs: ['Saves/RetroArch/saves', 'Saves/RetroArch/states'],
    howTo: 'RetroArch → Settings → Directory → Save Files: choose Saves/RetroArch/saves. '
        'Save States: choose Saves/RetroArch/states.',
    specific: true,
  ),
  SaveLayout(
    emulatorId: 'ppsspp',
    dirs: ['Saves/PPSSPP'],
    howTo: 'PPSSPP → Settings → System → Memory Stick folder: choose Saves/PPSSPP. PPSSPP then keeps all its '
        'data there; saves go to PSP/SAVEDATA and states to PSP/PPSSPP_STATE inside it.',
    specific: true,
  ),
  SaveLayout(emulatorId: 'duckstation', dirs: ['Saves/DuckStation'], howTo: _generic),
  SaveLayout(emulatorId: 'mupen64plus_fz', dirs: ['Saves/Mupen64PlusFZ'], howTo: _generic),
  SaveLayout(emulatorId: 'melonds', dirs: ['Saves/melonDS'], howTo: _generic),
  SaveLayout(emulatorId: 'drastic', dirs: ['Saves/DraStic'], howTo: _generic),
  SaveLayout(emulatorId: 'flycast', dirs: ['Saves/Flycast'], howTo: _generic),
  SaveLayout(emulatorId: 'redream', dirs: ['Saves/Redream'], howTo: _generic),
  SaveLayout(emulatorId: 'dolphin', dirs: ['Saves/Dolphin'], howTo: _generic),
  SaveLayout(emulatorId: 'aethersx2', dirs: ['Saves/AetherSX2'], howTo: _generic),
];

SaveLayout? saveLayoutFor(String emulatorId) {
  for (final l in saveLayouts) {
    if (l.emulatorId == emulatorId) return l;
  }
  return null;
}

/// One BIOS file an emulator commonly looks for.
class BiosFile {
  const BiosFile(this.name, this.region, {this.usedBy = ''});
  final String name;
  final String region;
  final String usedBy;
}

/// BIOS expectations per console. GAMEBOX never provides BIOS files; dump
/// them from your own console. File names are the ones commonly documented
/// by the emulators; check your emulator's documentation if one isn't found.
class BiosInfo {
  const BiosInfo({
    required this.consoleId,
    required this.required,
    required this.note,
    this.files = const [],
    this.anyDump = false,
  });
  final String consoleId;

  /// False when the emulators have a built-in replacement (HLE) for most games.
  final bool required;
  final String note;
  final List<BiosFile> files;

  /// The emulator accepts any dump; file names don't matter.
  final bool anyDump;

  String get dir => 'BIOS/${consoleById(consoleId)!.folderName}';
}

const biosInfo = <BiosInfo>[
  BiosInfo(
    consoleId: 'ps1',
    required: true,
    note: 'DuckStation needs a PS1 BIOS (any region; choose this folder in its BIOS settings). '
        'RetroArch cores look for these names in RetroArch\'s System/BIOS folder.',
    files: [
      BiosFile('scph5500.bin', 'Japan', usedBy: 'RetroArch Beetle PSX'),
      BiosFile('scph5501.bin', 'USA', usedBy: 'RetroArch Beetle PSX / PCSX ReARMed'),
      BiosFile('scph5502.bin', 'Europe', usedBy: 'RetroArch Beetle PSX'),
      BiosFile('scph1001.bin', 'USA', usedBy: 'RetroArch PCSX ReARMed'),
    ],
  ),
  BiosInfo(
    consoleId: 'ps2',
    required: true,
    anyDump: true,
    note: 'AetherSX2/NetherSX2 need a dump of your own PS2 BIOS (any file name). Choose this folder when the '
        'emulator asks for the BIOS.',
  ),
  BiosInfo(
    consoleId: 'saturn',
    required: true,
    note: 'RetroArch Saturn cores look for these names in RetroArch\'s System/BIOS folder.',
    files: [
      BiosFile('sega_101.bin', 'Japan', usedBy: 'RetroArch Beetle Saturn'),
      BiosFile('mpr-17933.bin', 'USA/Europe', usedBy: 'RetroArch Beetle Saturn'),
      BiosFile('saturn_bios.bin', 'any', usedBy: 'RetroArch Yabause'),
    ],
  ),
  BiosInfo(
    consoleId: 'dreamcast',
    required: false,
    note: 'Flycast and Redream run many games without a BIOS. Some games need it. In RetroArch the files go '
        'in System/BIOS/dc/.',
    files: [
      BiosFile('dc_boot.bin', 'any', usedBy: 'Flycast / Redream'),
      BiosFile('dc_flash.bin', 'any', usedBy: 'Flycast'),
    ],
  ),
  BiosInfo(
    consoleId: 'nds',
    required: false,
    note: 'melonDS has a built-in replacement; real BIOS/firmware improves compatibility. DraStic needs none.',
    files: [
      BiosFile('bios7.bin', 'any', usedBy: 'melonDS'),
      BiosFile('bios9.bin', 'any', usedBy: 'melonDS'),
      BiosFile('firmware.bin', 'any', usedBy: 'melonDS'),
    ],
  ),
  BiosInfo(
    consoleId: 'gba',
    required: false,
    note: 'Optional. mGBA runs games without it.',
    files: [BiosFile('gba_bios.bin', 'any', usedBy: 'RetroArch mGBA / gpSP')],
  ),
  BiosInfo(
    consoleId: 'gamecube',
    required: false,
    note: 'Optional. Dolphin runs games without it (the IPL only adds the boot animation).',
    files: [BiosFile('IPL.bin', 'per region', usedBy: 'Dolphin (GC/USA, GC/EUR or GC/JAP folder)')],
  ),
];

/// Folder RetroArch's System/BIOS directory can be pointed at.
const retroArchBiosDir = 'BIOS/RetroArch';

/// Every folder of the layout, relative to the GAMEBOX root.
List<String> gameboxFolders() => [
      for (final c in consoleCatalog) 'Games/${c.folderName}',
      'Artwork/Covers',
      'Artwork/Screenshots',
      'Artwork/Backgrounds',
      for (final l in saveLayouts) ...l.dirs,
      for (final b in biosInfo) b.dir,
      retroArchBiosDir,
      'Backups',
      'Downloads',
      'Exports',
    ];

/// Status of one console's BIOS folder.
class BiosStatus {
  const BiosStatus(this.info, this.present);
  final BiosInfo info;

  /// File names found in the folder (as found).
  final List<String> present;

  bool has(String name) => present.any((p) => p.toLowerCase() == name.toLowerCase());

  /// At least one usable file is present.
  bool get ready => info.anyDump ? present.isNotEmpty : info.files.any((f) => has(f.name));
}

/// Folders that never contain games: BIOS dumps (anywhere, e.g. RetroArch's
/// System/BIOS) and GAMEBOX's own Saves/Backups/Exports. The library scan
/// skips them so BIOS `.bin` files are not imported as PS1 games.
bool isNonGameFolder(List<String> dirSegments) {
  if (dirSegments.any((d) => d.toLowerCase() == 'bios')) return true;
  return dirSegments.isNotEmpty && const {'saves', 'backups', 'exports'}.contains(dirSegments.first.toLowerCase());
}
