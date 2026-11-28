/// The GAMEBOX folder layout. Paths are relative to a *base*: the device
/// storage root (with all-files access, e.g. `/storage/emulated/0`), a folder
/// the user picked (SAF tree), or GAMEBOX's app folder as a last resort.
///
/// ```
/// <base>/
///   ROMs/<system>/            games, shared with RetroArch and other apps
///                             (nes, snes, psx, … — ES-DE / RetroPie names)
///   GAMEBOX/
///     Saves/<Emulator>/...    suggested save folders, one per emulator
///     BIOS/<CONSOLE>/, BIOS/RetroArch/   user-supplied BIOS (none bundled)
///     Playlists/              RetroArch playlists written by GAMEBOX
///     Artwork/  Backups/  Downloads/  Exports/
/// ```
library;

import '../constants/console_catalog.dart';

/// Folder of GAMEBOX's own data inside the base.
const dataDir = 'GAMEBOX';

/// Games folder inside the base.
const romsDir = 'ROMs';

/// Standard system folder names (the convention of ES-DE, RetroPie and
/// Daijishou), so other frontends and emulators find the same folders.
const romFolderNames = <String, String>{
  'nes': 'nes',
  'snes': 'snes',
  'sms': 'mastersystem',
  'megadrive': 'megadrive',
  'neogeo': 'neogeo',
  'arcade': 'arcade',
  'gb': 'gb',
  'gbc': 'gbc',
  'gba': 'gba',
  'ps1': 'psx',
  'n64': 'n64',
  'saturn': 'saturn',
  'nds': 'nds',
  'psp': 'psp',
  'dreamcast': 'dreamcast',
  'gamecube': 'gc',
  'ps2': 'ps2',
  'wii': 'wii',
};

/// Relative path of a console's game folder, e.g. `ROMs/psx`.
String gamesDirFor(String consoleId) =>
    '$romsDir/${romFolderNames[consoleId] ?? consoleById(consoleId)!.folderName.toLowerCase()}';

/// Folder of the RetroArch playlists GAMEBOX writes.
const playlistsDir = '$dataDir/Playlists';

/// Suggested save folder(s) for an emulator, and how to point the emulator
/// at them. Menu names are given only where they are well known; other
/// emulators get generic advice, because their settings differ by version.
class SaveLayout {
  const SaveLayout({required this.emulatorId, required this.dirs, required this.howTo, this.specific = false});
  final String emulatorId;

  /// Relative to the base. The first entry's emulator folder is registered
  /// with the Save Manager (sub-folders are scanned too).
  final List<String> dirs;
  final String howTo;

  /// True when [howTo] names actual menu entries.
  final bool specific;

  /// `GAMEBOX/Saves/<Emulator>`.
  String get root => dirs.first.split('/').take(3).join('/');
}

const _generic = 'Open the emulator\'s settings and look for a save, memory-card or data folder option. '
    'If there is one, choose this folder. If not, the emulator keeps saves in its own folder; '
    'register that folder under Saves instead.';

