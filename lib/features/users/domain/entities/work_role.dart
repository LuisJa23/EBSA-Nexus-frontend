// work_role.dart
//
// Entidad de rol de trabajo
//
// PROPÓSITO:
// - Representar los diferentes roles de trabajo disponibles
// - Diferenciar entre roles internos y externos
// - Proveer información para dropdowns del formulario
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Tipo de trabajador
enum WorkType {
  intern('intern', 'Interno'),
  extern('extern', 'Externo');

  final String value;
  final String displayName;

  const WorkType(this.value, this.displayName);

  static WorkType fromString(String value) {
    return WorkType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => WorkType.intern,
    );
  }
}

/// Entidad que representa un rol de trabajo
///
/// Los roles de trabajo definen las funciones específicas
/// que puede tener un trabajador dentro de EBSA.
class WorkRole extends Equatable {
  /// ID único del rol de trabajo
  final int id;

  /// Nombre del rol
  final String name;

  /// Tipo de trabajador (interno/externo)
  final WorkType workType;

  /// Descripción opcional del rol
  final String? description;

  const WorkRole({
    required this.id,
    required this.name,
    required this.workType,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, workType, description];

  @override
  String toString() => 'WorkRole(id: $id, name: $name, workType: ${workType.value})';
}
