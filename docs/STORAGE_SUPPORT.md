# Storage support

## Detection (Phase 1)

* Mounted volumes come from `Context.getExternalFilesDirs(null)`, which needs no permission and works on API 23. Capacity comes from `StatFs`.
* On API 24+, descriptions and unmounted/removed volumes come from `StorageManager.getStorageVolume(s)`.
* GAMEBOX doesn't assume any mount path (`/storage/XXXX-XXXX`, `/mnt/usb`, …). Paths are shown for information only.
* USB vs SD is inferred from the system's volume description (e.g. "USB drive", "SD card"). Otherwise it's shown as *Type UNKNOWN*.
* `ACTION_MEDIA_MOUNTED/UNMOUNTED/REMOVED/BAD_REMOVAL/EJECT` broadcasts trigger a rescan and a notification. Volumes missing from a scan are marked disconnected in `storage_devices`.

## Access (Phase 1)

* **Add game folder** opens `ACTION_OPEN_DOCUMENT_TREE`. The chosen tree URI gets `takePersistableUriPermission`, so access survives reboots, and is saved in settings.
* Removing a folder releases the permission. It **never deletes files**.
* No broad storage permission (`MANAGE_EXTERNAL_STORAGE` / `READ_EXTERNAL_STORAGE`) is requested.

## Known issue

Some Android TV firmwares ship **without the DocumentsUI folder picker**. GAMEBOX detects this (`saf_unavailable`) and tells the user. Alternatives are in KNOWN_LIMITATIONS.md.

## Game scanning (Phase 2)

See [ROM_MANAGER.md](ROM_MANAGER.md): GAMEBOX folders on every volume, recursive SAF scanning, missing vs. disconnected detection, automatic rescan when storage is connected.

## Game folder, setup wizard and ROM search (0.10.0)

Feedback on 0.9.0 (phone + RetroArch): **Play failed and RetroArch's own menu was empty.** Cause: games lived in GAMEBOX's app folder (`Android/data/…`), which RetroArch can't read on Android 11+, a public folder had to be picked by hand, and RetroArch only lists games it scanned itself. 0.10.0 changes the model:

**Layout** (`lib/core/storage/gamebox_layout.dart`), relative to a *base*:

```
<base>/
  ROMs/nes, snes, mastersystem, megadrive, gb, gbc, gba, psx, n64,
       saturn, nds, psp, dreamcast, gc, ps2, wii      ← games
  GAMEBOX/Saves/<Emulator>/…, BIOS/<CONSOLE>/, BIOS/RetroArch/,
          Playlists/, Artwork/, Backups/, Downloads/, Exports/
```

`ROMs/<system>` uses the folder names of ES-DE, RetroPie and Daijishou, so other frontends find the same games. The old names (`NES`, `PS1`, `GAMEBOY`, …) are still recognised.

**Base**, chosen automatically:

| Mode | When | Base | RetroArch can read | Kept on uninstall |
|---|---|---|---|---|
| Shared storage (recommended) | storage access granted | `/storage/emulated/0` (Internal storage) | yes | yes |
| Picked folder | user chose a folder (e.g. on USB) | that folder (SAF) | yes, if on primary storage or the emulator accepts it | yes |
| App folder | no access | `Android/data/com.gamebox.console/files` | **no** (Android 11+) | no |

**Storage access:** Android 11+ "All files access" (`MANAGE_EXTERNAL_STORAGE`, opened from the wizard; GAMEBOX is distributed as an APK, not through Play); Android 7–10 the storage permission (`requestLegacyExternalStorage` for Android 10). Some Android TV firmwares have no "All files access" screen: the wizard then shows `adb shell appops set --uid com.gamebox.console MANAGE_EXTERNAL_STORAGE allow`, or the user picks a folder instead. Returning from the settings screen re-checks access and, when granted, creates the folders, registers save folders and scans.

**Setup wizard** (dashboard banner until finished; STORAGE → Setup wizard), each step with ✓/✗ and one action:
1. Allow storage access (or pick a USB/SD folder).
2. Put games in `ROMs/`: *Find ROMs on this device*, and *Move N games to ROMs* for games still in the app folder.
3. Get RetroArch ready: install cores (Online Updater → Core Downloader), allow its storage access, write playlists, open RetroArch.
4. Optional: BIOS still needed, save folders.

**Find ROMs on this device** (`rom_search_service.dart`) walks every volume's shared storage (skipping `Android/`, media folders, emulator data such as `system`, `saves`, `states`, BIOS folders and `ROMs/` itself; max depth 12, 30,000 candidate files). Recognition: the file's header first (NES, GB/GBC, GBA, N64, Mega Drive, PSP "PSP GAME" / PS2 "PLAYSTATION" ISO volume ids, GameCube/Wii disc magic, …), then a unique extension or the folder name. Files under 8 KB, and archives or track files that nothing identifies, are ignored. Ambiguous files (e.g. `.iso` without a recognisable header) are listed under *Needs a console*. `.cue`/`.gdi` games carry the track files they reference. Results are grouped by console (biggest group first) with the destination folder, a selected count and All/None per console; before copying or moving, a summary shows games and size per console, total, free space and the mode, and blocks copies that would leave less than 50 MB free (0.12.2). **Copy** (default; original kept) or **Move** puts each game in `ROMs/<system>/` (multi-file games in `ROMs/<system>/<name>/`), never overwriting, and adds it to the library. Files already in the library, or copied there before (same name and size), aren't offered again.

**Move games to ROMs** (`roms_migration_service.dart`) moves every library game whose files are in the app folder (0.9.0 `GAMEBOX/Games/<CONSOLE>`, `ROMs/` of the app folder, old downloads) into `ROMs/<system>/` and updates the library entry in place, so history, favourites, artwork and saves stay linked.

**Downloads** are moved into `ROMs/<system>/` of the current base when the console is known or detectable (ZIPs of one console extracted into `ROMs/<system>/<name>/`); others wait in `GAMEBOX/Downloads/` until the console is chosen.

The library scans `ROMs/` of shared storage (and of removable volumes that have one), the app folder, and picked folders. `BIOS` folders anywhere and GAMEBOX's `Saves/`, `Backups/`, `Exports/`, `Playlists/` are skipped, so BIOS dumps are never imported as games.

**Verification:** unit-tested with temporary folders laid out like Android storage and a simulated SAF tree (`test/library_location_test.dart`). The emulator CI checks the layout on Android 7 and 14 *without* storage access (app folder). "All files access", the shared `ROMs/` folder and RetroArch reading it are **PENDING on a real device** (TESTING_GUIDE step 20).
