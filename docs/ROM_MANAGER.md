# ROM Manager (Phase 2)

GAMEBOX only **references** game files. It never copies, moves, extracts or runs them, and it never downloads or bundles games.

## Where games come from

| Source | How | Permission |
|---|---|---|
| **GAMEBOX folders** | `Android/data/com.gamebox.console/files/GAMEBOX/Games/<CONSOLE>/` is created automatically on every mounted volume (internal, SD, USB) | none (app-specific storage) |
| **Registered folders** | STORAGE → *Add game folder* (Storage Access Framework tree); access persists across reboots | user grants per folder |
| **Manual import** | MY GAMES → *Import files* (system file picker, multi-select) | user grants per file |

## Scanning

* Runs at startup and whenever storage is connected or removed (debounced 3 s), if **Settings → Gaming → Auto scan** is on. It can also be started manually from MY GAMES or STORAGE.
* SAF folders are walked natively (`DocumentsContract`), breadth-first, up to 8 folder levels and 20,000 matching files per folder. Hidden entries are skipped. Only ROM, disc, archive and image extensions are listed.

### Console identification (`lib/core/rom/console_detector.dart`)

1. If the extension belongs to one console (`.sfc`, `.gba`, `.z64`, `.nds`, …), that console is used.
2. Shared extensions (`.iso`, `.bin`, `.chd`, `.cue`, `.cso`, …) are resolved from the **closest parent folder** name. GAMEBOX folder names and common aliases from other frontends are understood (`PSX`, `PlayStation`, `Genesis`, `GC`, `NGC`, `Dreamcast`, `DC`, …).
3. `.zip` and `.7z` are accepted only in folders of cartridge-era systems.
4. Anything else is **not guessed**: it's listed as "not recognised" in the scan details. During manual import, the user picks the console.

### Disc images (`scan_planner.dart`)

* Track files (`.bin`, `.raw`, `.img`, `.sub`, `.mdf`, `.ecm`) are skipped when a descriptor (`.cue`, `.gdi`, `.ccd`, `.mds`, `.m3u`) is in the same folder.
* `Game (Disc 1)`, `Game (Disc 2)` in one folder become **one game** with several files. An `.m3u` playlist becomes the primary file when present.

### Titles (`title_normalizer.dart`)

Bracketed tags are removed. Regions are kept separately (`(USA)`, `(Europe, Australia)`) and disc numbers are recognised. A trailing article is moved to the front (`Legend of Zelda, The` → `The Legend of Zelda`). Underscores, and dots in space-less names, become spaces. The sort title drops a leading article.

## Missing files vs. disconnected storage

* A file that is absent from a **readable** folder is marked missing. A game is missing when all its files are missing. When the file reappears, it's restored automatically.
* If a registered folder **can't be read** (USB unplugged, access revoked), its files are **not** marked missing. The scan details report the folder as unavailable instead.

## Integrity verification (`rom_header_validator.dart`)

| System | Check |
|---|---|
| NES | iNES / NES 2.0 `NES\x1A`, FDS, UNIF signatures |
| Game Boy / Color | Nintendo logo bytes + header checksum (0x14D) |
| GBA | fixed byte 0xB2 = 0x96 + header complement (0xBD) |
| N64 | z64 / v64 / n64 byte-order signature |
| NDS | header CRC16 (0x15E) |
| Mega Drive | `SEGA` system string at 0x100 (`.smd` interleaved: not checked) |
| Master System | `TMR SEGA` header (absent on some carts → "not checkable") |
| SNES | LoROM/HiROM checksum + complement pair (copier header allowed) |
| Disc formats | CHD, PBP, CISO, RVZ, WBFS signatures; ISO 9660, GameCube and Wii disc magic |

A format without a reliable signature is reported as **not checkable**, never as valid. Files ≤ 16 MB are hashed automatically (SHA-1 + CRC32) after import. Larger files are hashed with **Verify file** on the game page. **Duplicates**: identical SHA-1; without a hash, the same name and size count as a *possible* duplicate.

## Artwork (local only in Phase 2)

* During a scan, an image (`png`, `jpg`, `jpeg`, `webp`) anywhere in the scanned tree whose name matches the game becomes its cover. An image inside the same console's folder tree is preferred. Example: `GAMEBOX/Artwork/Covers/SNES/Demo World.png`.
* **Choose artwork** on the game page picks any image.
* Covers are decoded natively, downscaled to at most 600 px (RGB_565) and cached as JPEG in app storage, which keeps memory low on 2 GB devices.
* Online artwork and metadata scraping is Phase 5.

## Removing and deleting

* **Remove from library**: GAMEBOX forgets the game, and the file stays on storage. The next folder scan re-adds it if it's still in a scanned folder.
* **Delete files…**: two confirmations, then the files are deleted (SAF `deleteDocument` or `File.delete`). The library entry is removed only if every file was deleted.
