package com.gamebox.console.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import io.flutter.plugin.common.EventChannel

/** Online/offline status. Offline is the normal, fully supported state. */
class ConnectivityMonitor(private val context: Context) : EventChannel.StreamHandler {
    private val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private var sink: EventChannel.EventSink? = null
    private var callback: ConnectivityManager.NetworkCallback? = null

    fun status(): Map<String, Any?> {
        val network = cm.activeNetwork
        val caps = network?.let { cm.getNetworkCapabilities(it) }
        val transport = when {
            caps == null -> "none"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
            else -> "other"
        }
        return mapOf(
            "connected" to (caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true),
            "validated" to (caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true),
            "transport" to transport,
        )
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        val cb = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) = push()
            override fun onLost(network: Network) = push()
            override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) = push()
        }
        callback = cb
        try {
            cm.registerNetworkCallback(NetworkRequest.Builder().build(), cb)
        } catch (_: SecurityException) {
        }
        push()
    }

    override fun onCancel(arguments: Any?) {
        callback?.let { try { cm.unregisterNetworkCallback(it) } catch (_: Throwable) {} }
        callback = null
        sink = null
    }

    private fun push() {
        Background.postMain { sink?.success(status()) }
    }
}

/** Emits an event whenever removable media is mounted, ejected or removed. */
class StorageEvents(private val context: Context) : EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val r = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                events?.success(
                    mapOf(
                        "action" to (intent?.action?.substringAfterLast('.') ?: "unknown"),
                        "path" to intent?.data?.path,
                    ),
                )
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_MEDIA_MOUNTED)
            addAction(Intent.ACTION_MEDIA_UNMOUNTED)
            addAction(Intent.ACTION_MEDIA_REMOVED)
            addAction(Intent.ACTION_MEDIA_BAD_REMOVAL)
            addAction(Intent.ACTION_MEDIA_EJECT)
            addDataScheme("file")
        }
        receiver = r
        // Media broadcasts are system broadcasts, so the receiver does not
        // need to be exported to other apps.
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(r, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(r, filter)
        }
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let { try { context.unregisterReceiver(it) } catch (_: Throwable) {} }
        receiver = null
    }
}
