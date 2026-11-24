package com.gamebox.console.player

import java.lang.ref.WeakReference

/**
 * Live state of the built-in player, read by GAMEBOX (and the on-device
 * tests) through the "gamebox/emulator" channel.
 */
object PlayerStatus {
    /** idle | starting | running | error | closed */
    @Volatile var state: String = "idle"
    @Volatile var frames: Long = 0
    @Volatile var errorCode: Int? = null
    @Volatile var errorMessage: String? = null
    @Volatile var core: String? = null
    var activity: WeakReference<PlayerActivity>? = null

    fun reset(core: String?) {
        state = "starting"
        frames = 0
        errorCode = null
        errorMessage = null
        this.core = core
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "state" to state,
        "frames" to frames,
        "errorCode" to errorCode,
        "errorMessage" to errorMessage,
        "core" to core,
    )
}
