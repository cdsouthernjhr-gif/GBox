package com.gamebox.console.player

import android.app.AlertDialog
import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.os.Bundle
import android.view.Gravity
import android.view.InputDevice
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.lifecycle.lifecycleScope
import com.swordfish.libretrodroid.GLRetroView
import com.swordfish.libretrodroid.GLRetroViewData
import com.swordfish.libretrodroid.Variable
import kotlinx.coroutines.launch
import java.io.File

/**
 * GAMEBOX's built-in player: runs a bundled libretro core (LibretroDroid)
 * full screen. No external emulator, core download or emulator settings.
 *
 * Extras (all strings):
 *  core       core name, e.g. "fceumm" (lib<core>_libretro_android.so, bundled)
 *  rom        absolute path of the game file (.cue for multi-file discs)
 *  system     folder with BIOS files (may not exist)
 *  saves      folder for battery saves (.srm) and save states (.state)
 *  title      game title (menu)
 *  touch      "auto" | "on" | "off" — on-screen controls
 *  layout     touch layout: "nes", "gb", "snes", "gba", "md", "ps1"
 *
 * Controls: gamepad buttons by position (bottom = B, right = A, left = Y,
 * top = X, as on a SNES pad); TV remote D-pad = D-pad, OK = A, Menu = Start;
 * BACK (or the controller's Mode button) opens the pause menu.
 */
class PlayerActivity : ComponentActivity() {

    private lateinit var retroView: GLRetroView
    private var touch: TouchControls? = null
    private lateinit var romFile: File
    private lateinit var savesDir: File
    private var menuOpen = false

    private val srmFile get() = File(savesDir, "${romFile.nameWithoutExtension}.srm")
    private val stateFile get() = File(savesDir, "${romFile.nameWithoutExtension}.state")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        hideSystemBars()

        val core = intent.getStringExtra(EXTRA_CORE)
        val rom = intent.getStringExtra(EXTRA_ROM)
        val coreFile = core?.let { File(applicationInfo.nativeLibraryDir, "lib${it}_libretro_android.so") }
        if (core == null || rom == null || coreFile == null) return fail("The game could not be started (missing core or game).")
        if (!coreFile.isFile) return fail("The $core emulator is not part of this GAMEBOX build.")
        romFile = File(rom)
        if (!romFile.canRead()) return fail("GAMEBOX cannot read the game file:\n$rom")
        savesDir = File(intent.getStringExtra(EXTRA_SAVES) ?: File(filesDir, "saves").path).apply { mkdirs() }
        val systemDir = File(intent.getStringExtra(EXTRA_SYSTEM) ?: File(filesDir, "system").path).apply { mkdirs() }

        val data = GLRetroViewData(this).apply {
            coreFilePath = coreFile.absolutePath
            gameFilePath = romFile.absolutePath
            systemDirectory = systemDir.absolutePath
            savesDirectory = savesDir.absolutePath
            saveRAMState = srmFile.takeIf { it.isFile }?.readBytes()
            variables = coreVariables(core)
            preferLowLatencyAudio = true
        }
        retroView = GLRetroView(this, data)
        lifecycle.addObserver(retroView)

