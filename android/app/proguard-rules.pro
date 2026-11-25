# Built-in player (LibretroDroid). Its native code looks up these classes,
# fields and methods by name through JNI (Variable, Controller, shaders,
# exceptions, virtual files, callbacks), and the library ships no keep rules.
# Without this, R8 renames them in release builds and the player crashes as
# soon as a core starts (seen in 0.12.0: black screen, then the app closes).
-keep class com.swordfish.libretrodroid.** { *; }
-keepclassmembers class com.swordfish.libretrodroid.** { *; }

# GLRetroView uses @OnLifecycleEvent callbacks (called by reflection).
-keepclassmembers class * implements androidx.lifecycle.LifecycleObserver {
    @androidx.lifecycle.OnLifecycleEvent <methods>;
}

# GAMEBOX's player activity and status (started/read by name).
-keep class com.gamebox.console.player.** { *; }
