# Emulator inventory (0.17.0 baseline)

## A. Built-in libretro cores (LibretroDroid 0.14.0)

Source: LemuroidCores, commit `fee2e824525daa22bcf318f96127fe43fa8a15ad`. The cores are fetched and SHA-256-checked by `tool/fetch_cores.sh` into the git-ignored `android/app/src/main/jniLibs`. The table also shows whether each core is present in the published APKs.

| Core | Consoles in GAMEBOX | arm64 | v7a | x86_64 | Licence | Verified |
|---|---|---|---|---|---|---|
| FCEUmm | NES | ✓ | ✓ | ✓ | GPL-2.0 | **CI device:** debug and release builds render frames (API 24/34, x86_64) |
| Snes9x | SNES | ✓ | ✓ | ✓ | Non-commercial | Packaging only |
| Gambatte | GB, GBC | ✓ | ✓ | ✓ | GPL-2.0 | Packaging only |
| mGBA | GBA | ✓ | ✓ | ✓ | MPL-2.0 | Packaging only |
| Genesis Plus GX | Mega Drive, Master System | ✓ | ✓ | ✓ | Non-commercial | Packaging only |
| PCSX ReARMed | PS1 (HLE BIOS, or a real BIOS in `GAMEBOX/BIOS/PS1`) | ✓ | ✓ | ✓ | GPL-2.0 | Packaging only |
| Mupen64Plus-Next GLES3 | N64 | ✓ | ✓ | ✓ | GPL-2.0 | Packaging only |
| DeSmuME | NDS (touch through the pointer, screens top/bottom) | ✓ | ✓ | ✓ | GPL-2.0 | Packaging only |
| PPSSPP (+ `assets/ppsspp.zip`) | PSP | ✓ | ✓ | — | GPL-2.0 | Packaging only |

**Checksum note (audit finding):** 18 of 27 packaged `.so` files differ from the pinned SHA-256 values.
* **Cause:** AGP's `stripDebugSymbols` rewrites the ELF section-name table (`.shstrtab`) of cores that had unsorted section names. It was checked on `libfceumm` arm64: build ID, program headers and `.text` are identical, and only the 222-byte `.shstrtab` differs.
* **Conclusion:** the pinned checksums verify the *downloaded inputs*, not the packaged outputs.
* **Proposal:** a CI check that compares build IDs.

**x86_64 finding:** `assets/ppsspp.zip` is packaged in the x86_64 APK although there is no PPSSPP core for it. It is 11.5 MB of unused data, and could be removed per ABI.

### LibretroDroid capabilities used, and missing

| Capability | 0.17.0 |
|---|---|
| Video | GLES (`GLRetroView`) |
| Shaders | Default, Sharp, CRT, LCD, CUT2 (display filter per core) |
| Core options | `getVariables` / `updateVariables` (in-game menu, saved per core in `files/core_options/<core>.json`) |
| Save states | `serializeState` / `unserializeState`: one slot per game, files `<rom>.state` |
| SRAM | `serializeSRAM` on exit, `<rom>.srm` |
| Input | Key and motion events per port (port = controller number), touch pointer |
| Rumble | `getRumbleEvents`: available in the library, **not used** |
| Disc change | `changeDisk` / `getAvailableDisks`: available, **not used** (multi-disc via `.m3u` only) |
| Cheats | `setCheat`: available, **not used** |
| Frame speed | `frameSpeed`: available, **not used** (no fast-forward) |
| **Netplay** | **Not available** in LibretroDroid 0.14.0 (no API) |
| **Achievements (rcheevos)** | **Not available** in LibretroDroid 0.14.0 (no API) |

## B. External emulator apps (launch only; GAMEBOX does not bundle or download them)

| Emulator | Consoles | Launch method in GAMEBOX | Verified |
|---|---|---|---|
| RetroArch (3 package ids) | NES, SNES, SMS, MD, GB/GBC/GBA, PS1, N64, NDS, PSP, Saturn, Dreamcast (several cores per console) | RetroActivityFuture with `ROM` (file path), `LIBRETRO` (core inside RetroArch's data folder) and `CONFIGFILE` extras | Intent plans unit-tested; **never launched on a device** |
| DuckStation | PS1 | EmulationActivity, `bootPath` extra (content URI with read grant, or path) | Same |
| PPSSPP | PSP | PpssppActivity, VIEW + content URI | Same |
| Mupen64Plus FZ | N64 | SplashActivity, VIEW + content URI | Same |
| melonDS | NDS | `me.magnum.melonds.LAUNCH_ROM`, `uri` extra | Same |
| DraStic | NDS | DraSticActivity, `GAMEPATH` (file path) | Same |
| Flycast, Redream | Dreamcast | VIEW + content URI | Same |
| Dolphin | GameCube, Wii | MainActivity, `AutoStartFile` | Same |
| AetherSX2 / NetherSX2 | PS2 | EmulationActivity, `bootPath` | Same (discontinued app, user-installed only) |
| User-added (0.16.0) | any, including user systems | VIEW + content URI / named path extra / app only | Unit and widget tests only |

Detection: `installedVersions` for known package ids (manifest `<queries>`) and for apps with a launcher icon.

## C. Downloadable emulator packages

None. GAMEBOX links to the Play Store and official sites only (`core/constants/emulator_links.dart`). It never downloads or installs APKs.

## Candidates for 1.0 (not yet integrated)

| Core | Systems | Availability at the pinned LemuroidCores commit | Licence | Notes |
|---|---|---|---|---|
| FBNeo | Neo Geo, CPS1/2/3, many arcade boards | arm64-v8a, armeabi-v7a, x86_64 present (HTTP 206 on a range request) | Non-commercial (FBNeo licence) | Lemuroid's arcade core. Needs `neogeo.zip` BIOS for Neo Geo (user-supplied). ROM sets must match the FBNeo version |
| MAME 2003-Plus | Arcade (MAME 0.78-era sets) | arm64-v8a, armeabi-v7a, x86_64 present | MAME non-commercial | Alternative or extra arcade core. ROM sets must match 0.78 |
| Stella / ProSystem / Handy / others | Atari 2600 / 7800 / Lynx | Not checked yet | Varies (Stella GPL-2.0) | To be checked in Phase 2 before promising Atari |

Any new core must go through the same steps:
* SHA-256 pinning;
* an alignment check;
* a licence entry in THIRD_PARTY_LICENSES;
* a CI device run where a freely licensed test image exists.

Like the existing cores, it would otherwise be marked "packaging only".
