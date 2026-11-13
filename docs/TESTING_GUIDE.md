# Testing guide

## Automated tests (run with `flutter test`)

| File | Covers | Count |
|---|---|---|
| `test/device_intelligence_test.dart` | `/proc/cpuinfo` parser (ARM64 and legacy ARMv7 formats, empty input), UNKNOWN mapping, profile round-trip, native-scan merge, 32-bit-on-64-bit detection, tier classification (RAM never raises the tier, RAM/ABI/GLES caps), console/emulator estimates, catalogue integrity | 26 |
| `test/database_test.dart` | all 26 tables created, idempotent seeding, FK + CHECK enforcement, profile save/restore, settings, favourites/streams, remove-from-library keeps files, emulator detection upsert, storage disconnect marking, controller dedupe, no BLOB columns | 11 |
| `test/launcher_widget_test.dart` | at 960×540 logical (1080p TV): all sections render, D-pad navigation switches sections, BACK never exits, emulator detection shown, theme setting persists, missing values render as UNKNOWN, startup scan fills My Games and search filters it, Play on the game page sends the RetroArch intent and records the session, mapping wizard (pad binding, B→BACK fallback ignored, remote BACK skips, saved remap pushed to native), Downloads screen import + Sources view, post-game "how did it run?" prompt stored (opt-in sharing off), performance screen live values and unavailability labels | 12 |
| `test/rom_logic_test.dart` | title normaliser, console detector (unique extensions, folder aliases, closest folder, archives), header validator (NES, GB, GBA, N64, NDS, CHD; synthetic headers only), scan planner (track files, multi-disc, m3u, artwork matching) | 24 |
| `test/rom_library_service_test.dart` | folder layout creation, scan + import + verification, idempotent rescans, missing and restored files, SAF folders with unresolved files and covers, disconnected storage not marked missing, duplicates, manual import with console choice, delete, search/filters/sorting with LIKE escaping, manual metadata | 10 |
| `test/launch_test.dart` | SAF→path resolver (incl. traversal rejection), RetroArch intent (extras, core choice, unknown-core fallback, Android/data rule by API level), DuckStation intent (content URI + grant, path fallback), launch service (no emulator, launch + history + session close, missing file, remembered default and core, FileProvider URI for GAMEBOX folders, native failure not counted) | 17 |
| `test/controller_test.dart` | key remap (swaps, identities, conflicts), calibration maths, dead-zone suggestion, serialisation, player cycle, RetroArch autoconfig (RetroPad naming, sanitising, axes omitted), profile persistence, per-console override, native config push (remaps, dead zones, stick-navigation setting, reset), player slot exclusivity, vibration rules, export file | 13 |
| `test/online_core_test.dart` | URL rules (https only, credentials, redirect downgrade), file-name sanitising and Content-Disposition, catalogue validation (licence optional, recorded when stated), ZIP guard (traversal, absolute/drive paths, symlinks, entry count, bombs, non-ZIP), **download engine against a real local HTTP server**: redirect, SHA-256 pass/fail, redirect loops/unsafe targets, HTML and executables refused, size/space limits, sanitised names, truncated transfer kept for resume, pause → Range resume byte-identical, no-Range restart, cancel cleanup, probe/fetch | 21 |
| `test/online_services_test.dart` | catalogue source → browse → download → auto-import with metadata, licence and cover; offline wait; gameplay pause + Range resume; user pause/cancel; 404 fail + retry; automatic network retries; ZIP extraction import and malicious ZIP rejection; console chooser path; remove; enqueue validation; source authorisation/HTML/invalid catalogue; **deterministic regression test for the queue race**; catalogue entry without a licence downloaded and labelled "not stated" | 12 |
| `test/phase6_launch_test.dart` | every emulator/console has a launcher, dedicated-first ordering, nothing marked verified, new RetroArch cores, each recipe (PPSSPP incl. Gold package, Dolphin arm64 + AutoStartFile, DraStic path rule, melonDS action/extra, Flycast/Redream VIEW, AetherSX2), fallback serialisation, content-required blocking, below-tier warning, 32-bit Dolphin block, PPSSPP preferred over RetroArch | 14 |
| `test/phase7_test.dart` | save classification and unique matching; save scan/link/unmatched; backup + restore with safety copy; restore refusals; unreadable folder kept; save export/import incl. malicious ZIP; evidence precedence (estimate → community → own test → verified) and import never verified; anonymous report consent and no identifiers; library `VACUUM INTO` backup + staged restore; benchmarks positive and stored | 11 |
| `test/library_location_test.dart` | layout (every console, emulator save folder and BIOS folder), BIOS/Saves folders excluded from scans, BIOS status, downloads moved into `Games/<CONSOLE>` (unique names, unknown console waits in Downloads, ZIP extracted into `Games/<CONSOLE>/<name>/`, single-console ZIP detection), public folder (layout created, game folders and save folders registered, downloads written into the tree and imported with its root, no duplicate on rescan, delete removes the document, ZIP folders kept), save scan limited to `Saves/<Emulator>` of the tree, switching back to the app folder | 14 |
| `test/migration_test.dart` | v1–v4 → v5 upgrades match the v5 snapshot exactly; existing data preserved | 5 |

Hardware profiles and ROM headers in tests are **synthetic** (headers are built byte-by-byte from public format documentation; no game data is used). They exercise logic only and say nothing about real devices.

## On-device tests

`integration_test/device_test.dart` runs on a real Android device or emulator with the real native layer:

```bash
flutter test integration_test/device_test.dart -d <device-id>
./tool/ci_device_tests.sh   # integration tests + adb HOME-launcher checks (needs emulator-5554)
```

