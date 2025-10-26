# 🚀 Guía Rápida: Cómo Usar la Lista de Novedades

## ✅ Verificación Pre-vuelo

Antes de probar la funcionalidad, asegúrate de:

1. **Backend corriendo** en la URL configurada:
   - Revisa `lib/core/constants/api_constants.dart`
   - Verifica que `currentBaseUrl` apunte a tu servidor
   - Por defecto: `http://192.168.1.38:8080`

2. **Sesión activa**:
   - Inicia sesión en la app
   - El token JWT se maneja automáticamente

3. **Dependencias instaladas**:
   ```bash
   flutter pub get
   ```

## 📱 Navegación a la Página

La página de novedades ya está integrada en el router de la app. Para acceder:

```dart
// Usando GoRouter
context.go('/incidents/list');

// O desde cualquier lugar con el contexto
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const IncidentListPage()),
);
```

## 🎮 Funcionalidades Disponibles

### 1. **Ver Lista de Novedades**
Al abrir la página, automáticamente se cargan las primeras 10 novedades.

**Información mostrada por novedad**:
- 🏷️ ID y estado
- ⚡ Prioridad
- 📝 Descripción
- 📋 Motivo
- 🏢 Área
- 👥 Cuadrilla (si está asignada)
- 🖼️ Cantidad de imágenes
- 📅 Fecha de creación
- 👤 Creador

### 2. **Scroll Infinito**
Desplázate hacia abajo para cargar más novedades automáticamente.
- Se activa al llegar al 90% del scroll
- Carga 10 novedades adicionales por vez
- Indicador de carga al final de la lista

### 3. **Pull-to-Refresh**
Arrastra la lista hacia abajo para refrescar los datos.
- 🔄 Recarga la primera página
- ⚡ Mantiene los filtros activos

### 4. **Filtros**

#### Abrir panel de filtros:
1. Toca el icono de filtro (🔍) en la barra superior
2. Aparece un bottom sheet con opciones

#### Filtrar por Estado:
- **Todos** - Sin filtro
- **Pendiente** - Novedades sin asignar
- **Asignada** - Asignadas a cuadrilla
- **En Progreso** - Siendo trabajadas
- **Resuelta** - Trabajo completado
- **Verificada** - Verificada por supervisor
- **Cancelada** - Canceladas

#### Filtrar por Prioridad:
- **Todas** - Sin filtro
- **Baja** - No urgente
- **Media** - Normal
- **Alta** - Requiere atención
- **Crítica** - Urgente

#### Aplicar filtros:
1. Selecciona los filtros deseados
2. Toca "Aplicar"
3. La lista se recarga automáticamente

#### Limpiar filtros:
- Opción 1: Toca "Limpiar" en el panel de filtros
- Opción 2: Toca "Limpiar" en la barra de información (cuando hay filtros activos)

### 5. **Ver Detalle**
Toca cualquier novedad de la lista para ver sus detalles completos.
> ⚠️ **Nota**: La página de detalle debe implementarse aún. Actualmente muestra un Snackbar.

## 🎨 Indicadores Visuales

### Estados con Colores:
- 🟠 **Pendiente**: Naranja
- 🔵 **Asignada**: Azul
- 🟣 **En Progreso**: Púrpura
- 🟢 **Resuelta**: Verde
- 🟦 **Verificada**: Verde azulado
- 🔴 **Cancelada**: Rojo

### Prioridades con Badges:
- 🟢 **Baja**: Verde
- 🟠 **Media**: Naranja
- 🟤 **Alta**: Naranja oscuro
- 🔴 **Crítica**: Rojo

### Iconos:
- 👥 Cuadrilla asignada
- 🖼️ Cantidad de imágenes
- 🏢 Área
- 📅 Fecha
- 👤 Creador

## 🔧 Personalización Avanzada

### Cambiar ordenamiento (en código):
```dart
ref.read(noveltyListProvider.notifier).setSorting('createdAt', 'DESC');
// Campos: 'createdAt', 'priority', 'status', etc.
// Dirección: 'ASC' o 'DESC'
```

### Filtros programáticos:
```dart
// Filtrar por estado
ref.read(noveltyListProvider.notifier).setStatusFilter(NoveltyStatus.pending);

// Filtrar por prioridad
ref.read(noveltyListProvider.notifier).setPriorityFilter(NoveltyPriority.high);

// Filtrar por área (preparado, requiere UI)
ref.read(noveltyListProvider.notifier).setAreaFilter(1);

// Filtrar por cuadrilla (preparado, requiere UI)
ref.read(noveltyListProvider.notifier).setCrewFilter(1);
```

### Acceder al estado:
```dart
final state = ref.watch(noveltyListProvider);

print('Total de novedades: ${state.totalElements}');
print('Página actual: ${state.currentPage}');
print('¿Hay más páginas?: ${state.hasMore}');
print('Novedades cargadas: ${state.novelties.length}');
```

## 🐛 Solución de Problemas

### Problema: "No hay novedades"
**Posibles causas**:
- ✅ No hay novedades en el backend
- ✅ Los filtros son muy restrictivos
- ✅ Problema de conexión

**Soluciones**:
1. Limpia los filtros
2. Verifica la conexión al backend
3. Revisa los logs del servidor

### Problema: Error de carga
**Posibles causas**:
- ❌ Backend no disponible
- ❌ Token expirado
- ❌ Sin internet

**Soluciones**:
1. Verifica que el backend esté corriendo
2. Cierra sesión y vuelve a iniciar
3. Verifica tu conexión a internet
4. Revisa la URL en `api_constants.dart`

### Problema: Token expirado
**Síntoma**: Error 401 Unauthorized

**Solución**:
1. Cierra sesión
2. Inicia sesión nuevamente
3. El nuevo token se guardará automáticamente

## 📊 Datos de Prueba

Para probar la funcionalidad, asegúrate de tener novedades en el backend:

```bash
# Ejemplo de novedad (JSON del backend)
{
  "id": 1,
  "description": "Medidor dañado en sector norte",
  "status": "PENDING",
  "priority": "HIGH",
  "reason": "Medidor defectuoso",
  "accountNumber": "123456",
  "meterNumber": "M789",
  "activeReading": "1234",
  "reactiveReading": "567",
  "municipality": "Bucaramanga",
  "address": "7.123,-73.456",
  "areaId": 1,
  "areaName": "Zona Norte",
  "creatorId": 5,
  "creatorName": "Juan Pérez",
  "imageCount": 2,
  "createdAt": "2025-10-26T10:30:00Z"
}
```

## 🎯 Próximos Pasos

Una vez que la lista funcione correctamente:

1. **Implementar detalle de novedad**
   - Crear `NoveltyDetailPage`
   - Mostrar toda la información
   - Galería de imágenes
   - Historial de cambios

2. **Agregar más filtros**
   - Por área (selector)
   - Por cuadrilla (selector)
   - Por rango de fechas (date picker)
   - Búsqueda por texto

3. **Mejoras UX**
   - Animaciones
   - Caché local
   - Modo offline
   - Notificaciones de cambios

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs de la consola de Flutter
2. Verifica los logs del backend
3. Consulta `NOVELTIES_LIST_IMPLEMENTATION.md` para detalles técnicos
4. Revisa el archivo `BACKEND_FIX_REQUIRED.md` para problemas conocidos del backend

---

**¡La funcionalidad de lista de novedades está lista para usar!** 🎉
