// user.dart
//
// Entidad de dominio para Usuario
//
// PROPÓSITO:
// - Representar concepto de Usuario en el negocio
// - Lógica de negocio pura (sin dependencias externas)
// - Inmutable y con validaciones de dominio
// - Núcleo de la funcionalidad de autenticación
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// REGLAS CRÍTICAS:
// - NO importar Flutter, Dio, Drift, etc.
// - Solo Dart puro y packages como Equatable
// - Inmutable (final fields)

import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un usuario del sistema EBSA Nexus
class User extends Equatable {
  /// Identificador único del usuario (ID numérico del backend)
  final String id;

  /// UUID único del usuario (identificador universal)
  final String? uuid;

  /// Nombre de usuario (username)
  final String? username;

  /// Email del usuario (usado para login)
  final String email;

  /// Nombres del usuario
  final String firstName;

  /// Apellidos del usuario
  final String lastName;

  /// Nombre completo del usuario (computado)
  String get fullName => '$firstName $lastName'.trim();

  /// Rol del usuario en el sistema
  final UserRole role;

  /// Área de trabajo asignada (workRoleName del backend)
  final String? workArea;

  /// Tipo de contratación (intern/extern)
  final String? workType;

  /// Número de documento de identidad
  final String? documentNumber;

  /// Número de teléfono
  final String? phoneNumber;

  /// Indica si el usuario está activo
  final bool isActive;

  /// Fecha y hora de creación del usuario
  final DateTime createdAt;

  /// Fecha y hora de última actualización
  final DateTime updatedAt;

