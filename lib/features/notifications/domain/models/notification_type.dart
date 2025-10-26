// notification_type.dart
//
// Enum para tipos de notificación sincronizado con el backend
//
// PROPÓSITO:
// - Definir todos los tipos de notificaciones del sistema
// - Mapear strings del backend a enums de Flutter
// - Proporcionar iconos y textos display para cada tipo

import 'package:flutter/material.dart';

/// Tipos de notificaciones sincronizados con el backend de EBSA Nexus
///
/// Estos tipos coinciden exactamente con los strings que envía el backend
/// según el archivo FLUTTER_NOTIFICATIONS_GUIDE.md
enum NotificationType {
  /// Nueva novedad reportada en el sistema
  noveltyCreated('NEW_NOVELTY', '📋', 'Nueva Novedad'),

  /// Novedad asignada a una cuadrilla
  noveltyAssigned('NOVELTY_ASSIGNED', '📌', 'Novedad Asignada'),

  /// Cambio de estado de una novedad
  statusChange('STATUS_CHANGE', '🔄', 'Cambio de Estado'),

  /// Novedad completada
  noveltyCompleted('NOVELTY_COMPLETED', '✅', 'Novedad Completada'),

  /// Completación rechazada por administrador
  completionRejected('COMPLETION_REJECTED', '❌', 'Completación Rechazada'),

  /// Novedad cancelada
  noveltyCancelled('NOVELTY_CANCELLED', '🚫', 'Novedad Cancelada'),

  /// Novedad vencida (overdue)
  noveltyOverdue('NOVELTY_OVERDUE', '⏰', 'Novedad Vencida'),

  /// Asignación/remoción de cuadrilla
  crewAssigned('CREW_ASSIGNED', '👥', 'Asignación de Cuadrilla'),

  /// Alerta del sistema
  systemAlert('SYSTEM_ALERT', '⚠️', 'Alerta del Sistema'),

  /// Recordatorio
  reminder('REMINDER', '🔔', 'Recordatorio'),

  /// Notificación general
  general('GENERAL', '📢', 'General');

  /// Valor string usado por el backend
  final String value;

  /// Icono emoji para mostrar
  final String icon;

  /// Nombre display para UI
  final String displayName;

  const NotificationType(this.value, this.icon, this.displayName);

  /// Convierte un string del backend a NotificationType
  ///
  /// Si el string no coincide con ningún tipo conocido,
  /// retorna [NotificationType.general] por defecto
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }

  /// Obtiene el color asociado al tipo de notificación
  ///
  /// Colores basados en la importancia y tipo de acción
  Color get color {
    switch (this) {
      case NotificationType.noveltyCreated:
        return const Color(0xFF2196F3); // Azul - Nueva información
      case NotificationType.noveltyAssigned:
        return const Color(0xFFFF9800); // Naranja - Acción requerida
      case NotificationType.statusChange:
        return const Color(0xFF9C27B0); // Púrpura - Cambio
      case NotificationType.noveltyCompleted:
        return const Color(0xFF4CAF50); // Verde - Éxito
      case NotificationType.completionRejected:
        return const Color(0xFFF44336); // Rojo - Error/Rechazo
      case NotificationType.noveltyCancelled:
        return const Color(0xFF9E9E9E); // Gris - Cancelación
      case NotificationType.noveltyOverdue:
        return const Color(0xFFFF5722); // Rojo Naranja - Urgente
      case NotificationType.crewAssigned:
        return const Color(0xFF00BCD4); // Cyan - Equipo
      case NotificationType.systemAlert:
        return const Color(0xFFFF9800); // Naranja - Alerta
      case NotificationType.reminder:
        return const Color(0xFF673AB7); // Deep Purple - Recordatorio
      case NotificationType.general:
        return const Color(0xFF607D8B); // Blue Grey - General
    }
  }

  /// Obtiene el IconData de Material Icons asociado al tipo
  IconData get iconData {
    switch (this) {
      case NotificationType.noveltyCreated:
        return Icons.fiber_new;
      case NotificationType.noveltyAssigned:
        return Icons.assignment;
      case NotificationType.statusChange:
        return Icons.sync;
      case NotificationType.noveltyCompleted:
        return Icons.check_circle;
      case NotificationType.completionRejected:
        return Icons.cancel;
      case NotificationType.noveltyCancelled:
        return Icons.block;
      case NotificationType.noveltyOverdue:
        return Icons.alarm;
      case NotificationType.crewAssigned:
        return Icons.group;
      case NotificationType.systemAlert:
        return Icons.warning;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.general:
        return Icons.info;
    }
  }

  @override
  String toString() => value;
}