| Test | Checks |
|---|---|
| hardware scan | native scan returns API ≥ 24, ABIs, RAM, display size, a primary storage volume; prints a `DEVICE:` line |
| bundled SQLite | a real database **file** opens, seeds 16 consoles, writes, `VACUUM INTO` backup reopens with the data |
| library | GAMEBOX folders created on device storage, scan imports a synthetic NES file, native header check `valid`, native SHA-1, FileProvider gives a `content://com.gamebox.console.files/` URI |
| emulator launch errors | launching a non-installed app walks the fallback chain and returns `not_found` without throwing |
| channels | storage, input devices, connectivity, performance snapshot, default-launcher state, app list, free space, input config |
| launcher UI | the real app boots on the device, HOME and MY GAMES render; on a landscape screen all 11 menu entries fit; no Flutter exception |

`tool/ci_device_tests.sh` then installs the debug APK and checks with adb: HOME and LEANBACK_LAUNCHER filters registered (`dumpsys package`), GAMEBOX set as default HOME (`cmd package set-home-activity`), HOME key → GAMEBOX is the resumed activity, BACK → GAMEBOX stays in front, no crash in logcat.

### Emulator results (CI runs #14 and #17, commits 5d5f8e1 and 7918e2d, 2026-11-11)

Run #17 also logs the resumed activity as evidence, e.g. `mResumedActivity: ActivityRecord{… com.gamebox.console/.MainActivity …}` after HOME and again after BACK, on both API levels.

| Emulator | Integration tests | HOME filters | Set default HOME | HOME → GAMEBOX | BACK stays | Crash |
|---|---|---|---|---|---|---|
| API 24 (Android 7.0) default x86_64, 1920×1080 | 6/6 PASS | PASS | command accepted (no output) | PASS | PASS | none |
| API 34 (Android 14) google_apis x86_64, 1920×1080 | 6/6 PASS | PASS | `Success` | PASS | PASS | none |
| API 30 android-tv x86 | not run: Flutter doesn't support 32-bit x86 ("unsupported" device) | — | — | — | — | — |

These are **Android emulators on x86_64, not TV boxes**. They prove the APK installs and runs on Android 7.0 and 14, the native layer, SQLite and FileProvider work, and Android accepts GAMEBOX as the HOME app. They don't prove anything about ARM TV-box firmware, real remotes or controllers, USB/SD, GPU drivers, or emulator launches. Those remain PENDING.

## Acceptance checklist (Part 26)

| # | Test | Phase | Status |
|---|---|---|---|
| 1 | Installation | 1/8 | **PASSED on Android emulators** API 24 and API 34 (CI device-tests); physical TV box PENDING |
| 2 | Launcher selection (HOME role / Home settings) | 1/8 | **PASSED on emulators** via adb (set default HOME, HOME → GAMEBOX, BACK stays); in-app RoleManager/Home-settings flow and physical TV box PENDING |
| 3 | Device scanning | 1/8 | Logic PASSED (unit); native scan PASSED on emulators; real TV-box values PENDING |
| 4 | Database operations | 1/8 | PASSED (unit, in-memory) and **on emulators** with a real database file and backup |
| 5 | ROM import | 2 | Logic PASSED (unit/widget, fake picker); SAF picker on device PENDING |
| 6 | ROM scanning | 2/8/0.9 | Logic PASSED; GAMEBOX-folder scan + native header/hash PASSED on emulators; SAF/USB/SD on device PENDING |
| 7 | Emulator detection | 1/3 | UI logic PASSED (fake gateway); on-device PENDING |
| 8 | Game launching | 3/6 | Intent building, fallbacks, selection and history PASSED (unit/widget) for all 10 emulators; **on-device launch PENDING** |
| 9 | Bluetooth controller | 1/4 | Mapping/calibration logic PASSED (unit/widget); hardware PENDING |
| 10 | USB controller | 1/4 | Logic PASSED; hardware PENDING |
| 11 | USB storage | 1/4 | PENDING (needs hardware) |
| 12 | SD card | 1/4 | PENDING (needs hardware) |
| 13 | Offline gameplay | 3 | Offline launcher/library: by design + widget test; gameplay NOT STARTED |
| 14 | Save and load | 7 | Backup/restore/export/import PASSED (unit, real files); emulator save folders on device PENDING |
| 15 | Online downloads | 5 | PASSED against a local HTTP server (unit/service); real HTTPS on device PENDING |
| 16 | Download validation | 5 | PASSED (SHA-256, size, ZIP traversal/bomb, executables, HTML) |
| 17 | Low-memory performance | 1 | PENDING (needs 2 GB device) |
| 18 | Application recovery | 1 | Startup retry screen implemented; on-device PENDING |
| — | Android 7.0 (API 24) support | 8 | **PASSED on the API 24 emulator**; physical Android 7 box PENDING |
| — | Android 6.0 (API 23) support | — | **NOT SUPPORTED** (build declares minSdk 24; see KNOWN_LIMITATIONS) |

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
20. 0.9.0: STORAGE → Choose public folder…, create `GAMEBOX` on internal storage and select it. Check with a file manager that `Games/…`, `Saves/…` and `BIOS/…` exist. Download a homebrew NES file: it must appear in `GAMEBOX/Games/NES/` and in MY GAMES, and launch with RetroArch (path access). Put a BIOS file in `BIOS/PS1`: the BIOS list shows it as found and it is not imported as a game. Point RetroArch's save folder at `Saves/RetroArch/saves`, save in a game, then Saves → Scan: the save is linked to the game. Repeat the folder choice on a USB drive.
19. Phase 7: register RetroArch's saves folder, play a game until it saves, then Back up saves. Play on so the save changes, then Restore the backup and check the old progress is back. Run the benchmarks on a 2 GB box and check nothing stutters or crashes. Check temperatures appear on the performance screen. Back up the library, change something, Restore library, restart, and check the change is gone.