        val root = FrameLayout(this)
        root.setBackgroundColor(0xFF000000.toInt())
        root.addView(retroView, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT, Gravity.CENTER))
        if (wantsTouchControls()) {
            val pad = TouchControls(
                this,
                TouchControls.layoutFor(intent.getStringExtra(EXTRA_LAYOUT) ?: "nes"),
                send = { action, key -> retroView.sendKeyEvent(action, key, 0) },
                onMenu = { showMenu() },
            )
            touch = pad
            root.addView(pad, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        }
        setContentView(root)
        retroView.isFocusable = true
        retroView.requestFocus()

        lifecycleScope.launch {
            retroView.getGLRetroErrors().collect { code ->
                val msg = when (code) {
                    GLRetroView.ERROR_LOAD_LIBRARY -> "The emulator core could not be loaded on this device."
                    GLRetroView.ERROR_LOAD_GAME -> "The emulator could not open this game. The file may be damaged, " +
                        "in an unsupported format, or need files that are missing (e.g. the .bin of a .cue)."
                    GLRetroView.ERROR_GL_NOT_COMPATIBLE -> "This device's graphics are not supported by the emulator."
                    else -> "The emulator stopped with an error ($code)."
                }
                fail(msg)
            }
        }
    }

    /** Core options that make the bundled cores work without a BIOS where possible. */
    private fun coreVariables(core: String): Array<Variable> = when (core) {
        // PCSX ReARMed has a built-in BIOS replacement; a real BIOS in the
        // system folder is used automatically when present.
        "pcsx_rearmed" -> arrayOf(Variable("pcsx_rearmed_drc", "enabled"))
        "genesis_plus_gx" -> arrayOf(Variable("genesis_plus_gx_bram", "per game"))
        else -> arrayOf()
    }

    private fun wantsTouchControls(): Boolean = when (intent.getStringExtra(EXTRA_TOUCH)) {
        "on" -> true
        "off" -> false
        else -> {
            val tv = (getSystemService(Context.UI_MODE_SERVICE) as UiModeManager).currentModeType ==
                Configuration.UI_MODE_TYPE_TELEVISION
            !tv && !hasGamepad()
        }
    }

    private fun hasGamepad(): Boolean = InputDevice.getDeviceIds().any { id ->
        val d = InputDevice.getDevice(id) ?: return@any false
        !d.isVirtual && (d.sources and InputDevice.SOURCE_GAMEPAD == InputDevice.SOURCE_GAMEPAD ||
            d.sources and InputDevice.SOURCE_JOYSTICK == InputDevice.SOURCE_JOYSTICK)
    }

    // ---- input ----

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (!::retroView.isInitialized || menuOpen) return super.dispatchKeyEvent(event)
        val code = event.keyCode
        if (code == KeyEvent.KEYCODE_BACK || code == KeyEvent.KEYCODE_BUTTON_MODE || code == KeyEvent.KEYCODE_ESCAPE) {
            if (event.action == KeyEvent.ACTION_UP) showMenu()
            return true
        }
        if (code == KeyEvent.KEYCODE_VOLUME_UP || code == KeyEvent.KEYCODE_VOLUME_DOWN || code == KeyEvent.KEYCODE_VOLUME_MUTE) {
            return super.dispatchKeyEvent(event)
        }
        val mapped = mapKey(code) ?: return super.dispatchKeyEvent(event)
        if (event.action == KeyEvent.ACTION_DOWN || event.action == KeyEvent.ACTION_UP) {
            if (event.repeatCount == 0 || event.action == KeyEvent.ACTION_UP) {
                retroView.sendKeyEvent(event.action, mapped, portOf(event.device))
            }
            // A physical controller in use: hide the on-screen controls.
            if (event.source and InputDevice.SOURCE_GAMEPAD == InputDevice.SOURCE_GAMEPAD) touch?.visibility = View.GONE
        }
        return true
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        if (::retroView.isInitialized && !menuOpen &&
            event.source and InputDevice.SOURCE_JOYSTICK == InputDevice.SOURCE_JOYSTICK &&
            event.action == MotionEvent.ACTION_MOVE
        ) {
            val port = portOf(event.device)
            retroView.sendMotionEvent(GLRetroView.MOTION_SOURCE_DPAD,
                event.getAxisValue(MotionEvent.AXIS_HAT_X), event.getAxisValue(MotionEvent.AXIS_HAT_Y), port)
            retroView.sendMotionEvent(GLRetroView.MOTION_SOURCE_ANALOG_LEFT,
                event.getAxisValue(MotionEvent.AXIS_X), event.getAxisValue(MotionEvent.AXIS_Y), port)
            retroView.sendMotionEvent(GLRetroView.MOTION_SOURCE_ANALOG_RIGHT,
                event.getAxisValue(MotionEvent.AXIS_Z), event.getAxisValue(MotionEvent.AXIS_RZ), port)
            touch?.visibility = View.GONE
            return true
        }
        return super.dispatchGenericMotionEvent(event)
    }

    private fun portOf(device: InputDevice?): Int = ((device?.controllerNumber ?: 1) - 1).coerceIn(0, 3)

    // ---- pause menu, saves ----

    private fun showMenu() {
        if (menuOpen || isFinishing) return
        menuOpen = true
        // Stops the emulation thread while the menu is open. While it is
        // stopped, the core is called directly (useEmulationThread = false).
        retroView.onPause()
        var chosen = 0
        val items = arrayOf("Resume", "Save state", "Load state", "Restart game", "Quit to GAMEBOX")
        AlertDialog.Builder(this)
            .setTitle(intent.getStringExtra(EXTRA_TITLE) ?: "Paused")
            .setItems(items) { _, which -> chosen = which }
            .setOnDismissListener {
                when (chosen) {
                    1 -> saveState()
                    2 -> loadState()
                    3 -> runCatching { retroView.reset(false) }
                    4 -> {
                        saveSram()
                        finish()
                        return@setOnDismissListener
                    }
                }
                menuOpen = false
                if (!isFinishing) {
                    retroView.onResume()
                    hideSystemBars()
                }
            }
            .show()
    }

    /** Called while the emulation thread is stopped (menu open). */
    private fun saveState() {
        val ok = runCatching { stateFile.writeBytes(retroView.serializeState(false)) }.isSuccess
        toast(if (ok) "State saved" else "Could not save the state")
    }

    /** Called while the emulation thread is stopped (menu open). */
    private fun loadState() {
        if (!stateFile.isFile) return toast("No saved state yet")
        val ok = runCatching { retroView.unserializeState(stateFile.readBytes(), false) }.getOrDefault(false)
        toast(if (ok) "State loaded" else "Could not load the state")
    }

    /**
     * Battery saves (SRAM) are written whenever the player is left. Only
     * called while emulation is stopped: after the lifecycle paused the view
     * (onPause) or with the menu open.
     */
    private fun saveSram() {
        if (!::retroView.isInitialized || !::savesDir.isInitialized) return
        runCatching {
            val bytes = retroView.serializeSRAM(false)
            if (bytes.isNotEmpty()) srmFile.writeBytes(bytes)
        }
    }

    override fun onPause() {
        // The view observes the lifecycle and has paused emulation by now
        // (ON_PAUSE is dispatched before Activity.onPause on API 29+).
        super.onPause()
        saveSram()
    }

    // ---- helpers ----

    private fun fail(message: String) {
        if (isFinishing) return
        AlertDialog.Builder(this)
            .setTitle("Cannot start the game")
            .setMessage(message)
            .setPositiveButton("Back to GAMEBOX") { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun toast(msg: String) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()

    @Suppress("DEPRECATION")
    private fun hideSystemBars() {
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or View.SYSTEM_UI_FLAG_FULLSCREEN or
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_LAYOUT_STABLE)
    }

    companion object {
        const val EXTRA_CORE = "core"
        const val EXTRA_ROM = "rom"
        const val EXTRA_SYSTEM = "system"
        const val EXTRA_SAVES = "saves"
        const val EXTRA_TITLE = "title"
        const val EXTRA_TOUCH = "touch"
        const val EXTRA_LAYOUT = "layout"

        /**
         * Android key → key code LibretroDroid understands. Face buttons are
         * mapped by position (Android's A is the bottom button, which is
         * RetroPad B), so every pad plays like a SNES pad.
         */
        fun mapKey(code: Int): Int? = when (code) {
            KeyEvent.KEYCODE_BUTTON_A -> KeyEvent.KEYCODE_BUTTON_B
            KeyEvent.KEYCODE_BUTTON_B -> KeyEvent.KEYCODE_BUTTON_A
            KeyEvent.KEYCODE_BUTTON_X -> KeyEvent.KEYCODE_BUTTON_Y
            KeyEvent.KEYCODE_BUTTON_Y -> KeyEvent.KEYCODE_BUTTON_X
            KeyEvent.KEYCODE_BUTTON_L1, KeyEvent.KEYCODE_BUTTON_R1, KeyEvent.KEYCODE_BUTTON_L2, KeyEvent.KEYCODE_BUTTON_R2,
            KeyEvent.KEYCODE_BUTTON_THUMBL, KeyEvent.KEYCODE_BUTTON_THUMBR,
            KeyEvent.KEYCODE_BUTTON_START, KeyEvent.KEYCODE_BUTTON_SELECT,
            KeyEvent.KEYCODE_DPAD_UP, KeyEvent.KEYCODE_DPAD_DOWN, KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.KEYCODE_DPAD_RIGHT -> code
            // TV remote / keyboard
            KeyEvent.KEYCODE_DPAD_CENTER, KeyEvent.KEYCODE_ENTER, KeyEvent.KEYCODE_NUMPAD_ENTER -> KeyEvent.KEYCODE_BUTTON_A
            KeyEvent.KEYCODE_MENU -> KeyEvent.KEYCODE_BUTTON_START
            KeyEvent.KEYCODE_SPACE -> KeyEvent.KEYCODE_BUTTON_SELECT
            KeyEvent.KEYCODE_Z -> KeyEvent.KEYCODE_BUTTON_B
            KeyEvent.KEYCODE_X -> KeyEvent.KEYCODE_BUTTON_A
            else -> null
        }
    }
}
