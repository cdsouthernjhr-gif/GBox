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

## BIOS

Some systems (PS1 optional, Saturn, PS2) need user-supplied BIOS dumps. GAMEBOX will only point users to the emulator's own BIOS setting. It never downloads or ships BIOS files.
