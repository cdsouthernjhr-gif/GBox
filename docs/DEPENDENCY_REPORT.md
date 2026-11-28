# Dependency report (0.17.0 baseline)

Versions are taken from `pubspec.lock`, the Gradle files, `tool/fetch_cores.sh` and the published APKs.

## Toolchain

| Component | Version | Notes |
|---|---|---|
| Flutter | 3.47.9 stable | `FlutterExtension.minSdkVersion = 24`: the default and supported Android floor of this Flutter release |
| Dart | 3.13.7 | Uses Dart 3.x features (records, patterns, null-aware elements, private named parameters) |
| Android Gradle Plugin | 9.1.0 | |
| Kotlin | 2.4.0 | JVM target 17 |
| Gradle | 9.3.1 | |
| compileSdk / targetSdk | 36 / 36 | From Flutter defaults |
| minSdk | 24 | Verified with `aapt2 dump badging` (CI) on all APKs |
| NDK | Flutter default | No native code is compiled by this project; cores are prebuilt |

## Dart packages (runtime)

| Package | Resolved | Use | Android floor |
|---|---|---|---|
| drift | 2.35.4 | SQLite ORM, streams, migrations | — |
| drift_flutter | 0.3.1 | Opens the database on Android (bundles SQLite via `sqlite3`) | — |
| sqlite3 (transitive) | 3.5.2 | Native SQLite (`libsqlite3.so`, built by native-assets hooks) | Not documented; tested on API 24 |
| sqlite3_flutter_libs (transitive) | 0.6.0+eol | End-of-life stub (SQLite now comes from `sqlite3` hooks) | — |
| path_provider / _android | 2.1.6 / 2.3.1 | App directories (uses `jni`) | — |
| jni / jni_flutter (transitive) | 1.1.2 / 1.0.4+1 | `libdartjni.so` | minSdk 21 |
| path | 1.9.1 | Path utilities | — |
| crypto | 3.0.8 | SHA-1, SHA-256 | — |
| archive | 4.6.0 | ZIP extraction (with traversal/size guards) | — |

Dev: flutter_lints 6.0.0, drift_dev 2.35.3, build_runner 2.17.1, integration_test (SDK).

**No other packages:**
* no state-management framework;
* no HTTP client package (Dart's `HttpClient` is used);
* no image or network caching package;
* no Firebase or analytics.

## Android libraries (Gradle)

| Library | Version | Licence | Use |
|---|---|---|---|
| com.github.Swordfish90:LibretroDroid | 0.14.0 (JitPack, group-restricted repository) | GPL-3.0 | Built-in player (`GLRetroView`). Its own minSdk is 21 |
| androidx.core:core | 1.13.1 | Apache-2.0 | FileProvider |
| androidx.activity:activity-ktx | 1.9.3 | Apache-2.0 | PlayerActivity (ComponentActivity) |
| androidx.lifecycle:lifecycle-runtime-ktx | 2.8.7 | Apache-2.0 | `lifecycleScope` in the player |

R8 keep rules (`android/app/proguard-rules.pro`) cover the following, and CI fails if the R8 mapping renames them:
* `com.swordfish.libretrodroid.**`;
* LifecycleObserver methods;
* `com.gamebox.console.player.**`.

## Native binaries in the APKs (0.17.0)

| Library | arm64-v8a | armeabi-v7a | x86_64 | Source |
|---|---|---|---|---|
| libflutter.so, libapp.so | ✓ | ✓ | ✓ | Flutter |
| libsqlite3.so | ✓ | ✓ | ✓ | sqlite3 package |
| libdartjni.so | ✓ | ✓ | ✓ | jni package |
| liblibretrodroid.so | ✓ | ✓ | ✓ | LibretroDroid |
| 8 cores (FCEUmm, Snes9x, Gambatte, mGBA, Genesis Plus GX, PCSX ReARMed, Mupen64Plus-Next GLES3, DeSmuME) | ✓ | ✓ | ✓ | LemuroidCores `fee2e82…` |
| PPSSPP core | ✓ | ✓ | — (no build) | LemuroidCores |
| assets/ppsspp.zip (11.5 MB) | ✓ | ✓ | ✓ (unused) | LemuroidCores |

All native libraries in the arm64-v8a and armeabi-v7a APKs have LOAD segments aligned to at least 16 KB (0x4000, or 0x10000 for Flutter). This was checked with `readelf -l` on the published 0.17.0 APKs during this audit. **CI does not check alignment**; a CI step is proposed in UPGRADE_PLAN.

## Risks and constraints for 1.0

1. **Android 6 (API 23) is outside Flutter 3.47's supported range.** Supporting it means one of these, each with a large cost ([COMPATIBILITY_REPORT.md](COMPATIBILITY_REPORT.md)):
   * a second build line on an older Flutter, AGP and Kotlin, with every package re-pinned to versions that still build there; or
   * accepting Android 7.0 as the floor.
2. **JitPack availability.** LibretroDroid is fetched from JitPack at build time. An outage blocks builds, as happened with Gradle network blips.
   * Mitigation: mirror the AAR in the repository, or in a cache step.
3. **Cores are prebuilt binaries** from a third-party repository, pinned by commit and SHA-256. New cores (FBNeo, MAME 2003-Plus) follow the same path. Adding them requires:
   * checksums;
   * 16 KB alignment checks;
   * licence notes (both are non-commercial).
4. **New packages for 1.0** (for example UUID generation, image caching, audio for background music) must each be checked for Android 7.0 support and licence before they are added.
   * UUID v4 can be generated with `dart:math` `Random.secure()`, so no package is needed.
