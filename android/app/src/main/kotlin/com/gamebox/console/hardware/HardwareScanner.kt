package com.gamebox.console.hardware

import android.app.ActivityManager
import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.GLES20
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import com.gamebox.console.controllers.ControllerManager
import com.gamebox.console.storage.StorageScanner
import java.io.File

/**
 * Device Intelligence Engine – native half.
 *
 * Collects only information exposed through public Android APIs or readable
 * world-accessible kernel files. Anything unavailable is returned as null so
 * the Flutter side can show UNKNOWN instead of a guess.
 */
class HardwareScanner(private val context: Context) {

    companion object {
        private const val TAG = "GameBoxHw"

        @Volatile
        private var cachedGl: Map<String, String?>? = null
    }

    fun scan(): Map<String, Any?> {
        val map = HashMap<String, Any?>()
        map.putAll(buildInfo())
        map.putAll(cpuInfo())
        map.putAll(memoryInfo())
        map.putAll(gpuInfo())
        map.putAll(displayInfo())
        map["storageVolumes"] = StorageScanner(context).volumes()
        map["inputDevices"] = ControllerManager(context).listDevices()
        return map
    }

    private fun buildInfo(): Map<String, Any?> {
        val m = HashMap<String, Any?>()
        m["manufacturer"] = Build.MANUFACTURER
        m["brand"] = Build.BRAND
        m["model"] = Build.MODEL
        m["device"] = Build.DEVICE
        m["product"] = Build.PRODUCT
        m["board"] = Build.BOARD
        m["hardware"] = Build.HARDWARE
        m["androidVersion"] = Build.VERSION.RELEASE
        m["sdkInt"] = Build.VERSION.SDK_INT
        m["buildId"] = Build.ID
        m["buildFingerprint"] = Build.FINGERPRINT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            m["socModel"] = Build.SOC_MODEL.takeUnless { it == Build.UNKNOWN }
            m["socManufacturer"] = Build.SOC_MANUFACTURER.takeUnless { it == Build.UNKNOWN }
        }
        m["supportedAbis"] = Build.SUPPORTED_ABIS.toList()
        m["supported32BitAbis"] = Build.SUPPORTED_32_BIT_ABIS.toList()
        m["supported64BitAbis"] = Build.SUPPORTED_64_BIT_ABIS.toList()
        return m
    }

    private fun cpuInfo(): Map<String, Any?> {
        val m = HashMap<String, Any?>()
        // Raw text is parsed in Dart (unit-tested parser).
        m["cpuInfoRaw"] = readText("/proc/cpuinfo", 64 * 1024)
        m["cpuCores"] = possibleCpuCount() ?: Runtime.getRuntime().availableProcessors()
        var maxFreq: Int? = null
        val cpuDir = File("/sys/devices/system/cpu")
        cpuDir.listFiles { f -> f.name.matches(Regex("cpu\\d+")) }?.forEach { cpu ->
            val v = readText("${cpu.path}/cpufreq/cpuinfo_max_freq", 64)?.trim()?.toIntOrNull()
            if (v != null && (maxFreq == null || v > maxFreq!!)) maxFreq = v
        }
        m["cpuMaxFreqKhz"] = maxFreq
        return m
    }

    /** Parses /sys/devices/system/cpu/possible, e.g. "0-7" or "0-3,6". */
    private fun possibleCpuCount(): Int? {
        val text = readText("/sys/devices/system/cpu/possible", 64)?.trim() ?: return null
        var count = 0
        for (part in text.split(',')) {
            val range = part.split('-')
            val a = range[0].trim().toIntOrNull() ?: return null
            val b = if (range.size > 1) range[1].trim().toIntOrNull() ?: return null else a
            count += (b - a + 1)
        }
        return if (count > 0) count else null
    }

    fun memoryInfo(): Map<String, Any?> {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val mi = ActivityManager.MemoryInfo()
        am.getMemoryInfo(mi)
        val rt = Runtime.getRuntime()
        return mapOf(
            "totalRamBytes" to mi.totalMem,
            "availableRamBytes" to mi.availMem,
            "lowMemory" to mi.lowMemory,
            "lowMemoryThresholdBytes" to mi.threshold,
            "isLowRamDevice" to am.isLowRamDevice,
            "memoryClassMb" to am.memoryClass,
            "largeMemoryClassMb" to am.largeMemoryClass,
            "appHeapUsedBytes" to (rt.totalMemory() - rt.freeMemory()),
            "appHeapMaxBytes" to rt.maxMemory(),
        )
    }

    private fun gpuInfo(): Map<String, Any?> {
        val m = HashMap<String, Any?>()
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        m["glEsVersion"] = am.deviceConfigurationInfo?.glEsVersion
        m.putAll(probeGl())

        val pm = context.packageManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            var vkVersion: Int? = null
            var vkLevel: Int? = null
            for (f in pm.systemAvailableFeatures) {
                when (f.name) {
                    PackageManager.FEATURE_VULKAN_HARDWARE_VERSION -> vkVersion = f.version
                    PackageManager.FEATURE_VULKAN_HARDWARE_LEVEL -> vkLevel = f.version
                }
            }
            m["vulkanSupported"] = vkVersion != null
            m["vulkanHardwareLevel"] = vkLevel
            m["vulkanApiVersion"] = vkVersion?.let {
                "${it shr 22}.${(it shr 12) and 0x3ff}.${it and 0xfff}"
            }
        } else {
            // Vulkan is not exposed by the platform before Android 7.0.
            m["vulkanSupported"] = false
        }
        return m
    }

    /** Creates a throw-away 1x1 pbuffer GLES2 context to read GL strings. */
    private fun probeGl(): Map<String, String?> {
        cachedGl?.let { return it }
        val result = HashMap<String, String?>()
        var display = EGL14.EGL_NO_DISPLAY
        var ctx = EGL14.EGL_NO_CONTEXT
        var surface = EGL14.EGL_NO_SURFACE
        try {
            display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            val ver = IntArray(2)
            if (!EGL14.eglInitialize(display, ver, 0, ver, 1)) return result
            val attribs = intArrayOf(
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                EGL14.EGL_NONE,
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val num = IntArray(1)
            if (!EGL14.eglChooseConfig(display, attribs, 0, configs, 0, 1, num, 0) || num[0] == 0) {
                return result
            }
            ctx = EGL14.eglCreateContext(
                display, configs[0], EGL14.EGL_NO_CONTEXT,
                intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE), 0,
            )
            surface = EGL14.eglCreatePbufferSurface(
                display, configs[0],
                intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0,
            )
            if (ctx == EGL14.EGL_NO_CONTEXT || surface == EGL14.EGL_NO_SURFACE) return result
            if (EGL14.eglMakeCurrent(display, surface, surface, ctx)) {
                result["glVendor"] = GLES20.glGetString(GLES20.GL_VENDOR)
                result["glRenderer"] = GLES20.glGetString(GLES20.GL_RENDERER)
                result["glVersion"] = GLES20.glGetString(GLES20.GL_VERSION)
            }
        } catch (t: Throwable) {
            Log.w(TAG, "GL probe failed", t)
        } finally {
            if (display != EGL14.EGL_NO_DISPLAY) {
                EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
                if (surface != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(display, surface)
                if (ctx != EGL14.EGL_NO_CONTEXT) EGL14.eglDestroyContext(display, ctx)
                // Do not eglTerminate the shared default display: Flutter's
                // renderer uses it in this process.
                EGL14.eglReleaseThread()
            }
        }
        if (result.isNotEmpty()) cachedGl = result
        return result
    }

    private fun displayInfo(): Map<String, Any?> {
        val m = HashMap<String, Any?>()
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        @Suppress("DEPRECATION")
        val display = wm.defaultDisplay
        val dm = DisplayMetrics()
        @Suppress("DEPRECATION")
        display.getRealMetrics(dm)
        // Display.Mode (API 23) reports the panel resolution, which on TVs can
        // differ from the UI resolution (e.g. 4K panel, 1080p UI).
        val mode = display.mode
        m["displayWidth"] = mode?.physicalWidth ?: dm.widthPixels
        m["displayHeight"] = mode?.physicalHeight ?: dm.heightPixels
        m["uiWidth"] = dm.widthPixels
        m["uiHeight"] = dm.heightPixels
        m["refreshRate"] = display.refreshRate.toDouble()
        m["densityDpi"] = dm.densityDpi
        val ui = context.getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        m["isTelevision"] = ui.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
            context.packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        return m
    }

    private fun readText(path: String, maxBytes: Int): String? = try {
        File(path).inputStream().use { input ->
            val buf = ByteArray(maxBytes)
            var total = 0
            while (total < maxBytes) {
                val n = input.read(buf, total, maxBytes - total)
                if (n <= 0) break
                total += n
            }
            String(buf, 0, total)
        }
    } catch (t: Throwable) {
        null
    }
}
