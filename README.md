# 📱 EBSA Nexus - Frontend

Sistema de gestión de novedades eléctricas para técnicos de campo de EBSA.

**Versión:** 1.0.0  
**Tecnología:** Flutter 3.x + Dart  
**Arquitectura:** Clean Architecture + Riverpod

---

## 🎯 Características Principales

### ✅ Funcionalidades Implementadas

- 🏠 **Dashboard** - Vista general del sistema
- 📋 **Gestión de Novedades** - Lista y detalles de incidencias
- 👥 **Gestión de Cuadrillas** - Equipos de trabajo
- 📝 **Reportes Offline** - Creación sin conexión a internet
- 💾 **Caché Local** - SQLite con Drift
- 🔄 **Sincronización** - Upload de reportes offline
- 🔐 **Autenticación** - Login con JWT
- 🗺️ **Geolocalización** - GPS para ubicación de reportes

### 🚧 En Desarrollo

- 🔄 Sincronización automática en background
- 📊 Reportes avanzados
- 🔔 Notificaciones push

---

## 🚀 Inicio Rápido

### Prerrequisitos

```bash
# Flutter SDK 3.x
flutter --version

# Dart SDK 3.x
dart --version
```

### Instalación

```bash
# Clonar repositorio
git clone <repository-url>
cd EBSA-Nexus-frontend

# Instalar dependencias
flutter pub get

# Generar código (Drift, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run
```

---

## 📚 Documentación

### 🎯 Documentos Principales

1. **[INDICE_DOCUMENTACION.md](INDICE_DOCUMENTACION.md)** ⭐

   - Índice completo de toda la documentación

2. **[ESTADO_ACTUAL_PROYECTO.md](ESTADO_ACTUAL_PROYECTO.md)** ⭐

   - Estado actual del proyecto
   - Qué funciona y qué no

3. **[GUIA_PRUEBAS_REPORTES_OFFLINE.md](GUIA_PRUEBAS_REPORTES_OFFLINE.md)** ⭐
   - Cómo probar la funcionalidad offline

### 📖 Documentación Técnica

- **[RESUMEN_COMPLETO_REPORTES_OFFLINE.md](RESUMEN_COMPLETO_REPORTES_OFFLINE.md)**

  - Documentación técnica completa de reportes offline

- **[SOLUCION_WORK_START_DATE_NULL.md](SOLUCION_WORK_START_DATE_NULL.md)**

  - Solución al error SQLite de campos NULL

- **[SOLUCION_CACHE_MIEMBROS_CUADRILLA.md](SOLUCION_CACHE_MIEMBROS_CUADRILLA.md)**
  - Cacheo de cuadrillas y miembros

### 🐛 Problemas Conocidos

- **[ERROR_BACKEND_REPORTES.md](ERROR_BACKEND_REPORTES.md)**
  - Errores actuales del backend
  - Soluciones propuestas

---

## 🏗️ Arquitectura

### Estructura de Carpetas

```
lib/
├── app.dart                 # Widget principal
├── main.dart               # Entry point
├── config/                 # Configuración global
│   ├── database/          # Drift database provider
│   ├── dependency_injection/  # Get_it DI
│   ├── router/            # GoRouter configuración
│   └── theme/             # Temas y estilos
├── core/                   # Funcionalidad compartida
│   ├── database/          # Tablas Drift
│   ├── network/           # HTTP client
│   ├── theme/             # Colores y estilos
│   ├── utils/             # Utilidades
│   └── widgets/           # Widgets reutilizables
└── features/               # Features por módulo
    ├── auth/              # Autenticación
    ├── crews/             # Cuadrillas
    ├── incidents/         # Novedades
    └── reports/           # Reportes
        ├── data/          # Data sources, models, repositories
        ├── domain/        # Entities, use cases
        └── presentation/  # UI, providers, pages
```

### Capas

1. **Presentation** - UI + State Management (Riverpod)
2. **Domain** - Lógica de negocio + Entities
3. **Data** - Data sources + Repositories + Models

---

## 🛠️ Tecnologías

