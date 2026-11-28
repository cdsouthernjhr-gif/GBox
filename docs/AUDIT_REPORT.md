# GAMEBOX 1.0 — Phase 0 audit report

Audit of the repository and the published 0.17.0 APKs before any 1.0 work.
No application code was changed in Phase 0.

* **Baseline:** commit `ca98296`, tag `v0.17.0`, version `0.17.0+22`.
* **Release APKs:** published on GitHub (pre-release v0.17.0) and kept unchanged:
  * `app-arm64-v8a-release.apk` (38 191 773 bytes);
  * `app-armeabi-v7a-release.apk` (36 509 605 bytes);
  * `app-x86_64-release.apk` (29 432 913 bytes).
* **Source code:** complete. Dart, Kotlin, Gradle, tests and CI are in this repository. No reconstruction from the APK was needed.

Detailed reports:

| Report | Content |
|---|---|
| [EXISTING_FEATURES.md](EXISTING_FEATURES.md) | What 0.17.0 does today, with its verification status |
| [DEPENDENCY_REPORT.md](DEPENDENCY_REPORT.md) | Toolchain, packages and native dependencies |
| [EMULATOR_INVENTORY.md](EMULATOR_INVENTORY.md) | Bundled cores (APK vs repository), external emulators, launch methods |
| [DATABASE_AUDIT.md](DATABASE_AUDIT.md) | Schema v5, migrations, gaps against the 1.0 entity list |
| [COMPATIBILITY_REPORT.md](COMPATIBILITY_REPORT.md) | Android versions, ABIs, TV/touch, what was actually tested |
| [UPGRADE_PLAN.md](UPGRADE_PLAN.md) | Phased plan for 1.0, with the decisions that need approval |

## 1. Repository at a glance (checklist items 1–20)

| # | Item | Finding |
|---|---|---|
| 1 | Repository | 84 Dart source files (~19 200 lines, generated code excluded); 15 Kotlin files (2 838 lines); 17 unit/widget test files (233 tests, all passing) and 1 on-device integration test file; 2 CI workflows |
| 2 | Flutter | 3.47.9 stable (engine 89c39edfdf) |
| 3 | Dart | 3.13.7 (`sdk: ^3.13.7`) |
| 4 | pubspec.yaml | 6 runtime packages: drift, drift_flutter, path_provider, path, crypto, archive. Dev: flutter_lints, drift_dev, build_runner, integration_test |
| 5 | Gradle | AGP 9.1.0, Kotlin 2.4.0, Gradle 9.3.1, Java/JVM 17; `useLegacyPackaging = true` (cores loaded by path); R8 with `proguard-rules.pro` |
| 6 | AndroidManifest | HOME + LAUNCHER + LEANBACK_LAUNCHER launcher; MANAGE_EXTERNAL_STORAGE, READ (≤32) / WRITE (≤29) storage, INTERNET, VIBRATE, ACCESS_NETWORK_STATE; PlayerActivity (not exported) + shell-only smoke-test alias; FileProvider (not exported); `<queries>` for launcher apps and known emulators |
| 7 | min/target SDK | **minSdk 24 (Android 7.0), targetSdk 36, compileSdk 36**. This was checked with `aapt2 dump badging` on every APK in CI. API 23 was tried before: the toolchain injects 24 ([COMPATIBILITY_REPORT.md](COMPATIBILITY_REPORT.md)) |
| 8 | Native dependencies | LibretroDroid 0.14.0 (JitPack); 9 libretro cores from LemuroidCores at a pinned commit; libsqlite3 (sqlite3 package); libdartjni (jni, via path_provider) |
| 9 | Database | Drift (SQLite), `gamebox.db`, foreign keys on |
| 10 | Schema | 26 tables, **schema version 5** |
| 11 | Migrations | v1→v5 adds only columns (no data rewrites); generated schema snapshots v1…v5; tests upgrade each version to v5 and check data is kept |
| 12 | Routes | No named router. 6 shell sections (`LauncherSection`) plus `Navigator.push(MaterialPageRoute)` for sub-pages (24 call sites); `SubPage` wraps section screens opened from Settings |
| 13 | State management | No framework. `AppServices` (dependency container) is exposed through `AppScope` (InheritedWidget). State lives in `ValueNotifier`s and Drift streams (`StreamBuilder`/`ValueListenableBuilder`). Stable, and easy to test with `FakeGateway` |
| 14 | Emulator integration | `GameLauncherAdapter` registry with four kinds of launcher: built-in player, RetroArch, DuckStation, `RecipeLauncher` recipes for 8 standalone apps; user-added emulators (`CustomLauncher`) |
| 15 | LibretroDroid | `PlayerActivity` hosts `GLRetroView`. It provides display filters (shaders), saved per-core options, a pause menu (one state slot, SRAM, reset), touch layouts per system and a crash report |
| 16 | Kotlin/JNI | No custom JNI. LibretroDroid's own JNI is used (R8 keep rules, checked in CI). Flutter ↔ Kotlin: MethodChannels `gamebox/device`, `gamebox/storage`, `gamebox/emulator`, `gamebox/launcher`, `gamebox/controllers`, `gamebox/connectivity`; EventChannels `gamebox/controller_events`, `gamebox/raw_input`, `gamebox/storage_events` |
| 17 | Controllers | InputDevice detection, mapping wizard, calibration, dead zone, trigger threshold, vibration test, player slots, RetroArch autoconfig export; native key remap inside GAMEBOX |
| 18 | ROM scanning | Folder layout `ROMs/<system>`, SAF trees, direct paths with "All files access", app folders; extension + folder detection, header validation, multi-disc grouping, duplicate (SHA-1) detection, missing-file tracking, device-wide ROM search with organise (copy/move) |
| 19 | Save states | Built-in player: `.srm` written on exit, one `.state` slot per game. External emulators: registered save folders, backup/restore/export/import with checksums |
| 20 | Storage permissions | 3 location modes: device ("All files access"), picked SAF folder, app folder; setup wizard; adb fallback documented |

