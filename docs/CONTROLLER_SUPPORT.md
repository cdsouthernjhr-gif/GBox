# Controller support

## Phase 1 (implemented)

* Enumerates every non-virtual `InputDevice`. Each device is classified as gamepad / joystick / dpad / keyboard (alphabetic) / remote / mouse / touchpad, based on its sources.
* Reports name, descriptor, vendor and product ID, Android controller (player) number, the gamepad buttons present (`hasKeys`), joystick axes (`motionRanges`) and vibrator presence (`VibratorManager` on 31+, `Vibrator` before).
* `InputManager.InputDeviceListener` sends connect/disconnect events, which show a notification in the UI. Controllers are remembered in `controller_devices`.
* **Controller test screen** (Controllers → Test input): live key down/up and axis values per device, read straight from `dispatchKeyEvent` / `dispatchGenericMotionEvent`. Axis updates are throttled to about 30 Hz.
* Navigation: D-pad and arrow keys move focus. Enter / Select / DPAD_CENTER / **A** activate. **B** is left to Android's fallback (BACK).

## Limits of public Android APIs

* The bus type (USB vs Bluetooth vs 2.4 GHz receiver) isn't exposed. GAMEBOX only shows a hint from the device name, or "External".
* `isExternal` is only available on Android 10+.
* Not every controller reports vibration or all axes. GAMEBOX shows what is reported and nothing more.

## Phase 4 (implemented)

Per controller (identified by its InputDevice descriptor, stable across reconnects), on the CONTROLLERS screen:

| Feature | How it works | Takes effect |
|---|---|---|
| **Map buttons** | Wizard for 16 actions (A, B, X, Y, L1, R1, L2, R2, Start, Select, D-pad ×4, L3, R3). Each press of *that* controller binds. Analog triggers and hat D-pads bind as axis + direction. BACK on the remote skips a step. BACK arriving < 300 ms after a key from the pad (Android's B→BACK fallback) is ignored. Nothing on screen is focusable while capturing, so pressing A can't also click a button. Conflicts are shown before saving. | GAMEBOX: `InputConfig.remap` rewrites the key code of every event from that controller before Flutter sees it |
| **Calibrate** | 3 s at rest (centre + noise), then 10 s of full movement (range), both timed so no button is needed. Saves per-axis centre/min/max and a **suggested dead zone** (2× resting wobble + 5 %, 5–50 %). | stored; dead zone used by stick navigation |
| **Dead zone** | 5–50 %. | stick navigation |
| **Trigger threshold** | 30–90 %. | stored / exported (for future embedded cores) |
| **Vibration** | on/off + **Test rumble** (`VibratorManager` on Android 12+, `Vibrator` before). Disabled when Android reports no vibrator. | rumble test |
| **Player 1–4 / Auto** | One slot per controller; assigning a taken slot frees it from the other pad. | recorded (see limitation) |
| **Export for RetroArch** | Writes `GAMEBOX/Controllers/<name>.cfg` (RetroArch Android autoconfig, button key codes only, RetroPad naming: Android A → `b`, B → `a`, X → `y`, Y → `x`). | import manually into RetroArch |
| **Reset** | Deletes the controller's mapping and calibration. | immediately |

**Stick navigation** (Settings → Controllers, on by default): the left stick or hat moves the launcher focus with key repeat (400 ms, then 120 ms). A stick must clear max(dead zone, 50 %) to start and drops below 70 % of that to stop (hysteresis). This replaces Android's built-in joystick→D-pad synthesis (fixed threshold), which makes drifting sticks on cheap pads jump the focus. It's paused while the test, mapping and calibration screens listen to raw input.

**Per-console profiles**: the database and repository support a profile per (controller, console) that overrides the universal one (tested). It has no effect yet, because external emulators use their own input configuration. It's intended for embedded cores (strategy C).

### Limitations

* Mappings, dead zone and calibration apply to **GAMEBOX itself**. Android doesn't let one app change another app's input handling, so RetroArch, DuckStation etc. use their own settings. The RetroArch export is the bridge (experimental, buttons only: RetroArch's Android axis numbering isn't documented well enough to export axes safely).
* Player slots are recorded but not enforced on emulators. They assign ports themselves, usually by connection order.
* Bus type (USB / Bluetooth / 2.4 GHz receiver) isn't exposed by public APIs. All three are handled identically through InputDevice.
* **All of the above is PENDING verification on physical controllers.** Only the logic is covered by automated tests.
