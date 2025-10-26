# 🔔 Sistema de Notificaciones - EBSA Nexus Frontend

## ✅ Implementación Completa

Se ha implementado un sistema completo de notificaciones con **pull (polling)** que se actualiza automáticamente cada 30 segundos.

---

## 📁 Estructura de Archivos Creados

```
lib/features/notifications/
├── domain/
│   └── models/
│       ├── notification_type.dart          ✅ Enum de tipos
│       └── notification_model.dart         ✅ Modelo con parseo de fechas
├── data/
│   └── services/
│       └── notification_service.dart       ✅ Cliente API HTTP
└── presentation/
    ├── providers/
    │   ├── notification_provider.dart      ✅ State management (Riverpod)
    │   └── notification_polling_service.dart ✅ Auto-refresh cada 30s
    ├── widgets/
    │   ├── notification_card.dart          ✅ Tarjeta de notificación
    │   └── notification_badge.dart         ✅ Badge con contador
    └── pages/
        └── notifications_page.dart         ✅ Página completa

lib/core/constants/
└── api_constants.dart                      ✅ Endpoints actualizados

lib/features/authentication/presentation/pages/
└── notifications_page.dart                 ✅ Actualizada con nueva lógica
```

---

## 🚀 Características Implementadas

### ✅ Gestión de Notificaciones

- [x] Obtener todas las notificaciones del usuario
- [x] Filtrar por leídas/no leídas
- [x] Obtener contador de no leídas en tiempo real
- [x] Marcar una notificación como leída
- [x] Marcar todas como leídas
- [x] Eliminar notificación individual
- [x] Eliminar todas las notificaciones

### ✅ Actualización Automática (Polling)

- [x] Auto-refresh cada 30 segundos (configurable)
- [x] Actualización silenciosa sin loading spinner
- [x] Pause/Resume según ciclo de vida de la app
- [x] Optimistic updates (UI instantánea)

### ✅ UI/UX

- [x] Tarjeta de notificación con tipo, icono, título, mensaje
- [x] Badge con contador de no leídas
- [x] Filtros por estado (todas, no leídas, leídas)
- [x] Pull-to-refresh manual
- [x] Menú contextual (marcar leída, eliminar)
- [x] Estados: loading, error, vacío

### ✅ Parseo Robusto

- [x] Manejo de fechas sin milisegundos del backend
- [x] Conversión de tipos (userId String → int)
- [x] Error handling en todos los endpoints
- [x] Logs detallados para debugging

---

## 🎯 Próximos Pasos de Integración

### 1. Agregar Badge al AppBar

**Archivo**: `app_router.dart`

```dart
// Importar
import '../../features/notifications/presentation/widgets/notification_badge.dart';

// En _buildAppBar, agregar a actions:
if (userId != null && currentPath != RouteNames.notifications) {
  actions.add(
    NotificationBadge(
      userId: userId,
      child: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: () => context.go(RouteNames.notifications),
      ),
    ),
  );
}
```

### 2. Iniciar Polling al Autenticar

**Opción A**: En `home_page.dart`

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      final userId = int.parse(authState.user!.id);
      ref.read(notificationPollingServiceProvider(userId)).start();
    }
  });
}
```

**Opción B**: En `app.dart` (recomendado)

```dart
// Escuchar cambios de autenticación y gestionar el polling
ref.listenManual(authNotifierProvider, (previous, next) {
  if (next.status == AuthStatus.authenticated && next.user != null) {
    final userId = int.parse(next.user!.id);
    ref.read(notificationProvider(userId).notifier).loadNotifications();
    ref.read(notificationPollingServiceProvider(userId)).start();
  } else if (next.status == AuthStatus.unauthenticated) {
    if (previous?.user != null) {
      final userId = int.parse(previous!.user!.id);
      ref.read(notificationPollingServiceProvider(userId)).stop();
    }
  }
});
```

### 3. Agregar Ruta en `route_names.dart`

```dart
static const String notifications = '/notifications';

// Y en el mapa de rutas protegidas
static bool requiresAuth(String route) {
  return route != login && route != splash;
}
```

---

## 📡 Endpoints del Backend

Base URL: `http://192.168.1.38:8080` (configurado en `api_constants.dart`)

| Método   | Endpoint                                           | Uso                      |
| -------- | -------------------------------------------------- | ------------------------ |
| `GET`    | `/api/v1/notifications/user/{userId}`              | Todas las notificaciones |
| `GET`    | `/api/v1/notifications/user/{userId}/unread`       | Solo no leídas           |
| `GET`    | `/api/v1/notifications/user/{userId}/unread/count` | Contador                 |
| `PATCH`  | `/api/v1/notifications/{id}/read`                  | Marcar como leída        |
| `PATCH`  | `/api/v1/notifications/user/{userId}/read-all`     | Marcar todas             |
| `DELETE` | `/api/v1/notifications/{id}`                       | Eliminar una             |
| `DELETE` | `/api/v1/notifications/user/{userId}`              | Eliminar todas           |

