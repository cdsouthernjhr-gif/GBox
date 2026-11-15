package com.gamebox.console.storage

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings

/**
 * Broad storage access so GAMEBOX can keep games in a shared `ROMs/` folder
 * that RetroArch and other emulators can read, and search the device for
 * ROM files.
 *
 * * Android 11+ (API 30): "All files access" (MANAGE_EXTERNAL_STORAGE),
 *   granted by the user in system settings. Some Android TV firmwares have
 *   no such settings screen; then [settingsAvailable] is false and the user
 *   can grant it with adb or use a picked folder instead.
 * * Android 10 and lower: READ/WRITE_EXTERNAL_STORAGE runtime permissions
 *   (with requestLegacyExternalStorage on Android 10).
 */
class StorageAccess(private val activity: Activity) {

    fun status(): Map<String, Any?> {
        val sdk = Build.VERSION.SDK_INT
        val granted = if (sdk >= 30) {
            Environment.isExternalStorageManager()
        } else {
            activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
        @Suppress("DEPRECATION")
        val root = Environment.getExternalStorageDirectory()?.absolutePath
        return mapOf(
            "sdk" to sdk,
            "granted" to granted,
            "mode" to if (sdk >= 30) "all_files" else "legacy",
            "settingsAvailable" to (sdk < 30 || settingsIntent() != null),
            "publicRoot" to root,
        )
    }

    private fun settingsIntent(): Intent? {
        if (Build.VERSION.SDK_INT < 30) return null
        val pm = activity.packageManager
        val forApp = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
            .setData(Uri.parse("package:${activity.packageName}"))
        if (forApp.resolveActivity(pm) != null) return forApp
        val general = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
        return if (general.resolveActivity(pm) != null) general else null
    }

    /** Opens the system screen or asks for the runtime permission. */
    fun request(): String {
        if (Build.VERSION.SDK_INT >= 30) {
            val intent = settingsIntent() ?: return "unavailable"
            return try {
                activity.startActivity(intent)
                "opened"
            } catch (_: Exception) {
                "unavailable"
            }
        }
        activity.requestPermissions(
            arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
            REQUEST_CODE,
        )
        return "requested"
    }

    companion object {
        const val REQUEST_CODE = 4110
    }
}
