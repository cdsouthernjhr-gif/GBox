# Third-party licences

GAMEBOX is licensed under the **GNU General Public License v3.0** (see `LICENSE`), because its built-in player links LibretroDroid, which is GPLv3.

## Built-in player

| Component | Licence | Source |
|---|---|---|
| LibretroDroid 0.14.0 (libretro frontend library) | GPL-3.0-or-later | github.com/Swordfish90/LibretroDroid (tag `0.14.0`) |
| FCEUmm core (NES) | GPL-2.0 | github.com/libretro/libretro-fceumm |
| Snes9x core (SNES) | Snes9x licence: **non-commercial use only** | github.com/libretro/snes9x |
| Gambatte core (Game Boy / Color) | GPL-2.0 | github.com/libretro/gambatte-libretro |
| mGBA core (Game Boy Advance) | MPL-2.0 | github.com/libretro/mgba |
| Genesis Plus GX core (Mega Drive, Master System) | Genesis Plus GX licence: **non-commercial use only** | github.com/libretro/Genesis-Plus-GX |
| PCSX ReARMed core (PlayStation) | GPL-2.0 | github.com/libretro/pcsx_rearmed |

The core binaries are the prebuilt Android builds published by the Lemuroid project in github.com/Swordfish90/LemuroidCores at commit `fee2e824525daa22bcf318f96127fe43fa8a15ad`. `tool/fetch_cores.sh` downloads them at build time and verifies each file's SHA-256; they are not stored in this repository. Each core's source code is available from the repository listed above (and LemuroidCores documents how its builds are made).

Licence names are as published by each project; check the project for the authoritative terms. Because Snes9x and Genesis Plus GX forbid commercial use, **GAMEBOX builds that include them must not be sold.** The cores are loaded at run time as separate libretro plug-ins, the same way Lemuroid distributes them; this is a description of how the app is built, not legal advice.

## Other dependencies

See the dependency table in `README.md` (Flutter, drift, sqlite3, path_provider, crypto, archive, AndroidX: BSD-3-Clause, MIT, Apache-2.0).
