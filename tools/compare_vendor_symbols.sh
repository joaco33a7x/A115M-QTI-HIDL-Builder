#!/usr/bin/env bash
set -euo pipefail

GENERATED="${1:-}"
VENDOR="${2:-}"

if [[ ! -f "$GENERATED" || ! -f "$VENDOR" ]]; then
  echo "Uso: $0 generated.so vendor.qti.hardware.bluetooth_audio@2.0.so"
  exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

nm -D -C "$GENERATED" |
  grep 'IBluetoothAudioPort' |
  sed -E 's/^[0-9a-fA-F]+ [A-Za-z] //' |
  sort -u > "$TMP/generated.txt"

nm -D -C "$VENDOR" |
  grep 'IBluetoothAudioPort' |
  sed -E 's/^[0-9a-fA-F]+ [A-Za-z] //' |
  sort -u > "$TMP/vendor.txt"

echo "=== Solo en generado ==="
comm -23 "$TMP/generated.txt" "$TMP/vendor.txt" || true

echo
echo "=== Solo en vendor ==="
comm -13 "$TMP/generated.txt" "$TMP/vendor.txt" || true

echo
echo "=== Coincidentes ==="
comm -12 "$TMP/generated.txt" "$TMP/vendor.txt" || true
