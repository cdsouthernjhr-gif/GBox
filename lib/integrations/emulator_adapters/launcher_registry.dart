import '../duckstation/duckstation_launcher.dart';
import '../retroarch/retroarch_launcher.dart';
import 'emulator_adapter.dart';
import 'recipe_launcher.dart';

/// Emulators that GAMEBOX can hand a game to. All are experimental until a
/// launch has been verified on real hardware (docs/EMULATOR_INTEGRATION.md).
/// Order matters: the first installed one is the default for a console.
final List<GameLauncherAdapter> gameLaunchers = [
  // Phase 3
  RetroArchLauncher(),
  DuckStationLauncher(),
  // Phase 6 — standalone emulators
  RecipeLauncher(
    emulatorId: 'ppsspp',
    consoleIds: {'psp'},
    recipe: const LaunchRecipe(
      className: 'org.ppsspp.ppsspp.PpssppActivity',
      action: 'android.intent.action.VIEW',
      categories: ['android.intent.category.DEFAULT'],
      handoff: FileHandoff.contentData,
      mimeType: 'application/octet-stream',
    ),
  ),
  RecipeLauncher(
    emulatorId: 'mupen64plus_fz',
    consoleIds: {'n64'},
    recipe: const LaunchRecipe(
      className: 'paulscode.android.mupen64plusae.SplashActivity',
      action: 'android.intent.action.VIEW',
      handoff: FileHandoff.contentData,
      mimeType: 'application/octet-stream',
    ),
  ),
  RecipeLauncher(
    emulatorId: 'melonds',
    consoleIds: {'nds'},
    recipe: const LaunchRecipe(
      action: 'me.magnum.melonds.LAUNCH_ROM',
      handoff: FileHandoff.contentOrPathExtra,
      extraKey: 'uri',
    ),
    limitations: ['DS BIOS/firmware dumps may be required depending on melonDS settings.'],
  ),
  RecipeLauncher(
    emulatorId: 'drastic',
    consoleIds: {'nds'},
    recipe: const LaunchRecipe(
      className: 'com.dsemu.drastic.DraSticActivity',
      handoff: FileHandoff.pathExtra,
      extraKey: 'GAMEPATH',
      genericViewFallback: false,
    ),
    limitations: ['Reads games by file path (Android 11+: not from Android/data).'],
  ),
  RecipeLauncher(
    emulatorId: 'flycast',
    consoleIds: {'dreamcast'},
    recipe: const LaunchRecipe(
      action: 'android.intent.action.VIEW',
      categories: ['android.intent.category.DEFAULT'],
      handoff: FileHandoff.contentData,
      mimeType: 'application/octet-stream',
    ),
    limitations: ['Some games need Dreamcast BIOS files configured in Flycast.'],
  ),
  RecipeLauncher(
    emulatorId: 'redream',
    consoleIds: {'dreamcast'},
    recipe: const LaunchRecipe(
      action: 'android.intent.action.VIEW',
      categories: ['android.intent.category.DEFAULT'],
      handoff: FileHandoff.contentData,
      mimeType: 'application/octet-stream',
    ),
  ),
  RecipeLauncher(
    emulatorId: 'dolphin',
    consoleIds: {'gamecube', 'wii'},
    requiresArm64: true,
    recipe: const LaunchRecipe(
      className: 'org.dolphinemu.dolphinemu.ui.main.MainActivity',
      action: 'android.intent.action.VIEW',
      handoff: FileHandoff.contentOrPathExtra,
      extraKey: 'AutoStartFile',
    ),
    limitations: ['Demanding: expect playable speed only on HIGH PERFORMANCE devices.'],
  ),
  RecipeLauncher(
    emulatorId: 'aethersx2',
    consoleIds: {'ps2'},
    requiresArm64: true,
    recipe: const LaunchRecipe(
      className: 'xyz.aethersx2.android.EmulationActivity',
      action: 'android.intent.action.MAIN',
      handoff: FileHandoff.contentOrPathExtra,
      extraKey: 'bootPath',
    ),
    limitations: [
      'Requires a user-supplied PS2 BIOS configured in the emulator.',
      'Discontinued app: only launched if the user installed it themselves.',
    ],
  ),
];

GameLauncherAdapter? launcherFor(String emulatorId) {
  for (final l in gameLaunchers) {
    if (l.emulatorId == emulatorId) return l;
  }
  return null;
}

/// Consoles where a dedicated emulator is usually the better default than a
/// RetroArch core, so it is listed (and chosen) first when installed.
const _standaloneFirst = {'n64', 'nds', 'psp', 'saturn', 'dreamcast', 'gamecube', 'wii', 'ps2'};

List<GameLauncherAdapter> launchersForConsole(String consoleId) {
  final list = [for (final l in gameLaunchers) if (l.supports(consoleId)) l];
  if (_standaloneFirst.contains(consoleId)) {
    list.sort((a, b) => (a.emulatorId == 'retroarch' ? 1 : 0) - (b.emulatorId == 'retroarch' ? 1 : 0));
  }
  return list;
}
