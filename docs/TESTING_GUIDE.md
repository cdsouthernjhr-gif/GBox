# Testing guide

## Automated tests (run with `flutter test`)

| File | Covers | Count |
|---|---|---|
| `test/device_intelligence_test.dart` | `/proc/cpuinfo` parser (ARM64 and legacy ARMv7 formats, empty input), UNKNOWN mapping, profile round-trip, native-scan merge, 32-bit-on-64-bit detection, tier classification (RAM never raises the tier, RAM/ABI/GLES caps), console/emulator estimates, catalogue integrity | 26 |
| `test/database_test.dart` | all 26 tables created, idempotent seeding, FK + CHECK enforcement, profile save/restore, settings, favourites/streams, remove-from-library keeps files, emulator detection upsert, storage disconnect marking, controller dedupe, no BLOB columns | 11 |
| `test/launcher_widget_test.dart` | at 960×540 logical (1080p TV): all sections render, D-pad navigation switches sections, BACK never exits, emulator detection shown, theme setting persists, missing values render as UNKNOWN | 6 |

Hardware profiles in tests are **synthetic**. They exercise logic only and say nothing about real devices.

## On-device tests

`integration_test/device_smoke_test.dart` calls the real platform channels:

```bash
flutter test integration_test/device_smoke_test.dart -d <device-id>
```

## Acceptance checklist (Part 26)

| # | Test | Phase | Status |
|---|---|---|---|
| 1 | Installation | 1 | APK builds (CI); install PENDING (needs Android 7.0+ device) |
| 2 | Launcher selection (HOME role / Home settings) | 1 | PENDING (needs device) |
| 3 | Device scanning | 1 | Logic PASSED (unit); on-device PENDING |
| 4 | Database operations | 1 | PASSED (unit, in-memory SQLite) |
| 5 | ROM import | 2 | NOT STARTED |
| 6 | ROM scanning | 2 | NOT STARTED |
| 7 | Emulator detection | 1/3 | UI logic PASSED (fake gateway); on-device PENDING |
| 8 | Game launching | 3 | NOT STARTED |
| 9 | Bluetooth controller | 1/4 | Detection PENDING (needs hardware) |
| 10 | USB controller | 1/4 | PENDING (needs hardware) |
| 11 | USB storage | 1/4 | PENDING (needs hardware) |
| 12 | SD card | 1/4 | PENDING (needs hardware) |
| 13 | Offline gameplay | 3 | Offline launcher/library: by design + widget test; gameplay NOT STARTED |
| 14 | Save and load | 7 | NOT STARTED |
| 15 | Online downloads | 5 | NOT STARTED |
| 16 | Download validation | 5 | NOT STARTED |
| 17 | Low-memory performance | 1 | PENDING (needs 2 GB device) |
| 18 | Application recovery | 1 | Startup retry screen implemented; on-device PENDING |

## Manual on-device checklist for Phase 1

1. Install the APK and open GAMEBOX from the app list or the TV app row (banner shown).
2. Settings → Default HOME app → set GAMEBOX. Press HOME: GAMEBOX opens on HOME.
3. BACK on the dashboard doesn't leave GAMEBOX. Android Settings and ANDROID APPS can still be reached.
4. Settings → Device information: check each value against the box's spec sheet. Values not reported should say UNKNOWN. Export the report.
5. Connect and disconnect a Bluetooth pad, a USB pad and a 2.4 GHz receiver: notifications appear and Controllers lists VID:PID. Use Test input on each button and stick.
6. Insert a USB drive or SD card: a notification appears and Storage shows the volume. Add a game folder, reboot, and check the folder is still listed.
7. Turn Wi-Fi off: the status shows Offline and everything still works.
8. On a 2 GB box: low-memory mode activates automatically (no focus zoom).
