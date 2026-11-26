package com.gamebox.console.player

import android.content.Context
import com.swordfish.libretrodroid.Variable
import org.json.JSONObject
import java.io.File

/**
 * Emulator (libretro core) options the user changed, saved per core in
 * files/core_options/<core>.json as {"key": "value"}. GAMEBOX (Settings)
 * lists and resets them through the "gamebox/emulator" channel.
 */
object CoreOptions {

    /** One option as the core declared it: "Description; first|second|…". */
    data class Option(val key: String, val label: String, val value: String, val choices: List<String>) {
        companion object {
            fun parse(v: Variable): Option? {
                val key = v.key ?: return null
                val desc = v.description ?: return null
                val i = desc.indexOf("; ")
                if (i < 0) return null
                val choices = desc.substring(i + 2).split('|').filter { it.isNotEmpty() }
                if (choices.size < 2) return null
                return Option(key, desc.substring(0, i), v.value ?: choices.first(), choices)
            }
        }
    }

    private val safeName = Regex("^[a-z0-9_]+$")

    private fun file(context: Context, core: String): File? =
        if (safeName.matches(core)) File(context.filesDir, "core_options/$core.json") else null

    fun load(context: Context, core: String): Map<String, String> = runCatching {
        val f = file(context, core) ?: return emptyMap()
        if (!f.isFile) return emptyMap()
        val j = JSONObject(f.readText())
        j.keys().asSequence().associateWith { j.getString(it) }
    }.getOrDefault(emptyMap())

    fun save(context: Context, core: String, key: String, value: String) {
        val f = file(context, core) ?: return
        runCatching {
            val m = load(context, core).toMutableMap()
            m[key] = value
            f.parentFile?.mkdirs()
            f.writeText(JSONObject(m as Map<*, *>).toString())
        }
    }

    fun reset(context: Context, core: String): Boolean = file(context, core)?.let { !it.exists() || it.delete() } ?: false

    fun displayName(core: String): String = when (core) {
        "fceumm" -> "FCEUmm"
        "snes9x" -> "Snes9x"
        "gambatte" -> "Gambatte"
        "mgba" -> "mGBA"
        "genesis_plus_gx" -> "Genesis Plus GX"
        "pcsx_rearmed" -> "PCSX ReARMed"
        "mupen64plus_next_gles3" -> "Mupen64Plus-Next"
        "desmume" -> "DeSmuME"
        "ppsspp" -> "PPSSPP"
        else -> core
    }
}
