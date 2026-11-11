# Performance monitor and benchmarks (Phase 7)

Settings → System → **Performance & benchmarks**.

## Live monitor (refreshes every 2 s)

| Value | Source | Availability |
|---|---|---|
| RAM in use / low-memory state | `ActivityManager.MemoryInfo` | always |
| GAMEBOX CPU use | `Process.getElapsedCpuTime()` delta ÷ uptime ÷ cores | always |
| System CPU use | `/proc/stat` | **not accessible to apps on Android 8+**; shown as such |
| CPU core clocks | `/sys/devices/system/cpu/cpuN/cpufreq/scaling_cur_freq` | often readable on TV boxes; UNKNOWN otherwise |
| Temperatures | `/sys/class/thermal/thermal_zone*/temp` (+ `type`) | often readable; values outside −30…150 °C are discarded |
| Thermal status | `PowerManager.getCurrentThermalStatus()` | Android 10+ |
| Game running | GAMEBOX play session | always |

Nothing is overclocked and no system service is touched. Before a game launches, GAMEBOX frees its own image cache and pauses downloads (Phase 3/5).

## Benchmarks

They measure **the box itself**. External emulator apps don't expose their frame rate to other apps, so GAMEBOX doesn't report emulator FPS. Your own "how did it run?" answers are the per-game evidence.

| Benchmark | Method | Unit |
|---|---|---|
| CPU (1 core) | SHA-256 over 64 MB in a background isolate | MB/s |
| CPU (all cores) | the same in one isolate per core (max 8), summed | MB/s |
| Memory copy | 8 × 16 MB buffer copies (2 × 16 MB allocated, safe on 2 GB boxes) | MB/s |
| Storage write / read | 32 MB sequential file in `GAMEBOX/Downloads`, deleted afterwards; the read may come from OS cache | MB/s |
| Launcher rendering | animated scene for 5 s, engine `FrameTiming` raster-finish timestamps; average FPS and worst full second | FPS |

Results are stored per device in the `benchmarks` table and listed with their dates. They aren't yet used to change compatibility ratings, because there's no calibrated mapping from these scores to emulator performance. That mapping would need real-device data.
