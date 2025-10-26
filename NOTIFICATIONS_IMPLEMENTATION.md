# 📱 Sistema de Notificaciones - Guía de Implementación

## ✅ Componentes Implementados

### 1. **Modelos de Datos**

- ✅ `notification_type.dart` - Enum de tipos de notificación
- ✅ `notification_model.dart` - Modelo de notificación con parseo de fechas corregido
- ✅ `NotificationSummary` - Resumen de notificaciones

### 2. **Servicio de API**

- ✅ `notification_service.dart` - Cliente HTTP para el backend
  - Obtener todas las notificaciones
  - Obtener no leídas
  - Contar no leídas
  - Filtrar por tipo
  - Marcar como leída(s)
  - Eliminar notificación(es)

### 3. **Gestión de Estado (Riverpod)**

- ✅ `notification_provider.dart` - Provider principal de notificaciones
- ✅ `notification_polling_service.dart` - Servicio de actualización automática

### 4. **Widgets de UI**

- ✅ `notification_card.dart` - Tarjeta de notificación
- ✅ `notification_badge.dart` - Badge con contador
- ✅ `notifications_page.dart` - Página completa de notificaciones

### 5. **Constantes**

- ✅ `api_constants.dart` - Endpoints actualizados

---

## 🚀 Uso Básico

### Paso 1: Cargar Notificaciones

```dart
// En cualquier widget ConsumerWidget
final userId = 9; // ID del usuario autenticado

// Cargar notificaciones
ref.read(notificationProvider(userId).notifier).loadNotifications();

// Observar el estado
final notificationState = ref.watch(notificationProvider(userId));
```

### Paso 2: Mostrar Contador en UI

```dart
// En el AppBar o BottomNavigationBar
NotificationBadge(
  userId: userId,
  child: IconButton(
    icon: Icon(Icons.notifications),
    onPressed: () => context.go('/notifications'),
  ),
)
```

### Paso 3: Iniciar Polling Automático

```dart
// En initState de la HomePage o App principal
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId != null) {
      // Iniciar actualización automática cada 30 segundos
      ref.read(notificationPollingServiceProvider(int.parse(userId))).start();
    }
  });
}

@override
void dispose() {
  final userId = ref.read(authNotifierProvider).user?.id;
  if (userId != null) {
    ref.read(notificationPollingServiceProvider(int.parse(userId))).stop();
  }
  super.dispose();
}
```

---

## 📋 Endpoints Disponibles

| Método | Endpoint                                           | Descripción              |
| ------ | -------------------------------------------------- | ------------------------ |
| GET    | `/api/v1/notifications/user/{userId}`              | Todas las notificaciones |
| GET    | `/api/v1/notifications/user/{userId}/unread`       | Solo no leídas           |
| GET    | `/api/v1/notifications/user/{userId}/unread/count` | Contador de no leídas    |
| GET    | `/api/v1/notifications/user/{userId}/summary`      | Resumen completo         |
| GET    | `/api/v1/notifications/user/{userId}/type/{type}`  | Filtrar por tipo         |
| PATCH  | `/api/v1/notifications/{id}/read`                  | Marcar como leída        |
| PATCH  | `/api/v1/notifications/user/{userId}/read-all`     | Marcar todas como leídas |
| DELETE | `/api/v1/notifications/{id}`                       | Eliminar una             |
| DELETE | `/api/v1/notifications/user/{userId}`              | Eliminar todas           |

---

## 🎨 Tipos de Notificación

| Tipo               | Backend String        | Color        | Icono                  |
| ------------------ | --------------------- | ------------ | ---------------------- |
| Nueva Novedad      | `NEW_NOVELTY`         | Azul         | `fiber_new`            |
| Novedad Asignada   | `NOVELTY_ASSIGNED`    | Naranja      | `assignment`           |
| Cambio de Estado   | `STATUS_CHANGE`       | Púrpura      | `sync`                 |
| Completada         | `NOVELTY_COMPLETED`   | Verde        | `check_circle`         |
| Rechazada          | `COMPLETION_REJECTED` | Rojo         | `cancel`               |
| Cancelada          | `NOVELTY_CANCELLED`   | Gris         | `block`                |
| Vencida            | `NOVELTY_OVERDUE`     | Rojo Naranja | `alarm`                |
| Cuadrilla Asignada | `CREW_ASSIGNED`       | Cyan         | `group`                |
| Alerta Sistema     | `SYSTEM_ALERT`        | Naranja      | `warning`              |
| Recordatorio       | `REMINDER`            | Deep Purple  | `notifications_active` |
| General            | `GENERAL`             | Blue Grey    | `info`                 |

---

## 🔧 Configuración del Polling

### Cambiar Intervalo de Actualización

Por defecto, las notificaciones se actualizan cada **30 segundos**. Para cambiar esto:

```dart
// En notification_polling_service.dart, línea ~31
NotificationPollingService({
  required this.ref,
  required this.userId,
  this.interval = const Duration(seconds: 15), // Cambiar aquí
});
```

### Pausar/Reanudar Polling

