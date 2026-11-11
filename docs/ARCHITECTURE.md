# Architecture

## Layers

```
┌──────────────────────────── Presentation (lib/features, lib/shared) ─────────────────────────┐
│ LauncherShell · Dashboard · Library · Consoles · Emulators · Controllers · Storage · Settings │
└───────────────▲──────────────────────────────────────────────────────────────────────────────┘
                │ ValueListenable / Stream (no direct MethodChannel or emulator access)
┌───────────────┴──────── Application (lib/app, lib/core/services, lib/core/device) ────────────┐
│ AppServices (DI container) · DeviceIntelligenceService · ControllerService · StorageService    │
│ ConnectivityService · EmulatorDetectionService · SettingsRepository                           │
└───────▲───────────────────────────▲──────────────────────────────────▲───────────────────────┘
        │ Domain (lib/domain)        │ Data (lib/core/database,          │ Emulator Adapter Layer
        │ HardwareProfile,           │ lib/data)                         │ (lib/integrations)
        │ PerformanceTier, ratings   │ Drift AppDatabase, repositories   │ EmulatorAdapter contract
        │ PerformanceClassifier      │                                   │ ExternalAppAdapter
┌───────┴───────────────────────────┴──────────────────────────────────┴───────────────────────┐
│ PlatformGateway (lib/core/services/platform_gateway.dart) — single Flutter↔Android boundary   │
└───────────────▲──────────────────────────────────────────────────────────────────────────────┘
                │ MethodChannel / EventChannel
┌───────────────┴──────────── Android native layer (Kotlin, com.gamebox.console) ──────────────┐
│ hardware/HardwareScanner · storage/StorageScanner · controllers/ControllerManager,           │
│ RawInputStream · launcher/LauncherBridge · services/ConnectivityMonitor, StorageEvents,      │
│ Background (executor) · MainActivity (channel registration, SAF picker, HOME intent)          │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

* **Hardware compatibility layer**: `HardwareScanner` (native facts) → `cpuinfo_parser.dart` → `PerformanceClassifier` (tiers and ratings) → `device_compatibility` table.
* **Online services layer**: Phase 1 only has `ConnectivityService` and the schema (`game_sources`, `source_connectors`, `download_queue`, `download_history`). The transfer engine arrives in Phase 5.

## Platform channels

| Channel | Type | Methods / events |
|---|---|---|
| `gamebox/device` | Method | `scan`, `memory`, `connectivity` |
| `gamebox/launcher` | Method (both directions) | `isDefaultLauncher`, `requestDefaultLauncher`, `openHomeSettings`, `openAndroidSettings`, `openAppDetails`, `listApps`, `appImage`, `launchApp`, `installedVersions`; native → Dart `onHomePressed` |
| `gamebox/controllers` | Method | `list` |
| `gamebox/storage` | Method | `volumes`, `pickDirectory`, `persistedDirectories`, `releaseDirectory` |
| `gamebox/controller_events` | Event | `{event: added/removed/changed, deviceId}` |
| `gamebox/raw_input` | Event | key and joystick-axis events (only while the test screen listens) |
| `gamebox/connectivity` | Event | `{connected, validated, transport}` |
| `gamebox/storage_events` | Event | media mounted/unmounted/removed/eject |

Blocking native work (EGL probe, file reads, package queries, icon rendering) runs on a 2-thread executor. Results are posted back to the main thread.

## Startup sequence

1. Error handlers are installed, and the log file is opened (`<app support>/logs/gamebox.log`).
2. The database opens, and the console/emulator catalogue is upserted (`beforeOpen`).
3. Settings load, then the **cached** hardware profile loads. The UI appears immediately, even offline.
4. In the background: connectivity, controllers, storage and emulator detection run, then a hardware rescan if enabled.
5. If startup fails, a recovery screen offers **Retry** and **Open Android Settings**.

## Memory budget decisions (2 GB devices)

* Only the selected section is built. Previous sections are disposed.
* Image cache is capped (24 MB in low-memory mode, 48 MB by default).
* No bundled bitmaps apart from a 256 px logo. Backgrounds are gradients.
* App icons are rendered at 128 px and cached per session.
* Animations are disabled automatically in low-memory mode.

## Project structure

See the tree in the spec (Part 23). The empty Phase 2+ folders (`rom_manager`, `game_scraper`, `source_manager`, `save_manager`, `performance`, `integrations/retroarch`, …) aren't committed until they contain code.
