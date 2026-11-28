#!/usr/bin/env bash
# Downloads the libretro cores GAMEBOX's built-in player bundles into
# android/app/src/main/jniLibs/<abi>/ (git-ignored; run before building).
#
# Source: prebuilt cores of the Lemuroid project (github.com/Swordfish90/
# LemuroidCores), pinned to one commit and verified by SHA-256. Licences:
# docs/THIRD_PARTY_LICENSES.md (fceumm, gambatte, pcsx_rearmed, desmume,
# mupen64plus-next: GPLv2; ppsspp: GPLv2+; mgba: MPL-2.0; snes9x,
# genesis_plus_gx, fbneo: non-commercial).
set -euo pipefail
COMMIT=fee2e824525daa22bcf318f96127fe43fa8a15ad
BASE="https://raw.githubusercontent.com/Swordfish90/LemuroidCores/$COMMIT"
DEST="$(cd "$(dirname "$0")/.." && pwd)/android/app/src/main/jniLibs"
CORES="fceumm snes9x gambatte mgba genesis_plus_gx pcsx_rearmed mupen64plus_next_gles3 desmume fbneo"
# PPSSPP has no x86_64 build in LemuroidCores (PSP is ARM-only in GAMEBOX).
ARM_ONLY_CORES="ppsspp"
ABIS="arm64-v8a armeabi-v7a x86_64"
ASSETS="$(cd "$(dirname "$0")/.." && pwd)/android/app/src/main/assets"

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
c7e44a9f6bfc67411a76d0253e12b546cd36746cc5adf2fffe68146544fe8d7a  arm64-v8a/libmupen64plus_next_gles3_libretro_android.so
34e1966167fb367ee57fd5156557772b406f712b3d72f2248e5e082e994f9ece  armeabi-v7a/libmupen64plus_next_gles3_libretro_android.so
59aaa8e0df8dd665dbf2b9a53c3a0ea3626b2b7c33b4bf2711d91b046fe99f6e  x86_64/libmupen64plus_next_gles3_libretro_android.so
d1ecc0bad6ad6ff573b88315202eb1ffdf7ba4da18c1709c098e1f2744276e0c  arm64-v8a/libdesmume_libretro_android.so
a90af50930057c3643d6a1d5840f716d958b48de90c903736f4d9347571f93ba  armeabi-v7a/libdesmume_libretro_android.so
72e5faa3a613db0b68afe9ec84aa62db8fad1ca5568750d315b27606728ab2a6  x86_64/libdesmume_libretro_android.so
88fd9f4aa9d8f235b58e64e78947ede0965c1e7ff85caf03dbcfcfe914b2e583  arm64-v8a/libfbneo_libretro_android.so
52d96ed7a86e865dfabeb77392793867ac688e289d55f605c07b9ee1844010aa  armeabi-v7a/libfbneo_libretro_android.so
144876bf1c0897ed506efd431a745ccb0e6cd6d87c9d778a67cb4c0a2f5736ef  x86_64/libfbneo_libretro_android.so
2d5370602e07df1e5bc0fb20467cff52aafa8ccbade904b5d7f60b3eebd2ff23  arm64-v8a/libppsspp_libretro_android.so
c0e5522565afc64c034b858cec96d5122adaeca1cdf1a33d9c090f77fec9bbf3  armeabi-v7a/libppsspp_libretro_android.so
2ae4b85598b1759ee405cefeea2d8cf8a75971ff641b860b7fc45a8c83eca0d5  assets/ppsspp.zip
SUMS_END
)

# fetch <checksum key> <url path> <destination>
fetch() {
  local key="$1" path="$2" out="$3"
  local want
  want=$(echo "$SUMS" | awk -v f="$key" '$2 == f {print $1}')
  if [ -z "$want" ]; then echo "no checksum for $key" >&2; exit 1; fi
  mkdir -p "$(dirname "$out")"
  if [ -f "$out" ] && echo "$want  $out" | sha256sum -c --status; then
    return 0
  fi
  for attempt in 1 2 3; do
    if curl -fsSL --retry 3 -o "$out.tmp" "$BASE/$path"; then break; fi
    [ "$attempt" = 3 ] && { echo "download failed: $key" >&2; exit 1; }
    sleep $((attempt * 5))
  done
  if ! echo "$want  $out.tmp" | sha256sum -c --status; then
    echo "checksum mismatch: $key" >&2
    rm -f "$out.tmp"
    exit 1
  fi
  mv "$out.tmp" "$out"
}

for abi in $ABIS; do
  cores="$CORES"
  [ "$abi" != x86_64 ] && cores="$cores $ARM_ONLY_CORES"
  for core in $cores; do
    file="$abi/lib${core}_libretro_android.so"
    fetch "$file" "lemuroid_core_$core/src/main/jniLibs/$file" "$DEST/$file"
  done
done
# PPSSPP's assets (fonts, flash0): extracted by the player on first PSP game.
fetch assets/ppsspp.zip assets/ppsspp.zip "$ASSETS/ppsspp.zip"
echo "Cores ready in $DEST"
