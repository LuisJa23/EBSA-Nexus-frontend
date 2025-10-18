// worker.dart
//
// Entidad de dominio para Worker
//
// PROPÓSITO:
// - Representar un trabajador en el dominio
// - Libre de dependencias externas
// - Reglas de negocio básicas
//
// CAPA: DOMAIN LAYER

/// Entidad de dominio que representa un trabajador del sistema
///
/// Esta entidad contiene la información básica de un trabajador
/// sin dependencias de frameworks externos.
class Worker {
  final int id;
  final String uuid;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String workType;
  final String documentNumber;
  final String phone;
  final bool active;

  const Worker({
    required this.id,
    required this.uuid,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.workType,
    required this.documentNumber,
    required this.phone,
    required this.active,
  });

  /// Nombre completo del trabajador
  String get fullName => '$firstName $lastName';

  /// Verifica si el trabajador está activo
  bool get isActive => active;

  /// Tipo de trabajo localizado
  String get workTypeLocalized {
    switch (workType.toLowerCase()) {
      case 'intern':
        return 'Interno';
      case 'external':
        return 'Externo';
      case 'contractor':
        return 'Contratista';
      default:
        return workType;
    }
  }

  /// Representación en string para debugging
  @override
  String toString() {
    return 'Worker(id: $id, username: $username, fullName: $fullName, active: $active)';
  }

  /// Comparación por igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker && other.id == id && other.uuid == uuid;
  }

  /// Hash code
  @override
  int get hashCode => Object.hash(id, uuid);

  /// Copia la entidad con campos modificados
  Worker copyWith({
    int? id,
    String? uuid,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? workType,
    String? documentNumber,
    String? phone,
    bool? active,
  }) {
    return Worker(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      workType: workType ?? this.workType,
      documentNumber: documentNumber ?? this.documentNumber,
      phone: phone ?? this.phone,
      active: active ?? this.active,
    );
  }
}