const saveLayouts = <SaveLayout>[
  SaveLayout(
    emulatorId: 'gamebox',
    dirs: ['$dataDir/Saves/GAMEBOX'],
    howTo: 'Built-in player: battery saves (.srm) and save states (.state) are stored here automatically, '
        'one folder per system.',
    specific: true,
  ),
  SaveLayout(
    emulatorId: 'retroarch',
    dirs: ['$dataDir/Saves/RetroArch/saves', '$dataDir/Saves/RetroArch/states'],
    howTo: 'RetroArch → Settings → Directory → Save Files: choose GAMEBOX/Saves/RetroArch/saves. '
        'Save States: choose GAMEBOX/Saves/RetroArch/states.',
    specific: true,
  ),
  SaveLayout(
    emulatorId: 'ppsspp',
    dirs: ['$dataDir/Saves/PPSSPP'],
    howTo: 'PPSSPP → Settings → System → Memory Stick folder: choose GAMEBOX/Saves/PPSSPP. PPSSPP then keeps all its '
        'data there; saves go to PSP/SAVEDATA and states to PSP/PPSSPP_STATE inside it.',
    specific: true,
  ),
  SaveLayout(emulatorId: 'duckstation', dirs: ['$dataDir/Saves/DuckStation'], howTo: _generic),
  SaveLayout(emulatorId: 'mupen64plus_fz', dirs: ['$dataDir/Saves/Mupen64PlusFZ'], howTo: _generic),
  SaveLayout(emulatorId: 'melonds', dirs: ['$dataDir/Saves/melonDS'], howTo: _generic),
  SaveLayout(emulatorId: 'drastic', dirs: ['$dataDir/Saves/DraStic'], howTo: _generic),
  SaveLayout(emulatorId: 'flycast', dirs: ['$dataDir/Saves/Flycast'], howTo: _generic),
  SaveLayout(emulatorId: 'redream', dirs: ['$dataDir/Saves/Redream'], howTo: _generic),
  SaveLayout(emulatorId: 'dolphin', dirs: ['$dataDir/Saves/Dolphin'], howTo: _generic),
  SaveLayout(emulatorId: 'aethersx2', dirs: ['$dataDir/Saves/AetherSX2'], howTo: _generic),
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
    this.folder,
  });
  final String consoleId;

  /// BIOS folder name when it isn't the console's own (Neo Geo and arcade
  /// share FinalBurn Neo's).
  final String? folder;

  /// False when the emulators have a built-in replacement (HLE) for most games.
  final bool required;
  final String note;
  final List<BiosFile> files;

  /// The emulator accepts any dump; file names don't matter.
  final bool anyDump;

  String get dir => '$dataDir/BIOS/${folder ?? consoleById(consoleId)!.folderName}';
}

const biosInfo = <BiosInfo>[
  BiosInfo(
    consoleId: 'neogeo',
    required: true,
    folder: 'ARCADE',
    note: 'FinalBurn Neo needs the Neo Geo BIOS set neogeo.zip (a dump of your own, matching the core version). '
        'It may also sit next to the games; GAMEBOX does not list it as a game.',
    files: [BiosFile('neogeo.zip', 'any', usedBy: 'FinalBurn Neo')],
  ),
  BiosInfo(
    consoleId: 'arcade',
    required: false,
    folder: 'ARCADE',
    note: 'Only some boards need a BIOS set (e.g. neogeo.zip for Neo Geo games, pgm.zip for PGM). Same folder as Neo Geo.',
    files: [BiosFile('neogeo.zip', 'any', usedBy: 'FinalBurn Neo (Neo Geo games)'), BiosFile('pgm.zip', 'any', usedBy: 'FinalBurn Neo (PGM)')],
  ),
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
const retroArchBiosDir = '$dataDir/BIOS/RetroArch';

/// Every folder of the layout, relative to the GAMEBOX root.
/// (Each folder once: some consoles share a BIOS folder.)
List<String> gameboxFolders() => {
      for (final c in allConsoles) gamesDirFor(c.id),
      '$dataDir/Artwork/Covers',
      '$dataDir/Artwork/Screenshots',
      '$dataDir/Artwork/Backgrounds',
      for (final l in saveLayouts) ...l.dirs,
      for (final b in biosInfo) b.dir,
      retroArchBiosDir,
      playlistsDir,
      '$dataDir/Backups',
      '$dataDir/Downloads',
      '$dataDir/Exports',
    }.toList();

/// Folders of the 0.9.0 layout (`Games/<CONSOLE>` inside the GAMEBOX
/// folder), moved into `ROMs/<system>` by the migration.
String legacyGamesDir(String consoleId) => 'Games/${consoleById(consoleId)!.folderName}';

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
/// System/BIOS) and GAMEBOX's own data folders. The library scan skips them
/// so BIOS `.bin` files are not imported as PS1 games.
bool isNonGameFolder(List<String> dirSegments) {
  const data = {'saves', 'backups', 'exports', 'playlists'};
  final segs = [for (final d in dirSegments) d.toLowerCase()];
  if (segs.contains('bios')) return true;
  if (segs.isNotEmpty && data.contains(segs.first)) return true; // relative to a GAMEBOX folder
  for (var i = 0; i + 1 < segs.length; i++) {
    if (segs[i] == 'gamebox' && data.contains(segs[i + 1])) return true;
  }
  return false;
}
