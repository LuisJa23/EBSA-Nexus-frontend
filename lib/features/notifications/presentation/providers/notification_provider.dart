// notification_provider.dart
//
// Provider de estado para notificaciones usando Riverpod
//
// PROPÓSITO:
// - Gestionar el estado de las notificaciones
// - Proporcionar métodos para cargar, marcar como leídas y eliminar
// - Implementar polling automático para actualizar notificaciones

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/models/notification_type.dart';

/// Estado de las notificaciones
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Obtiene solo las notificaciones no leídas
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// Obtiene notificaciones recientes (últimas 10)
  List<NotificationModel> get recentNotifications =>
      notifications.take(10).toList();
}

/// Notifier para gestión de notificaciones
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;
  final int userId;

  NotificationNotifier({
    required NotificationService service,
    required this.userId,
  }) : _service = service,
       super(NotificationState());

  // ==========================================================================
  // MÉTODOS DE CARGA
  // ==========================================================================

  /// Cargar todas las notificaciones del usuario
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📱 Cargando notificaciones para usuario $userId...');
      final notifications = await _service.getUserNotifications(userId);

      // Ordenar por fecha (más recientes primero)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Contar no leídas
      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        error: null,
      );

      print(
        '✅ ${notifications.length} notificaciones cargadas, $unreadCount no leídas',
      );
    } catch (e) {
      print('❌ Error al cargar notificaciones: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar notificaciones: $e',
      );
    }
  }

  /// Actualizar solo el contador de no leídas (más ligero)
  Future<void> updateUnreadCount() async {
    try {
      final count = await _service.countUnreadNotifications(userId);
      state = state.copyWith(unreadCount: count);
      print('✅ Contador actualizado: $count no leídas');
    } catch (e) {
      print('❌ Error al actualizar contador: $e');
      // No actualizar el estado de error para no molestar al usuario
    }
  }

  /// Cargar notificaciones de forma silenciosa (sin loading)
  Future<void> refreshNotifications() async {
    try {
      final notifications = await _service.getUserNotifications(userId);
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        error: null,
      );

      print('🔄 Notificaciones actualizadas: ${notifications.length} total');
    } catch (e) {
      print('⚠️ Error en refresh silencioso: $e');
      // No actualizar el estado de error
    }
  }

  // ==========================================================================
  // MÉTODOS DE MODIFICACIÓN
  // ==========================================================================

  /// Marcar una notificación como leída
  Future<void> markAsRead(int notificationId) async {
    try {
      print('📖 Marcando notificación $notificationId como leída...');

      // Actualizar localmente primero (optimistic update)
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.markAsRead();
        }
        return n;
      }).toList();

      final newUnreadCount = updatedNotifications
          .where((n) => !n.isRead)
          .length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );

      // Actualizar en el backend
      await _service.markAsRead(notificationId);

      print('✅ Notificación $notificationId marcada como leída');
    } catch (e) {
      print('❌ Error al marcar como leída: $e');
      // Recargar para sincronizar
      await loadNotifications();
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      print('📖 Marcando todas las notificaciones como leídas...');

      // Actualizar localmente primero
      final updatedNotifications = state.notifications
          .map((n) => n.markAsRead())
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Actualizar en el backend
      await _service.markAllAsRead(userId);

      print('✅ Todas las notificaciones marcadas como leídas');
    } catch (e) {
      print('❌ Error al marcar todas como leídas: $e');
      state = state.copyWith(error: 'Error al marcar como leídas');
      // Recargar para sincronizar
      await loadNotifications();
    }
  }

  /// Eliminar una notificación
  Future<void> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Eliminando notificación $notificationId...');

      // Eliminar localmente primero
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();
      final newUnreadCount = updatedNotifications
          .where((n) => !n.isRead)
          .length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );

      // Eliminar en el backend
      await _service.deleteNotification(notificationId);

      print('✅ Notificación $notificationId eliminada');
    } catch (e) {
      print('❌ Error al eliminar notificación: $e');
      state = state.copyWith(error: 'Error al eliminar notificación');
      // Recargar para sincronizar
      await loadNotifications();
    }
  }

  /// Eliminar todas las notificaciones
  Future<void> deleteAllNotifications() async {
    try {
      print('🗑️ Eliminando todas las notificaciones...');

      // Limpiar localmente primero
      state = state.copyWith(notifications: [], unreadCount: 0);

      // Eliminar en el backend
      await _service.deleteAllNotifications(userId);

      print('✅ Todas las notificaciones eliminadas');
    } catch (e) {
      print('❌ Error al eliminar todas las notificaciones: $e');
      state = state.copyWith(error: 'Error al eliminar notificaciones');
      // Recargar para sincronizar
      await loadNotifications();
    }
  }

  // ==========================================================================
  // MÉTODOS DE FILTRADO
  // ==========================================================================

  /// Obtener notificaciones por tipo
  List<NotificationModel> getByType(NotificationType type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  /// Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider del servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Obtener el token de autenticación si está disponible
  // TODO: Integrar con el auth provider cuando esté disponible
  final authToken = null; // ref.watch(authTokenProvider);

  return NotificationService(authToken: authToken);
});

/// Provider del notifier de notificaciones
///
/// Requiere el userId como parámetro
final notificationProvider =
    StateNotifierProvider.family<NotificationNotifier, NotificationState, int>((
      ref,
      userId,
    ) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationNotifier(service: service, userId: userId);
    });

/// Provider para el contador de notificaciones no leídas
///
/// Útil para mostrar badges en la UI
final unreadCountProvider = Provider.family<int, int>((ref, userId) {
  final state = ref.watch(notificationProvider(userId));
  return state.unreadCount;
});

/// Provider para verificar si hay notificaciones no leídas
final hasUnreadNotificationsProvider = Provider.family<bool, int>((
  ref,
  userId,
) {
  final count = ref.watch(unreadCountProvider(userId));
  return count > 0;
});
