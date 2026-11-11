package com.gamebox.console.controllers

import android.content.Context
import android.hardware.input.InputManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import io.flutter.plugin.common.EventChannel

/**
 * Enumerates input devices through the public InputDevice API and reports
 * connect/disconnect events. Bus type (USB vs Bluetooth) is not exposed by
 * public API, so it is not reported.
 */
class ControllerManager(private val context: Context) {

    companion object {
        val GAMEPAD_KEYS = intArrayOf(
            KeyEvent.KEYCODE_BUTTON_A, KeyEvent.KEYCODE_BUTTON_B,
            KeyEvent.KEYCODE_BUTTON_X, KeyEvent.KEYCODE_BUTTON_Y,
            KeyEvent.KEYCODE_BUTTON_L1, KeyEvent.KEYCODE_BUTTON_R1,
            KeyEvent.KEYCODE_BUTTON_L2, KeyEvent.KEYCODE_BUTTON_R2,
            KeyEvent.KEYCODE_BUTTON_THUMBL, KeyEvent.KEYCODE_BUTTON_THUMBR,
            KeyEvent.KEYCODE_BUTTON_START, KeyEvent.KEYCODE_BUTTON_SELECT,
            KeyEvent.KEYCODE_BUTTON_MODE,
            KeyEvent.KEYCODE_DPAD_UP, KeyEvent.KEYCODE_DPAD_DOWN,
            KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.KEYCODE_DPAD_RIGHT,
            KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_BACK,
        )
    }

    private val inputManager = context.getSystemService(Context.INPUT_SERVICE) as InputManager

    fun listDevices(): List<Map<String, Any?>> =
        InputDevice.getDeviceIds().mapNotNull { id -> InputDevice.getDevice(id)?.let { describe(it) } }

    fun describe(d: InputDevice): Map<String, Any?>? {
        if (d.isVirtual) return null
        val sources = d.sources
        fun has(src: Int) = (sources and src) == src
        val classes = ArrayList<String>()
        val isGamepad = has(InputDevice.SOURCE_GAMEPAD)
        val isJoystick = has(InputDevice.SOURCE_JOYSTICK)
        if (isGamepad) classes.add("gamepad")
        if (isJoystick) classes.add("joystick")
        if (has(InputDevice.SOURCE_DPAD)) classes.add("dpad")
        if (has(InputDevice.SOURCE_KEYBOARD)) {
            if (d.keyboardType == InputDevice.KEYBOARD_TYPE_ALPHABETIC) {
                classes.add("keyboard")
            } else if (!isGamepad && !isJoystick) {
                classes.add("remote")
            }
        }
        if (has(InputDevice.SOURCE_MOUSE)) classes.add("mouse")
        if (has(InputDevice.SOURCE_TOUCHSCREEN)) classes.add("touchscreen")
        if (has(InputDevice.SOURCE_TOUCHPAD)) classes.add("touchpad")

        val buttons = ArrayList<String>()
        if (isGamepad || isJoystick) {
            val present = d.hasKeys(*GAMEPAD_KEYS)
            GAMEPAD_KEYS.forEachIndexed { i, code ->
                if (present[i]) buttons.add(KeyEvent.keyCodeToString(code).removePrefix("KEYCODE_"))
            }
        }
        val axes = d.motionRanges
            .filter { (it.source and InputDevice.SOURCE_CLASS_JOYSTICK) != 0 }
            .map { MotionEvent.axisToString(it.axis).removePrefix("AXIS_") }
            .distinct()

        val hasVibrator = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                d.vibratorManager.vibratorIds.isNotEmpty()
            } else {
                @Suppress("DEPRECATION")
                d.vibrator.hasVibrator()
            }
        } catch (_: Throwable) {
            false
        }

        return mapOf(
            "id" to d.id,
            "name" to d.name,
            "descriptor" to d.descriptor,
            "isExternal" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) d.isExternal else null),
            "classes" to classes,
            "vendorId" to d.vendorId,
            "productId" to d.productId,
            "hasVibrator" to hasVibrator,
            "axes" to axes,
            "buttons" to buttons,
            "controllerNumber" to d.controllerNumber.takeIf { it > 0 },
        )
    }

    /** Streams `{event: added|removed|changed, deviceId}` maps to Flutter. */
    inner class DeviceEvents : EventChannel.StreamHandler, InputManager.InputDeviceListener {
        private var sink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
            inputManager.registerInputDeviceListener(this, Handler(Looper.getMainLooper()))
        }

        override fun onCancel(arguments: Any?) {
            inputManager.unregisterInputDeviceListener(this)
            sink = null
        }

        override fun onInputDeviceAdded(deviceId: Int) = emit("added", deviceId)
        override fun onInputDeviceRemoved(deviceId: Int) = emit("removed", deviceId)
        override fun onInputDeviceChanged(deviceId: Int) = emit("changed", deviceId)

        private fun emit(event: String, id: Int) {
            sink?.success(mapOf("event" to event, "deviceId" to id))
        }
    }
}

/**
 * Forwards raw key and joystick events to the controller test screen while it
 * is listening. Events are still delivered to Flutter's normal input pipeline.
 */
class RawInputStream : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val lastMotion = HashMap<Int, Long>()

    val isListening: Boolean get() = sink != null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun onKey(e: KeyEvent) {
        val s = sink ?: return
        s.success(
            mapOf(
                "type" to "key",
                "deviceId" to e.deviceId,
                "keyCode" to e.keyCode,
                "keyName" to KeyEvent.keyCodeToString(e.keyCode).removePrefix("KEYCODE_"),
                "action" to if (e.action == KeyEvent.ACTION_DOWN) "down" else "up",
            ),
        )
    }

    private val axesToReport = intArrayOf(
        MotionEvent.AXIS_X, MotionEvent.AXIS_Y, MotionEvent.AXIS_Z, MotionEvent.AXIS_RZ,
        MotionEvent.AXIS_RX, MotionEvent.AXIS_RY,
        MotionEvent.AXIS_HAT_X, MotionEvent.AXIS_HAT_Y,
        MotionEvent.AXIS_LTRIGGER, MotionEvent.AXIS_RTRIGGER,
        MotionEvent.AXIS_BRAKE, MotionEvent.AXIS_GAS,
    )

    fun onMotion(e: MotionEvent) {
        val s = sink ?: return
        if ((e.source and InputDevice.SOURCE_CLASS_JOYSTICK) == 0) return
        if (e.action != MotionEvent.ACTION_MOVE) return
        // Throttle to ~30 updates/s per device to keep the UI light.
        val now = e.eventTime
        val last = lastMotion[e.deviceId] ?: 0L
        if (now - last < 33) return
        lastMotion[e.deviceId] = now
        val device = e.device
        val values = HashMap<String, Double>()
        for (axis in axesToReport) {
            if (device?.getMotionRange(axis, e.source) != null) {
                values[MotionEvent.axisToString(axis).removePrefix("AXIS_")] = e.getAxisValue(axis).toDouble()
            }
        }
        s.success(mapOf("type" to "motion", "deviceId" to e.deviceId, "axes" to values))
    }
}
