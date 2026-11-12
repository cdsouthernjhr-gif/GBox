# Online sources and downloads (Phase 5)

GAMEBOX ships **no game sources**. The user adds them. Only content the user is allowed to download is supported: homebrew, public-domain games, and the user's own files. GAMEBOX never scrapes websites, never bypasses logins, DRM or paywalls, and **never executes downloaded files**.

## Source types

| Type (spec Part 12) | Connector | What the URL must be |
|---|---|---|
| Direct download URL | `direct_url` | a direct link to one file |
| Authorised game distribution website | `direct_url` | a direct file link (not the web page) |
| Personal cloud storage | `direct_url` | a public/shared direct file link |
| User-owned file hosting | `direct_url` | a direct file link |
| Authorised homebrew repository | `gamebox_catalog` | a GAMEBOX catalogue (JSON) |
| Public-domain game repository | `gamebox_catalog` | a GAMEBOX catalogue (JSON) |
| Custom documented HTTP API | `gamebox_catalog` | an endpoint returning a GAMEBOX catalogue |

Adding a source requires confirming *"I am allowed to download the games this source offers"*. **Check connection** probes the URL (HEAD, falling back to a 1-byte GET) and stores the status and time. A `text/html` answer is flagged as a web page.

Sources that need a login aren't supported in this phase. URLs with embedded credentials are refused.

## GAMEBOX catalogue format (v1)

```json
{
  "format": "gamebox-catalog",
  "version": 1,
  "name": "Example Homebrew Collection",
  "games": [
    {
      "title": "Pixel Quest",
      "console": "nes",
      "url": "https://example.org/files/pixel-quest.nes",
      "license": "CC-BY-4.0",
      "size": 40976,
      "sha256": "64 lowercase hex characters",
      "description": "Optional.",
      "developer": "Optional.",
      "year": "2025",
      "cover": "https://example.org/files/pixel-quest.png"
    }
  ]
}
```

* `license` is **optional** (since 0.8.1). Entries without it are listed as **"Licence not stated"**. Before such an entry is downloaded, GAMEBOX asks you to confirm that you own the game, that the developer offers it as a free download, or that downloading it is otherwise legal for you. GAMEBOX can't check this, so the responsibility is yours. Imported games get "Licence not stated by the source" in their description.
* Everything else is unchanged: HTTPS only, no embedded credentials, web pages and executables refused, SHA-256 and size checks, safe ZIP extraction. GAMEBOX still doesn't scrape web pages or bypass logins, DRM or paywalls.
* `console` must be a GAMEBOX console id (`nes`, `snes`, `sms`, `megadrive`, `gb`, `gbc`, `gba`, `ps1`, `n64`, `saturn`, `nds`, `psp`, `dreamcast`, `gamecube`, `ps2`, `wii`).
* `url` and `cover` must be `https://`. `sha256`, when given, is verified, and a mismatch deletes the file.
* Catalogue size limit: 2 MB.

Catalogue entries supply **metadata** on import: title, description (with the licence appended), developer, year and cover. Metadata the user edited manually is never overwritten.

## Download engine safeguards

| Risk | Protection |
|---|---|
| Insecure transport | HTTPS only; certificates verified by the platform (never disabled) |
| Malicious redirects | Max 5; every hop re-validated; https → http downgrade refused |
| Scraping | `text/html` responses refused |
| Executables | `.apk`, `.exe`, `.so`, `.dex`, `.jar`, `.sh`, … refused; only game, archive, image and JSON files allowed |
| Path tricks in names | `Content-Disposition`/URL names reduced to one safe component; unique name if it already exists |
| Huge files / full storage | Max size setting (1–16 GB); free space checked before starting (50 MB margin) |
| Corruption | Size checked against `Content-Length` / catalogue; SHA-256 computed while streaming |
| Interrupted transfers | `.part` file kept; resumed with HTTP `Range`; servers without range support restart from 0 |
| Network errors | 3 automatic retries with back-off (2 s, 4 s, 8 s), then *failed* (manual Retry) |
| Stalled connections | 20 s connect timeout, 30 s idle timeout |

## ZIP archives

Before anything is written, the central directory is checked. Archives are refused if they contain:

* absolute paths, drive letters, `..` components or backslash tricks;
* symbolic links;
* more than 2,000 entries, any entry over 4 GB, more than 8 GB in total, or a compression ratio over 200:1 on entries over 1 MB (archive bombs).

During extraction the bytes actually written are counted again, so a lying header is caught too and the extraction is undone. Files are extracted to `<download>_files/` and imported with folder-based console detection. `.7z` isn't extracted.

## Queue behaviour

* One download at a time. Order: oldest first.
* **Offline**: queued items wait and start automatically when the network is back.
* **While playing** (Settings → Downloads, on by default): the active download pauses when a game launches and continues when you return to GAMEBOX.
* Downloads interrupted by an app restart resume from the `.part` file.
* **Auto import** (on by default): finished downloads with a known console (catalogue entries, or a console chosen when adding) are added to the library. Otherwise use *Import into library* and pick the console.
* Files go to `GAMEBOX/Downloads/` in app storage on the primary volume.
* Downloads run while the GAMEBOX process is alive. There's no foreground service yet, so Android may stop a long download if GAMEBOX stays in the background for a long time. It resumes from the partial file when GAMEBOX runs again.

## Metadata providers

Online scrapers (ScreenScraper, TheGamesDB, IGDB, …) need personal API keys and have their own terms, so none is built in. Metadata comes from catalogue entries and manual editing (game page → Edit info). Cached data is used offline.
