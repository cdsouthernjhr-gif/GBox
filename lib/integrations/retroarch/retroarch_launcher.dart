/// RetroArch launcher (libretro frontend), external-app strategy.
///
/// Launch interface: RetroArch's Android activity
/// `com.retroarch.browser.retroactivity.RetroActivityFuture` with string
/// extras `ROM` (filesystem path), `LIBRETRO` (core .so path inside
/// RetroArch's own data directory) and `CONFIGFILE`. This is the interface
/// used by established Android frontends; GAMEBOX does not modify RetroArch.
///
/// RetroArch reads the ROM by **path**, so:
/// * files only reachable through a content URI (Downloads/cloud providers)
///   cannot be launched;
/// * on Android 11+ files inside another app's `Android/data` folder
///   (including GAMEBOX's own folders) are unreadable for RetroArch.
library;

import '../../core/rom/rom_path_resolver.dart';
import '../emulator_adapters/emulator_adapter.dart';

/// Recommended cores per console, first = default. Core names are the
/// libretro core file stems (`<core>_libretro_android.so`). The user must
/// install the core inside RetroArch (Main Menu → Load Core → Download).
const Map<String, Map<String, String>> retroArchCores = {
  'nes': {'fceumm': 'FCEUmm', 'nestopia': 'Nestopia UE', 'mesen': 'Mesen', 'quicknes': 'QuickNES (fast)'},
  'snes': {'snes9x': 'Snes9x', 'snes9x2010': 'Snes9x 2010 (fast)', 'bsnes': 'bsnes (accurate, heavy)'},
  'gb': {'gambatte': 'Gambatte', 'sameboy': 'SameBoy', 'mgba': 'mGBA'},
  'gbc': {'gambatte': 'Gambatte', 'sameboy': 'SameBoy', 'mgba': 'mGBA'},
  'gba': {'mgba': 'mGBA', 'vba_next': 'VBA Next', 'gpsp': 'gpSP (fast)'},
  'sms': {'genesis_plus_gx': 'Genesis Plus GX', 'picodrive': 'PicoDrive'},
  'megadrive': {'genesis_plus_gx': 'Genesis Plus GX', 'picodrive': 'PicoDrive (fast)'},
  'ps1': {'pcsx_rearmed': 'PCSX ReARMed', 'swanstation': 'SwanStation', 'mednafen_psx': 'Beetle PSX'},
  // Phase 6
  'n64': {'mupen64plus_next': 'Mupen64Plus-Next', 'parallel_n64': 'ParaLLEl N64'},
  'nds': {'melonds': 'melonDS', 'desmume': 'DeSmuME'},
  'psp': {'ppsspp': 'PPSSPP'},
  'saturn': {'yabasanshiro': 'YabaSanshiro', 'yabause': 'Yabause', 'mednafen_saturn': 'Beetle Saturn (very heavy)'},
  'dreamcast': {'flycast': 'Flycast'},
};

class RetroArchLauncher extends GameLauncherAdapter {
  static const activity = 'com.retroarch.browser.retroactivity.RetroActivityFuture';

  @override
  String get emulatorId => 'retroarch';

  @override
  Set<String> get consoleIds => retroArchCores.keys.toSet();

  @override
  bool get verifiedOnDevice => false;

  @override
  String get launchMechanism => 'RetroActivityFuture with ROM / LIBRETRO / CONFIGFILE extras (file path)';

  @override
  List<String> get knownLimitations => const [
        'The selected core must already be installed inside RetroArch.',
        'RetroArch needs storage access to the game folder (grant it in RetroArch).',
        'Needs a real file path: games from Downloads/cloud pickers cannot be launched.',
        'Android 11+: games inside Android/data (including GAMEBOX folders) are not readable by RetroArch.',
      ];

  @override
  List<LaunchOption> options(String consoleId) {
    final cores = retroArchCores[consoleId];
    if (cores == null) return const [];
    return [LaunchOption(key: 'core', label: 'RetroArch core', values: cores, defaultValue: cores.keys.first)];
  }

  @override
  LaunchPlan plan(LaunchTarget target, LaunchEnvironment env, Map<String, String> options) {
    final cores = retroArchCores[target.consoleId];
    if (cores == null) return LaunchBlocked(['RetroArch is not configured for this console in GAMEBOX.']);

    final path = target.filesystemPath;
    final reasons = <String>[];
    if (path == null) {
      reasons.add('RetroArch needs a file path, but this file was added from a source that has no path '
          '(e.g. Downloads or a cloud picker). Put the game in a folder on internal storage, USB or SD and '
          'register that folder under STORAGE.');
    } else if (env.sdkInt >= 30 && isAppPrivateExternalPath(path)) {
      reasons.add('On Android 11 and newer, RetroArch cannot read files inside "Android/data" '
          '(this includes the GAMEBOX folders). Move the game to a normal folder such as '
          '/storage/emulated/0/ROMs and register it under STORAGE.');
    }
    if (reasons.isNotEmpty) return LaunchBlocked(reasons);

    final core = cores.containsKey(options['core']) ? options['core']! : cores.keys.first;
    final pkg = env.installedPackage;
    return LaunchReady(
      IntentSpec(
        packageName: pkg,
        className: activity,
        extras: {
          'ROM': path!,
          'LIBRETRO': '/data/data/$pkg/cores/${core}_libretro_android.so',
          'CONFIGFILE': '/storage/emulated/0/Android/data/$pkg/files/retroarch.cfg',
        },
        flags: const ['newTask', 'clearTask', 'clearTop', 'noHistory'],
      ),
      notes: ['Core: ${cores[core]} — if RetroArch reports a missing core, install it inside RetroArch.'],
    );
  }
}
