#!/usr/bin/env bash
# Checks the native libraries packaged in APKs:
#  1. every LOAD segment is aligned to at least 16 KB (Android 15+ devices
#     with 16 KB pages refuse libraries that aren't);
#  2. each bundled libretro core is the pinned build: its GNU build ID equals
#     the one of the file fetched by tool/fetch_cores.sh. (The SHA-256 of the
#     packaged file differs: AGP's strip step rewrites the ELF section-name
#     table without changing code or data.)
#
# Usage: tool/check_native_libs.sh <jniLibs dir> <apk>...
set -euo pipefail

JNI="$1"; shift
[ -d "$JNI" ] || { echo "no jniLibs folder: $JNI" >&2; exit 1; }
fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

build_id() {
  local out
  out=$(readelf -n "$1" 2>/dev/null) || return 0
  sed -n 's/.*Build ID: \([0-9a-f]*\).*/\1/p' <<<"$out"
}

for apk in "$@"; do
  name=$(basename "$apk")
  rm -rf "$tmp/x" && mkdir -p "$tmp/x"
  unzip -q -o "$apk" 'lib/*' -d "$tmp/x" || { echo "$name: no native libraries" >&2; fail=1; continue; }
  checked=0
  for so in "$tmp"/x/lib/*/*.so; do
    abi=$(basename "$(dirname "$so")")
    lib=$(basename "$so")
    segs=$(readelf -lW "$so")
    # Last column of each LOAD line is the alignment, in hex (0x4000).
    while read -r hex; do
      [ -z "$hex" ] && continue
      align=$((16#${hex#0x}))
      if (( align < 16384 )); then
        echo "$name: $abi/$lib has a LOAD segment aligned to $align bytes (needs 16384)" >&2
        fail=1
      fi
    done < <(awk '$1 == "LOAD" { print $NF }' <<<"$segs")
    if [[ "$lib" == *_libretro_android.so ]]; then
      src="$JNI/$abi/$lib"
      if [ ! -f "$src" ]; then
        echo "$name: $abi/$lib is not in $JNI" >&2
        fail=1
      else
        want=$(build_id "$src"); got=$(build_id "$so")
        if [ -z "$want" ] || [ "$want" != "$got" ]; then
          echo "$name: $abi/$lib build ID ${got:-none} differs from the fetched core (${want:-none})" >&2
          fail=1
        fi
      fi
    fi
    checked=$((checked + 1))
  done
  echo "$name: $checked native libraries checked"
done
exit $fail
