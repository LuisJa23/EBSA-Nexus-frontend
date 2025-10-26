# Actualización de Estados y Endpoints - Novedades

## ✅ Cambios Aplicados

### 1. **NoveltyStatus Enum** - Estados Actualizados

Se actualizó el enum para coincidir con los estados del backend:

**ANTES:**
```dart
enum NoveltyStatus {
  pending('PENDING', 'Pendiente'),
  assigned('ASSIGNED', 'Asignada'),
  inProgress('IN_PROGRESS', 'En Progreso'),
  resolved('RESOLVED', 'Resuelta'),
  verified('VERIFIED', 'Verificada'),
  cancelled('CANCELLED', 'Cancelada');
}
```

**AHORA:**
```dart
enum NoveltyStatus {
  creada('CREADA', 'Creada'),
  enCurso('EN_CURSO', 'En Curso'),
  completada('COMPLETADA', 'Completada'),
  cerrada('CERRADA', 'Cerrada'),
  cancelada('CANCELADA', 'Cancelada');
}
```

---

## 🔄 Flujo de Estados

```
┌─────────┐
│ CREADA  │ ← Novedad recién creada, sin cuadrilla
└────┬────┘
     │
     ├─────────────────────┐
     │                     │
     ▼                     ▼
┌──────────┐         ┌────────────┐
│ EN_CURSO │         │ CANCELADA  │ (solo desde CREADA)
└────┬─────┘         └────────────┘
     │
     ▼
┌──────────────┐
│ COMPLETADA   │ ← Trabajo completado
└──────┬───────┘
       │
       ▼
┌────────────┐
│  CERRADA   │ ← Finalizada con reporte
└────────────┘
```

---

## 🎨 Colores por Estado

| Estado       | Color    | Hex       | Significado                     |
|--------------|----------|-----------|----------------------------------|
| CREADA       | 🟠 Naranja | #FFA726   | Recién creada, pendiente        |
| EN_CURSO     | 🔵 Azul    | #42A5F5   | Trabajo en progreso             |
| COMPLETADA   | 🟣 Púrpura | #AB47BC   | Completada, esperando cierre    |
| CERRADA      | 🟢 Verde   | #66BB6A   | Finalizada correctamente        |
| CANCELADA    | 🔴 Rojo    | #EF5350   | Cancelada                       |

---

## 🔐 Validaciones de Transición de Estados

### Métodos Agregados:

```dart
// ✅ Verifica si se puede asignar una cuadrilla
bool get canAssignCrew => this == NoveltyStatus.creada;

// ✅ Verifica si se puede cancelar
bool get canBeCancelled => this == NoveltyStatus.creada;

// ✅ Verifica si se pueden subir evidencias
bool get canUploadEvidence => this == NoveltyStatus.enCurso;

// ✅ Verifica si se puede completar
bool get canComplete => this == NoveltyStatus.enCurso;

// ✅ Verifica si se puede cerrar
bool get canClose => this == NoveltyStatus.completada;

// ✅ Verifica si es un estado terminal
bool get isTerminal => 
    this == NoveltyStatus.cerrada || this == NoveltyStatus.cancelada;

// ✅ Valida si la transición es válida
bool canTransitionTo(NoveltyStatus targetStatus) { ... }
```

### Tabla de Transiciones Válidas:

| Estado Actual | Estados Permitidos        | Estados Bloqueados     |
|---------------|---------------------------|------------------------|
| CREADA        | EN_CURSO, CANCELADA       | COMPLETADA, CERRADA    |
| EN_CURSO      | COMPLETADA, CANCELADA     | CERRADA                |
| COMPLETADA    | CERRADA                   | EN_CURSO, CANCELADA    |
| CERRADA       | ❌ Ninguno (terminal)     | Todos                  |
| CANCELADA     | ❌ Ninguno (terminal)     | Todos                  |

---

## 📡 Endpoints Disponibles del Backend

### 1. **Listar Novedades con Filtros y Paginación**
```http
GET /api/v1/novelties/search
```

**Query Parameters:**
```
?page=0
&size=10
&sort=createdAt
&direction=DESC
&status=CREADA
&priority=HIGH
&areaId=1
&crewId=2
&creatorId=3
&startDate=2025-01-01T00:00:00
&endDate=2025-12-31T23:59:59
```

**Ejemplo:**
```bash
curl "http://192.168.1.38:8080/api/v1/novelties/search?page=0&size=10&status=CREADA"
```

