# Database schema

Engine: SQLite via Drift (`lib/core/database/tables.dart`, `app_database.dart`). File: `gamebox.sqlite` in the app support directory. **Schema version: 1.** `PRAGMA foreign_keys = ON` is set on every open.

ROM binaries are never stored. `game_files` holds a URI/path, size and hashes only. A test checks that no BLOB columns exist.

| # | Table | Key | Purpose / notable columns | Relations & indexes |
|---|---|---|---|---|
| 1 | devices | id | device_key (unique: manufacturer\|model\|device\|fingerprint), first/last seen | — |
| 2 | device_hardware_profiles | id | snapshot per scan: tier, confidence, ABIs, GPU, RAM, raw_json (full profile) | FK devices (cascade); idx (device_id, scanned_at); last 20 kept |
| 3 | device_compatibility | id | knowledge base; **source ∈ detected / community / verified** (CHECK) | idx (manufacturer, model) |
| 4 | compatibility_test_results | id | result ∈ rating enum (CHECK), source ∈ local/community/verified, consent_to_share, submitted | FK devices, emulators, consoles, games (set null) |
| 5 | consoles | id (text) | catalogue: extensions, folder, min/recommended tier | seeded |
| 6 | emulators | id (text) | catalogue: licence, strategy, arm64 requirement | seeded |
| 7 | emulator_profiles | id | per emulator/console settings JSON | FK emulators (cascade), consoles |
| 8 | emulator_adapters | id | package, strategy, installed, version, last detected | FK emulators; UNIQUE (emulator_id, package_name) |
| 9 | games | id | title, sort_title, console, preferred emulator, play stats, is_missing | FK consoles, emulators; idx console_id, last_played_at |
| 10 | game_files | id | uri (unique), display path, extension, size, sha1, crc32, file_exists | FK games (cascade), storage_devices (set null); idx sha1 (duplicates) |
| 11 | game_metadata | game_id | description, developer, publisher, genre, provider, edited_manually | FK games (cascade) |
| 12 | game_artworks | id | type ∈ cover/screenshot/background, local_path, source_url | FK games (cascade) |
| 13 | favorites | game_id | added_at | FK games (cascade) |
| 14 | game_history | id | started/ended, duration, exit status | FK games (cascade); idx started_at |
| 15 | controller_devices | id | descriptor (unique), VID/PID, type, buttons/axes JSON, assigned player | — |
| 16 | controller_profiles | id | dead zone, trigger threshold, vibration, per controller/console | FK consoles |
| 17 | controller_mappings | id | action → key code / axis | FK profiles (cascade); UNIQUE (profile_id, action) |
| 18 | storage_devices | id | volume_id (unique), kind, SAF tree URI, capacity, is_connected | — |
| 19 | game_sources | id | type ∈ 7 spec source types (CHECK), auth type, status | FK source_connectors |
| 20 | source_connectors | id (text) | connector registry (seeded: direct_url) | — |
| 21 | download_queue | id | status ∈ queued/downloading/paused/completed/failed/cancelled, expected hash | FK game_sources (set null); idx status |
| 22 | download_history | id | final status, sha256, error | FK game_sources (set null) |
| 23 | save_states | id | kind ∈ state/native/memcard (keeps emulator states, native saves and memory cards separate), slot, path | FK games (cascade) |
| 24 | save_backups | id | backup path, size, note | FK games, save_states (set null) |
| 25 | benchmarks | id | measured FPS/score only (no estimates), duration | FK devices (cascade), games |
| 26 | app_settings | key | string values; typed by `SettingsRepository` | — |

## Migration strategy

* `schemaVersion` is bumped for every schema change. `onUpgrade` gets `if (from < N)` steps that use `Migrator` (`addColumn`, `createTable`, …). User tables are never dropped.
* Catalogue data (consoles, emulators, connectors) is upserted on every open, so catalogue changes don't need migrations.
* Before shipping a schema change, add a Drift schema dump (`dart run drift_dev make-migrations`) and a migration test.
