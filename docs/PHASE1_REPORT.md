# GAMEBOX 1.0 — Phase 1 report (0.18.0)

Scope from [UPGRADE_PLAN.md](UPGRADE_PLAN.md) Phase 1. Tests: `flutter analyze` clean, 239 unit/widget tests passing locally; CI (build, R8, native-library checks, device tests on API 24 and 34) runs on push.

## Completed

| Item | What was done | Verification |
|---|---|---|
| Database v6 | `profiles` + default profile; favourites keyed by (profile, game); `game_history.profile_id`; `uuid` on games, game_files, game_history; unique indexes | `test/migration_test.dart`: v1–v5 → v6 schema equality, data kept, default profile, unique UUIDs |
| Upgrade safety | `VACUUM INTO` copy before upgrading; all steps in one transaction; row-count, foreign-key and integrity checks; rollback on failure; clear start-screen message; copies listed in Restore library | Tests: backup copy contains the old library; a failing upgrade leaves the v5 schema and data untouched |
| Modern Retro theme | New default (navy / electric blue / purple / orange Play); old themes kept; saved choices kept | Widget tests (theme setting, rendering) |
| HOME quick actions + status | Add games, Find ROMs, Emulators, Controllers, Settings; controllers, storage, system tiles; all open their screens; UNKNOWN for unreported values | Widget test "HOME quick actions and status tiles open what they describe" |
| Phone layout | Bottom navigation under 720 dp width; portrait allowed on phones (shortest side < 600 dp); GAMES filters wrap; compact status bar; chips and buttons shrink instead of overflowing | Widget test at 360×780: every section and the game page lay out without overflow |
| CI checks | `tool/check_native_libs.sh`: 16 KB LOAD alignment of every native library and build ID of every core against the fetched file; in CI and release workflows | Run locally on the published 0.17.0 APKs (all aligned); negative tests (4 KB alignment, wrong build ID) fail as expected |

## Not done in Phase 1 (moved or dropped)

* **Remove `ppsspp.zip` from the x86_64 APK:** not done. Assets are shared by all split APKs; per-ABI assets need product flavours, which would change the build and release workflows. It is kept for a later phase (11.5 MB, x86_64 only).
* **Regression tests for every existing feature:** existing features already have tests ([EXISTING_FEATURES.md](EXISTING_FEATURES.md)). Phase 1 added tests for what it changed (database, theme, HOME, phone layout). An upgrade test from the **real 0.17.0 APK to 0.18.0 on the CI emulator** is not done yet. It is planned for Phase 2, so the migration is also checked on Android, not only on desktop SQLite.
* **Per-profile play statistics:** `games.last_played_at` and `play_count` stay global until profiles become selectable (Phase 4).

## Known issues / PENDING

* None of the Phase 1 changes have run on a physical phone or TV box.
* Bottom navigation is touch-first. On a phone with a gamepad, D-pad focus reaches the bottom bar through normal traversal; this is not tuned yet.
