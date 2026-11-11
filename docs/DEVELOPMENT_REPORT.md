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
| Flutter engine 3.47 | officially 24, hard error < 23 | builds with warning; **unverified** | armeabi-v7a, arm64-v8a, x86_64 | use; document |
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

## Pending features

Phases 2–8 as listed in KNOWN_LIMITATIONS → "Not yet implemented". All hardware acceptance tests are PENDING.

## Next step (Phase 2)

ROM manager: SAF tree scanning of registered folders, extension → console detection (folder-based disambiguation of `iso/bin/chd`), SHA-1/CRC32 hashing in a background isolate, duplicate detection, missing-file checks, search/filter/sort, local artwork.
