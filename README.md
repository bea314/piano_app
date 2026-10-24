# PIANO by Eu De

Piano sencillo en Flutter con audio nativo (C++ / OpenSL ES en Android). Objetivo actual: **primera versión en Google Play**; mejoras de sonido (SoundFont, etc.) en fases posteriores.

## Estado del producto

- Motor de audio: síntesis básica en C++ (sin SoundFont).
- UI: teclado Flutter + Riverpod.
- Android: `applicationId` `com.be314.piano`, `minSdk` 24.

## Roadmap

### Fase 1 — Play Store (ahora)

- [ ] Pulir teclado (octavas, landscape, scroll si hace falta).
- [ ] Ajustar latencia y clicks/pops en audio.
- [ ] Ícono, capturas de pantalla y textos de la ficha.
- [ ] Política de privacidad (URL pública; la app no pide permisos sensibles hoy).
- [ ] Firma de release (`key.properties` + keystore) y `flutter build appbundle`.
- [ ] Subir AAB a Play Console (prueba interna → producción).

### Fase 2 — Después del lanzamiento

- [ ] SoundFont / FluidSynth (descarga bajo demanda o SF2 ligero).
- [ ] Más octavas, volumen, opciones de sonido.
- [ ] iOS si aplica.

## Build para Play Store

1. Crear keystore (una sola vez; **guardar copia segura**):

   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. En `android/key.properties` (no se sube a Git):

   ```properties
   storePassword=<tu-password>
   keyPassword=<tu-password>
   keyAlias=upload
   storeFile=<ruta-al-jks>
   ```

3. Configurar firma release en `android/app/build.gradle.kts` (plantilla estándar de Flutter).

4. Generar el bundle:

   ```bash
   flutter build appbundle --release
   ```

   Salida: `build/app/outputs/bundle/release/app-release.aab`

## Desarrollo local

```bash
flutter pub get
flutter run
```

## SoundFont (.sf2)

No forma parte del repositorio: archivos muy grandes y el motor actual no los usa. Cuando toque la fase 2, se puede añadir un SF2 pequeño, Git LFS o descarga en la primera ejecución.
