/// Static catalogue of consoles and known external emulator apps.
///
/// Requirement tiers are GAMEBOX *estimates* used for the hardware-only
/// compatibility rating. They are replaced by benchmark and test evidence as
/// it becomes available (see the compatibility database).
library;

import '../../domain/entities/performance_tier.dart';

class ConsoleDefinition {
  const ConsoleDefinition({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.category,
    required this.folderName,
    required this.extensions,
    required this.minTier,
    required this.recommendedTier,
    required this.plannedPhase,
    this.requiresArm64 = false,
    this.minGlEs = 2.0,
    this.notes,
  });

  final String id;
  final String name;
  final String manufacturer;
  final ConsoleCategory category;

  /// Folder name inside `GAMEBOX/Games/`.
  final String folderName;

  /// Lower-case extensions without dot. Extensions shared between consoles
  /// (e.g. `iso`, `bin`, `chd`) are resolved by folder during scanning.
  final List<String> extensions;
  final PerformanceTier minTier;
  final PerformanceTier recommendedTier;
  final int plannedPhase;
  final bool requiresArm64;
  final double minGlEs;
  final String? notes;
}

enum ConsoleCategory { retro, gen32_64, handheld, console3d }

extension ConsoleCategoryLabel on ConsoleCategory {
  String get label => switch (this) {
        ConsoleCategory.retro => 'Retro systems',
        ConsoleCategory.gen32_64 => '32-bit & 64-bit systems',
        ConsoleCategory.handheld => 'Handheld systems',
        ConsoleCategory.console3d => '3D consoles',
      };
}

