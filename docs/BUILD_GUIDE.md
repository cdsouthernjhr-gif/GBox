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
| minSdk | **24 (Android 7.0)** | verified via `aapt2 dump badging`; API 23 not achievable with this toolchain (KNOWN_LIMITATIONS) |
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

Create a keystore once and keep it (and its passwords) safe. An app signed with a lost key can never be updated in place:

```bash
keytool -genkeypair -v -keystore gamebox-release.jks -alias gamebox \
  -keyalg RSA -keysize 4096 -validity 10000
```

### Signing in GitHub Actions

Add four repository secrets (GitHub → Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `GAMEBOX_KEYSTORE_BASE64` | `base64 -w0 gamebox-release.jks` |
| `GAMEBOX_KEYSTORE_PASSWORD` | keystore password |
| `GAMEBOX_KEY_ALIAS` | `gamebox` (the alias used above) |
| `GAMEBOX_KEY_PASSWORD` | key password |

With the secrets set, the **Android build** workflow signs the release APKs with that key (the "Checksums and APK details" step prints the signer's certificate). Without them it falls back to the debug key and says so in the log.

### Publishing a release

1. Bump `version:` in `pubspec.yaml` and `appVersion` in `lib/core/constants/app_info.dart`. Update `docs/RELEASE_NOTES.md`.
2. Make sure the **Android build** run for that commit is green, including both `device-tests` jobs.
3. Tag and push: `git tag v0.8.0 && git push origin v0.8.0`.
4. `.github/workflows/release.yml` checks the tag matches the pubspec version, requires the signing secrets, runs the tests, builds signed per-ABI APKs, **refuses to publish if they're debug-signed**, and creates a GitHub Release with the APKs, `SHA256SUMS.txt` and `docs/RELEASE_NOTES.md` as the description.

### Release checklist

* [ ] CI green: analyze, unit/widget tests, codegen check, APK build, device tests on API 24 and API 34.
* [ ] At least the Phase 1 manual checklist (TESTING_GUIDE) done on one **physical** TV box, result recorded in DEVICE_COMPATIBILITY.md.
* [ ] No emulator listed as verified unless it was launched on a device (EMULATOR_INTEGRATION.md).
* [ ] RELEASE_NOTES and KNOWN_LIMITATIONS current.
* [ ] Signing secrets set; release APK signer is not `CN=Android Debug`.

## Continuous integration

`.github/workflows/android.yml` runs on every push and pull request. It checks that the generated Drift code is current, runs the analyzer and the tests, builds the debug and per-ABI release APKs, prints `aapt2 dump badging` (package, SDK levels, ABIs, leanback) and SHA-256 sums, and uploads the **gamebox-apks** artifact.

The `device-tests` jobs then run the app on Android emulators (API 24 and API 34, 1920×1080 `tv_1080p` profile, KVM): `tool/ci_device_tests.sh` runs `integration_test/device_test.dart` and the adb HOME-launcher checks. See TESTING_GUIDE.

Why CI: the development container that produced Phase 1 couldn't reach `dl.google.com` (Android SDK downloads were blocked by its network policy), so APKs are produced on GitHub-hosted runners.
