# A115M QTI HIDL Reconstruction — Stage 2C.0.3

This package reconstructs only the QTI `IBluetoothAudioPort` contract needed
for offline ABI comparison.

## Established from the A115M blobs

The QTI interface has five functional slots:

1. `startStream()`
2. `suspendStream()`
3. `stopStream()`
4. `getPresentationPosition(...)`
5. `updateAptxMode(uint16_t)`

The fifth method occupies the slot used by AOSP for source metadata updates.

## Expected ABI from the A115M vendor blob

- `_ZTV...IBluetoothAudioPortE`: 272 bytes
- `_ZTT...IBluetoothAudioPortE`: 32 bytes
- primary address point: `_ZTV + 24`
- secondary address point: `_ZTV + 224`
- five pure-virtual functional slots
- exact mangled symbol for:
  `IBluetoothAudioPort::updateAptxMode(unsigned short)`

## Build environment

Use an Android 10 / VNDK 29 compatible AOSP tree. This package is not meant
for direct NDK-only compilation because generated HIDL interfaces depend on
`libhidlbase`, `libutils`, generated `IBase` headers and Soong integration.

## Steps

1. Copy `vendor/qti/hardware/bluetooth_audio/2.0` into the root of an AOSP tree.
2. Run `tools/generate.sh` from the AOSP root.
3. Build the generated interface.
4. Run `tools/verify_abi.sh` against the generated shared library.
5. Do not deploy anything unless every check passes.


## Target correction for the A115M

The tested A115M vendor reports VNDK 29. The reference build and ABI checks
must therefore use an Android 10 / API 29 platform environment, preferably
the official `android-10.0.0_r47` tag. Generating headers with another HIDL
version may be useful for comparison, but deployable binaries must not be
accepted unless their dynamic dependencies and ABI are compatible with
VNDK 29.

Recommended manifest tag:

```text
android-10.0.0_r47
```

Runtime gate:

- target architecture: arm64
- target API/VNDK: 29
- no dependency on VNDK 30-only libraries or symbols
- compare DT_NEEDED and versioned symbols against the A115M vendor blobs
