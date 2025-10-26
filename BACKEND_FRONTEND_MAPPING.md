# Mapeo Backend ↔️ Frontend - Novedades

## 📋 Estructura de Respuesta Paginada

### Backend (JSON):
```json
{
  "novelties": [...],        // Array de novedades
  "totalElements": 3,        // Total de elementos
  "totalPages": 1,           // Total de páginas
  "currentPage": 0,          // Página actual
  "pageSize": 20             // Tamaño de página
}
```

### Frontend (NoveltyPageResponse):
```dart
{
  content: [...],            // Array mapeado desde "novelties"
  totalElements: 3,          // Igual
  totalPages: 1,             // Igual
  number: 0,                 // Mapeado desde "currentPage"
  size: 20,                  // Mapeado desde "pageSize"
  first: true,               // Calculado
  last: true,                // Calculado
  empty: false               // Calculado
}
```

---

## 📦 Estructura de Novedad Individual

### Backend (JSON):
```json
{
  "id": 1,
  "areaId": 1,
  "reason": "ERROR_LECTURA",
  "accountNumber": "ACC-00001",
  "meterNumber": "MTR-00001",
  "activeReading": 1234.56,          // ⚠️ Número (double)
  "reactiveReading": 789.01,         // ⚠️ Número (double)
  "municipality": "Tunja",
  "address": "Zona Norte...",
  "description": "Descripción...",
  "observations": "Observaciones",
  "status": "CREADA",
  "priority": null,                   // ⚠️ Puede no venir
  "createdBy": 1,                     // ⚠️ Campo diferente
  "crewId": 1,
  "createdAt": "2025-10-26T19:17:54",
  "updatedAt": "2025-10-26T19:17:54",
  "completedAt": null,
  "closedAt": null,
  "cancelledAt": null,
  "imageCount": 0,
  "hasAssignment": false,
  "assignedCrew": null
}
```

### Frontend (NoveltyResponse):
```dart
NoveltyResponse(
  id: 1,
  areaId: 1,
  reason: "ERROR_LECTURA",
  accountNumber: "ACC-00001",
  meterNumber: "MTR-00001",
  activeReading: "1234.56",           // ✅ Convertido a String
  reactiveReading: "789.01",          // ✅ Convertido a String
  municipality: "Tunja",
  address: "Zona Norte...",
  description: "Descripción...",
  observations: "Observaciones",
  status: "CREADA",
  priority: "NORMAL",                 // ✅ Default si no viene
  creatorId: 1,                       // ✅ Mapeado desde "createdBy"
  creatorName: "",                    // ✅ Default si no viene
  crewId: 1,
  crewName: null,
  areaName: "",                       // ✅ Default si no viene
  imageCount: 0,
  createdAt: DateTime(...),
  updatedAt: DateTime(...),
)
```

---

## 🔄 Campos con Conversión Especial

### 1. activeReading y reactiveReading
```dart
// Backend: double
"activeReading": 1234.56

// Frontend: String
activeReading: (json['activeReading'] as num).toString()
// Resultado: "1234.56"
```

### 2. creatorId
```dart
// Backend: "createdBy"
"createdBy": 1

// Frontend: "creatorId"
creatorId: json['createdBy'] as int
```

### 3. Campos con valores por defecto
```dart
// priority (si no viene del backend)
priority: json['priority'] as String? ?? 'NORMAL'

// areaName (si no viene del backend)
areaName: json['areaName'] as String? ?? ''

// creatorName (si no viene del backend)
creatorName: json['creatorName'] as String? ?? ''

// imageCount (si no viene del backend)
imageCount: json['imageCount'] as int? ?? 0
```

---

## 📊 Mapeo de Paginación

