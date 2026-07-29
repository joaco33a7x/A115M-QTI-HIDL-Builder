#!/usr/bin/env bash
set -euo pipefail

LIB="${1:-}"
if [[ -z "$LIB" || ! -f "$LIB" ]]; then
  echo "Uso: $0 /ruta/a/vendor.qti.hardware.bluetooth_audio@2.0.so"
  exit 2
fi

ZTV="_ZTVN6vendor3qti8hardware15bluetooth_audio4V2_019IBluetoothAudioPortE"
ZTT="_ZTTN6vendor3qti8hardware15bluetooth_audio4V2_019IBluetoothAudioPortE"
APTX="_ZN6vendor3qti8hardware15bluetooth_audio4V2_019IBluetoothAudioPort14updateAptxModeEt"

fail() {
  echo "ABI_FAIL: $*" >&2
  exit 1
}

symbol_size() {
  local sym="$1"
  readelf -Ws "$LIB" |
    awk -v s="$sym" '$8 == s {print $3; exit}'
}

echo "=== Verificando símbolos ==="
readelf -Ws "$LIB" | grep -F "$ZTV" >/dev/null || fail "Falta _ZTV"
readelf -Ws "$LIB" | grep -F "$ZTT" >/dev/null || fail "Falta _ZTT"
readelf -Ws "$LIB" | grep -F "$APTX" >/dev/null || fail "Falta updateAptxMode(uint16_t)"

ZTV_SIZE="$(symbol_size "$ZTV")"
ZTT_SIZE="$(symbol_size "$ZTT")"

[[ "$ZTV_SIZE" == "272" ]] || fail "_ZTV mide $ZTV_SIZE; esperado 272"
[[ "$ZTT_SIZE" == "32" ]] || fail "_ZTT mide $ZTT_SIZE; esperado 32"

echo "=== Verificando que el slot AOSP de metadata no aparezca ==="
if nm -D -C "$LIB" | grep -F "IBluetoothAudioPort::updateMetadata" >/dev/null; then
  fail "Aparece updateMetadata; el quinto slot no coincide con QTI"
fi

echo "=== Métodos propios ==="
nm -D -C "$LIB" |
  grep -E 'IBluetoothAudioPort::(startStream|suspendStream|stopStream|getPresentationPosition|updateAptxMode)' |
  sort -u

COUNT="$(
  nm -D -C "$LIB" |
    grep -E 'IBluetoothAudioPort::(startStream|suspendStream|stopStream|getPresentationPosition|updateAptxMode)' |
    sed -E 's/.*IBluetoothAudioPort:://' |
    sort -u |
    wc -l
)"
[[ "$COUNT" -ge "5" ]] || fail "Solo se localizaron $COUNT métodos funcionales"


echo "=== Gate de dependencias para VNDK 29 ==="
readelf -d "$LIB" | grep -E 'NEEDED|SONAME' || true
if readelf -d "$LIB" | grep -E 'com\.android\.vndk\.v30|vndk-30' >/dev/null; then
  fail "La biblioteca referencia explícitamente VNDK 30"
fi

echo "=== Secciones y relocaciones relacionadas ==="
readelf -Wr "$LIB" |
  grep -E 'IBluetoothAudioPort|updateAptxMode' || true

echo "ABI_STATIC_CHECKS_PASSED"
echo
echo "Los address points +24 y +224 deben validarse con el mapper dinámico."
