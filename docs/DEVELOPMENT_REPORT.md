# Development report

## Environment inspection (2026-11-11)

| Item | Finding |
|---|---|
| Repository | empty (no commits); new project created |
| Flutter / Dart | not installed → installed Flutter 3.47.9 stable / Dart 3.13.7 |
| Java | OpenJDK 21.0.12 |
| Gradle | 8.14.3 system; project wrapper 9.3.1 |
| Kotlin | via Gradle plugin 2.4.0 |
| Android SDK | **not installed and not installable**: `dl.google.com` refused by the container's network proxy (HTTP 403) |
| Device / emulator | none available |

Consequence: Dart analysis and all Dart tests run locally. Gradle/Kotlin compilation and APK packaging run on GitHub Actions (`.github/workflows/android.yml`).

## Dependency compatibility assessment

| Dependency | Min SDK / requirement | API 23 OK? | ABI | Decision |
|---|---|---|---|---|
| Flutter engine 3.47 + AGP 9.1 | officially 24 | **no**: the built APK declares minSdk 24 even with `minSdk = 23` (CI runs #3/#4) | armeabi-v7a, arm64-v8a, x86_64 | use; minimum is Android 7.0; see KNOWN_LIMITATIONS |
| drift / drift_flutter | pure Dart + sqlite3 | yes | — | use |
| sqlite3 3.x (native assets) | prebuilt per-ABI SQLite | yes (NDK-built) | v7a, arm64, x86_64 | use |
| path_provider | Flutter plugin, API 21+ | yes | — | use |
| connectivity_plus, device_info_plus, shared_preferences | — | — | — | **not used**: native Kotlin channels cover these with fewer dependencies and no extra min-SDK constraints |
| Libretro cores | GPL, NDK | — | — | deferred (EMULATOR_INTEGRATION) |

## Completed features (Phase 1)

* Flutter project + Kotlin native layer with 8 platform channels.
* Android TV launcher: HOME/DEFAULT/LEANBACK filters, banner, landscape, singleTask, HOME-press handling, BACK guard, default-launcher request (RoleManager / Home settings / Settings fallbacks), Android apps drawer, Android Settings access.
* Dashboard with the 10 spec sections + Android apps, status widgets, DB-backed game rows, game cards and game information page.
* Device Intelligence Engine (native scan + cpuinfo parser + profile persistence + history).
* Adaptive engine: tiers + per-console/per-emulator estimates with evidence labels.
* Drift database: 26 tables, constraints, indexes, seeding, migration hook.
* Controller detection, live events, input test screen.
* Storage detection, mount events, SAF folder registration.
* Emulator app detection and opening (10 emulators).
* Settings (General, Gaming, Performance, System), 4 themes, low-memory mode, logs, report export.
* Local error log + startup recovery screen.
* 43 automated tests; on-device integration smoke test (pending a device).
* Documentation set.

## Issues found and fixed during Phase 1

* Nav-rail logo row overflowed by 19 px at 960×540 logical. Fixed (found by the widget test).
* Hardware was scanned twice on first boot. Fixed.
* Widget-test hang when closing Drift under fake time. Fixed in the test harness.

## Build results (GitHub Actions)

| Run | Commit | Result |
|---|---|---|
| #1 | 6f49388 | analyzer, codegen check and 43 tests passed; **Kotlin compile failed** (`IntArray.mapNotNull` doesn't exist) |
| #2 | 49b0d87 | **all steps passed**: analyze, tests, debug APK, per-ABI release APKs, artifact upload |
| #3 | f37bdf4 | passed; badging now shows `minSdkVersion:'24'` despite `minSdk = 23` in Gradle |
| #4 | 3f82f04 | passed; manifest-merger report: minSdkVersion 24 *INJECTED* from the build variant |
| #5 | 6ba771b | passed (Gradle states minSdk 24 explicitly) |
| #6 | 520cf76 | **Phase 2: all steps passed first time** (80 tests, new Kotlin compiled). APKs report versionName 0.2.0, versionCodes 1002/2002/4002, minSdkVersion 24. Artifact ID 13838675229 |

APK details from run #2 (`aapt2 dump badging`, `sha256sum`):

| File | Size | versionCode | native-code | SHA-256 |
|---|---|---|---|---|
| app-armeabi-v7a-release.apk | 16.8 MB | 1001 | armeabi-v7a | 187857457379b11e7696f6beae5b9014e1718305ffd423ee01d2cc007ea266c6 |
| app-arm64-v8a-release.apk | 19.5 MB | 2001 | arm64-v8a | 180f7b2a199881afb9fab0f0960137eef896835e2832ff3efdbde39e3bbe6f67 |
| app-x86_64-release.apk | 20.9 MB | 4001 | x86_64 | 130d25c978fc5590e955c280b7f3be01080dfd44a062611dd2f7ae307e15b48e |
| app-debug.apk | 161.7 MB | 1 | arm64-v8a, armeabi-v7a, x86_64 | 2f86c9f8b3724dba8a9999456ea63252d41d0a03a279593eca148109a791dc65 |

Every later run rebuilds the APKs, so checksums change per commit; each run's `SHA256SUMS.txt` is inside its artifact. Package `com.gamebox.console`, version 0.1.0, compileSdk/targetSdk 36, label GAMEBOX. Both `launchable-activity` and `leanback-launchable-activity` (with banner) are present. Touchscreen, leanback and gamepad are declared not required. Release APKs are signed with the debug key.

## Phase 2 — Game Library

Completed: ROM manager service, native SAF scanning/hashing/header reads/artwork import/pickers/deletion, console detector, title normaliser, header validator, scan planner, schema v2 + migration test, My Games (search, filters, sorting, scan status), game page (verify, artwork, edit info, remove, delete), storage page (scan, GAMEBOX folder paths), auto-scan setting. Tests: 80 total (37 new).

Issues found by tests and fixed in Phase 2:
* STORAGE page header: three action buttons left the title ~0 px wide, so its subtitle wrapped one letter per line (408 px overflow). Page headers now reserve 40% for the title and wrap actions.
* Game cards overflowed the grid cell by 4–19 px (fixed 4:3 artwork). Artwork now takes the remaining height.
* `.chd`/`.pbp` signature checks were unreachable for PSP/PS2/GameCube/Wii. Moved before the console switch.

## Phase 3 — First emulator integration

Completed: adapter contract rewritten as pure launch planning (`IntentSpec` / `LaunchReady` / `LaunchBlocked`), RetroArch and DuckStation adapters, SAF→path resolver, `EmulatorLauncher.kt` + FileProvider, LaunchService (selection, history, session close on resume), per-console default profiles, Play / Play with… UI, Emulators screen capability chips. Tests: 98 total (18 new).

Design finding: RetroArch takes file paths only, and Android 11+ hides `Android/data` from other apps. So RetroArch can't play games stored in the GAMEBOX folders created in Phase 2. GAMEBOX now detects this and explains it instead of launching into an error. DuckStation receives a FileProvider URI instead.

Issue found by tests and fixed: the Emulators screen tile header (name + 3 chips) overflowed by 197 px at 960 px width.

**Not verified:** no launch has been executed on a real device. Every launch acceptance test stays PENDING.

## Pending features

Phases 2–8 as listed in KNOWN_LIMITATIONS → "Not yet implemented". All hardware acceptance tests are PENDING.

## Next step (Phase 2)

ROM manager: SAF tree scanning of registered folders, extension → console detection (folder-based disambiguation of `iso/bin/chd`), SHA-1/CRC32 hashing in a background isolate, duplicate detection, missing-file checks, search/filter/sort, local artwork.
