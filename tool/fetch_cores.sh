#!/usr/bin/env bash
# Downloads the libretro cores GAMEBOX's built-in player bundles into
# android/app/src/main/jniLibs/<abi>/ (git-ignored; run before building).
#
# Source: prebuilt cores of the Lemuroid project (github.com/Swordfish90/
# LemuroidCores), pinned to one commit and verified by SHA-256. Licences:
# docs/THIRD_PARTY_LICENSES.md (fceumm, gambatte, pcsx_rearmed: GPLv2;
# mgba: MPL-2.0; snes9x, genesis_plus_gx: non-commercial).
set -euo pipefail
COMMIT=fee2e824525daa22bcf318f96127fe43fa8a15ad
BASE="https://raw.githubusercontent.com/Swordfish90/LemuroidCores/$COMMIT"
DEST="$(cd "$(dirname "$0")/.." && pwd)/android/app/src/main/jniLibs"
CORES="fceumm snes9x gambatte mgba genesis_plus_gx pcsx_rearmed"
ABIS="arm64-v8a armeabi-v7a x86_64"

SUMS=$(cat <<'SUMS_END'
a47b7abf60d5cf964e320b7db164379eef0201f05319a248f3f7591308aa2778  arm64-v8a/libfceumm_libretro_android.so
546c3f3a5517518b74258290983164638561c47fc779588f702a5cc215a5ec59  arm64-v8a/libgambatte_libretro_android.so
9c958d1fe2c060cf824aaa503751e32c9c819d0b3a3584c959a32cb954c3a000  arm64-v8a/libgenesis_plus_gx_libretro_android.so
fbb03681b7d7ea4fa04bac0f60a005d9fcdc732ece3df1b715fabc19d1f9b2ab  arm64-v8a/libmgba_libretro_android.so
1c32c21dcc488889db7556bd0bd11c72219228f8d35d36bc30c640472af21fd3  arm64-v8a/libpcsx_rearmed_libretro_android.so
4e5dc9199967f23bca5a8f56142f737ecd110b75afd05b2b90df6bf622b2806b  arm64-v8a/libsnes9x_libretro_android.so
b1ab0b653d5d8444af9e8694561cb26b988b31e858836cd70f4ea4f3b59479a6  armeabi-v7a/libfceumm_libretro_android.so
3da81562859af951004c61cd0638f177f005d654ceeb689a72e7955a8922b4bb  armeabi-v7a/libgambatte_libretro_android.so
0814b912f6748f722beb68ad01ebfa483b35fc5ef1dc175625c44196c1f01d1d  armeabi-v7a/libgenesis_plus_gx_libretro_android.so
1481af87811ab5c77fb8cf8d2af6d168d9b8ee873b3967644d16280617ee4208  armeabi-v7a/libmgba_libretro_android.so
7d2fdd86bc258c13ec1be0b123ba0883192d614fa9a12676552976f0bc71902d  armeabi-v7a/libpcsx_rearmed_libretro_android.so
b4e95f0bb3945c6dcbd196b67ae3ae8e62c03c4c2da9bd186fee5b4c5ae6a416  armeabi-v7a/libsnes9x_libretro_android.so
c10d9d4bc1c70c1eb62357429c0fc3df005a58099ef1ff6a5e1984c60e5980b1  x86_64/libfceumm_libretro_android.so
2e6a13b4e1ac03309d46990786cd4465a1e80038eb441d38a12de8678943f2a8  x86_64/libgambatte_libretro_android.so
c86491984c675edec6a61e765244952d7caa7335c36534f9e802a71ae3647f26  x86_64/libgenesis_plus_gx_libretro_android.so
3ed96eb2299ac97e9400c2ddbd111c4877d2c5f4f1e2b9a22fba1845f1f16007  x86_64/libmgba_libretro_android.so
0d3e89477595ed1952f1acbbea256a81aaeb12feeafb5ec8c0798be78b3db52f  x86_64/libpcsx_rearmed_libretro_android.so
4b58c9e5b92aea6a0b08ad76e99a4a5f112f84fdfdd7e2e382bcfd0b284cd0ee  x86_64/libsnes9x_libretro_android.so
SUMS_END
)

for abi in $ABIS; do
  mkdir -p "$DEST/$abi"
  for core in $CORES; do
    file="$abi/lib${core}_libretro_android.so"
    want=$(echo "$SUMS" | awk -v f="$file" '$2 == f {print $1}')
    if [ -z "$want" ]; then echo "no checksum for $file" >&2; exit 1; fi
    out="$DEST/$file"
    if [ -f "$out" ] && echo "$want  $out" | sha256sum -c --status; then
      continue
    fi
    for attempt in 1 2 3; do
      if curl -fsSL --retry 3 -o "$out.tmp" "$BASE/lemuroid_core_$core/src/main/jniLibs/$file"; then break; fi
      [ "$attempt" = 3 ] && { echo "download failed: $file" >&2; exit 1; }
      sleep $((attempt * 5))
    done
    if ! echo "$want  $out.tmp" | sha256sum -c --status; then
      echo "checksum mismatch: $file" >&2
      rm -f "$out.tmp"
      exit 1
    fi
    mv "$out.tmp" "$out"
  done
done
echo "Cores ready in $DEST"
