#!/usr/bin/env bash
set -euo pipefail

AOSP_ROOT="${AOSP_ROOT:-$(pwd)}"
PKG="vendor.qti.hardware.bluetooth_audio@2.0"
ROOT_ARG="vendor.qti.hardware:vendor/qti/hardware"

cd "$AOSP_ROOT"

command -v hidl-gen >/dev/null 2>&1 || {
  echo "ERROR: hidl-gen no está disponible."
  echo "Ejecutá: source build/envsetup.sh && lunch <target>"
  exit 1
}

echo "[1/4] Validando sintaxis HIDL"
hidl-gen -Lcheck \
  -r"$ROOT_ARG" \
  -randroid.hidl:system/libhidl/transport \
  "$PKG"

echo "[2/4] Generando Android.bp"
hidl-gen -Landroidbp \
  -r"$ROOT_ARG" \
  -randroid.hidl:system/libhidl/transport \
  "$PKG" > vendor/qti/hardware/bluetooth_audio/2.0/Android.bp.generated

echo "[3/4] Generando headers C++"
rm -rf out/qti_bt_audio_hidl_headers
mkdir -p out/qti_bt_audio_hidl_headers
hidl-gen -o out/qti_bt_audio_hidl_headers \
  -Lc++-headers \
  -r"$ROOT_ARG" \
  -randroid.hidl:system/libhidl/transport \
  "$PKG"

echo "[4/4] Generando fuentes C++"
rm -rf out/qti_bt_audio_hidl_sources
mkdir -p out/qti_bt_audio_hidl_sources
hidl-gen -o out/qti_bt_audio_hidl_sources \
  -Lc++-sources \
  -r"$ROOT_ARG" \
  -randroid.hidl:system/libhidl/transport \
  "$PKG"

echo "Generación completada."
echo "Ahora compilá: m vendor.qti.hardware.bluetooth_audio@2.0"
