# Gate de seguridad VNDK 29 antes de Stage 2C.0.4

- [ ] `hidl-gen -Lcheck` termina sin errores.
- [ ] El paquete generado usa namespace `vendor::qti::hardware`.
- [ ] `_ZTV IBluetoothAudioPort` mide 272 bytes.
- [ ] `_ZTT IBluetoothAudioPort` mide 32 bytes.
- [ ] Existe `updateAptxMode(unsigned short)`.
- [ ] No existe `updateMetadata(SourceMetadata)` en la interfaz QTI.
- [ ] Se observan cinco métodos funcionales en el orden medido.
- [ ] Address point primario confirmado en `+24`.
- [ ] Address point secundario confirmado en `+224`.
- [ ] El objeto local entra y sale de `android::sp<>` sin fuga ni doble destrucción.
- [ ] `interfaceDescriptor()`, `ping()` y `getDebugInfo()` responden.
- [ ] No se llama `startSession()` durante la autoprueba.


- [ ] Compilado desde AOSP Android 10 (`android-10.0.0_r47`) o equivalente API 29.
- [ ] Variante vendor ARM64 construida con objetivo VNDK 29.
- [ ] `DT_NEEDED` no contiene dependencias exclusivas de VNDK 30.
- [ ] Símbolos importados compatibles con las bibliotecas del vendor VNDK 29.
