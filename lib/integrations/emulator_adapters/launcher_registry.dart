import '../duckstation/duckstation_launcher.dart';
import '../retroarch/retroarch_launcher.dart';
import 'emulator_adapter.dart';

/// Emulators that GAMEBOX can launch games with (Phase 3). Other detected
/// emulators can only be opened, not given a game, until their adapter is
/// written and tested.
final List<GameLauncherAdapter> gameLaunchers = [RetroArchLauncher(), DuckStationLauncher()];

GameLauncherAdapter? launcherFor(String emulatorId) {
  for (final l in gameLaunchers) {
    if (l.emulatorId == emulatorId) return l;
  }
  return null;
}

List<GameLauncherAdapter> launchersForConsole(String consoleId) =>
    [for (final l in gameLaunchers) if (l.supports(consoleId)) l];
