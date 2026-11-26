# Emulator integration

## Strategy

1. **External emulator apps (first release).** The user installs the emulator from its official source. GAMEBOX detects it and launches it through documented Android intents.
2. **Standalone integration.** Deeper per-emulator configuration where an emulator documents it.
3. **Libretro cores.** Embedding cores directly. This would only be considered later, after licence review (GPL compatibility) and NDK work.

GAMEBOX **does not bundle** emulators, BIOS files or firmware.

## Phase 1 status

* `lib/integrations/emulator_adapters/emulator_adapter.dart` defines the universal adapter contract: name, consoles, version, install status, Android/ABI support, extensions, launch mechanism, save/controller support, limitations and errors.
* All 10 known emulators can be detected and opened. Game launching is implemented for RetroArch and DuckStation (see Phase 3 below).
* Detection uses `PackageManager.getPackageInfo` for these package ids, which are also declared in the manifest's `<queries>` for Android 11+:

| Emulator | Package ids | Consoles | Notes |
|---|---|---|---|
| RetroArch | com.retroarch, com.retroarch.aarch64, com.retroarch.ra32 | 8/16-bit, GB/GBA, PS1, N64, Saturn, NDS, PSP, Dreamcast | needs cores installed in RetroArch |
| PPSSPP | org.ppsspp.ppsspp, org.ppsspp.ppssppgold | PSP | GPLv2+ |
| DuckStation | com.github.stenzek.duckstation | PS1 | check current licence terms |
| Mupen64Plus FZ | org.mupen64plusae.v3.fzurita | N64 | |
| melonDS | me.magnum.melonds | NDS | |
| DraStic | com.dsemu.drastic | NDS | paid |
| Flycast | com.flycast.emulator | Dreamcast | GLES 3 |
| Redream | io.recompiled.redream | Dreamcast | |
| Dolphin | org.dolphinemu.dolphinemu | GameCube, Wii | arm64 only |
| AetherSX2 / NetherSX2 | xyz.aethersx2.android | PS2 | discontinued; only detected if user-installed |

Package ids should be re-verified against each emulator's official release before Phase 3.

## Phase 3: game launching (implemented, experimental)

Adapters are pure Dart (`lib/integrations/…`). Each one turns *where the file is* plus *which emulator build is installed* into an Android intent described as data (`IntentSpec`), or into readable reasons why it can't launch. `EmulatorLauncher.kt` only executes the spec. Choosing the emulator: an explicit choice ("Play with…") wins, then the console default saved in `emulator_profiles`, then the first installed compatible emulator.

| Emulator | Consoles | Intent | Game file passed as |
|---|---|---|---|
| RetroArch (`com.retroarch`, `.aarch64`, `.ra32`) | NES, SNES, Master System, Mega Drive, GB, GBC, GBA, PS1 | component `com.retroarch.browser.retroactivity.RetroActivityFuture`; extras `ROM`, `LIBRETRO=/data/data/<pkg>/cores/<core>_libretro_android.so`, `CONFIGFILE=/storage/emulated/0/Android/data/<pkg>/files/retroarch.cfg`; flags NEW_TASK, CLEAR_TASK, CLEAR_TOP, NO_HISTORY | **filesystem path** (SAF document ids from external storage are translated to `/storage/...` paths) |
| DuckStation (`com.github.stenzek.duckstation`) | PS1 | action MAIN, category DEFAULT, component `.EmulationActivity`; extra `bootPath`; flags NEW_TASK, CLEAR_TASK, CLEAR_TOP | **content URI** with a one-off read grant (SAF URI, or FileProvider URI for GAMEBOX folders), else path |

RetroArch cores offered (first is default): NES fceumm / nestopia / mesen / quicknes · SNES snes9x / snes9x2010 / bsnes · GB/GBC gambatte / sameboy / mgba · GBA mgba / vba_next / gpsp · SMS/MD genesis_plus_gx / picodrive · PS1 pcsx_rearmed / swanstation / mednafen_psx. GAMEBOX can't see which cores are installed inside RetroArch, so the user installs them in RetroArch (Load Core → Download a Core). An unknown core value always falls back to the default, so arbitrary paths can't be injected.

### Rules that block a launch (with a message to the user)

