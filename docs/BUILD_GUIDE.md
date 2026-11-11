# Build guide

## Toolchain (as used for Phase 1)

| Tool | Version | Note |
|---|---|---|
| Flutter | 3.47.9 stable (Dart 3.13.7) | pinned in CI |
| JDK | 17 (CI) / 21 (dev container) | AGP 9 needs 17+ |
| Android Gradle Plugin | 9.1.0 | from the Flutter template |
| Kotlin | 2.4.0 | |
| Gradle | 9.3.1 (wrapper) | |
| compileSdk / targetSdk | 36 / 36 | Flutter defaults |
| minSdk | **23 (Android 6.0)** | Flutter warns below 24; see KNOWN_LIMITATIONS |
| NDK | 28.2.13676358 | auto-installed by AGP if needed |

## Local build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only after editing tables.dart / app_database.dart
flutter analyze
flutter test
flutter build apk --debug                       # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release --split-per-abi     # app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk
```

You need an Android SDK with platform 36 (`ANDROID_HOME` or `android/local.properties` → `sdk.dir`).

## Release signing

Without `android/key.properties`, the release APK is signed with the **debug key**. That's fine for sideloading tests and **not** suitable for distribution. To sign properly:

```properties
# android/key.properties  (git-ignored)
storeFile=/absolute/path/gamebox-release.jks
storePassword=...
keyAlias=gamebox
keyPassword=...
```

## Continuous integration

`.github/workflows/android.yml` runs on every push and pull request. It checks that the generated Drift code is current, runs the analyzer and the tests, builds the debug and per-ABI release APKs, prints `aapt2 dump badging` (package, SDK levels, ABIs, leanback) and SHA-256 sums, and uploads the **gamebox-phase1-apks** artifact.

Why CI: the development container that produced Phase 1 couldn't reach `dl.google.com` (Android SDK downloads were blocked by its network policy), so APKs are produced on GitHub-hosted runners.
