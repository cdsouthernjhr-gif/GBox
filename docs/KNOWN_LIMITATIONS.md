# Known limitations

## Platform / build

* **Android 6.0 (API 23):** the APK declares `minSdk 23`. Flutter 3.47 officially supports API 24+ and prints a warning at 23. Android 6.0 support is **unverified** until the APK is run on an API 23 device. If the engine fails there, the fallback is an older Flutter release that supported API 23, which would mean re-validating every dependency.
* **No device testing yet:** Phase 1 was built and tested without an Android device or emulator. All hardware-dependent behaviour is PENDING (see TESTING_GUIDE).
* **Release signing:** without `key.properties`, the release APK uses the debug key.
* The dev container couldn't download the Android SDK (`dl.google.com` blocked), so APKs are built in GitHub Actions only.

## Launcher

* Google TV (Chromecast with Google TV, some newer operator builds) may not honour third-party HOME apps.
* Some firmwares hide `ACTION_HOME_SETTINGS`. GAMEBOX then opens Default apps settings or the main Settings.
* No kiosk or lock-task mode; that is out of scope unless explicitly requested.

## Hardware detection

* SoC name is often unavailable before Android 12 and on some kernels. It's then shown as UNKNOWN or as the generic `Hardware` string (e.g. "Amlogic").
* CPU max frequency may be unreadable due to SELinux.
* Bus type of controllers (USB/Bluetooth/receiver) isn't exposed by public APIs.
* USB vs SD classification relies on the system's volume description.
* Vulkan isn't detectable via the platform on API 23 and is reported as not available.
* Tier and ratings are **estimates**: the GPU table covers common TV-box GPUs only, and unknown GPUs fall back to GLES/Vulkan level.

## Storage

* Firmwares without DocumentsUI can't register folders through SAF. Planned alternatives: the app-specific folder `Android/data/com.gamebox.console/files/` (always accessible), or a guided `adb` setup.

## Not yet implemented (by phase)

ROM import/scanning, artwork, search (Phase 2) · game launching (Phase 3) · button mapping, profiles, calibration (Phase 4) · online sources, downloads, scraping (Phase 5) · additional emulators (Phase 6) · save manager, backups, benchmarks, compatibility import/submission, custom image wallpapers, temperature/CPU/FPS monitoring (Phase 7) · languages other than English.
