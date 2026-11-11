# Testing guide

## Automated tests (run with `flutter test`)

| File | Covers | Count |
|---|---|---|
| `test/device_intelligence_test.dart` | `/proc/cpuinfo` parser (ARM64 and legacy ARMv7 formats, empty input), UNKNOWN mapping, profile round-trip, native-scan merge, 32-bit-on-64-bit detection, tier classification (RAM never raises the tier, RAM/ABI/GLES caps), console/emulator estimates, catalogue integrity | 26 |
| `test/database_test.dart` | all 26 tables created, idempotent seeding, FK + CHECK enforcement, profile save/restore, settings, favourites/streams, remove-from-library keeps files, emulator detection upsert, storage disconnect marking, controller dedupe, no BLOB columns | 11 |
| `test/launcher_widget_test.dart` | at 960×540 logical (1080p TV): all sections render, D-pad navigation switches sections, BACK never exits, emulator detection shown, theme setting persists, missing values render as UNKNOWN, startup scan fills My Games and search filters it, Play on the game page sends the RetroArch intent and records the session, mapping wizard (pad binding, B→BACK fallback ignored, remote BACK skips, saved remap pushed to native), Downloads screen import + Sources view | 10 |
| `test/rom_logic_test.dart` | title normaliser, console detector (unique extensions, folder aliases, closest folder, archives), header validator (NES, GB, GBA, N64, NDS, CHD; synthetic headers only), scan planner (track files, multi-disc, m3u, artwork matching) | 24 |
| `test/rom_library_service_test.dart` | folder layout creation, scan + import + verification, idempotent rescans, missing and restored files, SAF folders with unresolved files and covers, disconnected storage not marked missing, duplicates, manual import with console choice, delete, search/filters/sorting with LIKE escaping, manual metadata | 10 |
| `test/launch_test.dart` | SAF→path resolver (incl. traversal rejection), RetroArch intent (extras, core choice, unknown-core fallback, Android/data rule by API level), DuckStation intent (content URI + grant, path fallback), launch service (no emulator, launch + history + session close, missing file, remembered default and core, FileProvider URI for GAMEBOX folders, native failure not counted) | 17 |
| `test/controller_test.dart` | key remap (swaps, identities, conflicts), calibration maths, dead-zone suggestion, serialisation, player cycle, RetroArch autoconfig (RetroPad naming, sanitising, axes omitted), profile persistence, per-console override, native config push (remaps, dead zones, stick-navigation setting, reset), player slot exclusivity, vibration rules, export file | 13 |
| `test/online_core_test.dart` | URL rules (https only, credentials, redirect downgrade), file-name sanitising and Content-Disposition, catalogue validation (licence required), ZIP guard (traversal, absolute/drive paths, symlinks, entry count, bombs, non-ZIP), **download engine against a real local HTTP server**: redirect, SHA-256 pass/fail, redirect loops/unsafe targets, HTML and executables refused, size/space limits, sanitised names, truncated transfer kept for resume, pause → Range resume byte-identical, no-Range restart, cancel cleanup, probe/fetch | 21 |
| `test/online_services_test.dart` | catalogue source → browse → download → auto-import with metadata, licence and cover; offline wait; gameplay pause + Range resume; user pause/cancel; 404 fail + retry; automatic network retries; ZIP extraction import and malicious ZIP rejection; console chooser path; remove; enqueue validation; source authorisation/HTML/invalid catalogue; **deterministic regression test for the queue race** | 11 |
| `test/phase6_launch_test.dart` | every emulator/console has a launcher, dedicated-first ordering, nothing marked verified, new RetroArch cores, each recipe (PPSSPP incl. Gold package, Dolphin arm64 + AutoStartFile, DraStic path rule, melonDS action/extra, Flycast/Redream VIEW, AetherSX2), fallback serialisation, content-required blocking, below-tier warning, 32-bit Dolphin block, PPSSPP preferred over RetroArch | 14 |
| `test/migration_test.dart` | v1/v2/v3 → v4 upgrades match the v4 snapshot exactly; existing data preserved | 4 |

