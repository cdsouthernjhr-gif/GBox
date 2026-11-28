# GAMEBOX 1.0 upgrade plan

Strategy: **preserve and upgrade** 0.17.0. Every phase:
1. ships as a pre-release (0.18 → 1.0);
2. keeps the package id `com.gamebox.console` and the signing key;
3. keeps the database, ROM, save and settings paths;
4. passes `flutter analyze`, all tests and the CI device tests before it is published.

Each phase ends with a report: completed, incomplete and known issues. Hardware tests stay PENDING until a device run is reported.

## Decisions (approved 2026-11-28)

All recommendations below were approved by the owner:
* **D1:** Android 7.0 (API 24) is the 1.0 floor; Android 6 is out of scope.
* **D2:** integer keys stay; `uuid` columns are added; new tables use UUID keys.
* **D4:** dashboard sections go in HOME; the menu keeps 6 entries.
* **D3 and D5–D12:** as written.


The brief leaves these open, or asks for something the audit found impossible or risky. Each has a recommendation.

| # | Decision | Recommendation | Why |
|---|---|---|---|
| D1 | Android floor | **Keep Android 7.0 (API 24)**; drop "Android 6" from 1.0 unless real API 23 boxes must be supported | Flutter 3.47 supports API 24+. Android 6 means a second app on an older toolchain ([COMPATIBILITY_REPORT.md](COMPATIBILITY_REPORT.md)) |
| D2 | UUID keys | **Keep integer keys on existing tables, add `uuid` columns; new tables get UUID keys** | Rebuilding every table and foreign key is the migration most likely to lose user data ([DATABASE_AUDIT.md](DATABASE_AUDIT.md)) |
| D3 | Profiles | **One shared library; per-profile favourites, history, saves, controller and emulator settings; a default profile created from today's data** | Same ROM files for everyone; nothing existing is hidden or lost |
| D4 | Dashboard | **Keep the 6-entry menu from 0.15.0.** Add the 1.0 sections to HOME: a compact status strip (controllers, storage, system) and a Quick Actions row. No separate dashboard | 0.15.0 removed the dashboard at your request because it duplicated HOME and GAMES |
| D5 | Mobile layout | **Bottom navigation and portrait support on phones; side menu on TV and tablets in landscape** | As the brief asks; TV stays as now |
| D6 | Arcade / Neo Geo | **Add FBNeo** (Neo Geo + arcade) as a built-in core; MAME 2003-Plus optional | Both exist at the pinned LemuroidCores commit for all ABIs; both are non-commercial like Snes9x |
| D7 | Netplay | **Not in 1.0** for the built-in player. Local multiplayer (assign controllers to players 1–4) **yes** | LibretroDroid 0.14.0 has no netplay API. RetroArch's own netplay can't be driven by GAMEBOX through a documented intent. Faking it is excluded by the brief |
| D8 | Achievements | **Local achievements only** (playtime, collection, milestones, custom). No RetroAchievements | LibretroDroid has no rcheevos integration. RetroAchievements also needs a user account and its API terms |
| D9 | "Downloadable emulator packages" | **Versioned manifest of official links (Play Store / developer site) and of optional resources (themes, artwork)**. No APK download or install by GAMEBOX | Installing APKs needs REQUEST_INSTALL_PACKAGES, which is a Play policy and safety risk. The brief already demands explicit confirmation; links avoid it entirely |
| D10 | Theme names | **Neutral names** for the console-inspired themes (e.g. "Retro Grey", "16-bit Blue", "Classic Red") instead of "PlayStation Retro", "Nintendo Classic", "Sega Genesis" | Trademarked names could suggest an affiliation |
| D11 | Metadata providers | **Adapter layer.** Built-in: libretro-thumbnails (covers, screenshots, title screens) + local editing. Optional: ScreenScraper with the **user's own** account | Other providers need personal API keys and have terms of use |
| D12 | Built-in save slots | **10 slots per game** with screenshot, core name/version and checksum in the database; the current single `.state` becomes slot 0 | Keeps existing states loadable |

## Phase 1: new UI, baseline protected (target 0.18)

1. **Database v6** (only what Phase 1 needs):
   * automatic pre-migration backup;
   * integrity checks;
   * `uuid` columns;
   * `profiles` + default profile, with `profile_id` on favourites and history;
   * migration tests v1…v5 → v6 with data, plus a failure-injection test.
