# Emulator integration

## Strategy

1. **External emulator apps (first release).** The user installs the emulator from its official source. GAMEBOX detects it and launches it through documented Android intents.
2. **Standalone integration.** Deeper per-emulator configuration where an emulator documents it.
3. **Libretro cores.** Embedding cores directly. This would only be considered later, after licence review (GPL compatibility) and NDK work.

GAMEBOX **does not bundle** emulators, BIOS files or firmware.

## Phase 1 status

* `lib/integrations/emulator_adapters/emulator_adapter.dart` defines the universal adapter contract: name, consoles, version, install status, Android/ABI support, extensions, launch mechanism, save/controller support, limitations and errors.
* `ExternalAppAdapter` implements detection and **opening the emulator app**. `launchGame` deliberately returns a failure: per-emulator game-launch intents differ, and none has been execution-tested yet.
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

## Phase 3 plan (NES, SNES, GB, GBA, PS1)

For each emulator, write a dedicated adapter that:
1. uses only the launch intent/extras that emulator documents (RetroArch: `com.retroarch.browser.retroactivity.RetroActivityFuture` with `ROM`, `LIBRETRO`, `CONFIGFILE` extras; verify against the installed version),
2. passes the file via a `content://` URI with a read grant where the emulator supports it,
3. records `game_history`,
4. is marked working **only after** it has launched a legally obtained test ROM (homebrew/public-domain) on a real device.

## BIOS

Some systems (PS1 optional, Saturn, PS2) need user-supplied BIOS dumps. GAMEBOX will only point users to the emulator's own BIOS setting. It never downloads or ships BIOS files.
