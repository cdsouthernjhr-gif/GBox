# Database audit (0.17.0 baseline)

* **Engine:** SQLite through Drift 2.35.4. The file is `gamebox.db` in the app's support directory.
* **Foreign keys:** on (`PRAGMA foreign_keys = ON` in `beforeOpen`).
* **Schema version:** 5.
* **Tests:** generated snapshots v1…v5 live in `test/generated_migrations`. `test/migration_test.dart` upgrades each version to v5, compares the result with the v5 schema, and checks that library data survives v1 → v5.
* **Settings:** key/value table `app_settings`. Settings include the JSON lists for user emulators and user systems, and per-core player settings.
* **ROM files:** never stored in the database; only URIs/paths, sizes, hashes and header results are.

## Tables (26)

| Group | Tables | Key type |
|---|---|---|
| Device | devices, device_hardware_profiles, device_compatibility, compatibility_test_results, benchmarks | integer auto-increment |
| Catalogue | consoles (text id), emulators (text id), emulator_profiles, emulator_adapters, source_connectors (text id) | text / integer |
| Library | games, game_files, game_metadata (key = game), game_artworks, favorites (key = game), game_history | integer |
| Controllers | controller_devices, controller_profiles, controller_mappings | integer |
| Storage & online | storage_devices, game_sources, download_queue, download_history | integer |
| Saves | save_states, save_backups | integer |
| Settings | app_settings (text key) | text |

Indexes:
* `idx_games_console`, `idx_games_last_played`;
* `idx_game_files_hash` (sha1), `idx_game_files_root`, `idx_game_files_game`;
* `idx_history_started`, `idx_download_status`;
* `idx_hw_profiles_device`, `idx_compat_model`.

Game search uses `LIKE` on title/sortTitle. There is no index on `sort_title` and no FTS.

## Migrations so far

| From → to | Change |
|---|---|
| 1 → 2 | games.regions; game_files.root_uri, last_modified, is_primary, disc_number, header_status, header_detail |
| 2 → 3 | controller_profiles.calibration_json |
| 3 → 4 | download_queue.file_path, console_id, catalog_json, sha256, imported_game_id |
| 4 → 5 | save_states.folder_uri, relative_path, last_modified |

All are additive (`ALTER TABLE … ADD COLUMN`). None rewrites or deletes data.

## Backup and restore today

* **Backup:** `AppDatabase.backupTo` runs `VACUUM INTO`, a consistent copy of the live database. It is run from Settings → System → *Back up library*.
* **Restore:** Settings → *Restore library…* replaces the database on the next start. The current one is kept as `gamebox.before-restore.sqlite`.
* **Gap:** there is no automatic backup before a schema upgrade.

## 1.0 entity list vs existing tables

| 1.0 entity | Existing | Gap |
|---|---|---|
| profiles | — | **New table** |
| consoles | consoles (+ user systems in settings) | Add: default emulator, BIOS requirement, availability, artwork. User systems could move from settings to rows |
| games | games | Add profile-independent UUID; per-game emulator (`preferred_emulator_id` exists, unused) |
| rom_files | game_files | Rename not needed; add sha256 (only sha1/crc32 today) |
| emulators | emulators (known), user emulators in settings | Add version, kind (built-in/external/user) |
| emulator_cores | built-in cores in code; RetroArch core map in code | **New table** (or keep in code; decision) |
| game_emulator_support | launchersForConsole (code) | **New table**, needed only for per-game overrides |
| bios_files | biosInfo (code) | **New table** for found files, hashes and status |
| artwork | game_artworks | Add types: screenshot, background, logo |
| save_records | save_states, save_backups | Add profile, core id, core version, emulator version, checksum, slot. The built-in player's own `.state`/`.srm` aren't in the database today |
| play_sessions | game_history | Add profile |
| controllers | controller_devices | — |
| controller_profiles | controller_profiles, controller_mappings | Add profile |
| multiplayer_sessions | — | **New table** (local player assignment only; see netplay limits) |
| achievements, user_achievements | — | **New tables** |
| themes | settings keys | **New table** only if user-created themes are kept; otherwise built-in theme ids in settings |
| backups | save_backups (saves only) | Generalise, or add a backups table for database and full backups |
| app_settings | app_settings | Add profile scope for per-profile settings |
| download_records | download_queue, download_history | — |

## Primary keys: integer vs UUID (decision needed)

All existing tables use integer keys. Changing them to UUIDs means:
* rebuilding every table;
* rewriting every foreign key in the user's library.

This is the riskiest possible migration. It is also the change most likely to lose or corrupt user data (play history, saves, favourites, controller profiles). **Recommendation:**

* **Keep the integer keys** of existing tables, so existing rows and relations don't change.
* **Add a `uuid TEXT UNIQUE` column** to the tables that are exported, shared or synced (games, game_files, save records, profiles, play sessions, controller profiles). Fill it during the migration with a random v4 value, generated with `Random.secure()`; no package is needed.
* **New 1.0 tables** (profiles, achievements, …) use a UUID text primary key, as the brief asks.

## Profile isolation (decision needed)

There are no profiles today. Proposal:
* Create a **default profile** during migration.
* Attach every existing favourite, play session, save record, controller profile and per-profile setting to it, so nothing is lost or hidden.
* Add `profile_id` (foreign key to profiles, `ON DELETE` restricted) to:
  * favorites (key becomes profile + game);
  * game_history;
  * save_states / save_backups;
  * controller_profiles;
  * emulator_profiles;
  * compatibility_test_results.
* Keep the library itself (games, files, artwork) shared between profiles. These are the same files on the device.
* Deleting a profile is blocked while it has saves, unless the user first moves or exports them.

## Migration safety for v6 and later

1. **Before** opening an older schema for upgrade, copy `gamebox.db` to `gamebox.before-v<N>.sqlite` (file copy while closed).
2. **Migration in one transaction:**
   * the upgrade steps are wrapped explicitly in a transaction (not relying on Drift defaults);
   * each step is additive, or copies data into new tables before anything is dropped.
3. **Verify after migration:**
   * `PRAGMA foreign_key_check`;
   * `PRAGMA integrity_check`;
   * row counts of games, files, favourites and history are unchanged.
4. **Recovery:**
   * if any check fails, the app keeps running on the pre-migration copy and reports the error;
   * Settings → *Restore library…* also lists the `before-v<N>` copies.
5. **Rollback:** an older app version can't open a newer schema, so rollback = install the previous APK and restore its `before-v<N>` copy. This is documented in the release notes of each migration.
6. **Tests:**
   * a new snapshot (`schema_v6.dart`);
   * upgrade tests v1…v5 → v6 with data;
   * a failure-injection test (migration throws → database unchanged, backup present).

## Other observations

* `games.preferred_emulator_id` exists but is unused. Per-console defaults are in `emulator_profiles`.
* User emulators and user systems are stored as JSON in `app_settings`. This is simple and validated on read, but invisible to SQL queries. Moving them into tables can happen in the v6 migration, if approved.
* Game search would benefit from an index on `sort_title`, or FTS5, for large libraries. FTS5 availability in the bundled SQLite must be checked.
