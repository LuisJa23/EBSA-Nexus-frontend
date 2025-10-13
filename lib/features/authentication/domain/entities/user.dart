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

/// Entidad de dominio que representa un usuario del sistema Nexus EBSA
class User extends Equatable {
  /// Identificador único del usuario
  final String id;

  /// Email del usuario (usado para login)
  final String email;

  /// Nombre completo del usuario
  final String fullName;

  /// Rol del usuario en el sistema
  final UserRole role;

  /// Área de trabajo asignada
  final String? workArea;

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
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.workArea,
    this.phoneNumber,
    this.lastLoginAt,
  });

  /// Crea un usuario con valores por defecto
  factory User.create({
    required String id,
    required String email,
    required String fullName,
    required UserRole role,
    String? workArea,
    String? phoneNumber,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      workArea: workArea,
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

  /// Actualiza información del usuario
  User updateInfo({String? fullName, String? workArea, String? phoneNumber}) {
    return copyWith(
      fullName: fullName ?? this.fullName,
      workArea: workArea ?? this.workArea,
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
    String? email,
    String? fullName,
    UserRole? role,
    String? workArea,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      workArea: workArea ?? this.workArea,
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
    return isActive && role == UserRole.admin;
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
    // Por ahora, todos los usuarios activos tienen asignación
    // En el futuro esto consultaría una tabla de asignaciones
    return isActive && role != UserRole.admin;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    workArea,
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

  /// Gerente de área
  areaManager('area_manager', 'Gerente de Área'),

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
    return this == UserRole.admin;
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