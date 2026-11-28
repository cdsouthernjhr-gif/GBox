# Release notes

## 0.19.0+24 — GAMEBOX 1.0 Phase 2: Neo Geo, arcade and Atari in the built-in player (pre-release)

**New systems, played directly in GAMEBOX:**

| System | Folder | Core | Files | BIOS |
|---|---|---|---|---|
| Neo Geo | `ROMs/neogeo` | FinalBurn Neo | romset `.zip`/`.7z` | `neogeo.zip` **required** |
| Arcade | `ROMs/arcade` | FinalBurn Neo (CPS1/2/3 and many other boards) | romset `.zip`/`.7z` | only some boards (e.g. `pgm.zip`) |
| Atari 2600 | `ROMs/atari2600` | Stella | `.a26`, `.bin` | — |
| Atari 7800 | `ROMs/atari7800` | ProSystem | `.a78`, `.bin` | optional |
| Atari Lynx | `ROMs/atarilynx` | Handy | `.lnx` | `lynxboot.img` **required** |

* **Arcade games are romset archives**, played as they are (never unpacked). The set names and contents must match the FinalBurn Neo version.
* **BIOS location:** arcade BIOS sets (`neogeo.zip`, …) go in `GAMEBOX/BIOS/ARCADE`, or next to the games. They are not listed as games.
* **ZIP files count only inside these folders**, and `.bin` only inside the Atari folders.
* **Missing BIOS:** when a required BIOS is missing, GAMEBOX says which file is needed and where it goes before starting, with *Play anyway*.
* **Consoles screen** (EMULATORS → Consoles) shows how each system plays: *Built-in*, *Needs an emulator app* or *Not playable yet*.
* RetroArch can also play these systems (FinalBurn Neo, MAME 2003-Plus, Stella, ProSystem, Handy cores).

**Size:** the APKs grow by about 16 MB, mostly FinalBurn Neo; it takes about 63 MB once installed on ARM64.

**Licences:** FinalBurn Neo is non-commercial, like Snes9x and Genesis Plus GX (see THIRD_PARTY_LICENSES).

**Not yet checked:** none of the new cores have run yet, on a device or in CI. Only packaging, checksums and alignment are checked.

**Note:** if you added "Neo Geo" or "Atari" yourself in 0.17.0, your system keeps its games. New systems can't reuse these folders.

## 0.18.0+23 — GAMEBOX 1.0 Phase 1: new look, phone layout, profile-ready database (pre-release)

**New:**
* **Modern Retro theme** (new default): dark navy, electric blue focus, purple accents, orange Play buttons. If you picked a theme earlier, it is kept; the other themes are still in Settings.
* **HOME** now also has:
  * **Quick actions:** Add games, Find ROMs, Emulators, Controllers, Settings.
  * **Status:** connected controllers; free space and USB/SD; device tier, Android version, RAM and network.
  Each tile opens its screen.
* **Phones held upright:**
  * bottom navigation instead of the side menu;
  * GAMES filters move under the search box;
  * the status bar is compact.
  TVs, tablets and phones in landscape keep the side menu.

**Database (schema v6):** prepares local profiles (Phase 4).
* All your favourites and play history now belong to a default profile, "Player 1". Nothing changes on screen.
* Games, files and play sessions get a stable unique id.
* **Upgrade safety:**
  * Before upgrading, GAMEBOX keeps a copy, `gamebox.before-v6.sqlite`, which *Settings → Restore library…* lists.
  * The upgrade runs as one transaction with integrity checks. If anything fails, nothing is changed, and the start screen says so.
  * To go back to 0.17.0: install it and restore that copy.

**CI:** every APK is checked for 16 KB-aligned native libraries, and for core build IDs equal to the pinned downloads.

**Not yet checked on a device:**
* the upgrade of a real 0.17.0 library on a phone or TV box (tested with databases of every earlier schema);
* the portrait layout on a real phone.

## 0.17.0+22 — Add systems GAMEBOX doesn't list (pre-release)

