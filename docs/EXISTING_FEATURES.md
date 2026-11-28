# Existing features (0.17.0 baseline)

What GAMEBOX 0.17.0 does, and how far each feature is verified. 1.0 work must keep all of these working; each row needs a regression test (column "Tests" names the current ones).

Status legend:
* **Tested**: covered by unit/widget tests (FakeGateway, in-memory database).
* **CI device**: also exercised on Android emulators in CI (API 24 and 34, x86_64, 1080p).
* **PENDING**: not yet run on a physical phone, tablet or TV box.

Every feature is PENDING on physical hardware.

## Launcher and navigation

| Feature | Status | Tests |
|---|---|---|
| HOME/LAUNCHER/LEANBACK launcher; set as default HOME (RoleManager / Home settings); BACK never exits | Tested, CI device (HOME/BACK adb checks) | launcher_widget_test, ci_device_tests.sh |
| 6-section side menu (HOME, GAMES, ADD GAMES, EMULATORS, SETTINGS, ANDROID APPS); collapses to icons on HOME | Tested, CI device | launcher_widget_test, device_test |
| HOME: large cover of the focused game + wallpaper (focus or mouse hover); Continue playing / Recently added; My systems (games per console + active emulator); Favourites | Tested | launcher_widget_test |
| D-pad, gamepad and stick navigation (dead-zone aware); OK plays, Y favourite, X/Menu options | Tested | launcher_widget_test, controller_test |
| Android apps drawer, Android Settings shortcut | Tested (UI) | launcher_widget_test |
| Status bar (network, controllers, storage) | Tested | launcher_widget_test |
| Themes: Dark Gaming, Retro Arcade, Minimal, Custom wallpaper; accent colour; animations on/off; low-memory mode | Tested | launcher_widget_test, phase7_test |

## Library and ROM management

| Feature | Status | Tests |
|---|---|---|
| `ROMs/<system>` layout (ES-DE names) + GAMEBOX data folders, created automatically | Tested | library_location_test |
| Library location: device ("All files access"), picked SAF folder (USB/SD), app folder; setup wizard | Tested | library_location_test |
| Folder scan: extension + folder detection, header validation, multi-disc grouping (cue/gdi/m3u), missing files, rescan on storage events | Tested, CI device (scan + native header read + hashing) | rom_logic_test, rom_library_service_test, device_test |
| Duplicate detection (SHA-1/CRC32), verify file | Tested | rom_library_service_test |
| Manual import (file picker), ZIP import/extraction with traversal and size guards | Tested | rom_library_service_test, online_core_test |
| Find ROMs on this device (results per console, summary, copy/move, free-space check) | Tested | library_location_test, launcher_widget_test |
| Move 0.9.0 app-folder games to `ROMs/` | Tested | library_location_test |
| Wrong-console detection from headers (PSP/PS2/GC/Wii discs, cartridges) with popup | Tested | player_covers_test, launcher_widget_test |
| Systems added by the user (name, folder, file types) | Tested | custom_console_test, launcher_widget_test |
| GAMES: search, console/favourite/missing filters, sort | Tested | launcher_widget_test |
| Game page: play, play with…, favourite, verify, artwork, edit info, remove, delete files (double confirmation) | Tested | launcher_widget_test, rom_library_service_test |

## Metadata and artwork

| Feature | Status | Tests |
|---|---|---|
| Local artwork (image next to the game or in `GAMEBOX/Artwork/Covers`), manual image pick | Tested | rom_library_service_test |
| Download cover from libretro-thumbnails (GitHub fallback, loose name matching, editable name) | Tested (fake network). The libretro server couldn't be reached from the build environment; the GitHub copy was reached | player_covers_test, launcher_widget_test |
| Manual metadata editing; catalogue metadata from downloads | Tested | rom_library_service_test, online_services_test |
| Online metadata providers (ScreenScraper, IGDB, …) | **Not implemented** (they need personal API keys) | — |

## Emulators and playing

| Feature | Status | Tests |
|---|---|---|
| Built-in player (LibretroDroid): NES, SNES, GB/GBC, GBA, Mega Drive, Master System, PS1, N64, NDS, PSP (ARM) | FCEUmm: CI device (debug + release, frames rendered). Other cores: packaging only | builtin_player_test, device_test, ci_device_tests.sh |
| Player: pause menu, save/load state (1 slot), SRAM on exit, restart, emulator options from the core (saved per core), display filters, touch layouts per system, controller ports | Tested (Dart side); native: CI device for start/frames only | builtin_player_test |
| Crash report of the built-in player on next start; "could not open" popup offering other emulators | Tested | launcher_widget_test |
| External emulators: RetroArch (cores per console), DuckStation, PPSSPP, Mupen64Plus FZ, melonDS, DraStic, Flycast, Redream, Dolphin, AetherSX2/NetherSX2 | Tested (intent plans); **never launched on a device** | launch_test, phase6_launch_test |
| User-added emulators (any app; open file / path extra / app only) | Tested | custom_emulator_test, launcher_widget_test |
| Emulator detection (installed version), get-emulator popup (Play Store / official site) | Tested | launch_test, launcher_widget_test |
| Per-console default emulator ("use as default"), per-launch choice | Tested | launch_test |
| RetroArch playlists written to `GAMEBOX/Playlists` | Tested | library_location_test |
| Play sessions, play count, "how did it run?" rating | Tested | launcher_widget_test |

## Saves

| Feature | Status | Tests |
|---|---|---|
| Registered emulator save folders (SAF), suggested folders per emulator | Tested | phase7_test |
| Save backup/restore/export/import with checksums, never-overwrite backups | Tested | phase7_test |
| Library database backup/restore | Tested | phase7_test, database_test |

## Controllers

| Feature | Status | Tests |
|---|---|---|
| Detection (InputDevice), mapping wizard, calibration, dead zone, trigger threshold, vibration test, player slots, input test | Tested (Dart); native PENDING | controller_test, launcher_widget_test |
| RetroArch autoconfig export | Tested | controller_test |

## Downloads and online

| Feature | Status | Tests |
|---|---|---|
| User-added sources (direct links, GAMEBOX catalogue v1), HTTPS engine with resume, SHA-256, size/space checks, http opt-in | Tested (local test server) | online_core_test, online_services_test |
| Find games online (opens the browser), legal homebrew sources | Tested | launcher_widget_test |
| Pause downloads while playing, auto-import | Tested | online_services_test |

## Device intelligence and performance

| Feature | Status | Tests |
|---|---|---|
| Hardware scan (CPU, ABIs, RAM, GPU/GL, display), performance tier, UNKNOWN for missing values | Tested, CI device | device_intelligence_test, device_test |
| Compatibility estimates per console, user ratings, community import/export with consent | Tested | phase7_test |
| Benchmarks, live performance monitor (no root; unavailable values shown as such) | Tested | phase7_test, launcher_widget_test |

## Not present in 0.17.0 (asked for in the 1.0 brief)

These are not in 0.17.0:

* **Profiles:** local profiles.
* **Achievements:** framework and any service.
* **Multiplayer:** netplay, and local multiplayer assignment UI. Per-controller ports already exist in the player.
* **Saves:** multiple save-state slots, and save metadata (core version, checksum) in the database.
* **Consoles:** Neo Geo / Arcade / Atari as built-in systems. They can be added as user systems.
* **Downloads:** downloadable emulator packages, and a versioned resource manifest.
* **UI:** mobile bottom navigation.
* **Performance:** presets.
* **Themes:**
  * the seven named 1.0 themes;
  * background music and navigation sound (there is only a sounds toggle);
  * card layout and icon size options.
* **Database:** UUID keys.
