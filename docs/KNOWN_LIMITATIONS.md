# Known limitations

## Platform / build

* **Android 6.0 (API 23) is NOT supported by the current build.** I set `minSdk = 23` in Gradle (Flutter 3.47 only warns at 23). The build succeeded, but `aapt2 dump badging` on every APK showed `minSdkVersion:'24'`. The manifest-merger report says the value was *INJECTED* from the build variant, so something in the AGP 9.1 + Flutter 3.47 build raises the floor to 24. A source search ruled out Flutter's Gradle plugin; the exact component wasn't identified. The Gradle file now states 24 explicitly. Options if Android 6.0 boxes matter:
  1. Find what injects 24 (print `variant.minSdk` in `androidComponents.onVariants`, test with AGP 8.x), then retest on an API 23 device. Even if the manifest allows 23, the Flutter 3.47 engine is only supported on 24+.
  2. Build a separate legacy flavour with an older Flutter release whose supported floor included API 23, and re-validate every dependency.
  3. Accept Android 7.0 as the minimum. Most TV boxes still in use run 7.1 or later, but this is an assumption, not data.
* **No physical TV box tested yet.** Since Phase 8 the app runs on Android emulators in CI (API 24 and API 34, x86_64, 1920×1080), which pass the on-device tests and HOME-launcher checks. Emulators aren't TV boxes: ARM firmware, real remotes/controllers, USB/SD, GPU drivers and emulator launches are still PENDING (TESTING_GUIDE).
* **No Android TV system image in CI:** the API 30 android-tv image is 32-bit x86, which Flutter doesn't support; the API 34 android-tv x86_64 image didn't boot on the GitHub runner. The leanback filter is checked, but leanback-specific behaviour is untested.
* **Release signing:** without signing secrets / `key.properties`, release APKs use the debug key. The release workflow refuses to publish such builds. No release has been published yet.
* The dev container couldn't download the Android SDK (`dl.google.com` blocked), so APKs are built and device-tested in GitHub Actions only.

## Launcher

* Google TV (Chromecast with Google TV, some newer operator builds) may not honour third-party HOME apps.
* Some firmwares hide `ACTION_HOME_SETTINGS`. GAMEBOX then opens Default apps settings or the main Settings.
* No kiosk or lock-task mode; that is out of scope unless explicitly requested.

## Hardware detection

* SoC name is often unavailable before Android 12 and on some kernels. It's then shown as UNKNOWN or as the generic `Hardware` string (e.g. "Amlogic").
* CPU max frequency may be unreadable due to SELinux.
* Bus type of controllers (USB/Bluetooth/receiver) isn't exposed by public APIs.
* USB vs SD classification relies on the system's volume description.
* Vulkan detection uses the platform feature flag. The API 24 emulator reports none even though some API 24 boxes have Vulkan drivers.
* Tier and ratings are **estimates**: the GPU table covers common TV-box GPUs only, and unknown GPUs fall back to GLES/Vulkan level.

## Storage

* Firmwares without DocumentsUI can't register folders through SAF. Planned alternatives: the app-specific folder `Android/data/com.gamebox.console/files/` (always accessible), or a guided `adb` setup.

## Game library (Phase 2)

* Scan limits: 8 folder levels, 20,000 matching files per registered folder (the scan reports when it stops at the limit).
* Files with shared extensions outside a recognisable console folder aren't imported automatically (no guessing). Use console folders, or Import files and choose the console.
* Archive contents (`.zip`, `.7z`) aren't inspected. Whether an emulator can open an archive depends on the emulator.
* Header checks cover the formats in ROM_MANAGER.md. PS1/Saturn/Dreamcast BIN/CUE/GDI have no reliable signature and are reported as "not checkable".
* Large disc images are only hashed on demand (Verify file), so duplicate detection for them uses name and size until verified.
* On Android 11+, some file managers can't open `Android/data/…`, where the GAMEBOX folders live. Copy games over USB from a PC (MTP shows the folder), or register your own folder instead.
* Metadata and artwork are local/manual only until Phase 5.

## Emulator launching (Phase 3)

* **Experimental:** the RetroArch and DuckStation launch intents follow those emulators' published Android interfaces but haven't been executed on a device yet.
* RetroArch needs a real file path. On Android 11+ it can't read GAMEBOX's own folders (`Android/data`). Keep RetroArch games in a regular folder (e.g. `ROMs/`) registered under SETTINGS → Storage.
* GAMEBOX can't check which RetroArch cores are installed. A missing core is reported by RetroArch itself.
* The FileProvider only covers GAMEBOX folders on the **primary** volume. GAMEBOX folders on SD/USB are passed as paths.
* Play time is the time GAMEBOX was in the background (an upper bound).
* Only RetroArch and DuckStation can launch games. The other 8 detected emulators can only be opened (Phase 6).

## Controllers (Phase 4)

