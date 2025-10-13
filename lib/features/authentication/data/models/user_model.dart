// user_model.dart
//
// Modelo de datos para Usuario (Data Layer)
//
// PROPÓSITO:
// - Representar datos de usuario de la API
// - Transformación JSON ↔ Objeto
// - Extensión de User entity del dominio
// - Serialización para almacenamiento local
//
// CAPA: DATA LAYER
// HERENCIA: extends User (domain entity)

import '../../domain/entities/user.dart';

/// Modelo de datos para Usuario que extiende la entidad del dominio
///
/// Actúa como adaptador entre la representación JSON de la API
/// y la entidad pura del dominio. Maneja la serialización/deserialización
/// y convierte entre diferentes formatos de datos.
///
/// **Responsabilidades**:
/// - Deserializar respuestas JSON de la API
/// - Serializar para envío a la API
/// - Convertir entre Model y Entity
/// - Manejar campos opcionales y validaciones
/// - Proporcionar valores por defecto seguros
class UserModel extends User {
  /// Constructor que inicializa el modelo con datos del usuario
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.workArea,
    super.phoneNumber,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
  });

  // ============================================================================
  // DESERIALIZACIÓN DESDE JSON (API → Model)
  // ============================================================================

  /// Crea UserModel desde respuesta JSON de la API
  ///
  /// **Formato esperado del JSON**:
  /// ```json
  /// {
  ///   "id": "user_123",
  ///   "email": "usuario@ebsa.com.co",
  ///   "full_name": "Juan Pérez",
  ///   "role": "field_worker",
  ///   "work_area": "Distribución Norte",
  ///   "phone_number": "+57 300 123 4567",
  ///   "is_active": true,
  ///   "created_at": "2024-01-15T10:30:00Z",
  ///   "updated_at": "2024-01-20T14:45:00Z",
  ///   "last_login_at": "2024-01-20T09:15:00Z"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: _parseStringField(json, 'id'),
        email: _parseStringField(json, 'email').toLowerCase().trim(),
        fullName: _parseStringField(json, 'full_name', defaultValue: ''),
        role: _parseUserRole(json['role']),
        workArea: _parseStringField(json, 'work_area', defaultValue: ''),
        phoneNumber: _parseOptionalString(json, 'phone_number'),
        isActive: _parseBoolField(json, 'is_active', defaultValue: true),
        createdAt: _parseDateTimeField(json, 'created_at'),
        updatedAt: _parseDateTimeField(json, 'updated_at'),
        lastLoginAt: _parseOptionalDateTime(json, 'last_login_at'),
      );
    } catch (e) {
      throw FormatException('Error deserializando UserModel: $e');
    }
  }

  /// Crea UserModel desde respuesta de login exitoso
  ///
  /// Formato específico que incluye token y permisos adicionales
  factory UserModel.fromLoginResponse(Map<String, dynamic> json) {
    try {
      print('🔍 DEBUG fromLoginResponse - JSON completo: $json');
      print('🔍 DEBUG fromLoginResponse - role field: ${json['role']}');
      final now = DateTime.now();

      final userModel = UserModel(
        id: json['username'] ?? 'unknown',
        email: _parseStringField(json, 'email').toLowerCase().trim(),
        fullName: json['username'] ?? 'Usuario',
        role: _parseUserRole(json['role']),
        workArea: json['workRole'] ?? '',
        phoneNumber: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      print(
        '✅ DEBUG fromLoginResponse - UserModel creado con role: ${userModel.role}',
      );
      return userModel;
    } catch (e) {
      throw FormatException('Error deserializando respuesta de login: $e');
    }
  }

  // ============================================================================
  // SERIALIZACIÓN A JSON (Model → API)
  // ============================================================================

  /// Convierte UserModel a JSON para envío a la API
  ///
  /// **Nota**: No incluye campos de solo lectura como timestamps
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.value,
      'work_area': workArea,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Convierte a JSON solo con campos editables para actualización
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'work_area': workArea,
      'phone_number': phoneNumber,
    };
  }

  // ============================================================================
  // CONVERSIÓN ENTRE MODEL Y ENTITY
  // ============================================================================

  /// Crea UserModel desde una entidad User del dominio
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      workArea: user.workArea,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Convierte a entidad User del dominio
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      workArea: workArea,
      phoneNumber: phoneNumber,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  // ============================================================================
  // SERIALIZACIÓN PARA ALMACENAMIENTO LOCAL
  // ============================================================================

  /// Convierte a JSON para almacenamiento en cache local
  Map<String, dynamic> toCacheJson() {
    return toJson();
  }

  /// Crea UserModel desde cache local
  factory UserModel.fromCache(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  // ============================================================================
  // UTILIDADES DE PARSING SEGURO
  // ============================================================================

  /// Parsea campo string requerido
  static String _parseStringField(
    Map<String, dynamic> json,
    String key, {
    String? defaultValue,
  }) {
    final value = json[key];
    if (value == null || value is! String) {
      if (defaultValue != null) return defaultValue;
      throw FormatException('Campo requerido "$key" faltante o inválido');
    }
    return value.trim();
  }

  /// Parsea campo string opcional
  static String? _parseOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  /// Parsea campo booleano
  static bool _parseBoolField(
    Map<String, dynamic> json,
    String key, {
    required bool defaultValue,
  }) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Parsea UserRole desde string
  static UserRole _parseUserRole(dynamic value) {
    print(
      '🔍 DEBUG _parseUserRole - Input value: $value (type: ${value.runtimeType})',
    );
    if (value == null || value is! String) {
      print(
        '⚠️ DEBUG _parseUserRole - Valor nulo o no string, usando fieldWorker por defecto',
      );
      return UserRole.fieldWorker; // Rol por defecto
    }
    final role = UserRole.fromValue(value);
    print('✅ DEBUG _parseUserRole - Role parseado: $role');
    return role;
  }

  /// Parsea DateTime requerido
  static DateTime _parseDateTimeField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return DateTime.now();

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  /// Parsea DateTime opcional
  static DateTime? _parseOptionalDateTime(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null || value is! String) return null;

    return DateTime.tryParse(value);
  }

  // ============================================================================
  // FACTORYS UTILITARIOS
  // ============================================================================

  /// Crea un UserModel vacío para casos de error
  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      id: '',
      email: '',
      fullName: '',
      role: UserRole.fieldWorker,
      workArea: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Crea UserModel de prueba para desarrollo
  factory UserModel.mockUser({String? id, String? email, UserRole? role}) {
    return UserModel(
      id: id ?? 'mock_user_123',
      email: email ?? 'test@ebsa.com.co',
      fullName: 'Usuario de Prueba',
      role: role ?? UserRole.fieldWorker,
      workArea: 'Área de Desarrollo',
      phoneNumber: '+57 300 123 4567',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  // ============================================================================
  // OVERRIDE PARA DEBUGGING
  // ============================================================================

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: ${role.value}, isActive: $isActive)';
  }
}
