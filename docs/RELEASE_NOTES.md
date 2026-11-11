# Release notes

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