* The game file is missing (storage disconnected).
* No compatible emulator is installed.
* RetroArch, but no filesystem path is available (file picked from Downloads, cloud or media providers).
* RetroArch on **Android 11+**, but the file is inside `Android/data/…`, including the GAMEBOX folders. Android blocks other apps from reading there. Use DuckStation for PS1, or keep games in a normal folder such as `/storage/emulated/0/ROMs` and register it.
* Android couldn't start the activity (e.g. an emulator version without that activity). The error is shown and the game is **not** counted as played.

### Play history

A successful launch writes a `game_history` row and updates `last_played_at` and `play_count`. When GAMEBOX returns to the foreground, the session is closed. The stored duration is the time GAMEBOX spent in the background, which is an upper bound of play time.

### Verification status

| Emulator | Console | Tested on device | Result |
|---|---|---|---|
| RetroArch | NES, SNES, SMS, MD, GB, GBC, GBA, PS1 | PENDING | — |
| DuckStation | PS1 | PENDING | — |

`verifiedOnDevice` stays `false` (shown as "Experimental" in the UI) until a launch with a legally obtained homebrew/public-domain test file has been confirmed on a real TV box and recorded here.

## Phase 6: additional emulators (implemented, experimental)

All 10 detected emulators can now be given a game. Standalone emulators are described as **launch recipes** (`lib/integrations/emulator_adapters/launcher_registry.dart`, `recipe_launcher.dart`). Recipes follow the launch interfaces used by established Android frontends. None has been executed on a device by GAMEBOX.

| Emulator | Consoles | Recipe | Game passed as | Fallback |
|---|---|---|---|---|
| PPSSPP / Gold | PSP | `org.ppsspp.ppsspp.PpssppActivity`, VIEW | content URI data | generic VIEW |
| Mupen64Plus FZ | N64 | `paulscode.android.mupen64plusae.SplashActivity`, VIEW | content URI data | generic VIEW |
| melonDS | NDS | action `me.magnum.melonds.LAUNCH_ROM` | `uri` extra (content or path) | generic VIEW |
| DraStic | NDS | `com.dsemu.drastic.DraSticActivity` | `GAMEPATH` extra (path) | none |
| Flycast | Dreamcast | VIEW to package | content URI data | — |
| Redream | Dreamcast | VIEW to package | content URI data | — |
| Dolphin | GameCube, Wii | `org.dolphinemu.dolphinemu.ui.main.MainActivity`, VIEW; **arm64 only** | `AutoStartFile` extra (content or path) | generic VIEW |
| AetherSX2 / NetherSX2 | PS2 | `xyz.aethersx2.android.EmulationActivity`, MAIN; **arm64 only** | `bootPath` extra (content or path) | generic VIEW |

New RetroArch cores: N64 mupen64plus_next / parallel_n64 · NDS melonds / desmume · PSP ppsspp · Saturn yabasanshiro / yabause / mednafen_saturn · Dreamcast flycast. **Saturn has no standalone recipe**, so it launches through RetroArch only.

**Fallback chain**: if the specific activity of a recipe isn't found (e.g. a different app version renamed it), the native layer tries a generic `ACTION_VIEW` intent to the same package with the game's content URI and a read grant. Only "activity not found" triggers the next attempt. Other errors are reported.

**Default per console**: for N64, NDS, PSP, Saturn, Dreamcast, GameCube, Wii and PS2 the dedicated emulator is preferred when installed. RetroArch is preferred for the retro systems and PS1. "Play with…" and the per-console default override this.

**Device intelligence**: arm64-only emulators are blocked on 32-bit Android with an explanation. When the device is below the estimated tier for the console, the launch proceeds with a warning (estimates never block).

| Emulator | Console(s) | Tested on device | Result |
|---|---|---|---|
| PPSSPP | PSP | PENDING | — |
| Mupen64Plus FZ | N64 | PENDING | — |
| melonDS / DraStic | NDS | PENDING | — |
| Flycast / Redream | Dreamcast | PENDING | — |
| Dolphin | GameCube, Wii | PENDING | — |
| AetherSX2 / NetherSX2 | PS2 | PENDING | — |
| RetroArch (new cores) | N64, NDS, PSP, Saturn, Dreamcast | PENDING | — |

## BIOS

