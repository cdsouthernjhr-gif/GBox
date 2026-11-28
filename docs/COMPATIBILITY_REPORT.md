# Compatibility report (0.17.0 baseline)

## Android versions

| Target in the 1.0 brief | 0.17.0 reality | Evidence |
|---|---|---|
| Android 6 (API 23) | **Not supported.** APKs declare `minSdkVersion 24` | `aapt2 dump badging` in CI on every APK; Flutter 3.47 `FlutterExtension.minSdkVersion = 24`; an earlier attempt with `minSdk = 23` still produced 24 (value injected by the variant) |
| Android 7.0 (API 24) | Supported | CI on the API 24 google_apis x86_64 emulator: unit/integration tests, HOME/BACK checks, built-in player (FCEUmm) in debug and release |
| Android 10–13 | Not tested in CI | — |
| Android 14 (API 34) | Supported | CI on the API 34 google_apis x86_64 emulator, same checks |
| Android 15–16 | Not tested; targetSdk is 36 | — |

### What Android 6 would take

Flutter 3.47 and its engine are supported on API 24+. Android 6 needs a **separate legacy build line**:
* an older Flutter that still supported API 23, with a matching AGP, Kotlin and Gradle;
* drift, sqlite3, path_provider and jni re-pinned to versions that build there;
* the Dart code kept compatible with that older Dart. 0.17.0 uses Dart 3.x features such as null-aware elements and private named parameters, which need a recent Dart.

In practice this is a fork of the app with its own test matrix.

Alternatives:
* **(a) accept Android 7.0** as the floor: recommended, documented;
* **(b) the legacy line**, only if real API 23 boxes are in use.

Either way, an API 23 emulator run must prove it before "Android 6" is claimed.

## CPU architectures

| ABI | 0.17.0 APK | Cores | Tested |
|---|---|---|---|
| arm64-v8a | ✓ | all 9 | **No physical device yet** |
| armeabi-v7a | ✓ | all 9 (PPSSPP included) | **No physical device yet** |
| x86_64 | ✓ (for emulators/PC) | 8 (no PPSSPP) | CI emulators (API 24, 34) |

ARM32 is built and packaged, but untested. The brief's "ARM32 only if all native dependencies support it" is met at the packaging level: every native library exists for v7a.

## Form factors and input

| Item | Status |
|---|---|
| TV (leanback launcher, banner, D-pad) | Leanback filter present (`aapt2`: `leanback-launchable-activity`); layout tested at 1920×1080 in CI. No Android TV image boots in CI (API 30 TV image is 32-bit x86, which Flutter doesn't support; API 34 TV x86_64 didn't boot) |
| Touch (phones/tablets) | Touch on all screens; on-screen controls in the player. Landscape forced; no bottom navigation and no portrait layout |
| Gamepads (Bluetooth/USB) | Detection, mapping and per-port input in the player. **PENDING on hardware** |
| TV remotes | D-pad navigation, BACK behaviour, Menu = Start in the player. **PENDING on hardware** |
| `uses-feature` | gamepad, touchscreen and leanback all `required=false` |

## Storage

| Item | Status |
|---|---|
| Internal storage with "All files access" (Android 11+) | Implemented; CI grants it with appops. PENDING on hardware (some boxes lack the settings screen, so an adb command is documented) |
| SAF folders (USB/SD) | Implemented, unit-tested with fakes. PENDING on hardware |
| App folder (no permission) | Implemented; external emulators on Android 11+ can't read it, which the UI explains |

## What "tested" means here

Only the following has run on a real Android build:
* the app on API 24 and API 34 x86_64 emulators in GitHub Actions;
* the built-in player with FCEUmm and a synthetic NES image.

**Not yet run on a phone, tablet or TV box:**
* any other core;
* any external emulator launch;
* any physical controller, remote or USB/SD storage.

These remain PENDING in TESTING_GUIDE.md and must stay marked so until a device test is reported.