  /// Fecha y hora de último login (opcional)
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.uuid,
    this.username,
    this.workArea,
    this.workType,
    this.documentNumber,
    this.phoneNumber,
    this.lastLoginAt,
  });

  /// Crea un usuario con valores por defecto
  factory User.create({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? uuid,
    String? username,
    String? workArea,
    String? workType,
    String? documentNumber,
    String? phoneNumber,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      uuid: uuid,
      username: username,
      workArea: workArea,
      workType: workType,
      documentNumber: documentNumber,
      phoneNumber: phoneNumber,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Actualiza el último login del usuario
  User updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now(), updatedAt: DateTime.now());
  }

  /// Actualiza información del usuario (perfil)
  User updateInfo({String? firstName, String? lastName, String? phoneNumber}) {
    return copyWith(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      updatedAt: DateTime.now(),
    );
  }

  /// Activa o desactiva el usuario
  User updateStatus({required bool isActive}) {
    return copyWith(isActive: isActive, updatedAt: DateTime.now());
  }

  /// Crea una copia del usuario con campos actualizados
  User copyWith({
    String? id,
    String? uuid,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? workArea,
    String? workType,
    String? documentNumber,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      workArea: workArea ?? this.workArea,
      workType: workType ?? this.workType,
      documentNumber: documentNumber ?? this.documentNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  /// Verifica si el usuario puede crear reportes
  bool get canCreateReports {
    return isActive &&
        (role == UserRole.fieldWorker ||
            role == UserRole.contractor ||
            role == UserRole.areaManager ||
            role == UserRole.admin);
  }

  /// Verifica si el usuario puede aprobar reportes
  bool get canApproveReports {
    return isActive && (role == UserRole.areaManager || role == UserRole.admin);
  }

  /// Verifica si el usuario puede asignar cuadrillas
  bool get canAssignWorkCrews {
    return isActive && (role == UserRole.areaManager || role == UserRole.admin);
  }

  /// Verifica si el usuario tiene permisos administrativos
  bool get hasAdminPermissions {
    return isActive && (role == UserRole.admin || role == UserRole.areaManager);
  }

  /// Verifica si el usuario puede ver todos los reportes
  bool get canViewAllReports {
    return isActive && (role == UserRole.areaManager || role == UserRole.admin);
  }

  /// Obtiene el nombre para mostrar (nombre completo o email)
  String get displayName {
    return fullName.isNotEmpty ? fullName : email;
  }

  /// Obtiene las iniciales del usuario
  String get initials {
    if (fullName.isEmpty) return email.substring(0, 1).toUpperCase();

    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }

  /// Verifica si el usuario ha hecho login recientemente (últimas 24h)
  bool get hasRecentLogin {
    if (lastLoginAt == null) return false;
    final dayAgo = DateTime.now().subtract(const Duration(days: 1));
    return lastLoginAt!.isAfter(dayAgo);
  }

  /// Verifica si es el primer login del usuario
  bool get isFirstLogin {
    return lastLoginAt == null;
  }

  /// Verifica si el usuario tiene asignaciones activas de trabajo
  /// TODO: En una implementación completa, esto debería consultar las asignaciones reales
  bool get hasActiveAssignment {
    // Por ahora, todos los usuarios activos tienen asignación excepto admin y areaManager
    // En el futuro esto consultaría una tabla de asignaciones
    return isActive && role != UserRole.admin && role != UserRole.areaManager;
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    username,
    email,
    firstName,
    lastName,
    role,
    workArea,
    workType,
    documentNumber,
    phoneNumber,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }
}

/// Enum para los roles de usuario en el sistema
enum UserRole {
  /// Trabajador de campo
  fieldWorker('field_worker', 'Trabajador de Campo'),

  /// Contratista
  contractor('contractor', 'Contratista'),

  /// Jefe de área
  areaManager('area_manager', 'Jefe de Área'),

  /// Administrador del sistema
  admin('admin', 'Administrador');

  const UserRole(this.value, this.displayName);

  /// Valor para almacenamiento/API
  final String value;

  /// Nombre para mostrar al usuario
  final String displayName;

  /// Obtiene UserRole desde string value
  static UserRole fromValue(String value) {
    print('🔍 DEBUG UserRole.fromValue - Input: "$value"');
    // Convertir a minúsculas para hacer case-insensitive
    final normalizedValue = value.toLowerCase();
    print('🔍 DEBUG UserRole.fromValue - Normalized: "$normalizedValue"');

    // Mapeo especial para valores del backend
    final mappedValue = _mapBackendValue(normalizedValue);
    print('🔍 DEBUG UserRole.fromValue - Mapped: "$mappedValue"');

    final role = UserRole.values.firstWhere(
      (role) => role.value.toLowerCase() == mappedValue,
      orElse: () {
        print(
          '⚠️ DEBUG UserRole.fromValue - No match found, usando fieldWorker',
        );
        return UserRole.fieldWorker;
      },
    );
    print('✅ DEBUG UserRole.fromValue - Result: $role');
    return role;
  }

  /// Mapea valores del backend a valores esperados del enum
  static String _mapBackendValue(String value) {
    switch (value) {
      case 'admin':
        return 'admin';
      case 'jefe_area':
        return 'area_manager';
      case 'area_manager':
        return 'area_manager';
      case 'field_worker':
        return 'field_worker';
      case 'contractor':
        return 'contractor';
      default:
        return value;
    }
  }

  /// Verifica si este rol puede crear reportes
  bool get canCreateReports {
    return this != UserRole.admin; // Todos excepto admin pueden crear
  }

  /// Verifica si este rol puede aprobar reportes
  bool get canApproveReports {
    return this == UserRole.areaManager || this == UserRole.admin;
  }

  /// Verifica si este rol tiene permisos administrativos
  bool get hasAdminPermissions {
    return this == UserRole.admin || this == UserRole.areaManager;
  }
}
//
// CONTENIDO ESPERADO:
// - class User extends Equatable
// - final String id, email, name, role
// - final List<String> permissions
// - final UserRole role (enum)
// - Constructor con validaciones
// - @override List<Object?> get props
// - factory constructors para diferentes escenarios
// - Métodos de negocio: hasPermission(), isActive(), etc.
// - toString() override para debugging