---

## 🎨 Tipos de Notificación Soportados

| Backend String        | Color        | Icono | Descripción          |
| --------------------- | ------------ | ----- | -------------------- |
| `NEW_NOVELTY`         | Azul         | 📋    | Nueva novedad        |
| `NOVELTY_ASSIGNED`    | Naranja      | 📌    | Novedad asignada     |
| `STATUS_CHANGE`       | Púrpura      | 🔄    | Cambio de estado     |
| `NOVELTY_COMPLETED`   | Verde        | ✅    | Completada           |
| `COMPLETION_REJECTED` | Rojo         | ❌    | Rechazada            |
| `NOVELTY_CANCELLED`   | Gris         | 🚫    | Cancelada            |
| `NOVELTY_OVERDUE`     | Rojo Naranja | ⏰    | Vencida              |
| `CREW_ASSIGNED`       | Cyan         | 👥    | Asignación cuadrilla |
| `SYSTEM_ALERT`        | Naranja      | ⚠️    | Alerta del sistema   |
| `REMINDER`            | Deep Purple  | 🔔    | Recordatorio         |
| `GENERAL`             | Blue Grey    | 📢    | General              |

---

## 🧪 Testing

### Verificar Conexión al Backend

```dart
final service = NotificationService();
final notifications = await service.getUserNotifications(9);
print('✅ ${notifications.length} notificaciones cargadas');
```

### Verificar Estado del Provider

```dart
final state = ref.watch(notificationProvider(userId));
print('Total: ${state.notifications.length}');
print('No leídas: ${state.unreadCount}');
print('Loading: ${state.isLoading}');
print('Error: ${state.error}');
```

### Verificar Polling

```dart
final polling = ref.read(notificationPollingServiceProvider(userId));
print('Polling activo: ${polling.isRunning}');
```

---

## ⚙️ Configuración

### Cambiar Intervalo de Polling

**Archivo**: `notification_polling_service.dart`

```dart
NotificationPollingService({
  required this.ref,
  required this.userId,
  this.interval = const Duration(seconds: 15), // Cambiar aquí
});
```

### Cambiar URL del Backend

**Archivo**: `api_constants.dart`

```dart
static String get currentBaseUrl {
  return baseUrlNetwork; // Para dispositivo físico
  // return baseUrlLocalhost; // Para emulador
}
```

---

## 📚 Documentación Adicional

- **[NOTIFICATIONS_IMPLEMENTATION.md](./NOTIFICATIONS_IMPLEMENTATION.md)**: Guía detallada de uso
- **[INTEGRATION_EXAMPLE.dart](./lib/features/notifications/INTEGRATION_EXAMPLE.dart)**: Ejemplos de código
- **Backend Docs**: Ver `/EBSA-Nexus-Backend/FLUTTER_NOTIFICATIONS_GUIDE.md`

---

## ✅ Checklist de Implementación

### Completado

- [x] Modelos de datos
- [x] Servicio de API
- [x] Provider de estado (Riverpod)
- [x] Polling automático
- [x] Widgets de UI
- [x] Página de notificaciones
- [x] Manejo de errores
- [x] Parseo de fechas
- [x] Optimistic updates

### Pendiente (Integración)

- [ ] Agregar badge al AppBar
- [ ] Iniciar polling en login
- [ ] Detener polling en logout
- [ ] Navegación a detalles de novedad
- [ ] Testing unitario
- [ ] Testing de integración

---

## 🐛 Solución de Problemas

### Notificaciones no se cargan

1. Verificar URL del backend en `api_constants.dart`
2. Verificar que el backend esté corriendo
3. Ver logs en consola para errores de red

### Badge no se actualiza

1. Verificar que el polling esté iniciado
2. Comprobar intervalo de actualización (30s por defecto)
3. Ver si hay errores en la consola

### Error de conversión userId

- El `User.id` es String, se convierte a int con `int.parse()`
- Ya está implementado en todos los lugares necesarios

---

## 🎉 Conclusión

El sistema de notificaciones está **100% implementado** y listo para ser integrado con el resto de la aplicación. Solo faltan los pasos de integración en el AppBar y el inicio del polling, que son configuraciones específicas de tu arquitectura de navegación.

**Archivos para revisar**:

1. `notifications_page.dart` - Página principal
2. `notification_provider.dart` - Lógica de estado
3. `notification_service.dart` - API client
4. `NOTIFICATIONS_IMPLEMENTATION.md` - Guía completa

**Siguiente paso**: Agregar el badge al AppBar siguiendo el ejemplo en `INTEGRATION_EXAMPLE.dart`.
