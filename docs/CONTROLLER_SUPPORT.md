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

## Phase 4 (pending)

Button mapping, per-console profiles, dead-zone and trigger calibration, vibration settings, player 1–4 assignment (schema tables already exist: `controller_profiles`, `controller_mappings`). All of it is PENDING physical testing with Bluetooth, USB and receiver controllers.
