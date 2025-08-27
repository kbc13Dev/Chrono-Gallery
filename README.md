# Chrono Gallery — *Tiempo juntos*

Una app Flutter pensada para parejas: cronómetro de tiempo juntos, espacio para cartas y mensajes, y una galería para inmortalizar recuerdos. Ideal para construir vuestro diario de relación.
Tres módulos principales: **Home** (contador de tiempo con anillos), **Cartas** (notas en Markdown) y **Galería** (fotos con carpetas y agrupación por fecha). El estado se persiste localmente en JSON y *SharedPreferences*, y la navegación usa un *bottom navigation* circular.

> Paquete raíz: `chrono_gallery` — Título de la app: **Tiempo juntos** (ES por defecto, EN disponible).

---

## 🚀 Características

### 🏠 Home
- Selección de fecha de inicio y guardado en preferencias (`SharedPreferences`) bajo la clave `start_date_ms`.
- Cálculo del tiempo transcurrido desde esa fecha.
- Visualización con **anillos de progreso** mediante `percent_indicator` (p.ej., segundos, minutos, horas, días y **años** con ciclo a 100).
- Modo oscuro y tema Material 3.

**Archivo:** `lib/screens/home_screen.dart`

---

### 📝 Cartas & Mensajes
- Dos pestañas: **Cartas** y **Mensajes** (`TabBar` + `TabBarView`).
- **Cartas**: título + contenido en **Markdown** con *preview* (`flutter_markdown` + `GoogleFonts`).
- **Mensajes**: autor + contenido; soporte de fecha opcional (selector de fecha).
- Persistencia en ficheros JSON en el directorio de documentos de la app:
  - `cards.json`
  - `messages.json`
- Edición/creación con *bottom sheets* estilizados.
- Tipografías: **Playfair Display** y **Lora**.

**Archivo:** `lib/screens/cards_screen.dart`

---

### 🖼️ Galería
- Importación de imágenes desde el dispositivo con `image_picker` (incluye `pickMultiImage`).
- Guardado de metadatos en `gallery.json` (en documentos de la app); las imágenes se referencian por ruta absoluta o relativa.
- **Agrupación por fecha** con separadores (títulos por día).
- **Carpetas**: mantener pulsado (long press) sobre una foto para **Crear carpeta**, **Mover a carpeta** o **Quitar de carpeta**.
- **Filtros por carpeta** mediante *chips*.
- **Grid responsivo** (distintas columnas según ancho).

**Archivo:** `lib/screens/gallery_screen.dart`

---

## 🧭 Navegación

- *Shell* con **CircleNavBar** y tres pestañas:
  1) Cartas
  2) Home
  3) Galería

**Archivo:** `lib/widgets/root_shell.dart`

---

## 🧱 Estructura del proyecto (archivos relevantes)

```
lib/
├─ main.dart                 # MaterialApp, localización ES/EN, tema oscuro, RootShell
├─ widgets/
│  └─ root_shell.dart        # Bottom navigation (CircleNavBar) con 3 páginas
└─ screens/
   ├─ home_screen.dart       # Contador/cronómetro con anillos y selector de fecha
   ├─ cards_screen.dart      # Pestañas Cartas/Mensajes con Markdown y JSON local
   └─ gallery_screen.dart    # Galería con agrupación por fecha y carpetas (long press)
```

---

## 📦 Dependencias detectadas

- **UI y utilidades**
  - `google_fonts`
  - `percent_indicator`
  - `circle_nav_bar`
  - `flutter_markdown`
- **Persistencia**
  - `shared_preferences`
  - `path_provider` (lectura/escritura de `cards.json`, `messages.json`, `gallery.json` en documentos de la app)
- **Multimedia**
  - `image_picker`

> Asegúrate de tener estas dependencias en `pubspec.yaml` y de ejecutar `flutter pub get`.

---

## 🔐 Permisos (Android)

Para `image_picker` en Android 13+ (API 33) se recomienda añadir permisos de lectura de medios. En `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <!-- Android 13+ -->
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
  <!-- Compatibilidad con versiones anteriores -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
  <application ...>
    <!-- ... -->
  </application>
</manifest>
```

> En iOS, añade las claves de privacidad correspondientes en `Info.plist` (p.ej., `NSPhotoLibraryUsageDescription`).

---

## 🌍 Localización

- Idiomas soportados: **Español** (`es`) y **Inglés** (`en`).
- Delegados: `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`.
- `locale: const Locale('es')` por defecto.

**Archivo:** `lib/main.dart`

---

## ▶️ Ejecución

```bash
flutter pub get
flutter run
```

Si compilas *release* para Android:
```bash
flutter build apk --release
```

---

## 🗂️ Persistencia y formato de datos

Los ficheros JSON se guardan en el **directorio de documentos** de la app (vía `path_provider`).

- `cards.json` – Lista de cartas:
  ```json
  [
    { "id": "...", "title": "Mi carta", "content": "## Markdown ...", "createdAt": "2025-08-27T10:00:00.000Z" }
  ]
  ```
- `messages.json` – Lista de mensajes:
  ```json
  [
    { "id": "...", "author": "Melissa", "content": "Hola", "createdAt": "2025-08-27T10:00:00.000Z" }
  ]
  ```
- `gallery.json` – Lista de fotos:
  ```json
  [
    { "id": "...", "absolutePath": "/storage/emulated/0/DCIM/...", "relativePath": "gallery/...", "createdAt": "2025-08-27T10:00:00.000Z", "folder": "Vacaciones" }
  ]
  ```

> Las claves exactas pueden variar ligeramente; este esquema es representativo del diseño presente en los *models* internos (`_CardItem`, `_MsgItem`, `_GalleryItem`).

---

## 🎨 Estilo

- Tema **oscuro** Material 3 (`ThemeData(useMaterial3: true, brightness: Brightness.dark)`).
- Tipografías **Playfair Display** (títulos) y **Lora** (texto).
- Color de acento recurrente: `#FF7FBF`.

---

## 🛣️ Roadmap sugerido

- [ ] Soporte de búsqueda y ordenación en Cartas/Mensajes.
- [ ] Previsualización de imágenes a pantalla completa con *swipe* (la base del visor ya está esbozada).
- [ ] Exportación/backup de JSON (Cartas, Mensajes, Galería).
- [ ] Compartir cartas/mensajes como imagen o texto.
- [ ] Eliminación/edición en lote en Galería.
- [ ] Internacionalización completa de cadenas (todas las acciones y labels).

---

## 🧪 Pruebas rápidas

- **Home**: Establece una fecha, cierra y vuelve a abrir la app → los anillos deben reflejar el tiempo transcurrido.
- **Cartas**: Crea una carta en Markdown y confirma que aparece renderizada. Reinicia la app → debe persistir.
- **Mensajes**: Añade un mensaje con autor, fecha opcional y contenido. Verifica persistencia.
- **Galería**: Importa varias imágenes, agrupa por fecha, crea una carpeta con *long press* y aplica el filtro por chip.

---

## 👤 Créditos

Creado con ❤️ por **kbc13Dev**.
