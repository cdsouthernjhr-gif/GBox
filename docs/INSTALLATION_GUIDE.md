# Installation guide

1. Download the APK that matches the box from the CI artifact **gamebox-apks**:
   * `app-arm64-v8a-release.apk` for 64-bit Android (Settings → Device information in GAMEBOX shows `arm64-v8a` under ABIs),
   * `app-armeabi-v7a-release.apk` for 32-bit Android (very common on budget boxes, even with 64-bit CPUs),
   * `app-debug.apk` is universal but larger and slower.
2. Copy it to the box (USB drive, or `adb install <file>.apk`) and install it with a file manager. Allow "install unknown apps" for that file manager.
3. Open **GAMEBOX** from the app list or the TV apps row.
4. To make it the console home screen: **Settings → Default HOME app → Set as default**. Android shows its own chooser or Home settings.
5. To undo: **Settings → Default HOME app → Change**, or Android Settings → Apps → Default apps → Home app. You can always reach Android Settings from GAMEBOX (Settings or ANDROID APPS). No root, firmware change or device-owner mode is used.

Note: some Google TV builds ignore third-party HOME apps. GAMEBOX then works as a normal app (see KNOWN_LIMITATIONS).
