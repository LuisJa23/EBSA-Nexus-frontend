// novelty.dart
//
// Entidad de dominio para novedades
//
// PROPÓSITO:
// - Representar una novedad en el dominio de la aplicación
// - Definir enums para estados y prioridades
//
// CAPA: DOMAIN LAYER - ENTITIES

import 'package:equatable/equatable.dart';

/// Entidad de novedad
class Novelty extends Equatable {
  final int id;
  final String description;
  final NoveltyStatus status;
  final NoveltyPriority priority;
  final String reason;
  final String accountNumber;
  final String meterNumber;
  final String activeReading;
  final String reactiveReading;
  final String municipality;
  final String address;
  final String? observations;
  final int? crewId;
  final String? crewName;
  final int areaId;
  final String areaName;
  final int creatorId;
  final String creatorName;
  final int imageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Novelty({
    required this.id,
    required this.description,
    required this.status,
    required this.priority,
    required this.reason,
    required this.accountNumber,
    required this.meterNumber,
    required this.activeReading,
    required this.reactiveReading,
    required this.municipality,
    required this.address,
    this.observations,
    this.crewId,
    this.crewName,
    required this.areaId,
    required this.areaName,
    required this.creatorId,
    required this.creatorName,
    required this.imageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    status,
    priority,
    reason,
    accountNumber,
    meterNumber,
    activeReading,
    reactiveReading,
    municipality,
    address,
    observations,
    crewId,
    crewName,
    areaId,
    areaName,
    creatorId,
    creatorName,
    imageCount,
    createdAt,
    updatedAt,
  ];

  /// Verifica si la novedad tiene cuadrilla asignada
  bool get hasCrewAssigned => crewId != null;

  /// Verifica si la novedad tiene imágenes
  bool get hasImages => imageCount > 0;
}

/// Estados posibles de una novedad
/// Flujo: CREADA → EN_CURSO → COMPLETADA → CERRADA
///        CREADA → CANCELADA (solo desde CREADA)
enum NoveltyStatus {
  creada('CREADA', 'Creada'),
  enCurso('EN_CURSO', 'En Curso'),
  completada('COMPLETADA', 'Completada'),
  cerrada('CERRADA', 'Cerrada'),
  cancelada('CANCELADA', 'Cancelada');

  final String value;
  final String label;

  const NoveltyStatus(this.value, this.label);

  /// Crea un estado desde un string
  static NoveltyStatus fromString(String value) {
    return NoveltyStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NoveltyStatus.creada,
    );
  }

  /// Verifica si se puede asignar una cuadrilla
  bool get canAssignCrew => this == NoveltyStatus.creada;

  /// Verifica si se puede cancelar
  bool get canBeCancelled => this == NoveltyStatus.creada;

  /// Verifica si se pueden subir evidencias
  bool get canUploadEvidence => this == NoveltyStatus.enCurso;

  /// Verifica si se puede completar
  bool get canComplete => this == NoveltyStatus.enCurso;

  /// Verifica si se puede cerrar
  bool get canClose => this == NoveltyStatus.completada;

  /// Verifica si es un estado terminal
  bool get isTerminal =>
      this == NoveltyStatus.cerrada || this == NoveltyStatus.cancelada;

  /// Valida si la transición al estado objetivo es válida
  bool canTransitionTo(NoveltyStatus targetStatus) {
    return switch (this) {
      NoveltyStatus.creada =>
        targetStatus == NoveltyStatus.enCurso ||
            targetStatus == NoveltyStatus.cancelada,
      NoveltyStatus.enCurso =>
        targetStatus == NoveltyStatus.completada ||
            targetStatus == NoveltyStatus.cancelada,
      NoveltyStatus.completada => targetStatus == NoveltyStatus.cerrada,
      NoveltyStatus.cerrada ||
      NoveltyStatus.cancelada => false, // Estados terminales
    };
  }

  /// Obtiene el color asociado al estado
  String get colorHex {
    switch (this) {
      case NoveltyStatus.creada:
        return '#FFA726'; // Naranja - Recién creada
      case NoveltyStatus.enCurso:
        return '#42A5F5'; // Azul - En progreso
      case NoveltyStatus.completada:
        return '#AB47BC'; // Púrpura - Completada, esperando cierre
      case NoveltyStatus.cerrada:
        return '#66BB6A'; // Verde - Finalizada
      case NoveltyStatus.cancelada:
        return '#EF5350'; // Rojo - Cancelada
    }
  }
}

/// Prioridades posibles de una novedad
enum NoveltyPriority {
  low('LOW', 'Baja'),
  medium('MEDIUM', 'Media'),
  high('HIGH', 'Alta'),
  critical('CRITICAL', 'Crítica');

  final String value;
  final String label;

  const NoveltyPriority(this.value, this.label);

  /// Crea una prioridad desde un string
  static NoveltyPriority fromString(String value) {
    return NoveltyPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NoveltyPriority.medium,
    );
  }

  /// Obtiene el color asociado a la prioridad
  String get colorHex {
    switch (this) {
      case NoveltyPriority.low:
        return '#4CAF50'; // Verde
      case NoveltyPriority.medium:
        return '#FF9800'; // Naranja
      case NoveltyPriority.high:
        return '#FF5722'; // Naranja oscuro
      case NoveltyPriority.critical:
        return '#F44336'; // Rojo
    }
  }
}
