package com.gamebox.console.player

import android.content.Context
import android.os.Process
import org.json.JSONObject
import java.io.File
import java.lang.ref.WeakReference

/**
 * Live state of the built-in player, read by GAMEBOX (and the on-device
 * tests) through the "gamebox/emulator" channel. It is also written to a
 * file, so that after a crash (which ends the whole app) the next start of
 * GAMEBOX can tell the player stopped unexpectedly and show why.
 */
object PlayerStatus {
    /** idle | starting | running | error | closed | crashed | reported */
    @Volatile var state: String = "idle"
    @Volatile var frames: Long = 0
    @Volatile var errorCode: Int? = null
    @Volatile var errorMessage: String? = null
    @Volatile var core: String? = null
    @Volatile var rom: String? = null
    var activity: WeakReference<PlayerActivity>? = null
    private var file: File? = null

    fun init(context: Context) {
        if (file == null) file = File(context.filesDir, "player_status.json")
    }

    fun reset(core: String?, rom: String?) {
        state = "starting"
        frames = 0
        errorCode = null
        errorMessage = null
        this.core = core
        this.rom = rom
        persist()
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "state" to state,
        "frames" to frames,
        "errorCode" to errorCode,
        "errorMessage" to errorMessage,
        "core" to core,
    )

    /** Writes the state with this process id. Never throws. */
    fun persist() {
        val f = file ?: return
        runCatching {
            f.writeText(
                JSONObject()
                    .put("state", state)
                    .put("frames", frames)
                    .put("core", core ?: "")
                    .put("rom", rom ?: "")
                    .put("errorMessage", errorMessage ?: "")
                    .put("pid", Process.myPid())
                    .put("time", System.currentTimeMillis())
                    .toString(),
            )
        }
    }

    /**
     * A report when the player of an earlier run stopped without closing
     * (crash), with the app's own log lines of that run. Reported once.
     */
    fun crashReport(context: Context): Map<String, Any?>? {
        init(context)
        val f = file ?: return null
        val j = runCatching { JSONObject(f.readText()) }.getOrNull() ?: return null
        val st = j.optString("state")
        val pid = j.optInt("pid")
        val crashedHere = st == "crashed"
        val diedEarlier = (st == "starting" || st == "running") && pid != Process.myPid()
        if (!crashedHere && !diedEarlier) return null
        j.put("state", "reported")
        runCatching { f.writeText(j.toString()) }
        return mapOf(
            "core" to j.optString("core"),
            "rom" to j.optString("rom"),
            "frames" to j.optLong("frames"),
            "message" to j.optString("errorMessage"),
            "log" to logFor(pid),
        )
    }

    /** Last log lines of [pid] plus crash lines (apps can read their own log). */
    private fun logFor(pid: Int): String = runCatching {
        val p = Runtime.getRuntime().exec(arrayOf("logcat", "-d", "-v", "threadtime", "-t", "1500"))
        val lines = p.inputStream.bufferedReader().readLines()
        p.waitFor()
        val pidText = " $pid "
        lines.filter { l ->
            l.contains(pidText) || l.contains(" F DEBUG") || l.contains("Fatal signal") ||
                l.contains("AndroidRuntime") || l.contains("libretro", ignoreCase = true)
        }.takeLast(150).joinToString("\n")
    }.getOrDefault("")
}
