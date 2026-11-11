# Saves and backup (Phase 7)

## Emulator saves

Emulators keep saves in **their own folders**. GAMEBOX doesn't move them. You register each save folder once (STORAGE → **Save folders** → *Add save folder*) through Android's folder picker and say which emulator uses it. Typical folders:

| Emulator | Usual save folder (user-configurable in the emulator) |
|---|---|
| RetroArch | `RetroArch/saves` (game saves `.srm`), `RetroArch/states` (`.state`, `.stateN`, `.state.auto`) |
| PPSSPP | `PSP/PPSSPP_STATE` (`.ppst`). `PSP/SAVEDATA` holds per-game folders, which aren't matched yet |
| DuckStation | `memcards` (`.mcd`) |
| Dolphin | `GC` memory cards (`.gci`, `.raw`) |
| AetherSX2/NetherSX2 | `memcards` (`.ps2`) |

Emulators that keep saves inside `Android/data/<their package>` can't be registered on Android 11+. Android blocks it. Configure such emulators to use a normal folder.

### Kinds (kept strictly separate)

| Kind | Examples | Note |
|---|---|---|
| Game save (native) | `.srm`, `.sav`, `.eep`, `.fla`, `.sra`, `.dsv`, `.rtc` | the game's own battery/flash save |
| Save state | `.state`, `.state1`–`.state9`, `.state.auto`, `.ppst` | **only works in the emulator (usually the same version) that created it** — GAMEBOX never converts states between emulators or cores |
| Memory card | `.mcd`, `.mcr`, `.mc`, `.gci`, `.ps2`, `.mpk` | often shared by many games, so usually not linked to one game |

A save file is linked to a game only when its name matches **exactly one** game (title or ROM file name, compared case- and punctuation-insensitively). Otherwise it's reported as "not matched". If a folder can't be read (storage disconnected), it's reported and its known saves are kept.

### Backup, restore, export, import

* **Back up**: game page → *Back up saves*, or STORAGE → *Back up all saves*. Files are copied to `GAMEBOX/Backups/saves/<timestamp>-<ms>-<n>/<game>/<emulator>/`. Every run gets a new folder, and backup files are **never overwritten**.
* **Restore**: game page → *Restore…* → pick a backup. The current save file is first copied to a new backup ("Automatic copy before restore"), so every restore can be undone. Restoring needs write access, which is granted when the folder is registered.
* **Export**: a ZIP of the game's current save files in `GAMEBOX/Exports/`.
* **Import**: a GAMEBOX save ZIP is validated (same archive guard as downloads: no path traversal, size limits) and each entry overwrites the known save file with the same relative path, after a safety backup. Entries that don't match a known save file are reported and **not** written anywhere else.

## Library backup and restore

Settings → System:

* **Back up library**: `VACUUM INTO` writes a consistent copy of the live database (library, settings, play history, controller profiles, sources, downloads, compatibility data, benchmarks) to `GAMEBOX/Backups/library/gamebox_<time>.sqlite`.
* **Restore library…**: the chosen backup is checked (SQLite header) and **staged**. It's applied at the next start, before the database opens. The current database is kept as `gamebox.before-restore.sqlite`. Older backups are migrated to the current schema automatically on open.

The live database is `gamebox.sqlite` in the app's documents directory.