const List<ConsoleDefinition> consoleCatalog = [
  ConsoleDefinition(
    id: 'nes', name: 'NES', manufacturer: 'Nintendo',
    category: ConsoleCategory.retro, folderName: 'NES',
    extensions: ['nes', 'fds', 'unf', 'unif'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'snes', name: 'SNES', manufacturer: 'Nintendo',
    category: ConsoleCategory.retro, folderName: 'SNES',
    extensions: ['sfc', 'smc', 'fig', 'swc', 'bs'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'sms', name: 'Sega Master System', manufacturer: 'Sega',
    category: ConsoleCategory.retro, folderName: 'MASTERSYSTEM',
    extensions: ['sms'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'megadrive', name: 'Sega Mega Drive', manufacturer: 'Sega',
    category: ConsoleCategory.retro, folderName: 'MEGADRIVE',
    extensions: ['md', 'gen', 'smd'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'gb', name: 'Game Boy', manufacturer: 'Nintendo',
    category: ConsoleCategory.retro, folderName: 'GAMEBOY',
    extensions: ['gb'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'gbc', name: 'Game Boy Color', manufacturer: 'Nintendo',
    category: ConsoleCategory.retro, folderName: 'GAMEBOYCOLOR',
    extensions: ['gbc'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.entry,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'gba', name: 'Game Boy Advance', manufacturer: 'Nintendo',
    category: ConsoleCategory.retro, folderName: 'GBA',
    extensions: ['gba'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.standard,
    plannedPhase: 3,
  ),
  ConsoleDefinition(
    id: 'ps1', name: 'PlayStation', manufacturer: 'Sony',
    category: ConsoleCategory.gen32_64, folderName: 'PS1',
    extensions: ['cue', 'bin', 'chd', 'pbp', 'iso', 'img', 'm3u', 'ecm'],
    minTier: PerformanceTier.entry, recommendedTier: PerformanceTier.standard,
    plannedPhase: 3,
    notes: 'Most PS1 emulators need a user-supplied BIOS dump for best results.',
  ),
  ConsoleDefinition(
    id: 'n64', name: 'Nintendo 64', manufacturer: 'Nintendo',
    category: ConsoleCategory.gen32_64, folderName: 'N64',
    extensions: ['n64', 'z64', 'v64'],
    minTier: PerformanceTier.standard, recommendedTier: PerformanceTier.advanced,
    plannedPhase: 6,
  ),
  ConsoleDefinition(
    id: 'saturn', name: 'Sega Saturn', manufacturer: 'Sega',
    category: ConsoleCategory.gen32_64, folderName: 'SATURN',
    extensions: ['cue', 'chd', 'iso', 'ccd', 'mds'],
    minTier: PerformanceTier.advanced, recommendedTier: PerformanceTier.high,
    plannedPhase: 6,
    notes: 'Saturn emulation is CPU-heavy and usually needs a BIOS dump.',
  ),
  ConsoleDefinition(
    id: 'nds', name: 'Nintendo DS', manufacturer: 'Nintendo',
    category: ConsoleCategory.handheld, folderName: 'NDS',
    extensions: ['nds'],
    minTier: PerformanceTier.standard, recommendedTier: PerformanceTier.standard,
    plannedPhase: 6,
  ),
  ConsoleDefinition(
    id: 'psp', name: 'PSP', manufacturer: 'Sony',
    category: ConsoleCategory.handheld, folderName: 'PSP',
    extensions: ['iso', 'cso', 'pbp', 'chd'],
    minTier: PerformanceTier.standard, recommendedTier: PerformanceTier.advanced,
    plannedPhase: 6,
  ),
  ConsoleDefinition(
    id: 'dreamcast', name: 'Dreamcast', manufacturer: 'Sega',
    category: ConsoleCategory.console3d, folderName: 'DREAMCAST',
    extensions: ['gdi', 'cdi', 'chd'],
    minTier: PerformanceTier.standard, recommendedTier: PerformanceTier.advanced,
    plannedPhase: 6, minGlEs: 3.0,
  ),
  ConsoleDefinition(
    id: 'gamecube', name: 'GameCube', manufacturer: 'Nintendo',
    category: ConsoleCategory.console3d, folderName: 'GAMECUBE',
    extensions: ['iso', 'gcm', 'gcz', 'rvz', 'ciso'],
    minTier: PerformanceTier.advanced, recommendedTier: PerformanceTier.high,
    plannedPhase: 6, requiresArm64: true, minGlEs: 3.0,
  ),
  ConsoleDefinition(
    id: 'ps2', name: 'PlayStation 2', manufacturer: 'Sony',
    category: ConsoleCategory.console3d, folderName: 'PS2',
    extensions: ['iso', 'chd', 'cso', 'bin'],
    minTier: PerformanceTier.high, recommendedTier: PerformanceTier.high,
    plannedPhase: 6, requiresArm64: true, minGlEs: 3.0,
    notes: 'Requires a user-supplied PS2 BIOS dump. Demanding on any TV box.',
  ),
  ConsoleDefinition(
    id: 'wii', name: 'Wii', manufacturer: 'Nintendo',
    category: ConsoleCategory.console3d, folderName: 'WII',
    extensions: ['wbfs', 'iso', 'rvz', 'wad'],
    minTier: PerformanceTier.high, recommendedTier: PerformanceTier.high,
    plannedPhase: 6, requiresArm64: true, minGlEs: 3.0,
  ),
];

ConsoleDefinition? consoleById(String id) {
  for (final c in consoleCatalog) {
    if (c.id == id) return c;
  }
  return null;
}

enum IntegrationStrategy { external, standalone, libretro }

/// A third-party emulator app that GAMEBOX can detect (and, from Phase 3,
/// launch) through Android's documented package and intent mechanisms.
/// GAMEBOX does not bundle these apps.
class KnownEmulator {
  const KnownEmulator({
    required this.id,
    required this.name,
    required this.packageIds,
    required this.consoleIds,
    required this.license,
    this.strategy = IntegrationStrategy.external,
    this.requiresArm64 = false,
    this.minSdk,
    this.minGlEs,
    this.notes,
  });

  final String id;
  final String name;

  /// Package names checked in order. Builds of the same emulator can be
  /// published under different ids (e.g. 32-bit and 64-bit variants).
  final List<String> packageIds;
  final List<String> consoleIds;
  final String license;
  final IntegrationStrategy strategy;
  final bool requiresArm64;
  final int? minSdk;
  final double? minGlEs;
  final String? notes;
}

/// Package ids must also be listed in AndroidManifest.xml `<queries>` so they
/// are visible on Android 11+.
const List<KnownEmulator> knownEmulators = [
  KnownEmulator(
    id: 'retroarch', name: 'RetroArch',
    packageIds: ['com.retroarch', 'com.retroarch.aarch64', 'com.retroarch.ra32'],
    consoleIds: [
      'nes', 'snes', 'sms', 'megadrive', 'gb', 'gbc', 'gba', 'ps1', 'n64',
      'saturn', 'nds', 'psp', 'dreamcast',
    ],
    license: 'GPLv3 (cores vary)',
    strategy: IntegrationStrategy.libretro,
    notes: 'Multi-system frontend. Each system needs its libretro core installed '
        'inside RetroArch.',
  ),
  KnownEmulator(
    id: 'ppsspp', name: 'PPSSPP',
    packageIds: ['org.ppsspp.ppsspp', 'org.ppsspp.ppssppgold'],
    consoleIds: ['psp'], license: 'GPLv2+',
  ),
  KnownEmulator(
    id: 'duckstation', name: 'DuckStation',
    packageIds: ['com.github.stenzek.duckstation'],
    consoleIds: ['ps1'],
    license: 'Proprietary/non-commercial (check current terms)',
    notes: 'Licence terms changed over time; GAMEBOX only launches the '
        'user-installed app and never redistributes it.',
  ),
  KnownEmulator(
    id: 'mupen64plus_fz', name: 'Mupen64Plus FZ',
    packageIds: ['org.mupen64plusae.v3.fzurita'],
    consoleIds: ['n64'], license: 'GPLv3',
  ),
  KnownEmulator(
    id: 'melonds', name: 'melonDS',
    packageIds: ['me.magnum.melonds'],
    consoleIds: ['nds'], license: 'GPLv3',
  ),
  KnownEmulator(
    id: 'drastic', name: 'DraStic',
    packageIds: ['com.dsemu.drastic'],
    consoleIds: ['nds'], license: 'Proprietary (paid)',
  ),
  KnownEmulator(
    id: 'flycast', name: 'Flycast',
    packageIds: ['com.flycast.emulator'],
    consoleIds: ['dreamcast'], license: 'GPLv2', minGlEs: 3.0,
  ),
  KnownEmulator(
    id: 'redream', name: 'Redream',
    packageIds: ['io.recompiled.redream'],
    consoleIds: ['dreamcast'], license: 'Proprietary (freemium)',
  ),
  KnownEmulator(
    id: 'dolphin', name: 'Dolphin',
    packageIds: ['org.dolphinemu.dolphinemu'],
    consoleIds: ['gamecube', 'wii'], license: 'GPLv2+',
    requiresArm64: true, minGlEs: 3.0,
  ),
  KnownEmulator(
    id: 'aethersx2', name: 'AetherSX2 / NetherSX2',
    packageIds: ['xyz.aethersx2.android'],
    consoleIds: ['ps2'], license: 'Discontinued; distribution status unclear',
    requiresArm64: true, minGlEs: 3.0,
    notes: 'Detected only if the user installed it themselves.',
  ),
];

List<String> get allKnownEmulatorPackages =>
    [for (final e in knownEmulators) ...e.packageIds];
