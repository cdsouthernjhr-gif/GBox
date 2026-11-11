package com.gamebox.console.controllers

import android.os.Build
import android.os.CombinedVibration
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import kotlin.math.abs
import kotlin.math.max

/**
 * Per-controller input settings pushed from Flutter (profiles in the
 * database): key remaps and stick dead zones. Keyed by InputDevice
 * descriptor, which is stable across reconnects.
 */
class InputConfig {
    @Volatile var remaps: Map<String, Map<Int, Int>> = emptyMap()
    @Volatile var deadZones: Map<String, Float> = emptyMap()
    @Volatile var stickNavigation: Boolean = true

    @Suppress("UNCHECKED_CAST")
    fun update(args: Map<String, Any?>) {
        val r = HashMap<String, Map<Int, Int>>()
        (args["remaps"] as? Map<String, Map<Any?, Any?>>)?.forEach { (descriptor, m) ->
            val inner = HashMap<Int, Int>()
            m.forEach { (k, v) ->
                val from = (k as? Number)?.toInt() ?: (k as? String)?.toIntOrNull()
                val to = (v as? Number)?.toInt()
                if (from != null && to != null) inner[from] = to
            }
            r[descriptor] = inner
        }
        remaps = r
        deadZones = (args["deadZones"] as? Map<String, Number>)?.mapValues { it.value.toFloat() } ?: emptyMap()
        stickNavigation = args["stickNavigation"] as? Boolean ?: true
    }

    /** Returns [e] with its key code replaced if the device has a remap. */
    fun remap(e: KeyEvent): KeyEvent {
        val descriptor = e.device?.descriptor ?: return e
        val to = remaps[descriptor]?.get(e.keyCode) ?: return e
        return KeyEvent(
            e.downTime, e.eventTime, e.action, to, e.repeatCount, e.metaState,
            e.deviceId, e.scanCode, e.flags, e.source,
        )
    }
}

/**
 * Turns left-stick and hat (D-pad) motion into D-pad key events for launcher
 * navigation, honouring each controller's dead zone, with key repeat while
 * held. Replaces Android's built-in synthesis (fixed 0.5 threshold) so that a
 * drifting stick on a cheap pad does not move the focus.
 */
class StickNavigator(private val config: InputConfig, private val emit: (KeyEvent) -> Unit) {
    private val handler = Handler(Looper.getMainLooper())
    private var heldKey = 0
    private var heldDevice = -1
    private var downTime = 0L
    private var repeats = 0
    private val repeat = object : Runnable {
        override fun run() {
            if (heldKey == 0) return
            repeats++
            send(KeyEvent.ACTION_DOWN, heldKey, repeats)
            handler.postDelayed(this, 120)
        }
    }

    /** Returns true when the event was a joystick move handled here. */
    fun onMotion(ev: MotionEvent): Boolean {
        if (!config.stickNavigation) return false
        if ((ev.source and InputDevice.SOURCE_JOYSTICK) != InputDevice.SOURCE_JOYSTICK) return false
        if (ev.action != MotionEvent.ACTION_MOVE) return false
        val dz = config.deadZones[ev.device?.descriptor] ?: 0.2f
        // Stick must clear both the dead zone and a deliberate-push threshold.
        val stickThreshold = max(dz, 0.5f)
        val releaseThreshold = stickThreshold * 0.7f

        val hatX = ev.getAxisValue(MotionEvent.AXIS_HAT_X)
        val hatY = ev.getAxisValue(MotionEvent.AXIS_HAT_Y)
        val sx = ev.getAxisValue(MotionEvent.AXIS_X)
        val sy = ev.getAxisValue(MotionEvent.AXIS_Y)
        val useHat = abs(hatX) > 0.5f || abs(hatY) > 0.5f
        val x = if (useHat) hatX else sx
        val y = if (useHat) hatY else sy
        val threshold = if (useHat) 0.5f else if (heldKey != 0) releaseThreshold else stickThreshold

        val key = when {
            abs(x) >= abs(y) && abs(x) > threshold -> if (x > 0) KeyEvent.KEYCODE_DPAD_RIGHT else KeyEvent.KEYCODE_DPAD_LEFT
            abs(y) > threshold -> if (y > 0) KeyEvent.KEYCODE_DPAD_DOWN else KeyEvent.KEYCODE_DPAD_UP
            else -> 0
        }
        if (key != heldKey) {
            release()
            if (key != 0) {
                heldKey = key
                heldDevice = ev.deviceId
                downTime = android.os.SystemClock.uptimeMillis()
                repeats = 0
                send(KeyEvent.ACTION_DOWN, key, 0)
                handler.postDelayed(repeat, 400)
            }
        }
        return true
    }

    fun release() {
        handler.removeCallbacks(repeat)
        if (heldKey != 0) send(KeyEvent.ACTION_UP, heldKey, 0)
        heldKey = 0
    }

    private fun send(action: Int, code: Int, repeatCount: Int) {
        emit(
            KeyEvent(
                downTime, android.os.SystemClock.uptimeMillis(), action, code, repeatCount, 0,
                heldDevice, 0, 0, InputDevice.SOURCE_DPAD,
            ),
        )
    }
}

object ControllerVibration {
    /** One-shot rumble on a controller. Returns false if it has no vibrator. */
    fun vibrate(deviceId: Int, durationMs: Long, amplitude: Int): Boolean {
        val device = InputDevice.getDevice(deviceId) ?: return false
        val amp = amplitude.coerceIn(1, 255)
        val ms = durationMs.coerceIn(10, 2000)
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = device.vibratorManager
                if (vm.vibratorIds.isEmpty()) return false
                vm.vibrate(CombinedVibration.createParallel(VibrationEffect.createOneShot(ms, amp)))
            } else {
                @Suppress("DEPRECATION")
                val v = device.vibrator
                if (!v.hasVibrator()) return false
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    v.vibrate(VibrationEffect.createOneShot(ms, amp))
                } else {
                    @Suppress("DEPRECATION")
                    v.vibrate(ms)
                }
            }
            true
        } catch (_: Exception) {
            false
        }
    }
}