* Mapping, dead zone and calibration only affect GAMEBOX. Emulators keep their own input settings (RetroArch export is buttons-only and experimental).
* Player slots and per-console profiles are stored but not applied to external emulators.
* Stick navigation replaces Android's joystick→D-pad synthesis. It hasn't been tried on real pads yet.

## Online services (Phase 5)

* No foreground service: very long downloads may be stopped by Android while GAMEBOX is in the background. They resume from the partial file.
* Sources needing a login, and online metadata scrapers (they need personal API keys and have their own terms), aren't supported. Metadata comes from catalogues and manual edits.
* `.7z` archives aren't extracted. Only ZIP is.
* Downloads go to app storage on the primary volume only.
* Verified against a local test server only. Real HTTPS sources on a device are PENDING.

## Additional emulators (Phase 6)

* All launch recipes are unverified on a device. Component names and extras follow those emulators' public launch interfaces as used by other frontends, and can change between app versions. The generic VIEW fallback reduces, but doesn't remove, that risk.
* Saturn launches through RetroArch only (no standalone recipe).
* GAMEBOX never provides BIOS/firmware. PS2, Saturn and some Dreamcast/NDS games need user-supplied dumps configured inside the emulator.
* Performance warnings are estimates from detected hardware, not measurements (benchmarks: Phase 7).

## Advanced features (Phase 7)

* Saves are only found in folders you register. Emulators that keep saves in their own `Android/data` folder can't be read on Android 11+. PPSSPP `SAVEDATA` folders aren't matched to games yet.
* Loading a specific save state at launch isn't possible through the emulators' public intents. Use the emulator's own menu.
* Imported compatibility data is always "community". No GAMEBOX upload server exists, so anonymous reports are files you share yourself.
* Benchmarks measure the box, not emulator FPS, and don't change ratings yet.
* System-wide CPU load can't be read by apps on Android 8+.
* Library restore applies at the next start.

## Game folder, storage access, ROM search (0.10.0)

* "All files access", the shared `ROMs/` folder, the ROM search on real storage and RetroArch reading the playlists are unit-tested only (temporary folders); on-device verification is PENDING.
* Some Android TV firmwares have no "All files access" screen; then use adb (shown in the wizard) or a picked folder.
* "All files access" doesn't include other apps' `Android/data`: playlists can't be written into a RetroArch that keeps its data there; set RetroArch's playlist folder to `GAMEBOX/Playlists` instead.
* GAMEBOX can't install RetroArch cores or check which are installed; a missing core is reported by RetroArch when a game starts.
* The search ignores files under 8 KB and archives/track files nothing identifies; games in `.zip` outside a console-named folder are not found.
* 0.9.0 picked-folder games in `Games/<CONSOLE>` stay where they are (still scanned and playable); *Move games to ROMs* only moves games from the app folder.
* GAMEBOX can't set emulators' save or BIOS folders; you point each emulator at them once.
* Save backups and exports are kept in the app folder (deleted with GAMEBOX).

## Emulators added by the user (0.16.0)

* GAMEBOX can't know how an unknown emulator accepts games: *Open the game file* works only with apps that open files sent from a file manager; otherwise use *Open the app only*. Game files GAMEBOX can't share (no content link) can't be sent.
* Only apps with a launcher icon can be picked (Android 11+ package visibility).

## Built-in player (0.12.0)

* Bundled cores: NES, SNES, Game Boy/Color/Advance, Mega Drive/Master System, PS1, N64, NDS, PSP (PSP on ARM only). Saturn, Dreamcast, PS2, GameCube/Wii still need an emulator app.
* N64, NDS and PSP have not run in CI (no freely licensed test images); only packaging is checked. N64/PSP are demanding on low-end TV boxes; the NDS touch screen needs a touch display.
* Verified on Android emulators only (a synthetic NES image renders frames). Real games, speed on low-end TV boxes, controllers and touch controls are untested.
* One save-state slot per game; no fast-forward, rewind or cheats yet. Display filters (0.14.0) are LibretroDroid's built-in shaders; their look on real TVs is untested. Single player (port 1) for the remote/touch; each physical controller uses its own port.
* Emulator options come from the running core; GAMEBOX can only show them while a game runs (Settings lists the changed ones). Some options only apply after *Restart game*; an option that breaks a game can be reset in Settings.
* Covers (0.14.0) are matched by name: files not named like No-Intro/Redump ("Title (Region)") may need the name typed. Covers exist only for consoles in libretro-thumbnails.
* The wrong-console check reads the file header: it recognises PSP/PS2/GameCube/Wii discs and cartridge headers; PS1 vs PS2 discs and CHD/PBP files can't be told apart, so they are never reported.
* `.7z` archives aren't opened (ZIP is). PS1 without a real BIOS relies on PCSX ReARMed's replacement, which some games don't like.
* APK size grows with the cores (PPSSPP and its assets add about 20 MB on ARM). Builds that include Snes9x and Genesis Plus GX must not be sold (non-commercial licences).

## Not yet implemented (by phase)

 · languages other than English.
