# PIANO by Eu De

Piano sencillo en Flutter con audio nativo (C++ / OpenSL ES en Android). Objetivo actual: **primera versión en Google Play**; mejoras de sonido (SoundFont, etc.) en fases posteriores.

## Estado del producto

- Motor de audio: síntesis básica en C++ (sin SoundFont).
- UI: teclado Flutter + Riverpod.
- Android: `applicationId` `com.be314.piano`, `minSdk` 24, versión `1.0.0` (`versionCode` 1 en `pubspec.yaml`).

## Documentación legal y tienda

| Documento | Uso |
|-----------|-----|
| [docs/PRIVACY.md](docs/PRIVACY.md) | Política de privacidad (ES/EN). Publicar en una **URL HTTPS** para Play Console. |
| [docs/TERMS.md](docs/TERMS.md) | Términos de uso (ES/EN). En repo por ahora; más adelante puede alojarse en krealistudio.com. |
| [docs/STORE_LISTING.md](docs/STORE_LISTING.md) | Borradores de ficha Play (ES/EN), checklist de gráficos y data safety. |

## Roadmap

### Fase 1 — Play Store (ahora)

- [ ] Pulir teclado (octavas, landscape, scroll si hace falta).
- [ ] Ajustar latencia y clicks/pops en audio.
- [ ] Ícono, capturas de pantalla y textos de la ficha.
- [ ] Política de privacidad (URL pública; ver [docs/PRIVACY.md](docs/PRIVACY.md)).
- [ ] Firma de release (`key.properties` + keystore) y `flutter build appbundle`.
- [ ] Subir AAB a Play Console (prueba interna → producción).

### Fase 2 — Después del lanzamiento

- [ ] SoundFont / FluidSynth (descarga bajo demanda o SF2 ligero).
- [ ] Más octavas, volumen, opciones de sonido.
- [ ] iOS si aplica.

## Build para Play Store (local — Bea)

Los secretos **no** van en Git. Ya están ignorados: `android/key.properties`, `*.jks`, `**/*.keystore` (ver `android/.gitignore` y `.gitignore`).

### 1. Crear keystore (una sola vez)

Guarda el `.jks` en un lugar seguro (copia de respaldo fuera del repo).

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

`keytool` pedirá contraseñas y datos del certificado; elige valores que recuerdes y guarda.

### 2. `android/key.properties`

Copia la plantilla y rellena con tus valores reales (rutas y contraseñas):

```bash
cp android/key.properties.example android/key.properties
```

Ejemplo de contenido (sustituye rutas y contraseñas):

```properties
storePassword=<la que elegiste al crear el keystore>
keyPassword=<normalmente la misma que storePassword>
keyAlias=upload
storeFile=/ruta/absoluta/a/upload-keystore.jks
```

Con `key.properties` presente, `android/app/build.gradle.kts` firma el build `release` con ese keystore. **Sin** `key.properties`, el proyecto sigue configurándose y el `release` usa firma debug (útil para CI o probar el pipeline; **no** sirve para subir a Play).

### 3. Generar el App Bundle

Desde la raíz del repo:

```bash
flutter pub get
flutter analyze
flutter build appbundle --release
```

Salida: `build/app/outputs/bundle/release/app-release.aab`

### 4. Play Console

- Sube el AAB en una pista de prueba interna primero.
- Pega la **URL pública** de la política de privacidad (contenido en [docs/PRIVACY.md](docs/PRIVACY.md)).
- Usa los textos de [docs/STORE_LISTING.md](docs/STORE_LISTING.md) como borrador.

## Desarrollo local

```bash
flutter pub get
flutter run
```

## SoundFont (.sf2)

No forma parte del repositorio: archivos muy grandes y el motor actual no los usa. Cuando toque la fase 2, se puede añadir un SF2 pequeño, Git LFS o descarga en la primera ejecución.
