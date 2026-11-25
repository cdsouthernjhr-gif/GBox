#!/usr/bin/env bash
# Runs inside the Android emulator job in CI.
# 1. On-device integration tests (real native layer, SQLite, files, UI).
# 2. HOME-launcher checks with adb: GAMEBOX is offered as a HOME app, can be
#    set as default and comes to the front on HOME.
set -euo pipefail
API=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
echo "== Emulator API level: $API"
adb shell getprop ro.build.characteristics | tr -d '\r'

# The emulator can report boot_completed before the package manager is
# ready; an install then hangs indefinitely (seen once on API 24, run #18).
wait_for_package_manager() {
  adb wait-for-device
  for i in $(seq 1 90); do
    if [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = "1" ] \
      && adb shell pm path android 2>/dev/null | grep -q "package:"; then
      echo "package manager ready"
      return 0
    fi
    sleep 2
  done
  echo "package manager not ready after 180 s" >&2
  return 1
}

echo "== Waiting for the package manager"
wait_for_package_manager

# Package verification can make installs wait forever on emulators (no UI
# to answer it). Turn it off for this test device only.
adb shell settings put global verifier_verify_adb_installs 0 || true
adb shell settings put global package_verifier_enable 0 || true

echo "== Pre-install the debug APK (diagnostics if it hangs)"
if ! timeout 300 adb install -r -t -g build/app/outputs/flutter-apk/app-debug.apk; then
  echo "Pre-install failed or hung. PackageManager log:"
  adb logcat -d | grep -iE "PackageManager|PackageInstaller|installd|dex2oat|INSTALL_" | tail -60 || true
  adb shell df /data || true
fi

echo "== Integration tests"
# (The release build is checked separately below: 0.12.0's player worked in
# debug but crashed in release.)
# Bounded so an emulator hang fails fast instead of using the job timeout.
# A timeout (exit 124) is retried once after restarting adb; a test
# failure is not retried.
set +e
timeout 900 flutter test integration_test/device_test.dart -d emulator-5554 --reporter expanded
STATUS=$?
if [ "$STATUS" = 124 ]; then
  echo "Integration tests timed out (emulator hang); restarting adb and retrying once"
  adb kill-server; adb start-server
  wait_for_package_manager
  timeout 900 flutter test integration_test/device_test.dart -d emulator-5554 --reporter expanded
  STATUS=$?
fi
set -e
if [ "$STATUS" != 0 ]; then
  echo "Integration tests failed (exit $STATUS)" >&2
  exit "$STATUS"
fi

echo "== Install debug APK for launcher checks"
# The API 24 emulator sometimes hangs on install (runs #18 and #23): bounded
# attempts, restarting adb in between.
for attempt in 1 2 3; do
  if timeout 180 adb install -r -g build/app/outputs/flutter-apk/app-debug.apk; then
    break
  fi
  if [ "$attempt" = 3 ]; then
    echo "adb install failed 3 times" >&2
    exit 1
  fi
  echo "adb install attempt $attempt failed or hung; restarting adb"
  adb kill-server; adb start-server
  wait_for_package_manager
done

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

echo "== Built-in player in a RELEASE build (R8), like the APKs users install"
RELEASE_APK=build/app/outputs/flutter-apk/app-release.apk
if [ -f "$RELEASE_APK" ]; then
  timeout 300 adb install -r "$RELEASE_APK"
  # Storage access, then a synthetic iNES image (header + 16 KB PRG + 8 KB CHR
  # of zeros; format documentation only) in the shared ROMs folder.
  if [ "$API" -ge 30 ]; then
    adb shell appops set --uid com.gamebox.console MANAGE_EXTERNAL_STORAGE allow
  else
    adb shell pm grant com.gamebox.console android.permission.READ_EXTERNAL_STORAGE || true
    adb shell pm grant com.gamebox.console android.permission.WRITE_EXTERNAL_STORAGE || true
  fi
  ROM_LOCAL=$(mktemp)
  { printf 'NES\x1a\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'; head -c $((16384 + 8192)) /dev/zero; } > "$ROM_LOCAL"
  adb shell mkdir -p /sdcard/ROMs/nes
  adb push "$ROM_LOCAL" /sdcard/ROMs/nes/ci_release_test.nes
  adb logcat -c
  # The alias is only startable from adb (protected by the DUMP permission).
  adb shell am start -W -n com.gamebox.console/.player.PlayerSmokeTest \
    --es core fceumm --es rom /sdcard/ROMs/nes/ci_release_test.nes --es touch off --es title CI
  sleep 12
  # Read the log once (grep -q on a pipe would SIGPIPE adb under pipefail).
  PLAYER_LOG=$(adb logcat -d | tr -d '\r' || true)
  echo "$PLAYER_LOG" | grep -E "GAMEBOX-Player|FATAL|Fatal signal|libretro" || true
  if echo "$PLAYER_LOG" | grep -qE "FATAL EXCEPTION|Fatal signal"; then
    echo "$PLAYER_LOG" | grep -A30 -E "FATAL EXCEPTION|Fatal signal" | head -60 || true
    echo "FAIL: the built-in player crashed in the release build" >&2
    exit 1
  fi
  if ! echo "$PLAYER_LOG" | grep -q "GAMEBOX-Player: running"; then
    echo "FAIL: the built-in player did not render frames in the release build" >&2
    exit 1
  fi
  [ -n "$(adb shell pidof com.gamebox.console | tr -d '\r')" ] || { echo "FAIL: GAMEBOX process died" >&2; exit 1; }
  echo "PASS: release build runs the built-in player (FCEUmm renders frames, no crash)"
  adb shell am force-stop com.gamebox.console
else
  echo "FAIL: $RELEASE_APK not built" >&2
  exit 1
fi

echo "== No crash in log"
if adb logcat -d | grep -E "FATAL EXCEPTION.*|AndroidRuntime.*com.gamebox.console" ; then
  echo "Crash found in logcat" >&2
  exit 1
fi
echo "All device checks passed"