## 2. APK inventory vs repository

All items in the brief's APK inventory are present in the repository and in the APKs. Two points in that inventory are inaccurate:

1. **Not ARM64 only.** 0.17.0 ships three APKs:
   * **ARM64:** all 9 cores.
   * **ARM32 (armeabi-v7a):** all 9 cores, including PPSSPP.
   * **x86_64:** 8 cores (no PPSSPP build exists).
2. **The pinned checksums don't match the packaged files byte for byte.** 18 of 27 packaged cores differ from the checksums in `tool/fetch_cores.sh`. This was investigated:
   * The build ID, program headers and `.text` are identical.
   * Only the section-name string table (`.shstrtab`) is reordered, by AGP's `stripDebugSymbols` step.
   * The cores are therefore the pinned builds, unmodified in code.
   * CI checks presence and keep rules, not post-packaging hashes ([EMULATOR_INVENTORY.md](EMULATOR_INVENTORY.md)).

Being in the APK does not prove a feature works. Verification status:

* **Run on an emulator (CI):** only FCEUmm. Its debug and release builds render frames from a synthetic NES image on Android 7.0 and 14 (x86_64).
* **Packaging checked only:** the other cores. They have never run in CI.
* **Not tested at all:** physical TV boxes, phones and controllers.

## 3. Findings that affect 1.0

| Severity | Finding | Where |
|---|---|---|
| High | Android 6 (API 23) is not reachable with the current toolchain (Flutter 3.47 engine floor and an injected minSdk 24) | COMPATIBILITY |
| High | Primary keys are integers, not UUIDs. Converting existing tables is a destructive, high-risk migration | DATABASE |
| High | No profile concept. Favourites, history, saves, controller and emulator settings are global | DATABASE |
| High | LibretroDroid 0.14.0 has **no netplay API and no achievements (rcheevos) API**. Netplay and RetroAchievements are not possible in the built-in player without changing the native library | EMULATOR_INVENTORY |
| Medium | The x86_64 APK carries `assets/ppsspp.zip` (11.5 MB) though it has no PPSSPP core | EMULATOR_INVENTORY |
| Medium | The built-in player has a single save-state slot, no save-state metadata in the database (core version, checksum), and no screenshot | EXISTING_FEATURES |
| Medium | The 1.0 brief asks for a dashboard with system/storage/controller status. 0.15.0 removed the dashboard at the user's request (menu from 11 to 6 entries). This needs a decision | UPGRADE_PLAN |
| Medium | Metadata comes only from catalogue entries and manual editing; covers from libretro-thumbnails. No other provider is integrated (they need personal API keys) | EXISTING_FEATURES |
| Low | `docs/KNOWN_LIMITATIONS.md` still says "No release has been published yet" (13 were) | docs |
| Low | ARCHITECTURE diagram and some docs still describe pre-0.15 screens | docs |
| Info | Neo Geo / Arcade: FBNeo and MAME 2003-Plus cores exist in LemuroidCores at the pinned commit for all three ABIs. Both have non-commercial licences, like Snes9x | EMULATOR_INVENTORY |

## 4. Baseline and backup

* **Git:** tag `v0.17.0` (on GitHub) = commit `ca98296` = the audited HEAD. This session cannot push new tags (HTTP 403), so the existing release tag is the baseline. A separate `baseline-0.17.0` tag can be pushed by the owner (`git tag baseline-0.17.0 v0.17.0 && git push origin baseline-0.17.0`).
* **APKs:** the v0.17.0 GitHub release keeps the three signed APKs and `SHA256SUMS.txt`. 1.0 work never re-publishes v0.17.0.
* **User data:** the app already has library backup/restore (Settings → System) and save backups. Phase 1 adds an automatic database backup before the first migration to schema v6 ([DATABASE_AUDIT.md](DATABASE_AUDIT.md)).
