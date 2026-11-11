# GAMEBOX – Ultimate Android Gaming Console

GAMEBOX turns an Android TV box into a dedicated gaming console. It's a full-screen launcher that can be set as the Android HOME app. It scans the device's hardware, keeps an offline game library and detects controllers and storage. It also manages external emulator apps.

> **Status: Phase 2 (Game Library).** Phase 1 (launcher, Device Intelligence Engine, database, controller/storage detection, settings) plus the ROM manager: folder scanning, console detection, manual import, missing-file and duplicate detection, header verification, local artwork, search/filter/sort and metadata editing. Game launching through emulators (Phase 3) is **not implemented yet**. See [docs/DEVELOPMENT_REPORT.md](docs/DEVELOPMENT_REPORT.md).

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
| Settings | 4 themes, animations, UI sounds, low-memory mode, image cache, startup rescan, sorting, default console, logs, device report export |

## Quick start

```bash
flutter pub get
flutter test                 # 80 unit/database/migration/widget tests
flutter build apk --debug    # needs the Android SDK (platform 36)
```

CI builds the APKs on every push: GitHub → Actions → **Android build** → artifact `gamebox-phase1-apks`.

See [docs/BUILD_GUIDE.md](docs/BUILD_GUIDE.md) for the full toolchain and CI. Installation and launcher setup are covered in [docs/INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md).

## Documentation

- [ROM_MANAGER](docs/ROM_MANAGER.md) · [ARCHITECTURE](docs/ARCHITECTURE.md) · [DATABASE_SCHEMA](docs/DATABASE_SCHEMA.md) · [EMULATOR_INTEGRATION](docs/EMULATOR_INTEGRATION.md)
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
| drift_dev, build_runner (dev) | 2.35.3 / 2.17.1 | MIT / BSD-3-Clause | Code generation |
| flutter_lints, flutter_test, integration_test (dev) | SDK | BSD-3-Clause | Linting, tests |
| Android Gradle Plugin / Kotlin / Gradle | 9.1.0 / 2.4.0 / 9.3.1 | Apache-2.0 | Android build |

Native Android code uses only platform APIs; it has no third-party Android libraries.
