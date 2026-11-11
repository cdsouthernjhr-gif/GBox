package com.gamebox.console.services

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Runs blocking platform work (file reads, EGL probing, package queries) off the
 * UI thread and delivers the MethodChannel result back on the main thread, as
 * the Flutter embedding requires.
 */
object Background {
    private const val TAG = "GameBox"
    private val executor: ExecutorService = Executors.newFixedThreadPool(2)
    private val main = Handler(Looper.getMainLooper())

    fun run(result: MethodChannel.Result, block: () -> Any?) {
        executor.execute {
            try {
                val value = block()
                main.post { result.success(value) }
            } catch (t: Throwable) {
                Log.e(TAG, "Platform call failed", t)
                main.post { result.error("native_error", t.message ?: t.javaClass.simpleName, null) }
            }
        }
    }

    fun postMain(block: () -> Unit) {
        main.post(block)
    }
}
