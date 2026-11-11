# Device compatibility

## Device compatibility report (Phase 1)

**No physical device has been tested yet.** The build environment had no Android device or emulator attached. Every hardware row below is therefore PENDING. The in-app report (**Settings → Device information & compatibility report → Export report**) writes a JSON report to `Android/data/com.gamebox.console/files/reports/`. Please attach that file when contributing a device result.

| Manufacturer / model | SoC | Android | Tier (detected) | Launcher | Scan | Controllers | USB/SD | Result |
|---|---|---|---|---|---|---|---|---|
| — | — | — | — | PENDING | PENDING | PENDING | PENDING | PENDING |

### Android emulators (CI, Phase 8)

Not TV boxes. Recorded so the evidence is visible, from the `DEVICE:` lines in CI run #14:

| Emulator | Android | ABIs | Cores / RAM | GPU (reported) | Vulkan | Screen | Launcher | Scan | DB file | Result |
|---|---|---|---|---|---|---|---|---|---|---|
| Android SDK built for x86_64 (manufacturer not reported → UNKNOWN) | 7.0 (API 24) | x86_64, x86 | 2 / 2.0 GB | SwiftShader, GLES 3.0 | false | 1920×1080 | PASS (adb) | PASS | PASS | 6/6 tests + launcher checks PASS |
| Google sdk_gphone64_x86_64 | 14 (API 34) | x86_64, arm64-v8a | 2 / 2.4 GB | SwiftShader, GLES 3.0 | true | 1920×1080 | PASS (adb) | PASS | PASS | 6/6 tests + launcher checks PASS |

Both report `TV false`: they're phone images with a TV-sized screen. A real Android TV image couldn't be used (TESTING_GUIDE → Emulator results).

## What the Device Intelligence Engine reads

| Item | Source | Notes |
|---|---|---|
| Manufacturer, model, device, build | `android.os.Build` | always available |
| SoC model | `Build.SOC_MODEL` (API 31+), else `/proc/cpuinfo` `Hardware` | often UNKNOWN on newer kernels |
| ABIs | `Build.SUPPORTED_*_ABIS` | detects 32-bit Android on 64-bit CPUs |
| Core types | `/proc/cpuinfo` `CPU implementer` / `CPU part` | ARM Ltd parts mapped to Cortex names |
| Cores / max freq | `/sys/devices/system/cpu/possible`, `cpufreq/cpuinfo_max_freq` | freq may be unreadable (UNKNOWN) |
| RAM | `ActivityManager.MemoryInfo`, `isLowRamDevice` | |
| GPU | throw-away EGL14 pbuffer + `glGetString` | `eglTerminate` is never called (Flutter shares the display) |
| OpenGL ES | `ConfigurationInfo.glEsVersion` | |
| Vulkan | `FEATURE_VULKAN_HARDWARE_VERSION/LEVEL` (API 24+) | reported as not available on API 23 |
| Display | `Display.Mode` physical size, refresh rate, density | |
| TV | `UiModeManager` / `FEATURE_LEANBACK` | |

Temperature, CPU usage and FPS aren't read in Phase 1 (Phase 7 performance manager).

## Classification

Each axis scores 0–3:

* **CPU**: best core class (Cortex-A7/A9 = 0, A53/A55 = 1, A72/A73 = 2, A75+ = 3), with adjustments for 8+ fast cores or fewer than 4 cores. If core types are unknown, it falls back to core count and frequency.
* **GPU**: known renderer families (Mali-400/450 = 0, G31 = 1, G52 = 2, G610 = 3, Adreno by series, …), otherwise GLES/Vulkan level.
* **RAM**: < 1.4 GB = 0, < 2.5 GB = 1, < 4.5 GB = 2, else 3.

Tier = min(CPU, GPU). Then caps apply: RAM 0 → ENTRY, RAM 1 → at most ADVANCED, no arm64 → at most ADVANCED, GLES < 3 → at most STANDARD. RAM never raises the tier.

Per-console ratings compare the tier with the console's estimated minimum/recommended tier. Hard requirements (arm64, GLES version, emulator min SDK) give **Unsupported**. Missing data gives **Not Tested**. Every rating is labelled *Estimate from detected hardware* until benchmark or test evidence exists. No FPS is ever promised.

## Evidence precedence (Phase 7)

For a console (and optionally emulator) on this device, GAMEBOX shows the strongest evidence available:

1. **Verified by GAMEBOX testing**: `device_compatibility` rows with source `verified` for this manufacturer + model. None exist yet. Imports can never create them.
2. **Your own test on this device**: the optional "How did it run?" prompt after returning from a game, or *Rate how it ran* on the game page.
3. **Community report (unverified)**: imported bundles, always stored as `community`.
4. **Estimate from detected hardware**: the Phase 1 classifier.

### Bundle format (`gamebox-compat`, v1)

```json
{"format": "gamebox-compat", "version": 1, "results": [
  {"manufacturer": "…", "model": "…", "console": "nes", "emulator": "retroarch",
   "result": "excellent|good|limited|unsupported|notTested", "chipset": "…", "gpu": "…",
   "ramGb": 2, "android": "9", "game": "…", "notes": "…", "date": "2026-11-11"}]}
```

Import: Device report → **Import compatibility data** (file picker). Invalid rows (unknown console or emulator, bad result, missing model) are rejected and counted.

### Anonymous reports (consent)

Device report → **Export anonymous results** writes the same format with **only** results you ticked "Include in anonymous reports" for. It has coarse hardware facts only: model, SoC, GPU, RAM rounded to GB, Android version. No serial, build fingerprint, build ID or account data. GAMEBOX has no upload server, so you share the file yourself. Exported results are marked as submitted.

## Compatibility database

Rows in `device_compatibility` have `source`:

* `detected`: written automatically after each scan (A),
* `community`: imported community reports (B), always shown as unverified,
* `verified`: GAMEBOX-tested results (C).

Anonymous report submission and database import are scheduled for Phase 7. They'll require explicit consent.
