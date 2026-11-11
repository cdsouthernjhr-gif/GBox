package com.gamebox.console.launcher

import android.app.Activity
import android.app.role.RoleManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import java.io.ByteArrayOutputStream

/**
 * Launcher integration: default-HOME status, settings shortcuts (so the user
 * is never locked out), the installed-apps drawer and app launching.
 */
class LauncherBridge(private val activity: Activity) {

    companion object {
        const val REQUEST_HOME_ROLE = 4101
    }

    private val pm: PackageManager get() = activity.packageManager

    fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val info = pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return info?.activityInfo?.packageName == activity.packageName
    }

    /**
     * Asks the system to make GAMEBOX the HOME app. Uses RoleManager on
     * Android 10+, falling back to the Home settings screen and finally the
     * main Settings app (some TV firmwares hide the Home settings screen).
     * Returns the mechanism used.
     */
    fun requestDefaultLauncher(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val rm = activity.getSystemService(RoleManager::class.java)
            if (rm != null && rm.isRoleAvailable(RoleManager.ROLE_HOME) && !rm.isRoleHeld(RoleManager.ROLE_HOME)) {
                try {
                    activity.startActivityForResult(rm.createRequestRoleIntent(RoleManager.ROLE_HOME), REQUEST_HOME_ROLE)
                    return "role_manager"
                } catch (_: ActivityNotFoundException) {
                }
            }
        }
        return openHomeSettings()
    }

    fun openHomeSettings(): String {
        if (tryStart(Intent(Settings.ACTION_HOME_SETTINGS))) return "home_settings"
        if (tryStart(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))) return "default_apps_settings"
        return if (openAndroidSettings()) "settings" else "unavailable"
    }

    fun openAndroidSettings(): Boolean = tryStart(Intent(Settings.ACTION_SETTINGS))

    fun openAppDetails(packageName: String): Boolean =
        tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))

    fun listApps(): List<Map<String, Any?>> {
        val apps = LinkedHashMap<String, Map<String, Any?>>()
        val leanback = pm.queryIntentActivities(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER), 0,
        )
        val normal = pm.queryIntentActivities(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER), 0,
        )
        for ((list, isTv) in listOf(leanback to true, normal to false)) {
            for (ri in list) {
                val pkg = ri.activityInfo.packageName
                if (pkg == activity.packageName || apps.containsKey(pkg)) continue
                apps[pkg] = mapOf(
                    "packageName" to pkg,
                    "label" to ri.loadLabel(pm).toString(),
                    "isTvApp" to isTv,
                )
            }
        }
        return apps.values.sortedBy { (it["label"] as String).lowercase() }
    }

    /** Returns a PNG of the app's TV banner (if [banner]) or icon. */
    fun appImage(packageName: String, banner: Boolean): ByteArray? {
        val drawable: Drawable = try {
            (if (banner) pm.getApplicationBanner(packageName) else null)
                ?: pm.getApplicationIcon(packageName)
        } catch (_: PackageManager.NameNotFoundException) {
            return null
        }
        val (w, h) = if (banner) 320 to 180 else 128 to 128
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        drawable.setBounds(0, 0, w, h)
        drawable.draw(canvas)
        val out = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
        bmp.recycle()
        return out.toByteArray()
    }

    fun launchApp(packageName: String): Boolean {
        val intent = pm.getLeanbackLaunchIntentForPackage(packageName)
            ?: pm.getLaunchIntentForPackage(packageName)
            ?: return false
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return tryStart(intent)
    }

    /** Version name for each installed package in [packages]; missing ones are omitted. */
    fun installedVersions(packages: List<String>): Map<String, String?> {
        val out = HashMap<String, String?>()
        for (p in packages) {
            try {
                out[p] = pm.getPackageInfo(p, 0).versionName
            } catch (_: PackageManager.NameNotFoundException) {
            }
        }
        return out
    }

    private fun tryStart(intent: Intent): Boolean = try {
        if (intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK == 0) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity.startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }
}
