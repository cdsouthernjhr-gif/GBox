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

### Suggested save folders (0.9.0)

GAMEBOX can't change where an emulator saves; each emulator has its own setting. STORAGE → **Emulator save folders** shows one suggested folder per emulator inside the GAMEBOX folder and how to point the emulator at it:

| Emulator | Folder | How |
|---|---|---|
| RetroArch | `Saves/RetroArch/saves`, `Saves/RetroArch/states` | Settings → Directory → Save Files / Save States |
| PPSSPP | `Saves/PPSSPP` | Settings → System → Memory Stick folder (saves then live in `PSP/SAVEDATA` inside it) |
| DuckStation, Mupen64Plus FZ, melonDS, DraStic, Flycast, Redream, Dolphin, AetherSX2 | `Saves/<name>` | generic advice: use the emulator's save/memory-card/data folder setting if it has one; menu names differ between versions, so none are claimed |

With a **public** library folder, the folders of installed emulators are registered with the Save Manager automatically (at startup and when the folder is chosen). They're stored as `<tree URI>#Saves/<Emulator>`, and only that part of the tree is scanned. With the app folder, register them by hand with **Register for installed emulators**; note that on Android 11+ emulators can't write into the app folder, so use a public folder for saves.

Backups (`Backups/saves`) and exports (`Exports/`) are still written to the app folder.

### BIOS (0.9.0)

GAMEBOX never provides BIOS files. STORAGE → **BIOS** lists `BIOS/<CONSOLE>/` per console, which file names the emulators commonly look for (e.g. `scph5501.bin` for RetroArch Beetle PSX, `dc_boot.bin` for Flycast), whether one is present, and whether it's required or optional (built-in replacement available). Point the emulator at that folder; for RetroArch set Settings → Directory → System/BIOS to `BIOS/RetroArch` and copy the files there (Dreamcast files in `dc/`). File names come from the emulators' documentation as commonly published; check your emulator's documentation if one isn't recognised.

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
