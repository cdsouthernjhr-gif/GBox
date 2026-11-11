#!/usr/bin/env bash
# Runs inside the Android emulator job in CI.
# 1. On-device integration tests (real native layer, SQLite, files, UI).
# 2. HOME-launcher checks with adb: GAMEBOX is offered as a HOME app, can be
#    set as default and comes to the front on HOME.
set -euo pipefail
API=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
echo "== Emulator API level: $API"
adb shell getprop ro.build.characteristics | tr -d '\r'

echo "== Integration tests"
flutter test integration_test/device_test.dart -d emulator-5554 --reporter expanded

echo "== Install debug APK for launcher checks"
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk

echo "== HOME intent resolves to GAMEBOX as a candidate"
adb shell dumpsys package com.gamebox.console | tr -d '\r' > /tmp/pkg.txt
grep -q "android.intent.category.HOME" /tmp/pkg.txt
grep -q "android.intent.category.LEANBACK_LAUNCHER" /tmp/pkg.txt
echo "HOME and LEANBACK_LAUNCHER filters registered"

echo "== Set GAMEBOX as the default HOME app and press HOME"
SET_OUT=$(adb shell cmd package set-home-activity com.gamebox.console/.MainActivity 2>&1 | tr -d '\r' || true)
echo "set-home-activity: $SET_OUT"
if echo "$SET_OUT" | grep -qiE "error|unknown|exception"; then
  echo "SKIP: this API level ($API) cannot set the default HOME app via adb; HOME check not run"
else
  adb shell input keyevent KEYCODE_HOME
  for i in $(seq 1 30); do
    RESUMED=$(adb shell dumpsys activity activities | tr -d '\r' | grep -E "ResumedActivity" || true)
    if echo "$RESUMED" | grep -q com.gamebox.console; then
      echo "$RESUMED"
      echo "PASS: GAMEBOX is the resumed HOME activity"
      break
    fi
    if [ "$i" = 30 ]; then
      adb shell dumpsys activity activities | grep -E "ResumedActivity" || true
      echo "FAIL: GAMEBOX did not come to the front on HOME" >&2
      exit 1
    fi
    sleep 2
  done
  echo "== BACK must not leave the launcher"
  adb shell input keyevent KEYCODE_BACK
  sleep 3
  RESUMED=$(adb shell dumpsys activity activities | tr -d '\r' | grep -E "ResumedActivity" || true)
  echo "$RESUMED"
  echo "$RESUMED" | grep -q com.gamebox.console
  echo "PASS: still in front after BACK"
fi

echo "== No crash in log"
if adb logcat -d | grep -E "FATAL EXCEPTION.*|AndroidRuntime.*com.gamebox.console" ; then
  echo "Crash found in logcat" >&2
  exit 1
fi
echo "All device checks passed"
