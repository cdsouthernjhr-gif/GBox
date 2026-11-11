package com.gamebox.console

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.view.KeyEvent
import android.view.MotionEvent
import com.gamebox.console.controllers.ControllerManager
import com.gamebox.console.controllers.RawInputStream
import com.gamebox.console.hardware.HardwareScanner
import com.gamebox.console.launcher.LauncherBridge
import com.gamebox.console.services.Background
import com.gamebox.console.services.ConnectivityMonitor
import com.gamebox.console.services.StorageEvents
import com.gamebox.console.storage.StorageScanner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Single activity hosting the Flutter UI. Registered for MAIN/LAUNCHER,
 * LEANBACK_LAUNCHER and HOME so it can act as the device launcher.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val REQUEST_PICK_DIRECTORY = 4102
    }

    private lateinit var launcher: LauncherBridge
    private lateinit var connectivity: ConnectivityMonitor
    private val rawInput = RawInputStream()
    private var launcherChannel: MethodChannel? = null
    private var pendingDirectoryResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        launcher = LauncherBridge(this)
        connectivity = ConnectivityMonitor(applicationContext)
        val controllers = ControllerManager(applicationContext)

        MethodChannel(messenger, "gamebox/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "scan" -> Background.run(result) { HardwareScanner(applicationContext).scan() }
                "memory" -> Background.run(result) { HardwareScanner(applicationContext).memoryInfo() }
                "connectivity" -> result.success(connectivity.status())
                else -> result.notImplemented()
            }
        }

        launcherChannel = MethodChannel(messenger, "gamebox/launcher").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDefaultLauncher" -> result.success(launcher.isDefaultLauncher())
                    "requestDefaultLauncher" -> result.success(launcher.requestDefaultLauncher())
                    "openHomeSettings" -> result.success(launcher.openHomeSettings())
                    "openAndroidSettings" -> result.success(launcher.openAndroidSettings())
                    "openAppDetails" -> result.success(
                        launcher.openAppDetails(call.argument<String>("packageName") ?: packageName),
                    )
                    "listApps" -> Background.run(result) { launcher.listApps() }
                    "appImage" -> Background.run(result) {
                        launcher.appImage(
                            call.argument<String>("packageName")!!,
                            call.argument<Boolean>("banner") ?: false,
                        )
                    }
                    "launchApp" -> result.success(launcher.launchApp(call.argument<String>("packageName")!!))
                    "installedVersions" -> Background.run(result) {
                        launcher.installedVersions(call.argument<List<String>>("packages") ?: emptyList())
                    }
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(messenger, "gamebox/controllers").setMethodCallHandler { call, result ->
            when (call.method) {
                "list" -> result.success(controllers.listDevices())
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, "gamebox/storage").setMethodCallHandler { call, result ->
            when (call.method) {
                "volumes" -> Background.run(result) { StorageScanner(applicationContext).volumes() }
                "pickDirectory" -> pickDirectory(result)
                "persistedDirectories" -> result.success(
                    contentResolver.persistedUriPermissions.map {
                        mapOf("uri" to it.uri.toString(), "read" to it.isReadPermission, "write" to it.isWritePermission)
                    },
                )
                "releaseDirectory" -> {
                    try {
                        contentResolver.releasePersistableUriPermission(
                            Uri.parse(call.argument<String>("uri")),
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                        )
                        result.success(true)
                    } catch (e: SecurityException) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "gamebox/controller_events").setStreamHandler(controllers.DeviceEvents())
        EventChannel(messenger, "gamebox/raw_input").setStreamHandler(rawInput)
        EventChannel(messenger, "gamebox/connectivity").setStreamHandler(connectivity)
        EventChannel(messenger, "gamebox/storage_events").setStreamHandler(StorageEvents(applicationContext))
    }

    /** Storage Access Framework folder picker with persisted permission. */
    private fun pickDirectory(result: MethodChannel.Result) {
        if (pendingDirectoryResult != null) {
            result.error("busy", "A folder picker is already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )
        try {
            pendingDirectoryResult = result
            startActivityForResult(intent, REQUEST_PICK_DIRECTORY)
        } catch (e: ActivityNotFoundException) {
            pendingDirectoryResult = null
            // Some TV firmwares ship without the DocumentsUI picker.
            result.error("saf_unavailable", "This device has no system folder picker", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_PICK_DIRECTORY) {
            val pending = pendingDirectoryResult ?: return
            pendingDirectoryResult = null
            val uri = data?.data
            if (resultCode != Activity.RESULT_OK || uri == null) {
                pending.success(null)
                return
            }
            try {
                contentResolver.takePersistableUriPermission(
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                )
            } catch (_: SecurityException) {
                try {
                    contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                } catch (_: SecurityException) {
                }
            }
            pending.success(uri.toString())
        }
    }

    /** Pressing HOME while GAMEBOX is the launcher returns to the dashboard. */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.hasCategory(Intent.CATEGORY_HOME)) {
            launcherChannel?.invokeMethod("onHomePressed", null)
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (rawInput.isListening) rawInput.onKey(event)
        return super.dispatchKeyEvent(event)
    }

    override fun dispatchGenericMotionEvent(ev: MotionEvent): Boolean {
        if (rawInput.isListening) rawInput.onMotion(ev)
        return super.dispatchGenericMotionEvent(ev)
    }
}