---

### 2. **Obtener Detalle de una Novedad**
```http
GET /api/v1/novelties/{id}
```

**Ejemplo:**
```bash
curl "http://192.168.1.38:8080/api/v1/novelties/1"
```

---

### 3. **Novedades por Cuadrilla**
```http
GET /api/v1/novelties/crew/{crewId}
```

**Ejemplo:**
```bash
curl "http://192.168.1.38:8080/api/v1/novelties/crew/1"
```

---

### 4. **Novedades por Estado**
```http
GET /api/v1/novelties/status/{status}
```

**Valores válidos para `{status}`:**
- `CREADA`
- `EN_CURSO`
- `COMPLETADA`
- `CERRADA`
- `CANCELADA`

**Ejemplo:**
```bash
curl "http://192.168.1.38:8080/api/v1/novelties/status/CREADA"
```

---

### 5. **Notificaciones por Usuario**
```http
GET /api/v1/notifications/user/{userId}
```

**Ejemplo:**
```bash
curl "http://192.168.1.38:8080/api/v1/notifications/user/1"
```

---

## 🔧 Uso en el Frontend

### Filtrar por Estado:

```dart
final filters = NoveltyFilters(
  page: 0,
  size: 10,
  status: NoveltyStatus.creada, // Solo novedades creadas
);

final result = await noveltyRepository.getNovelties(filters);
```

### Validar Transición de Estado:

```dart
final novelty = ...;

// Verificar si se puede completar
if (novelty.status.canComplete) {
  // Mostrar botón "Completar"
}

// Verificar transición específica
if (novelty.status.canTransitionTo(NoveltyStatus.completada)) {
  // Permitir cambiar a completada
}
```

### Usar Endpoints Específicos:

#### Novedades por Cuadrilla:
```dart
// TODO: Implementar en el servicio
Future<Response> getNoveliesByCrew(int crewId) async {
  return await _apiClient.get('/api/v1/novelties/crew/$crewId');
}
```

#### Novedades por Estado:
```dart
// TODO: Implementar en el servicio
Future<Response> getNoveliesByStatus(NoveltyStatus status) async {
  return await _apiClient.get('/api/v1/novelties/status/${status.value}');
}
```

---

## 📋 Filtros Disponibles en la UI

Los filtros actuales en `NoveltyFiltersBottomSheet` ahora mostrarán:

```
Estado:
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  Todos   │  Creada  │ En Curso │Completada│  Cerrada │
└──────────┴──────────┴──────────┴──────────┴──────────┘
┌──────────┐
│Cancelada │
└──────────┘

Prioridad:
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│  Todas   │   Baja   │  Media   │   Alta   │ Crítica  │
└──────────┴──────────┴──────────┴──────────┴──────────┘
```

---

## 🚀 Próximos Pasos

### 1. Hot Restart
```bash
flutter run
# o presiona Shift + Cmd + F5
```

### 2. Probar Filtros
- Navega a la pantalla de Novedades
- Toca el botón de filtros
- Selecciona "Creada" como estado
- Aplica el filtro
- Deberías ver solo las novedades con estado CREADA

### 3. Verificar Mapeo
- Los estados del backend (CREADA, EN_CURSO, etc.) ahora se mapean correctamente
- Los colores se muestran según el nuevo esquema
- Las transiciones de estado están validadas

---

## 📝 TODO: Endpoints Adicionales

Estos endpoints están disponibles en el backend pero AÚN NO implementados en el frontend:

### 1. Agregar al servicio:
```dart
// lib/features/incidents/data/novelty_service.dart

/// Obtiene novedades por cuadrilla
Future<Response> getNoveliesByCrew(int crewId) async {
  return await _apiClient.get('/api/v1/novelties/crew/$crewId');
}

/// Obtiene novedades por estado
Future<Response> getNoveliesByStatus(String status) async {
  return await _apiClient.get('/api/v1/novelties/status/$status');
}
```

### 2. Agregar constantes:
```dart
// lib/core/constants/api_constants.dart

/// Endpoint para novedades por cuadrilla
static String noveltiesByCrewEndpoint(int crewId) => 
    '/api/v1/novelties/crew/$crewId';

/// Endpoint para novedades por estado
static String noveltiesByStatusEndpoint(String status) => 
    '/api/v1/novelties/status/$status';
```

---

**Última actualización**: 2024-01-15  
**Estado**: ✅ Estados actualizados y sincronizados con backend