| Backend         | Frontend | Tipo    | Conversión                    |
|-----------------|----------|---------|-------------------------------|
| novelties       | content  | List    | Array de NoveltyResponse      |
| totalElements   | totalElements | int | Directo                      |
| totalPages      | totalPages | int    | Directo                      |
| currentPage     | number   | int     | Directo                       |
| pageSize        | size     | int     | Directo                       |
| -               | first    | bool    | Calculado (currentPage == 0)  |
| -               | last     | bool    | Calculado (currentPage >= totalPages-1) |
| -               | empty    | bool    | Calculado (novelties.isEmpty) |

---

## 🎯 Campos del Backend NO Mapeados (Actualmente)

Estos campos vienen del backend pero NO se usan en el frontend:

```json
{
  "completedAt": null,       // Fecha de completado
  "closedAt": null,          // Fecha de cierre
  "cancelledAt": null,       // Fecha de cancelación
  "hasAssignment": false,    // Si tiene asignación
  "assignedCrew": null       // Cuadrilla asignada
}
```

**Nota**: Si en el futuro necesitas estos campos, deberás:
1. Agregarlos a `NoveltyResponse.dart`
2. Agregarlos a `Novelty` entity
3. Mapearlos en `fromJson()`

---

## 🚨 Campos Requeridos por Frontend pero NO vienen del Backend

Estos campos son requeridos por el modelo de Flutter pero NO vienen del backend actual:

```dart
// ⚠️ Campos que necesitan ser agregados al backend o tener valores por defecto
areaName: '',       // Nombre del área (no viene del backend)
creatorName: '',    // Nombre del creador (no viene del backend)
crewName: null,     // Nombre de la cuadrilla (no viene del backend)
priority: 'NORMAL', // Prioridad (no viene del backend)
```

---

## ✅ Compatibilidad Bidireccional

El `fromJson()` ahora soporta AMBAS estructuras:

```dart
// Estructura Backend Actual (preferida)
{
  "novelties": [...],
  "currentPage": 0,
  "pageSize": 20
}

// Estructura Alternativa (por compatibilidad)
{
  "content": [...],
  "number": 0,
  "size": 20
}
```

---

## 🧪 Ejemplo de Respuesta Real

### Petición:
```bash
GET http://192.168.1.38:8080/api/v1/novelties/search?page=0&size=10
```

### Respuesta:
```json
{
  "novelties": [
    {
      "id": 1,
      "areaId": 1,
      "reason": "ERROR_LECTURA",
      "accountNumber": "ACC-00001",
      "meterNumber": "MTR-00001",
      "activeReading": 1234.56,
      "reactiveReading": 789.01,
      "municipality": "Tunja",
      "address": "Zona Norte - Transformador Principal",
      "description": "Transformador presenta sobrecalentamiento...",
      "observations": "Prioridad alta",
      "status": "CREADA",
      "createdBy": 1,
      "crewId": 1,
      "createdAt": "2025-10-26T19:17:54",
      "updatedAt": "2025-10-26T19:17:54",
      "imageCount": 0
    }
  ],
  "totalElements": 3,
  "totalPages": 1,
  "currentPage": 0,
  "pageSize": 20
}
```

### Conversión Flutter:
```dart
final pageResponse = NoveltyPageResponse.fromJson(response.data);
// pageResponse.content[0].id == 1
// pageResponse.content[0].activeReading == "1234.56"
// pageResponse.totalElements == 3
// pageResponse.number == 0 (mapeado desde currentPage)
```

---

## 📝 TODO: Mejoras Futuras

### Backend:
- [ ] Agregar campo `priority` en la respuesta
- [ ] Agregar campo `areaName` (nombre del área)
- [ ] Agregar campo `creatorName` (nombre del creador)
- [ ] Agregar campo `crewName` (nombre de la cuadrilla)
- [ ] Incluir información completa del área, creador y cuadrilla (objetos anidados)

### Frontend:
- [ ] Mapear campos adicionales cuando el backend los incluya
- [ ] Manejar campos `completedAt`, `closedAt`, `cancelledAt`
- [ ] Usar `assignedCrew` para mostrar información de asignación

---

**Última actualización**: 2024-01-15  
**Estado**: ✅ Mapeo funcional con valores por defecto