Some systems (PS1 optional, Saturn, PS2) need user-supplied BIOS dumps. GAMEBOX will only point users to the emulator's own BIOS setting. It never downloads or ships BIOS files.

## RetroArch playlists (0.10.0)

GAMEBOX writes one playlist per console, `GAMEBOX - <console>.lpl` (RetroArch 1.7.6+ JSON format, `version` 1.5), to `GAMEBOX/Playlists/` and, when it exists, RetroArch's `RetroArch/playlists/` on shared storage. Entries carry the game's real path, its title and the libretro database name (for thumbnails); the core is `DETECT`, so RetroArch offers the installed cores the first time. Playlists RetroArch made itself are never touched. Games RetroArch can't read (app folder, no path) are left out and counted. Playlists are rewritten after scans, downloads, ROM search and moves. If RetroArch doesn't show them: Settings → Directory → Playlists → `GAMEBOX/Playlists`, or Import Content → Scan Directory → `ROMs`. **Unverified on a device.**

## Built-in player (0.12.0)

GAMEBOX plays NES, SNES, Game Boy / Color / Advance, Mega Drive / Master System, PS1, N64, Nintendo DS and PSP games itself (PSP on ARM devices only: no x86_64 PPSSPP core), and uses it by default for those systems (`integrations/builtin/builtin_player_launcher.dart`, listed first in `gameLaunchers`). Other emulators stay available under *Play with…*.

* **Native:** `player/PlayerActivity.kt` hosts LibretroDroid's `GLRetroView` with a bundled core (`lib<core>_libretro_android.so` from `nativeLibraryDir`; native libraries are extracted at install). Cores: FCEUmm, Snes9x, Gambatte, mGBA, Genesis Plus GX, PCSX ReARMed, Mupen64Plus-Next (GLES3), DeSmuME, PPSSPP (`tool/fetch_cores.sh`; PPSSPP's assets `ppsspp.zip` are an APK asset extracted once into the player's private `system/ppsspp/PPSSPP`, docs/THIRD_PARTY_LICENSES.md).
* **Files:** `PlayerFiles` gives the player a path GAMEBOX can read: the file itself (shared storage with access, or GAMEBOX's app folder — the player is GAMEBOX, so `Android/data` is no problem), else a copy of all the game's files in a hidden cache (picked SAF folders), and ZIPs extracted (`.7z` refused). BIOS: `GAMEBOX/BIOS/<CONSOLE>` (PCSX ReARMed uses its built-in BIOS replacement when none is there). Saves: `GAMEBOX/Saves/GAMEBOX/<system>` — battery saves (`.srm`) written whenever the player is left, save states (`.state`) from the pause menu; registered with the Save Manager.
* **Controls:** gamepads by position (bottom = B, right = A, left = Y, top = X); TV remote D-pad, OK = A, Menu = Start; BACK or the pad's Mode button opens the pause menu (resume, save/load state, restart, quit). Phones get on-screen controls per system (Settings → Built-in player), hidden on TV or when a controller is used: an analog stick for N64 and PSP (N64 C-buttons drive the right stick), and touches outside the controls reach the Nintendo DS touch screen (DeSmuME pointer mode, screens top/bottom).
* **Pause safety:** while the menu is open the emulation thread is stopped and the core is called directly (LibretroDroid `useEmulationThread = false`), so menu actions can't deadlock.
* **Release builds:** LibretroDroid's native code finds classes, fields and methods by name (JNI), so `android/app/proguard-rules.pro` keeps `com.swordfish.libretrodroid.**`; CI fails if the R8 mapping renames them. (0.12.0 lacked this: the player crashed in release APKs only.)
* **Crash report:** `PlayerStatus` is written to `player_status.json`; when a run ends while the player was starting/running, the next GAMEBOX start reads the app's own log lines for that process and shows them (*Copy details*).
* **Verification:** CI starts the player on the Android 7.0 and 14 emulators (x86_64 cores, SwiftShader GL) with a synthetic NES image (debug build, `integration_test/device_test.dart`) and again in a **release** build started with adb (`tool/ci_device_tests.sh`, activity alias `.player.PlayerSmokeTest` that only the shell can start) and checks that FCEUmm loads and renders frames (`integration_test/device_test.dart`, `PlayerStatus`). Real games, controllers, touch controls and performance on ARM devices are PENDING.

