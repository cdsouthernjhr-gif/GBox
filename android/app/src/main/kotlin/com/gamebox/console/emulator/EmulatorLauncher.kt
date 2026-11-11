package com.gamebox.console.emulator

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File

/**
 * Executes an intent spec built by a Dart emulator adapter. It never decides
 * *what* to launch; it only translates the spec into an Intent, starts it
 * and reports a precise error.
 */
class EmulatorLauncher(private val activity: Activity) {

    private val flagValues = mapOf(
        "newTask" to Intent.FLAG_ACTIVITY_NEW_TASK,
        "clearTask" to Intent.FLAG_ACTIVITY_CLEAR_TASK,
        "clearTop" to Intent.FLAG_ACTIVITY_CLEAR_TOP,
        "noHistory" to Intent.FLAG_ACTIVITY_NO_HISTORY,
    )

    /**
     * Starts [spec]; if its activity is not found, tries each of its
     * "fallbacks" in order. Returns which attempt started (0 = primary).
     */
    @Suppress("UNCHECKED_CAST")
    fun launch(spec: Map<String, Any?>): Map<String, Any?> {
        val attempts = listOf(spec) + ((spec["fallbacks"] as? List<Map<String, Any?>>) ?: emptyList())
        var last: Map<String, Any?> = error("bad_spec", "Nothing to launch")
        for ((index, attempt) in attempts.withIndex()) {
            last = launchOne(attempt)
            if (last["ok"] == true) return last + ("attempt" to index)
            if (last["code"] != "not_found") return last
        }
        return last
    }

    @Suppress("UNCHECKED_CAST")
    private fun launchOne(spec: Map<String, Any?>): Map<String, Any?> {
        val pkg = spec["package"] as? String ?: return error("bad_spec", "Missing package")
        val intent = Intent()
        (spec["action"] as? String)?.let { intent.action = it }
        (spec["categories"] as? List<String>)?.forEach { intent.addCategory(it) }
        val className = spec["className"] as? String
        if (className != null) intent.setClassName(pkg, className) else intent.setPackage(pkg)
        val data = (spec["data"] as? String)?.let { Uri.parse(it) }
        val mime = spec["mimeType"] as? String
        when {
            data != null && mime != null -> intent.setDataAndType(data, mime)
            data != null -> intent.data = data
            mime != null -> intent.type = mime
        }
        (spec["extras"] as? Map<String, String>)?.forEach { (k, v) -> intent.putExtra(k, v) }
        (spec["flags"] as? List<String>)?.forEach { name -> flagValues[name]?.let { intent.addFlags(it) } }

        // Read grants apply to the intent's data and ClipData, so URIs passed
        // in extras are also attached as ClipData.
        val grants = (spec["grantReadUris"] as? List<String>).orEmpty()
        if (grants.isNotEmpty()) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val clip = ClipData.newRawUri("game", Uri.parse(grants[0]))
            grants.drop(1).forEach { clip.addItem(ClipData.Item(Uri.parse(it))) }
            intent.clipData = clip
        }

        return try {
            activity.startActivity(intent)
            mapOf("ok" to true)
        } catch (e: ActivityNotFoundException) {
            error("not_found", "The emulator activity was not found. The installed version may not support this launch method.")
        } catch (e: SecurityException) {
            error("security", e.message ?: "Android refused to start the emulator")
        } catch (e: Exception) {
            error("failed", e.message ?: e.javaClass.simpleName)
        }
    }

    /** content:// URI for a file inside GAMEBOX's app-specific folders. */
    fun shareableUri(path: String): String? = try {
        FileProvider.getUriForFile(activity, "${activity.packageName}.files", File(path)).toString()
    } catch (_: IllegalArgumentException) {
        null // not inside a configured FileProvider root
    }

    private fun error(code: String, message: String) = mapOf("ok" to false, "code" to code, "error" to message)
}
