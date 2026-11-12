# Release notes

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
