# 🧰 Toolbox App — Flutter

Aplicación Flutter multi-herramientas con 8 vistas, hecha con Dart puro y
Material 3. No requiere ninguna API key: todas las APIs usadas son públicas
y gratuitas.

## Vistas incluidas

| # | Vista | API utilizada |
|---|-------|----------------|
| 1 | Home / Caja de herramientas | Imagen de Wikimedia Commons (con fallback local) |
| 2 | Predecir género | `https://api.genderize.io` |
| 3 | Predecir edad | `https://api.agify.io` |
| 4 | Universidades por país | `https://adamix.net/proxy.php?country=...` |
| 5 | Clima en RD (hoy) | `https://api.open-meteo.com` (Santo Domingo) |
| 6 | Pokédex (foto, exp., habilidades, sonido) | `https://pokeapi.co/api/v2/pokemon/{nombre}` |
| 7 | Noticias deportivas (WordPress) | REST API nativa `wp-json/wp/v2/posts` de un sitio WordPress |
| 8 | Acerca de mí | Datos estáticos (foto + contacto) |

## ⚠️ Antes de entregar la actividad

- **Vista 7 (noticias):** el sitio configurado por defecto
  (`otesports.com`) es solo un ejemplo verificado que expone su REST API
  públicamente para que la vista funcione desde ya. Reemplázalo por el
  sitio de **noticias deportivas hecho en WordPress** que vayas a
  publicar en el foro de la actividad. Edita la constante `_defaultSite`
  en `lib/screens/news_screen.dart`, o simplemente escribe el dominio en
  el campo de texto dentro de la app (funciona con cualquier sitio
  WordPress que tenga la REST API habilitada, ej: `midominio.com`).
  No olvides publicar el link elegido en el foro del curso.
- **Vista 8 (Acerca de mí):** reemplaza los datos de ejemplo en
  `lib/screens/about_screen.dart` (nombre, foto, correo, teléfono, redes)
  por los tuyos.

## 🚀 Cómo ejecutar el proyecto

Este paquete contiene solo el código Dart (`lib/`) y `pubspec.yaml`. Para
correrlo necesitas generar los proyectos nativos de cada plataforma con el
Flutter SDK instalado en tu máquina:

```bash
# 1. Crea un proyecto Flutter nuevo (genera android/, ios/, web/, etc.)
flutter create toolbox_app
cd toolbox_app

# 2. Reemplaza el pubspec.yaml y la carpeta lib/ generados
#    por los que vienen en este entregable (copia y pega/sobrescribe).

# 3. Instala las dependencias
flutter pub get

# 4. Ejecuta en tu emulador, dispositivo o Chrome
flutter run
```

### Permisos de Internet

- **Android:** `flutter create` ya agrega el permiso de Internet por
  defecto en versiones recientes de Flutter. Si tu proyecto es más
  antiguo, agrega en `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
- **iOS/macOS:** no requiere configuración adicional para HTTPS estándar.
- **Web:** algunas APIs (como `adamix.net` o algunos sitios WordPress)
  podrían bloquear CORS en `flutter run -d chrome`. Se recomienda probar
  en un emulador Android/iOS o dispositivo físico para evitar ese
  problema.

## 📦 Dependencias (`pubspec.yaml`)

- `http` — llamadas REST a todas las APIs
- `url_launcher` — abrir enlaces (universidades, noticias, contacto)
- `audioplayers` — reproducir el sonido (cry) del Pokémon
- `intl` — formateo de fecha en español para la vista del clima

## 🗂️ Estructura

```
lib/
 ├─ main.dart
 ├─ theme/
 │   └─ app_theme.dart
 ├─ widgets/
 │   └─ common_widgets.dart
 └─ screens/
     ├─ home_screen.dart          (Vista 1)
     ├─ gender_screen.dart        (Vista 2)
     ├─ age_screen.dart           (Vista 3)
     ├─ universities_screen.dart  (Vista 4)
     ├─ weather_screen.dart       (Vista 5)
     ├─ pokemon_screen.dart       (Vista 6)
     ├─ news_screen.dart          (Vista 7)
     └─ about_screen.dart         (Vista 8)
```

## Notas de diseño

- Todas las pantallas manejan **estados de carga, error y éxito**.
- Vista 2 cambia el fondo/color de tema a **azul** si el género es
  masculino, o **rosa** en cualquier otro caso (femenino o indeterminado).
- Vista 3 clasifica la edad en **joven (≤25), adulto (26-59) o
  anciano (60+)**, mostrando ícono, mensaje y el número exacto de la edad.
- Vista 5 consulta el clima **del día actual** para Santo Domingo (puede
  adaptarse a otra ciudad de RD cambiando la latitud/longitud en
  `weather_screen.dart`).