**New:** when a console or system isn't in GAMEBOX's list (e.g. Neo Geo, arcade, Atari 2600, 3DS), add it yourself:
* **EMULATORS → Add emulator → Consoles it plays → *Other system…***, or **EMULATORS → Consoles → *Add system***.
* Give it a **name**, a **games folder** (`ROMs/<folder>`, suggested from the name) and its **file types** (e.g. `zip, neo`).
* GAMEBOX creates the folder; a scan adds the files of those types found there. Files of a type only it uses (e.g. `.neo`) are recognised anywhere, like other consoles. Archives (`.zip`, `.7z`) count only inside its folder.
* It appears in GAMES (filter), on HOME (*My systems*), in *Play with…* with the emulators you set up for it, and under *Systems added by you* in Consoles (select to edit or remove).

**Safeguards:** a new system can't take a folder or name already used by a known console, and it never takes files away from a known console (a `.nes` file outside its folder stays NES). A system that still has games in the library can't be removed. GAMEBOX shows "Not tested" instead of a hardware estimate for systems you add.

## 0.16.0+21 — Add your own emulators (pre-release)

**New: EMULATORS → Add emulator.** Any emulator app installed on the device can be added, even one GAMEBOX doesn't know:
1. choose the app from the list of installed apps (with search);
2. give it a name and choose the **consoles** it plays;
3. choose how GAMEBOX starts a game:
   * **Open the game file (recommended):** like "Open with" in a file manager; most emulators accept it.
   * **Game path in an extra (advanced):** for emulators whose documentation names an extra (e.g. `ROM_PATH`).
   * **Open the app only:** the emulator opens and you choose the game in it.

