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

## Library location and folder layout (0.9.0)

STORAGE → **GAMEBOX library location** chooses where the GAMEBOX folder lives:

| Location | Kept when GAMEBOX is uninstalled | RetroArch / path-only emulators (Android 11+) | Emulators can write saves there |
|---|---|---|---|
| App folder `Android/data/com.gamebox.console/files/GAMEBOX` (default) | no | no | no |
| **Public folder** picked with the system folder picker (recommended), e.g. `Internal storage/GAMEBOX` or a folder on a USB drive / SD card | yes | yes (folder on primary storage resolved to a path) | yes |

In the picker, create a folder named `GAMEBOX` and select it. GAMEBOX takes persistent read/write access (no broad storage permission), creates the layout and adds the folder to the game folders.

Layout (`lib/core/storage/gamebox_layout.dart`), created automatically at startup and with **Create missing folders**:

```
GAMEBOX/
  Games/<CONSOLE>/                 NES, SNES, …, PS1, PS2, WII
  Artwork/Covers|Screenshots|Backgrounds
  Saves/RetroArch/saves|states, Saves/PPSSPP, Saves/DuckStation, … (one per emulator)
  BIOS/PS1|PS2|SATURN|DREAMCAST|NDS|GBA|GAMECUBE, BIOS/RetroArch
  Backups/  Downloads/  Exports/
```

**Downloads are sorted automatically:** a finished download whose console is known (catalogue, chosen when adding, or a unique file extension) is moved into `Games/<CONSOLE>/` and imported there. A ZIP is extracted into `Games/<CONSOLE>/<archive name>/` (keeping its folders) when its console is known or all games inside are of one console; the ZIP is then deleted. Existing files are never overwritten (`name (2).ext`). Files whose console can't be determined wait in `Downloads/` until you choose the console (Downloads → *Import into library*); they are moved then. Downloads are always written to the app folder first and moved after verification.

The library scan skips `BIOS/` folders (anywhere) and GAMEBOX's `Saves/`, `Backups/` and `Exports/`, so BIOS `.bin` dumps are never imported as PS1 games.

**Removing** the library folder from *Registered game folders* only stops scanning it; its access is kept while it is the library location.

Implementation: native `ensureTreeDirs`, `writeToTree` (creates the folder path, picks a free name, never overwrites) and `listTreeNames`, plus `scanTree(subPath:)` in `RomFiles.kt`. **These SAF operations are unit-tested against a simulated tree only; on-device verification with a real folder picker is PENDING** (TESTING_GUIDE step 20).