Hardware profiles and ROM headers in tests are **synthetic** (headers are built byte-by-byte from public format documentation; no game data is used). They exercise logic only and say nothing about real devices.

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
| 5 | ROM import | 2 | Logic PASSED (unit/widget, fake picker); SAF picker on device PENDING |
| 6 | ROM scanning | 2 | Logic PASSED (real temp folders + simulated SAF trees); on-device SAF/USB/SD PENDING |
| 7 | Emulator detection | 1/3 | UI logic PASSED (fake gateway); on-device PENDING |
| 8 | Game launching | 3/6 | Intent building, fallbacks, selection and history PASSED (unit/widget) for all 10 emulators; **on-device launch PENDING** |
| 9 | Bluetooth controller | 1/4 | Mapping/calibration logic PASSED (unit/widget); hardware PENDING |
| 10 | USB controller | 1/4 | Logic PASSED; hardware PENDING |
| 11 | USB storage | 1/4 | PENDING (needs hardware) |
| 12 | SD card | 1/4 | PENDING (needs hardware) |
| 13 | Offline gameplay | 3 | Offline launcher/library: by design + widget test; gameplay NOT STARTED |
| 14 | Save and load | 7 | NOT STARTED |
| 15 | Online downloads | 5 | PASSED against a local HTTP server (unit/service); real HTTPS on device PENDING |
| 16 | Download validation | 5 | PASSED (SHA-256, size, ZIP traversal/bomb, executables, HTML) |
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
9. Phase 2: copy a legally obtained homebrew ROM into `Android/data/com.gamebox.console/files/GAMEBOX/Games/NES/`. It should appear in MY GAMES after a scan, and Verify file should report "Header OK".
10. Phase 2: register a folder on a USB drive and scan, then unplug the drive. The games must **not** show as missing, and the scan details show the folder as unavailable. Replug: an automatic rescan runs.
11. Phase 2: put `Game Name.png` next to a ROM and rescan. The cover appears.
12. Phase 3: install RetroArch and the `fceumm` core, put a legally obtained NES homebrew file in `/storage/emulated/0/ROMs/NES/`, register `ROMs` under STORAGE, then press Play. RetroArch should start the game. Exit RetroArch: GAMEBOX returns and the game appears under Recently played.
13. Phase 3: repeat for SNES (snes9x), GB (gambatte), GBA (mgba) and PS1 (pcsx_rearmed; BIOS configured in RetroArch). Then PS1 with DuckStation from a GAMEBOX folder (content URI path). Record each result in EMULATOR_INTEGRATION.md.
14. Phase 3: on Android 11+, a game inside the GAMEBOX folder with RetroArch must show the Android/data explanation instead of launching.
15. Phase 4: for a Bluetooth pad, a USB pad and a 2.4 GHz receiver pad: Map buttons with A and B swapped, then check that the launcher now uses the swapped buttons. Calibrate and check the suggested dead zone. Test rumble on a pad that reports vibration. Export for RetroArch and import the file into RetroArch.
16. Phase 4: with a pad whose stick drifts slightly, check the focus doesn't move by itself with stick navigation on, and that it moves reliably when pushed. Hat-switch D-pads should navigate too.
17. Phase 5: host a small GAMEBOX catalogue (e.g. a public HTTPS gist) listing a CC0 homebrew ROM with its SHA-256, add it as a homebrew source, browse it, download, and confirm the game appears in MY GAMES with title, licence and cover. Unplug the network mid-download: it waits and resumes. Launch a game during a download: it pauses and continues afterwards.
18. Phase 6: for each installed emulator (PPSSPP, Mupen64Plus FZ, melonDS, DraStic, Flycast, Redream, Dolphin, AetherSX2/NetherSX2) launch a legally obtained homebrew game. Record in EMULATOR_INTEGRATION.md whether the specific activity started or the generic VIEW fallback was used (logcat shows which). Check the below-tier warning on a weaker box.
