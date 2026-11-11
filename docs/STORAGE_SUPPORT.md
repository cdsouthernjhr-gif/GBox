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

## Pending

Moving files between volumes and backup/restore (Phases 4 and 7).
