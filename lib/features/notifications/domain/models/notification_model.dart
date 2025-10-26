// notification_model.dart
//
// Modelo de datos para notificaciones
//
// PROPÓSITO:
// - Representar notificaciones del backend
// - Parsear JSON del backend correctamente (incluyendo fechas sin milisegundos)
// - Proporcionar utilidades para manejo de notificaciones

import 'notification_type.dart';

/// Modelo de notificación de EBSA Nexus
///
/// Representa una notificación del sistema con toda su información
/// Sincronizado con el backend según NOTIFICATIONS_FLUTTER_FIX.md
class NotificationModel {
  final int id;
  final int userId;
  final int? noveltyId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.noveltyId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  /// Parsea fechas del backend correctamente
  ///
  /// El backend devuelve fechas en formato: "2025-10-26T17:17:39" (sin milisegundos)
  /// Este método agrega los milisegundos faltantes para que DateTime.parse() funcione
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    String dateStr = value.toString();

    // El backend devuelve: "2025-10-26T17:17:39"
    // Flutter necesita: "2025-10-26T17:17:39.000" o "2025-10-26T17:17:39Z"

    // Si no tiene milisegundos ni zona horaria, agregarlos
    if (!dateStr.contains('.') && dateStr.contains('T')) {
      // Verificar si tiene zona horaria
      if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
        dateStr = '$dateStr.000';
      }
    }

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('⚠️ Error parsing date: $dateStr - Error: $e');
      return DateTime.now();
    }
  }

  /// Crea una instancia desde JSON del backend
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['id'] as int,
        userId: json['userId'] as int,
        noveltyId: json['noveltyId'] as int?,
        type: NotificationType.fromString(json['type'] as String),
        title: json['title'] as String,
        message: json['message'] as String,
        isRead: json['isRead'] as bool? ?? false,
        readAt: json['readAt'] != null ? _parseDateTime(json['readAt']) : null,
        createdAt: _parseDateTime(json['createdAt']),
      );
    } catch (e) {
      print('❌ Error parsing notification: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'noveltyId': noveltyId,
      'type': type.value,
      'title': title,
      'message': message,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  NotificationModel copyWith({
    int? id,
    int? userId,
    int? noveltyId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      noveltyId: noveltyId ?? this.noveltyId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Marca la notificación como leída
  NotificationModel markAsRead() {
    return copyWith(isRead: true, readAt: DateTime.now());
  }

  /// Calcula el tiempo transcurrido desde la creación
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: ${type.value}, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Resumen de notificaciones (para mostrar en login o dashboard)
class NotificationSummary {
  final List<NotificationModel> allNotifications;
  final int unreadCount;
  final List<NotificationModel> recentNotifications;

  NotificationSummary({
    required this.allNotifications,
    required this.unreadCount,
    required this.recentNotifications,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationSummary(
        allNotifications: (json['allNotifications'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        unreadCount: json['unreadCount'] as int,
        recentNotifications: (json['recentNotifications'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      print('❌ Error parsing notification summary: $e');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'NotificationSummary(total: ${allNotifications.length}, unread: $unreadCount, recent: ${recentNotifications.length})';
  }
}
