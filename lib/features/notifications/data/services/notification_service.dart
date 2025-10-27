// notification_service.dart
//
// Servicio de API para notificaciones
//
// PROPÓSITO:
// - Comunicarse con el backend de notificaciones
// - Obtener, marcar como leídas y eliminar notificaciones
// - Manejar errores de red y parseo correctamente

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/models/notification_type.dart';

/// Servicio de API para gestión de notificaciones
///
/// Proporciona métodos para interactuar con todos los endpoints
/// de notificaciones del backend
class NotificationService {
  final String? authToken;

  NotificationService({this.authToken});

  /// Headers comunes para las peticiones
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  /// Construye la URL completa para un endpoint
  String _buildUrl(String endpoint) {
    return '${ApiConstants.currentBaseUrl}$endpoint';
  }

  // ==========================================================================
  // MÉTODOS DE LECTURA
  // ==========================================================================

  /// Obtener resumen de notificaciones (para login/dashboard)
  Future<NotificationSummary> getNotificationSummary(int userId) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/user/$userId/summary'),
      );

      print('🔄 Cargando resumen de notificaciones del usuario $userId...');
      final response = await http.get(url, headers: _headers);

      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final summary = NotificationSummary.fromJson(jsonData);
        print(
          '✅ Resumen cargado: ${summary.allNotifications.length} total, ${summary.unreadCount} no leídas',
        );
        return summary;
      } else {
        print('❌ Error al cargar resumen: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception(
          'Error al cargar resumen de notificaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Excepción en getNotificationSummary: $e');
      rethrow;
    }
  }

  /// Obtener todas las notificaciones de un usuario
  Future<List<NotificationModel>> getUserNotifications(int userId) async {
    try {
      final url = Uri.parse(_buildUrl('/api/v1/notifications/user/$userId'));

      print('🔄 Cargando notificaciones del usuario $userId...');
      final response = await http.get(url, headers: _headers);

      print('📡 Status code: ${response.statusCode}');
      print('📦 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        // Manejar array vacío
        if (response.body.trim() == '[]') {
          print('✅ Usuario sin notificaciones');
          return [];
        }

        final List<dynamic> jsonList = json.decode(response.body);
        print('📋 Parseando ${jsonList.length} notificaciones...');

        final notifications = jsonList
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        print(
          '✅ ${notifications.length} notificaciones convertidas exitosamente',
        );
        return notifications;
      } else {
        print('❌ Error al cargar notificaciones: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception(
          'Error al cargar notificaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Excepción al cargar notificaciones: $e');
      rethrow;
    }
  }

  /// Obtener notificaciones no leídas
  Future<List<NotificationModel>> getUnreadNotifications(int userId) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/user/$userId/unread'),
      );

      print('🔄 Cargando notificaciones no leídas del usuario $userId...');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        if (response.body.trim() == '[]') {
          print('✅ No hay notificaciones no leídas');
          return [];
        }

        final List<dynamic> jsonList = json.decode(response.body);
        final notifications = jsonList
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        print('✅ ${notifications.length} notificaciones no leídas cargadas');
        return notifications;
      } else {
        print(
          '❌ Error al cargar notificaciones no leídas: ${response.statusCode}',
        );
        throw Exception(
          'Error al cargar notificaciones no leídas: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en getUnreadNotifications: $e');
      rethrow;
    }
  }

  /// Contar notificaciones no leídas
  Future<int> countUnreadNotifications(int userId) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/user/$userId/unread/count'),
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final count = int.parse(response.body);
        print('✅ Contador de no leídas: $count');
        return count;
      } else {
        print(
          '❌ Error al contar notificaciones no leídas: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      print('❌ Error en countUnreadNotifications: $e');
      return 0; // Retornar 0 en caso de error
    }
  }

  /// Obtener notificaciones por tipo
  Future<List<NotificationModel>> getNotificationsByType(
    int userId,
    NotificationType type,
  ) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/user/$userId/type/${type.value}'),
      );

      print('🔄 Cargando notificaciones tipo ${type.value}...');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        if (response.body.trim() == '[]') {
          return [];
        }

        final List<dynamic> jsonList = json.decode(response.body);
        final notifications = jsonList
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        print(
          '✅ ${notifications.length} notificaciones tipo ${type.value} cargadas',
        );
        return notifications;
      } else {
        print(
          '❌ Error al cargar notificaciones por tipo: ${response.statusCode}',
        );
        throw Exception(
          'Error al cargar notificaciones por tipo: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en getNotificationsByType: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // MÉTODOS DE ESCRITURA
  // ==========================================================================

  /// Marcar notificación como leída
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/$notificationId/read'),
      );

      print('🔄 Marcando notificación $notificationId como leída...');
      final response = await http.patch(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final notification = NotificationModel.fromJson(jsonData);
        print('✅ Notificación $notificationId marcada como leída');
        return notification;
      } else {
        print('❌ Error al marcar como leída: ${response.statusCode}');
        throw Exception(
          'Error al marcar notificación como leída: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en markAsRead: $e');
      rethrow;
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead(int userId) async {
    try {
      final url = Uri.parse(
        _buildUrl('/api/v1/notifications/user/$userId/read-all'),
      );

      print(
        '🔄 Marcando todas las notificaciones del usuario $userId como leídas...',
      );
      final response = await http.patch(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Todas las notificaciones marcadas como leídas');
      } else {
        print('❌ Error al marcar todas como leídas: ${response.statusCode}');
        throw Exception(
          'Error al marcar todas las notificaciones como leídas: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en markAllAsRead: $e');
      rethrow;
    }
  }

  /// Eliminar una notificación
  Future<void> deleteNotification(int notificationId) async {
    try {
      final url = Uri.parse(_buildUrl('/api/v1/notifications/$notificationId'));

      print('🔄 Eliminando notificación $notificationId...');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Notificación $notificationId eliminada');
      } else {
        print('❌ Error al eliminar notificación: ${response.statusCode}');
        throw Exception(
          'Error al eliminar notificación: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en deleteNotification: $e');
      rethrow;
    }
  }

  /// Eliminar todas las notificaciones de un usuario
  Future<void> deleteAllNotifications(int userId) async {
    try {
      final url = Uri.parse(_buildUrl('/api/v1/notifications/user/$userId'));

      print('🔄 Eliminando todas las notificaciones del usuario $userId...');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Todas las notificaciones eliminadas');
      } else {
        print(
          '❌ Error al eliminar todas las notificaciones: ${response.statusCode}',
        );
        throw Exception(
          'Error al eliminar todas las notificaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en deleteAllNotifications: $e');
      rethrow;
    }
  }

  /// Crear una notificación (solo para testing o casos especiales)
  Future<NotificationModel> createNotification({
    required int userId,
    int? noveltyId,
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      final url = Uri.parse(_buildUrl('/api/v1/notifications'));

      final body = json.encode({
        'userId': userId,
        'noveltyId': noveltyId,
        'type': type,
        'title': title,
        'message': message,
      });

      print('🔄 Creando notificación...');
      final response = await http.post(url, headers: _headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final notification = NotificationModel.fromJson(jsonData);
        print('✅ Notificación creada con ID ${notification.id}');
        return notification;
      } else {
        print('❌ Error al crear notificación: ${response.statusCode}');
        throw Exception('Error al crear notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en createNotification: $e');
      rethrow;
    }
  }
}