### Principales

- **Flutter** - Framework UI
- **Riverpod** - State Management
- **Drift** - SQLite ORM
- **GoRouter** - Navegación
- **Get_it** - Dependency Injection

### Networking

- **Retrofit** - Cliente HTTP
- **Dio** - HTTP requests
- **JSON Serialization** - Serialización de datos

### Storage

- **Drift (ex-Moor)** - Base de datos local
- **Flutter Secure Storage** - Almacenamiento seguro
- **Shared Preferences** - Preferencias

### Otros

- **Geolocator** - Geolocalización
- **Permission Handler** - Permisos
- **UUID** - Generación de IDs
- **Intl** - Internacionalización

---

## 📊 Base de Datos Local (SQLite)

### Tablas Principales

```sql
-- Caché de novedades
CREATE TABLE novelty_cache (
  novelty_id INTEGER PRIMARY KEY,
  status TEXT,
  crew_id INTEGER,
  raw_json TEXT,
  cached_at INTEGER
);

-- Caché de cuadrillas
CREATE TABLE crew_cache (
  crew_id INTEGER PRIMARY KEY,
  name TEXT,
  raw_json TEXT,  -- Incluye miembros
  cached_at INTEGER
);

-- Reportes offline
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  novelty_id INTEGER,
  work_description TEXT,
  work_start_date INTEGER,  -- ✅ Campo requerido
  work_end_date INTEGER,    -- ✅ Campo requerido
  work_time INTEGER,
  participant_ids TEXT,     -- JSON array
  resolution_status TEXT,
  latitude REAL,
  longitude REAL,
  is_synced INTEGER,
  created_at INTEGER
);
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ver coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔧 Comandos Útiles

### Generación de Código

```bash
# Regenerar código Drift, Retrofit, etc.
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (regeneración automática)
flutter pub run build_runner watch
```

### Análisis de Código

```bash
# Analizar código
flutter analyze

# Fix automático de problemas
dart fix --apply
```

### Limpieza

```bash
# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get
```

---

## 📱 Plataformas Soportadas

- ✅ **Android** - Versión mínima: API 21 (Android 5.0)
- ✅ **iOS** - Versión mínima: iOS 12.0
- 🚧 **Web** - En desarrollo
- ❌ **Desktop** - No soportado actualmente

---

## 🚦 Estado del Proyecto

### ✅ Completado

- [x] Autenticación con JWT
- [x] Lista de novedades
- [x] Caché de datos offline
- [x] Creación de reportes offline
- [x] Formulario con validaciones
- [x] Guardado en SQLite
- [x] Preparación para sincronización

### ⏳ Pendiente

- [ ] Sincronización funcional (bloqueado por backend)
- [ ] Subida de imágenes
- [ ] Notificaciones push
- [ ] Modo oscuro
- [ ] Tests unitarios completos

### 🐛 Problemas Conocidos

1. **Backend no disponible**

   - Servidor no está corriendo
   - Ver: `ERROR_BACKEND_REPORTES.md`

2. **Campo faltante en BD backend**

   - `resolution_time_hours` no existe en PostgreSQL
   - Ver: `ERROR_BACKEND_REPORTES.md`

3. **Error de autenticación JWT**
   - Parseo incorrecto de userId
   - Ver: `ERROR_BACKEND_REPORTES.md`

---

## 👥 Equipo

- **Frontend:** Equipo Flutter
- **Backend:** Equipo Java/Spring Boot
- **Diseño:** Equipo UX/UI

---

## 📄 Licencia

Este proyecto es propiedad de EBSA (Empresa de Energía de Boyacá S.A. E.S.P.)

---

## 📞 Soporte

Para problemas o dudas:

1. Revisar documentación en archivos `.md`
2. Verificar [INDICE_DOCUMENTACION.md](INDICE_DOCUMENTACION.md)
3. Contactar al equipo de desarrollo

---

**Última actualización:** 15 de Junio 2025  
**Versión:** 1.0.0  
**Estado:** ✅ Frontend Funcional | ⏳ Backend Pendiente
