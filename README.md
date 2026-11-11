# GAMEBOX – Ultimate Android Gaming Console

GAMEBOX turns an Android TV box into a dedicated gaming console. It's a full-screen launcher that can be set as the Android HOME app. It scans the device's hardware, keeps an offline game library and detects controllers and storage. It also manages external emulator apps.

> **Status: Phase 6 (Additional emulators, experimental).** All 10 supported emulator apps can launch games: PPSSPP, Mupen64Plus FZ, melonDS, DraStic, Flycast, Redream, Dolphin, AetherSX2/NetherSX2, plus RetroArch cores for N64, NDS, PSP, Saturn and Dreamcast. Launch methods are unverified on a device. Earlier: **Phase 5 (Online Services).** User-added sources (direct links and the licence-required GAMEBOX catalogue format), HTTPS download engine with resume, SHA-256, size/space checks and safe ZIP extraction, download dashboard and history, catalogue metadata and covers. Earlier: **Phase 4 (Controllers).** Button mapping wizard, analog calibration, dead zone, trigger threshold, vibration test, player slots and RetroArch autoconfig export. Mappings apply inside GAMEBOX (native key remap + dead-zone-aware stick navigation). Earlier: **Phase 3 (First emulator integration, experimental).** Games can be launched through RetroArch (NES, SNES, Master System, Mega Drive, GB/GBC, GBA, PS1) and DuckStation (PS1), with play history. The launch methods are untested on a real device. Earlier phases: **Phase 2 (Game Library).** Phase 1 (launcher, Device Intelligence Engine, database, controller/storage detection, settings) plus the ROM manager: folder scanning, console detection, manual import, missing-file and duplicate detection, header verification, local artwork, search/filter/sort and metadata editing. Game launching through emulators (Phase 3) is **not implemented yet**. See [docs/DEVELOPMENT_REPORT.md](docs/DEVELOPMENT_REPORT.md).

## What works in Phase 1

**Minimum Android version: 7.0 (API 24).** Android 6.0 was requested but isn't achievable with the current toolchain; see [KNOWN_LIMITATIONS](docs/KNOWN_LIMITATIONS.md).

| Area | Implemented |
|---|---|
| Launcher | HOME / DEFAULT / LEANBACK_LAUNCHER intent filters, set or change the default launcher (RoleManager on Android 10+, Home settings otherwise), BACK never exits, HOME returns to the dashboard, Android apps drawer and Android Settings shortcut, so you're never locked out |
| Dashboard | 11 sections, D-pad/remote/gamepad focus navigation, status widgets (controllers, storage, device tier, online/offline, emulators), library rows backed by the database |
| Device Intelligence | Manufacturer, model, build, ABIs, `/proc/cpuinfo` core types, core count, max frequency, RAM and memory pressure, GPU vendor/renderer (EGL probe), OpenGL ES version, Vulkan, display mode/refresh/density, storage volumes, input devices. Any value the device doesn't report is shown as **UNKNOWN** |
| Adaptive engine | ENTRY / STANDARD / ADVANCED / HIGH PERFORMANCE tiers from CPU + GPU + RAM + ABI + GLES; per-console and per-emulator ratings, always labelled *hardware estimate* |
| Database | Drift/SQLite with all 26 tables, foreign keys, check constraints, indexes, migration hook. ROM binaries are never stored |
| Controllers | Live list via InputDevice (VID/PID, buttons, axes, vibration, player number), connect/disconnect notifications, raw input test screen |
| Storage | Volume detection (internal/USB/SD where Android labels it), capacity, mount/unmount events, SAF folder registration with persisted permission |
| Emulators | Detects 10 known external emulator apps and can open them. No emulators are bundled |
| Game library (Phase 2) | Auto-created `GAMEBOX/Games/<CONSOLE>` folders on every volume, SAF folder scanning, manual import with console chooser, console detection by extension/folder, multi-disc grouping, missing vs. disconnected detection, header checks + SHA-1/CRC32, duplicates, local cover artwork, search/filters/sorting, favourites, metadata editing, remove or (double-confirmed) delete — see [ROM_MANAGER](docs/ROM_MANAGER.md) |
| Game launching (Phase 3) | Play / Play with… (emulator + RetroArch core, remember per console), clear reasons when a launch is impossible, play history and Recently played, cache cleanup before launch — **experimental until verified on a device**; see [EMULATOR_INTEGRATION](docs/EMULATOR_INTEGRATION.md) |
| Controllers (Phase 4) | Mapping wizard, calibration with suggested dead zone, dead zone / trigger threshold, rumble test, Player 1–4, RetroArch export, stick/hat navigation — see [CONTROLLER_SUPPORT](docs/CONTROLLER_SUPPORT.md) |
| Online services (Phase 5) | Source manager (7 source types, connection check, catalogue browse), download queue (pause/resume/cancel/retry, speed/ETA, offline wait, pause while playing), HTTPS-only with safe redirects, SHA-256 and size checks, archive-bomb and path-traversal protection, import with catalogue metadata — see [ONLINE_SOURCES](docs/ONLINE_SOURCES.md) |
| Additional emulators (Phase 6) | Launch recipes with a generic-VIEW fallback, dedicated-emulator-first defaults, arm64 blocking and below-tier warnings from the Device Intelligence Engine — **experimental** |
| Settings | 4 themes, animations, UI sounds, low-memory mode, image cache, startup rescan, sorting, default console, logs, device report export |