It then appears under **Added by you** (installed or not), in *Play with…* for those consoles, as the default when no other emulator for the console is installed, and in *My systems* on HOME. Select it to edit or remove it (the app itself isn't uninstalled).

**Note:** GAMEBOX can't know how an unknown app accepts games, so whether the game opens depends on the emulator; if it opens without the game, edit it and choose *Open the app only*. Not yet tried on a device.

## 0.15.0+20 — Simpler menu, systems on HOME, cover download fix (pre-release)

**Changed — the side menu has 6 entries instead of 11:**
* **HOME:** the focused game's cover and wallpaper, *Continue playing* (or *Recently added*), then **My systems**: one tile per console with **how many games** it has and **which emulator** plays them ("Built-in player", an app name, or "Needs an emulator"). A tile opens that console's games. Then *Favourites* and *Recently added*. The per-console rows moved to GAMES.
* **GAMES** (was MY GAMES, CONSOLES, RECENTLY PLAYED, FAVOURITES): every game, with search, a filter per console, *Favourites*, *Missing*, and sorting by title, recently played or recently added.
* **ADD GAMES** (was DOWNLOADS): *Find ROMs on this device*, *Import files*, *Find games online*, downloads and sources.
* **EMULATORS:** the emulator apps, plus *Built-in emulator settings* and *Consoles* (compatibility per console).
* **SETTINGS:** now also opens **Controllers** and **Storage and game folders** (each with a Back button).
* **ANDROID APPS** unchanged.
* The old dashboard (Settings → Home screen) was removed; device status is in the status bar and Settings → System.

**Fixed:** *Download cover* saved the downloaded image to a folder apps can't write on Android, so it always failed. It now uses GAMEBOX's own cache folder and reports the reason when something goes wrong. When no exact name matches, GAMEBOX now fetches the console's list of covers once and matches the title loosely (regions, punctuation, case and "The" ignored), preferring USA/World/Europe releases.

**Fixed:** some screens could overflow on 1080p TVs when headers had many buttons; *Add download link* / *Add source* moved from the header into the list.

## 0.14.0+19 — Emulator settings, cover-first HOME, cover downloads (pre-release)

**New:**
* **Settings for each built-in emulator** (Settings → Built-in player → *Settings for each emulator*): per system a **display filter** (Standard, Sharp pixels, CRT TV, LCD, Smooth) and its own **on-screen controls** choice. While playing, **BACK → Emulator options** lists the emulator's own options with their real choices (as the emulator declares them, e.g. resolution, frameskip, region). A choice is applied at once and kept for that emulator; some only take effect after *Restart game*. The settings page lists changed options and can reset them.
* **HOME:** smaller game cards, so more fit in a row. The focused game's cover is shown **large** at the top and as the **wallpaper**, and both change as you move through the games. With a mouse, they change when the pointer is over a game, before you choose it.
* **Download cover** on the game page: box art from **libretro-thumbnails** (the collection RetroArch uses; GitHub copy when the server can't be reached). GAMEBOX tries the file name, then the title with common regions. If nothing matches, you can edit the name (e.g. "Crash Bandicoot (USA)") and search again. Only PNG images are accepted.
* **Game for another console:** before starting, GAMEBOX checks the file header. If, for example, a PS2 disc is in the PSP list, a popup offers **Move to PlayStation 2 and play**, **Get PlayStation 2 emulator** (official sources) or **Play anyway**. Only signatures specific to one console count.
* **Built-in player couldn't open the game:** after its error message, GAMEBOX lists the other emulators: installed ones to play with directly, the others with Play Store / official-site links.

**Not yet checked on a device:** the shaders, the in-game options menu and cover downloads ran in tests only (the libretro server could not be reached from the build environment; the GitHub copy was checked). PENDING on real hardware.

## 0.13.0+18 — N64, Nintendo DS and PSP in the built-in player (pre-release)

**New:** three more systems play directly in GAMEBOX, no emulator app needed:
* **Nintendo 64** (Mupen64Plus-Next, GLES3): on phones an on-screen analog stick, A/B, C-buttons, L/R/Z.
* **Nintendo DS** (DeSmuME, no BIOS needed): both screens stacked; tap the touch screen directly on phones.
* **PSP** (PPSSPP; on ARM phones and TV boxes): analog stick, face buttons, L/R. Its support files are unpacked on the first PSP game.

They become the default for these systems; PPSSPP, Mupen64Plus FZ, melonDS, DraStic and RetroArch stay under *Play with…*. Saturn, Dreamcast, PS2, GameCube and Wii still need an emulator app (no compatible built-in core).

**Note:** N64 and PSP need a reasonably fast device. APKs are larger (PSP core and assets). Like the other cores, these are checked to be in every APK, but they have only run on emulators in CI for NES, not yet on a phone.

## 0.12.3+17 — Get emulators, find games online (pre-release)

**New:**
* **No emulator for a game?** Pressing Play shows which emulators play it, each with **Play Store** and **Official site** buttons (official sources only). Install one, come back, press Play again. Emulators that aren't installed can also be fetched from the EMULATORS screen.
* **Find games online** (DOWNLOADS, or HOME when the library is empty): type anything and **Search** opens the device's web browser with that search. GAMEBOX itself doesn't fetch or list websites. Below it, legal sources of free homebrew games (itch.io, Homebrew Hub, PDRoms), and a shortcut to *Find ROMs on this device* for files you downloaded.

**Not included, on purpose:** download links for BIOS files (copyrighted by the console makers; dump your own) and lists of ROM sites.

## 0.12.2+16 — ROM search: per-console lists and a summary (pre-release)

**Improved — Find ROMs on this device** (STORAGE, Set up GAMEBOX, or HOME when the library is empty):
* Results are grouped **by console** (most games first), each showing its destination folder, e.g. `→ ROMs/nes/`, how many are selected, and **All / None** for that console. Files whose console is unclear stay under *Needs a console*.
* Before anything is copied or moved, a **summary** lists games and size per console with their folders, the total, the free space and whether originals are kept (copy) or moved. Copies that would leave less than 50 MB free are blocked.

## 0.12.1+15 — Fix: built-in player crashed in release APKs (pre-release)

**Fixed:** in 0.12.0 the built-in player showed a black screen and the app closed (reported on a phone with an NES game). Cause: release APKs are shrunk by R8, which renamed the classes and methods LibretroDroid's native code looks up by name (the library ships no keep rules). The emulator tests used debug builds, so they didn't catch it. Now:
* keep rules for LibretroDroid (`android/app/proguard-rules.pro`);
* CI checks the R8 mapping keeps those names, and fails otherwise;
* the emulator tests also start the player in a **release** build (like the APKs you install) and fail if it crashes or shows no frames.

**New:** if the built-in player ever stops unexpectedly, GAMEBOX shows what happened on its next start (or when you return), with **Copy details** to send to the developer. Audio uses the standard (not low-latency) path.

## 0.12.0+14 — Built-in player: play without RetroArch (pre-release)

Feedback: NES and PS1 games showed a black screen in RetroArch, even when opened in RetroArch itself. Setting up RetroArch (cores, permissions, config) was the hardest part of GAMEBOX.

**New:**
* **GAMEBOX plays games itself.** NES, SNES, Game Boy / Color / Advance, Mega Drive, Master System and PS1 run in a built-in player: press OK on a game and it starts. No emulator app, no core download, no emulator settings, no storage permission for another app.
* Bundled cores: FCEUmm, Snes9x, Gambatte, mGBA, Genesis Plus GX, PCSX ReARMed (PS1 works without a BIOS; a real one in `GAMEBOX/BIOS/PS1` is used when present).
* Pause menu with BACK (or the controller's Mode button): resume, save state, load state, restart, quit. Battery saves are kept automatically in `GAMEBOX/Saves/GAMEBOX/<system>` and appear in the Save Manager.
* Controllers by button position, TV remote (D-pad, OK, Menu), and on-screen controls on phones (Settings → Built-in player).
* Games in GAMEBOX's own folder, picked folders and ZIP archives play too.
* RetroArch and the other emulators remain under *Play with…*; systems the player doesn't cover (PSP, N64, NDS, Dreamcast, PS2, GameCube/Wii) still use them.

**Licence:** GAMEBOX is now GPLv3 (the player library LibretroDroid is GPLv3). Snes9x and Genesis Plus GX are non-commercial: these builds must not be sold. Details: docs/THIRD_PARTY_LICENSES.md.

**Status:** CI starts the player on Android 7 and 14 emulators and checks the NES core renders frames. Real games, controllers and touch controls on a phone/TV box are not yet verified. APKs are about 15 MB larger.

## 0.11.0+13 — Game Home: an interactive game launcher (pre-release)

**New:**
* **GAMEBOX opens straight on your games.** HOME is now a game launcher: a large panel with the focused game (artwork as background, console, last played, play count) and below it one **horizontal row per console** (NES, SNES, GBA, PS1, …), plus *Continue playing* and *Favourites*. D-pad left/right scrolls a row, up/down switches rows; swiping works on phones.
* **One button to play:** OK / A starts the game with the console's default emulator. **Y** adds or removes a favourite. **Menu / X** (or a long press) opens *Play with…*, details and favourite.
* The side menu shrinks to icons on the launcher; **left on the first game** (or Menu/Start) opens it, BACK returns to the games.
* Games without artwork get a generated card in the console's colour.
* Empty library: *Set up GAMEBOX* and *Find ROMs on this device* right on HOME.
* Settings → General: **Home screen** (Games or the previous Dashboard) and **Console rows** order (most games, recently played, alphabetical). With animations off (low-memory mode) the background isn't blurred.

**Fixed (found by tests):** BACK on the menu of the screen already shown didn't return focus to the games, because no frame was scheduled.

**Status:** verified by widget tests and on Android emulators (CI); not yet on a TV box or phone.

## 0.10.0+12 — Easy setup, shared ROMs folder, ROM search, RetroArch playlists (pre-release)

Based on testing on a phone with RetroArch: Play failed and RetroArch's own menu was empty, because games were kept in GAMEBOX's app folder (unreadable for RetroArch on Android 11+) and RetroArch only lists games it scanned itself.

**New:**
* **Setup wizard** (banner on HOME, or STORAGE → Setup wizard): allow storage access → put games in ROMs/ → get RetroArch ready → optional BIOS/saves, each step with ✓/✗.
* **Shared game folder `Internal storage/ROMs/<system>`** with standard names (`nes`, `snes`, `gba`, `psx`, `n64`, `psp`, …) also used by frontends such as ES-DE and Daijishou. GAMEBOX's own data is in `Internal storage/GAMEBOX/` (BIOS, Saves, Playlists, …). Needs "All files access" on Android 11+ (storage permission on older Android).
* **Find ROMs on this device:** searches internal storage, SD and USB (Download, WhatsApp, Telegram, …), identifies games by file header, extension and folder, and copies or moves them into `ROMs/<system>/`. Disc games keep their track files.
* **RetroArch playlists** "GAMEBOX - <console>" are written automatically, so games appear in RetroArch's own menu (RetroArch offers the installed cores on first start).
* **Move games to ROMs:** games from earlier versions (app folder) are moved with their history, favourites and saves kept.
* Downloads go straight to `ROMs/<system>/`.

**Changed:** the 0.9.0 layout (`GAMEBOX/Games/<CONSOLE>`) is replaced; old folders are still scanned. Clearer message when RetroArch can't read a game.

**Status:** storage access, the shared folder, the search on real storage and RetroArch reading the playlists are unit-tested only and not yet verified on a device.

**Downloads:** per-ABI APKs and `SHA256SUMS.txt`, same signing key (installs over 0.8/0.9).

## 0.9.0+11 — Organised folders: games, saves, BIOS (pre-release)

**New:**
* **Library location** (STORAGE): keep the GAMEBOX folder in the app folder or, recommended, in a **public folder** you pick (e.g. `Internal storage/GAMEBOX` or a USB drive). A public folder survives uninstalling GAMEBOX, and RetroArch can read it.
* The full layout is created automatically: `Games/<console>`, `Artwork/…`, `Saves/<emulator>`, `BIOS/<console>` and `BIOS/RetroArch`, `Backups`, `Downloads`, `Exports`.
* **Downloads go straight to their console folder:** files with a known console (catalogue, chosen, or a unique extension such as `.nes`) are moved into `Games/<console>/`. ZIPs are extracted into `Games/<console>/<name>/` and then removed. Files with an unknown console wait in `Downloads/` until you pick the console. Nothing is ever overwritten.
* **Emulator save folders:** one suggested folder per emulator, with directions for RetroArch and PPSSPP. With a public folder they are registered with the Save Manager automatically.
* **BIOS:** a per-console checklist of the files emulators commonly need, showing which are present. BIOS files are never imported as games. GAMEBOX still never provides BIOS.

**Status:** the public-folder (SAF) operations are new native code, unit-tested against a simulated folder only. They haven't run on a TV box yet.

**Downloads:** per-ABI APKs and `SHA256SUMS.txt`, same signing key (installs over 0.8.x).

## 0.8.2+10 — Downloads without restrictions (pre-release)

**Changed:** no more confirmations. Sources are added, catalogue entries (with or without a licence) and direct links are downloaded without asking you to confirm you're allowed to. Whether you may download a game is your responsibility.

**New settings (Settings → Downloads):** *Allow http:// downloads* (off by default) accepts unencrypted http:// sources, links and redirects. *Largest allowed download* goes up to 64 GB or **No limit**.

**Kept, for your device's safety:** web pages are refused (GAMEBOX needs a direct file link and doesn't scrape sites), apps/executables are never downloaded or run, free space is checked, ZIP archives are checked for path traversal and archive bombs, and SHA-256 is verified when known. GAMEBOX doesn't bypass logins, DRM or paywalls.

**Downloads:** per-ABI APKs and `SHA256SUMS.txt`, signed with the same key as 0.8.0 (installs over it). Not yet tested on a physical TV box.

## 0.8.1+9 — Sources without a licence (pre-release)

**Changed:** GAMEBOX catalogue entries no longer need a `license` field. Entries without one are listed as "Licence not stated" instead of being hidden. Downloading one asks you to confirm you're allowed to download it (you own it, the developer offers it free, or it's otherwise legal for you). GAMEBOX can't verify this. Direct-link downloads are unchanged: they already needed your confirmation and no licence.

**Unchanged:** HTTPS only, web pages and executables refused, SHA-256/size checks, safe ZIP extraction. No scraping, and no bypassing of logins, DRM or paywalls.

**Downloads:** `app-arm64-v8a-release.apk` (64-bit Android), `app-armeabi-v7a-release.apk` (32-bit Android), `app-x86_64-release.apk`, checked with `SHA256SUMS.txt`. Signed with the same key as 0.8.0, so it installs over 0.8.0 without uninstalling. Still not tested on a physical TV box.

## 0.8.0+8 — Phase 8 Testing and release preparation (pre-release)

**New:** on-device integration tests (`integration_test/device_test.dart`) and adb HOME-launcher checks, run in CI on Android emulators. Release signing from GitHub secrets. Tag-triggered release workflow that refuses debug-signed builds. Signing, release and checklist documentation.

**Verified (Android emulators, not TV boxes):** on Android 7.0 (API 24) and Android 14 (API 34) at 1920×1080, the APK installs, the native hardware scan works, a real SQLite database file opens and backs up, the library scan reads headers and hashes natively, FileProvider shares GAMEBOX files, launch errors are reported without crashing, the launcher UI boots, Android accepts GAMEBOX as the default HOME app, HOME brings it to the front and BACK doesn't leave it. No crash was logged.

**Still PENDING:** every physical TV-box test, all emulator (RetroArch, DuckStation, …) launches, controllers, USB/SD. Android 6.0 isn't supported.

**Downloads:** `app-arm64-v8a-release.apk` for 64-bit Android, `app-armeabi-v7a-release.apk` for 32-bit Android (common on budget boxes even with a 64-bit CPU), `app-x86_64-release.apk` for x86 boxes and emulators. Check them against `SHA256SUMS.txt`. Installation: docs/INSTALLATION_GUIDE.md. This is a **pre-release** for testers: it has been run on Android emulators, not yet on a TV box.

**Upgrading from earlier test builds:** builds before 0.8.0 were signed with a debug key. Android won't update an app signed with a different key, so uninstall the old GAMEBOX first. This deletes its local library database; game files in your own folders are kept, and files inside `Android/data/com.gamebox.console/` are deleted.

## 0.7.0+7 — Phase 7 Advanced features (pre-release, not for distribution)

**New:** Save Manager (save folders per emulator, state/game save/memory card classification, backup, restore with automatic safety copy, ZIP export/import). Library database backup and staged restore. Compatibility evidence precedence with your own "how did it run?" results, community bundle import and consent-only anonymous export. Device benchmarks (CPU single/multi, memory, storage, launcher rendering FPS). Live performance monitor (RAM, app CPU, core clocks, temperatures, Android thermal status). Accent colour and custom wallpaper image. Database schema v5.

**Fixed (found by tests):** a restore performed within the same second as its backup overwrote that backup with the current save, so restoring brought back the *current* data. Backup folders are now unique, and backups are never overwritten.

## 0.6.0+6 — Phase 6 Additional emulators (pre-release, not for distribution)

**New:** launch recipes for PPSSPP (PSP), Mupen64Plus FZ (N64), melonDS and DraStic (NDS), Flycast and Redream (Dreamcast), Dolphin (GameCube/Wii) and AetherSX2/NetherSX2 (PS2). RetroArch cores for N64, NDS, PSP, Saturn and Dreamcast. Native fallback to a generic VIEW intent when a recipe's activity isn't found. Dedicated emulators preferred for 3D/handheld systems. Arm64-only emulators blocked on 32-bit Android. Below-tier performance warnings. The Consoles screen lists launch options.

**Status:** experimental. No launch has been verified on a TV box.

## 0.5.0+5 — Phase 5 Online Services (pre-release, not for distribution)

**New:** Online Source Manager (7 source types, authorisation confirmation, connection check, GAMEBOX catalogue browsing with required licences). Download Manager (queue, pause/resume/cancel/retry/remove, speed and ETA, history, offline wait, pause while playing, auto import, max size). HTTPS-only engine with safe redirects, Range resume, SHA-256 and size verification, free-space check, refusal of web pages and executables. ZIP inspection and guarded extraction (path traversal, symlinks, archive bombs). Catalogue metadata and covers on import. Database schema v4.

**Fixed (found by tests):** download-queue race that could leave an item queued forever when it was added while the worker was finishing. Garbage files were accepted as empty ZIP archives.

## 0.4.0+4 — Phase 4 Controllers (pre-release, not for distribution)

**New:** button-mapping wizard (16 actions, axis triggers/hat D-pads, conflict warnings), analog calibration with suggested dead zone, dead zone and trigger threshold settings, vibration on/off and rumble test, Player 1–4 slots, RetroArch autoconfig export, native key remapping, dead-zone-aware stick/hat navigation (Settings → Controllers). Database schema v3.

**Fixed:** setup and controller test screens could pop the navigator twice when closed programmatically (re-entrant pop).

**Status:** controller features are verified by automated tests only. Physical Bluetooth/USB/receiver testing is PENDING.

## 0.3.0+3 — Phase 3 First emulator integration (pre-release, not for distribution)

**New:** Play and Play with… on the game page. RetroArch launcher (8 systems, core choice) and DuckStation launcher (PS1). Per-console default emulator. Clear blocking reasons (missing file, no emulator, no file path, Android 11+ `Android/data` restriction). FileProvider sharing of GAMEBOX-folder games with content-capable emulators. Play history, Recently played, play count. Image cache cleared before launch. Emulators screen shows which apps can launch games.

**Fixed:** Emulators screen header row overflowed by 197 px on 1080p.

**Status:** launch intents are **experimental**. They follow the emulators' published interfaces but haven't been executed on a TV box yet.

## 0.2.0+2 — Phase 2 Game Library (pre-release, not for distribution)

**New:** ROM manager (see ROM_MANAGER.md): auto-created GAMEBOX folders on every volume, SAF folder scanning (auto at startup and on storage changes), manual import with console chooser, extension/folder console detection, multi-disc grouping, missing vs. disconnected storage, header verification and SHA-1/CRC32 hashing, duplicate detection, local cover artwork, search/filters/sorting, manual metadata editing, remove-from-library and double-confirmed file deletion. Database schema v2 with a verified migration from v1.

**Fixed:** page headers squeezed their title to nothing when there were several action buttons (STORAGE on 1080p TVs); game cards overflowed their grid cell.

**Still not included:** game launching (Phase 3), downloads, online metadata, save management. **No on-device testing yet.**

## 0.1.0+1 — Phase 1 Foundation (pre-release, not for distribution)

**Scope:** launcher, Device Intelligence Engine, adaptive compatibility estimates, local database, controller/storage detection, basic settings. See README for the feature table.

**Not included:** ROM import, game launching, downloads, save management.

**Artifacts** (GitHub Actions → *Android build* → artifact `gamebox-apks`):
`app-debug.apk`, `app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, `app-x86_64-release.apk`, `SHA256SUMS.txt`. Release APKs are signed with the debug key.

**Minimum Android:** 7.0 (API 24). Android 6.0 isn't supported by this build (KNOWN_LIMITATIONS).

**Verification status:** analyzer clean; 43 automated tests pass; APKs build successfully in CI (details and checksums in DEVELOPMENT_REPORT.md). **No on-device testing has been done yet.** The APKs are proven to build, not proven to run.