2. **Modern Retro theme.** Dark navy background, electric blue focus, purple secondary, orange Play buttons. It becomes the new default theme; the existing themes stay selectable.
3. **HOME:**
   * Continue playing, My systems (Console Library), Recently played, Favourites;
   * Quick Actions (Add games, Find ROMs, Settings, Controllers);
   * status strip (controllers, storage, system).
   Every tile does something.
4. **Responsive layout.** TV: side menu, as now. Phones: bottom navigation, portrait support, responsive grid, search on GAMES.
5. **Regression tests** for every row of [EXISTING_FEATURES.md](EXISTING_FEATURES.md) that lacks one, plus a TV-navigation test and a mobile-layout test.
6. **CI additions:**
   * LOAD-segment alignment check;
   * build-ID check of the packaged cores;
   * removal of `ppsspp.zip` from the x86_64 APK.

## Phase 2: consoles, library, ROMs, metadata, arcade (target 0.19–0.20)

1. **Console definitions** become data (built-in table + user systems in the database). Each definition carries:
   * default emulator and supported cores;
   * BIOS requirement and artwork;
   * availability status: playable built-in / needs app / not playable.
   Unsupported systems are never shown as playable.
2. **Systems:**
   * Neo Geo and Arcade with FBNeo (built-in, D6);
   * Atari only where a verified core exists. It is checked first; if none passes, it is listed as "needs app".
3. **ROM manager:**
   * SHA-256 next to SHA-1;
   * batch import;
   * arcade ZIP handling (archives are not extracted for arcade: the set *is* the ZIP).
4. **BIOS manager:**
   * inventory per core;
   * known-hash verification where hashes are published;
   * missing-BIOS warnings before launch;
   * user-controlled import (copy into `GAMEBOX/BIOS/<console>`). No downloads.
5. **Metadata adapters (D11):**
   * screenshots / title screens from libretro-thumbnails;
   * image cache;
   * manual matching;
   * refresh.

## Phase 3: emulator manager and save manager (target 0.21–0.22)

1. **Unified emulator manager.** One list of built-in cores, known apps and user apps, showing:
   * version and installation status;
   * core availability;
   * per-game emulator choice (the existing `preferred_emulator_id` column);
   * compatibility notes.
2. **Saves:**
   * 10 slots in the built-in player (D12);
   * save records in the database (profile, core and version, checksum);
   * automatic backup before overwrite and before restore;
   * restore with verification, free-space check and confirmation;
   * export/import to USB/SD.
   Save states are marked as tied to the core version they were made with.

## Phase 4: profiles, controllers, local multiplayer (target 0.23–0.24)

1. **Profiles:**
   * create, edit, delete (blocked while saves exist unless exported);
   * avatar and theme;
   * switching never touches another profile's saves.
2. **Controller profiles** per profile and per console, with reset to default.
3. **Local multiplayer:**
   * a player-assignment screen (players 1–4) before starting a game;
   * the built-in player maps controllers to ports from that assignment.
   Netplay stays out (D7).

## Phase 5: performance and themes (target 0.25)

1. **Performance presets** (Low / Balanced / High), mapped to existing core options (resolution, frameskip) and display filters. FPS is shown only where LibretroDroid exposes frame events. No continuous background benchmark.
2. **Themes (D10):**
   * the seven themes;
   * wallpaper, accent and card layout options;
   * icon size;
   * optional navigation sound and background music (off by default);
   * one switch that turns off all non-essential animation and sound.
3. **Local achievements (D8).**

## Phase 6: compatibility, regression, 1.0 release

1. Full regression suite, migration tests from every published schema, and backup/restore tests.
2. CI device runs on API 24 and 34. Where freely licensed test images exist, run them for more cores (the brief's "never mark complete because a screen exists").
3. **Device test pass on real hardware** by you: one ARM64 phone, one ARM32 or ARM64 TV box, one controller. Results go into TESTING_GUIDE.md. Without it, 1.0 is published as a pre-release.
4. Deliverables:
   * APKs;
   * release notes, build report, test report, migration report;
   * installation and rollback instructions.
   v0.17.0 and every earlier release stay untouched.

## What will not be claimed

Nothing is described as working until it has run. Specifically:
* "Android 6": unless D1 changes and an API 23 run passes;
* "netplay" and "RetroAchievements";
* "ARM32 tested" or "TV tested": until devices report it;
* any core as "playable": until it renders frames in CI or on a reported device.