## Quick start

```bash
flutter pub get
flutter test                 # 161 unit/database/migration/widget/network tests
flutter build apk --debug    # needs the Android SDK (platform 36)
```

CI builds the APKs on every push: GitHub → Actions → **Android build** → artifact `gamebox-apks`.

See [docs/BUILD_GUIDE.md](docs/BUILD_GUIDE.md) for the full toolchain and CI. Installation and launcher setup are covered in [docs/INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md).

## Documentation

- [ONLINE_SOURCES](docs/ONLINE_SOURCES.md) · [ROM_MANAGER](docs/ROM_MANAGER.md) · [ARCHITECTURE](docs/ARCHITECTURE.md) · [DATABASE_SCHEMA](docs/DATABASE_SCHEMA.md) · [EMULATOR_INTEGRATION](docs/EMULATOR_INTEGRATION.md)
- [DEVICE_COMPATIBILITY](docs/DEVICE_COMPATIBILITY.md) · [CONTROLLER_SUPPORT](docs/CONTROLLER_SUPPORT.md) · [STORAGE_SUPPORT](docs/STORAGE_SUPPORT.md)
- [BUILD_GUIDE](docs/BUILD_GUIDE.md) · [TESTING_GUIDE](docs/TESTING_GUIDE.md) · [INSTALLATION_GUIDE](docs/INSTALLATION_GUIDE.md)
- [RELEASE_NOTES](docs/RELEASE_NOTES.md) · [KNOWN_LIMITATIONS](docs/KNOWN_LIMITATIONS.md) · [DEVELOPMENT_REPORT](docs/DEVELOPMENT_REPORT.md)

## Legal

GAMEBOX ships **no ROMs, BIOS files, firmware or emulators**. It only works with files you legally own and emulator apps you install yourself. It will never bypass DRM, authentication or paywalls.

## Dependencies and licences

| Dependency | Version | Licence | Purpose |
|---|---|---|---|
| Flutter SDK / Dart | 3.47.9 / 3.13.7 | BSD-3-Clause | UI framework |
| drift | ^2.35.4 | MIT | Typed SQLite ORM |
| drift_flutter | ^0.3.1 | MIT | Opens the on-device database |
| sqlite3 (+ bundled SQLite) | 3.5.2 (resolved) | MIT / public domain | SQLite native library |
| path_provider | ^2.1.6 | BSD-3-Clause | App directories |
| path | ^1.9.1 | BSD-3-Clause | Path utilities |
| crypto | ^3.0.8 | BSD-3-Clause | SHA-256 for download verification |
| archive | ^4.6.0 | MIT | ZIP inspection and guarded extraction |
| androidx.core:core (Android) | 1.13.1 | Apache-2.0 | FileProvider for sharing GAMEBOX-folder games with emulators |
| drift_dev, build_runner (dev) | 2.35.3 / 2.17.1 | MIT / BSD-3-Clause | Code generation |
| flutter_lints, flutter_test, integration_test (dev) | SDK | BSD-3-Clause | Linting, tests |
| Android Gradle Plugin / Kotlin / Gradle | 9.1.0 / 2.4.0 / 9.3.1 | Apache-2.0 | Android build |

Apart from androidx.core (FileProvider), native Android code uses only platform APIs.
