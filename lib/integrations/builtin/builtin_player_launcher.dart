/// GAMEBOX's built-in player: a bundled libretro core run by LibretroDroid
/// inside GAMEBOX (android/.../player/PlayerActivity.kt). No emulator app,
/// core download or emulator settings are needed, and GAMEBOX's own folders
/// (including its app folder) are readable.
library;

import '../../core/constants/console_catalog.dart';
import '../emulator_adapters/emulator_adapter.dart';

/// Bundled core per console (tool/fetch_cores.sh).
const builtInCores = <String, String>{
  'nes': 'fceumm',
  'snes': 'snes9x',
  'gb': 'gambatte',
  'gbc': 'gambatte',
  'gba': 'mgba',
  'megadrive': 'genesis_plus_gx',
  'sms': 'genesis_plus_gx',
  'ps1': 'pcsx_rearmed',
  'n64': 'mupen64plus_next_gles3',
  'nds': 'desmume',
  'psp': 'ppsspp',
};

/// Cores bundled for ARM only (no x86_64 build).
const armOnlyCores = {'ppsspp'};

/// Whether the built-in player can run [consoleId] on a device with [abis]
/// (unknown ABIs: assume yes).
bool builtInSupportsDevice(String consoleId, List<String> abis) {
  final core = builtInCores[consoleId];
  if (core == null) return false;
  if (!armOnlyCores.contains(core) || abis.isEmpty) return true;
  return abis.any((a) => a.startsWith('arm'));
}

const builtInCoreNames = <String, String>{
  'fceumm': 'FCEUmm',
  'snes9x': 'Snes9x',
  'gambatte': 'Gambatte',
  'mgba': 'mGBA',
  'genesis_plus_gx': 'Genesis Plus GX',
  'pcsx_rearmed': 'PCSX ReARMed',
  'mupen64plus_next_gles3': 'Mupen64Plus-Next',
  'desmume': 'DeSmuME',
  'ppsspp': 'PPSSPP',
};

/// On-screen control layout per console (TouchControls.kt).
const builtInTouchLayouts = <String, String>{
  'nes': 'nes',
  'gb': 'nes',
  'gbc': 'nes',
  'sms': 'nes',
  'snes': 'snes',
  'gba': 'gba',
  'megadrive': 'md',
  'ps1': 'ps1',
  'n64': 'n64',
  'nds': 'nds',
  'psp': 'psp',
};

/// File types each bundled core opens directly (archives are extracted by
/// GAMEBOX before launch).
const builtInExtensions = <String, Set<String>>{
  'nes': {'nes', 'fds', 'unf', 'unif'},
  'snes': {'sfc', 'smc', 'fig', 'swc', 'bs'},
  'gb': {'gb', 'gbc', 'dmg'},
  'gbc': {'gb', 'gbc', 'dmg'},
  'gba': {'gba', 'bin', 'agb'},
  'megadrive': {'md', 'gen', 'smd', 'bin', '68k', 'sgd'},
  'sms': {'sms', 'bin'},
  'ps1': {'cue', 'bin', 'img', 'mdf', 'pbp', 'chd', 'iso', 'm3u', 'ccd', 'cbn', 'toc'},
  'n64': {'n64', 'z64', 'v64', 'ndd'},
  'nds': {'nds'},
  'psp': {'iso', 'cso', 'pbp', 'elf', 'prx', 'chd'},
};

const playerActivity = 'com.gamebox.console.player.PlayerActivity';

class BuiltInPlayerLauncher extends GameLauncherAdapter {
  @override
  String get emulatorId => builtInPlayerId;

  @override
  Set<String> get consoleIds => builtInCores.keys.toSet();

  @override
  bool get builtIn => true;

  @override
  bool get verifiedOnDevice => false;

  @override
  String get launchMechanism => 'Built in (LibretroDroid, bundled core)';

  @override
  List<String> get knownLimitations => const [
        'Only the bundled cores: NES, SNES, Game Boy / Color / Advance, Mega Drive, Master System, PS1, '
            'N64, Nintendo DS, PSP (PSP on ARM devices only).',
        'N64 and PSP need a reasonably fast device; NDS touch screen works on phones (not with a TV remote).',
        'PS1 runs with the core\'s built-in BIOS replacement; a real BIOS in GAMEBOX/BIOS/PS1 improves compatibility.',
        '.7z archives are not supported (ZIP is extracted automatically).',
      ];

  @override
  List<LaunchOption> options(String consoleId) {
    final core = builtInCores[consoleId];
    if (core == null) return const [];
    return [LaunchOption(key: 'core', label: 'Core', values: {core: builtInCoreNames[core]!}, defaultValue: core)];
  }

  @override
  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options) {
    final core = builtInCores[target.consoleId];
    if (core == null) return LaunchBlocked(['The built-in player does not support this console.']);
    final path = target.localPath;
    if (path == null) {
      return LaunchBlocked(['GAMEBOX could not read the game file. If it is on a USB drive or SD card, '
          'check it is connected, then scan again.']);
    }
    final ext = path.split('.').last.toLowerCase();
    if (!(builtInExtensions[target.consoleId]?.contains(ext) ?? false)) {
      return LaunchBlocked(['The built-in player cannot open ".$ext" files for ${consoleById(target.consoleId)?.name}. '
          'Use "Play with…" to choose another emulator.']);
    }
    return LaunchReady(
      IntentSpec(
        packageName: gameboxPackage,
        className: playerActivity,
        extras: {
          'core': core,
          'rom': path,
          'system': ?env.systemDir,
          'saves': ?env.savesDir,
          'title': ?target.title,
          'touch': env.touchControls,
          'layout': builtInTouchLayouts[target.consoleId] ?? 'nes',
        },
      ),
      notes: const [],
    );
  }
}