```dart
final pollingService = ref.read(notificationPollingServiceProvider(userId));

// Pausar temporalmente
pollingService.pause();

// Reanudar
pollingService.resume();

// Detener completamente
pollingService.stop();
```

---

## 📱 Integración con AppBar

Para agregar el badge de notificaciones al AppBar existente:

```dart
// En app_router.dart, método _buildAppBar
PreferredSizeWidget? _buildAppBar(
  BuildContext context,
  GoRouterState state,
  WidgetRef ref,
) {
  final currentPath = state.matchedLocation;
  final title = _getTitleForRoute(currentPath);
  final authState = ref.watch(authNotifierProvider);

  return AppBar(
    title: Text(title),
    backgroundColor: AppColors.primary,
    actions: [
      // Badge de notificaciones
      if (authState.user != null)
        NotificationBadge(
          userId: int.parse(authState.user!.id),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go(RouteNames.notifications),
          ),
        ),

      // Otros botones...
    ],
  );
}
```

---

## 🧪 Probar el Sistema

### 1. Verificar Conexión al Backend

```dart
// En un botón de prueba o en initState
Future<void> testNotifications() async {
  final service = NotificationService();

  try {
    final notifications = await service.getUserNotifications(9);
    print('✅ ${notifications.length} notificaciones cargadas');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### 2. Verificar Usuario Autenticado

Asegúrate de que el usuario tiene ID numérico:

```dart
final authState = ref.watch(authNotifierProvider);
print('User ID: ${authState.user?.id}'); // Debe ser un número como "9"
```

### 3. Ver Logs en Consola

El sistema imprime logs detallados:

```
🔄 Cargando notificaciones del usuario 9...
📡 Status code: 200
📦 Response body length: 1876
✅ Parseadas 10 notificaciones
```

---

## ⚠️ Solución de Problemas

### Error: "FormatException: Invalid date format"

**Causa**: El backend devuelve fechas sin milisegundos  
**Solución**: ✅ Ya está implementado en `NotificationModel._parseDateTime`

### Error: "type 'String' can't be assigned to type 'int'"

**Causa**: El User.id es String pero los providers esperan int  
**Solución**: ✅ Ya está corregido con `int.parse(userId)`

### Las notificaciones no se actualizan

1. Verificar que el polling está iniciado:

```dart
final service = ref.read(notificationPollingServiceProvider(userId));
print('Polling running: ${service.isRunning}');
```

2. Verificar la URL del backend en `api_constants.dart`:

```dart
static String get currentBaseUrl {
  return baseUrlNetwork; // Debe apuntar al backend correcto
}
```

### Error 401 (No autorizado)

El servicio actual no requiere autenticación para endpoints públicos. Si el backend requiere token:

```dart
// En notification_provider.dart, línea ~157
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // TODO: Obtener token del authProvider
  final authState = ref.watch(authNotifierProvider);
  final authToken = authState.token; // Agregar token al authState

  return NotificationService(authToken: authToken);
});
```

---

## 🎯 Próximos Pasos

### Integración con Cuadrillas

Cuando se asigne una novedad a una cuadrilla, todos los miembros recibirán notificación automática.

### Navegación a Detalles

Implementar navegación al hacer tap en notificación:

```dart
onTap: () {
  if (notification.noveltyId != null) {
    context.go('/novelties/${notification.noveltyId}');
  }
}
```

### Push Notifications (Firebase)

Para notificaciones push cuando la app está cerrada, integrar Firebase Cloud Messaging.

---

## ✅ Checklist de Implementación

- [x] Modelos de datos creados
- [x] Servicio de API implementado
- [x] Provider de estado configurado
- [x] Polling service creado
- [x] Widgets de UI implementados
- [x] Página de notificaciones actualizada
- [x] Endpoints agregados a constantes
- [x] Manejo de errores implementado
- [ ] Integración con AppBar (pendiente)
- [ ] Navegación a detalles (pendiente)
- [ ] Testing completo (pendiente)

---

## 📚 Archivos Creados

```
lib/
├── features/
│   └── notifications/
│       ├── domain/
│       │   └── models/
│       │       ├── notification_type.dart ✅
│       │       └── notification_model.dart ✅
│       ├── data/
│       │   └── services/
│       │       └── notification_service.dart ✅
│       └── presentation/
│           ├── providers/
│           │   ├── notification_provider.dart ✅
│           │   └── notification_polling_service.dart ✅
│           ├── widgets/
│           │   ├── notification_card.dart ✅
│           │   └── notification_badge.dart ✅
│           └── pages/
│               └── (actualizada) notifications_page.dart ✅
└── core/
    └── constants/
        └── (actualizado) api_constants.dart ✅
```

---

## 🎉 ¡Todo Listo!

El sistema de notificaciones con polling está completamente implementado y listo para usar. Solo necesitas:

1. Verificar que el backend esté corriendo en la URL configurada
2. Iniciar el polling cuando el usuario se autentique
3. Agregar el badge al AppBar/BottomNav según tu diseño

Para cualquier duda, revisa los comentarios en el código o los logs en la consola.
