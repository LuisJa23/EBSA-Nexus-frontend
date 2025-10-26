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

import 'package:jwt_decoder/jwt_decoder.dart';
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
    required super.firstName,
    required super.lastName,
    required super.role,
    super.uuid,
    super.username,
    super.workArea,
    super.workType,
    super.documentNumber,
    super.phoneNumber,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
  });

  // ============================================================================
  // DESERIALIZACIÓN DESDE JSON (API → Model)
  // ============================================================================

  /// Crea UserModel desde respuesta JSON de la API `/api/users/me`
  ///
  /// **Formato esperado del JSON**:
  /// ```json
  /// {
  ///   "id": 3,
  ///   "uuid": "40861513-d450-468b-a993-5f7adb6ff710",
  ///   "username": "test1",
  ///   "email": "test01@ebsa.com.co",
  ///   "firstName": "Juan Carlos",
  ///   "lastName": "Pérez González",
  ///   "roleName": "JEFE_AREA",
  ///   "workRoleName": "Desarrollador",
  ///   "workType": "intern",
  ///   "documentNumber": "1000951117",
  ///   "phone": "3125594050",
  ///   "active": true,
  ///   "createdAt": "2025-10-13T21:29:50",
  ///   "updatedAt": "2025-10-13T22:49:32",
  ///   "lastLogin": "2025-10-13T22:49:32"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: _parseId(json['id']),
        uuid: _parseOptionalString(json, 'uuid'),
        username: _parseOptionalString(json, 'username'),
        email: _parseStringField(json, 'email').toLowerCase().trim(),
        firstName: _parseStringField(json, 'firstName', defaultValue: ''),
        lastName: _parseStringField(json, 'lastName', defaultValue: ''),
        role: _parseUserRole(json['roleName']),
        workArea: _parseOptionalString(json, 'workRoleName'),
        workType: _parseOptionalString(json, 'workType'),
        documentNumber: _parseOptionalString(json, 'documentNumber'),
        phoneNumber: _parseOptionalString(json, 'phone'),
        isActive: _parseBoolField(json, 'active', defaultValue: true),
        createdAt: _parseDateTimeField(json, 'createdAt'),
        updatedAt: _parseDateTimeField(json, 'updatedAt'),
        lastLoginAt: _parseOptionalDateTime(json, 'lastLogin'),
      );
    } catch (e) {
      throw FormatException('Error deserializando UserModel: $e');
    }
  }

  /// Crea UserModel desde respuesta de login exitoso
  ///
  /// Formato específico que incluye token y permisos adicionales
  factory UserModel.fromLoginResponse(Map<String, dynamic> json, String token) {
    try {
      print('🔍 DEBUG fromLoginResponse - JSON completo: $json');
      print('🔍 DEBUG fromLoginResponse - token: ${token.substring(0, 20)}...');

      // Decodificar el JWT para obtener el userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print(
        '🔍 DEBUG JWT decodificado - TODAS LAS CLAVES: ${decodedToken.keys.toList()}',
      );
      print('🔍 DEBUG JWT decodificado - TODOS LOS VALORES: $decodedToken');

      final now = DateTime.now();

      // Intentar obtener el userId del JWT primero
      String userId = 'unknown';

      // Revisar diferentes campos posibles en el JWT
      if (decodedToken.containsKey('userId')) {
        userId = decodedToken['userId'].toString();
        print('✅ userId encontrado en JWT.userId: $userId');
      } else if (decodedToken.containsKey('id')) {
        userId = decodedToken['id'].toString();
        print('✅ userId encontrado en JWT.id: $userId');
      } else if (decodedToken.containsKey('sub')) {
        userId = decodedToken['sub'].toString();
        print('✅ userId encontrado en JWT.sub: $userId');
      } else if (json.containsKey('userId')) {
        userId = json['userId'].toString();
        print('✅ userId encontrado en JSON.userId: $userId');
      } else if (json.containsKey('id')) {
        userId = json['id'].toString();
        print('✅ userId encontrado en JSON.id: $userId');
      } else {
        print(
          '⚠️ NO SE ENCONTRÓ userId en ningún lado, usando username como fallback',
        );
        userId = json['username'] ?? 'unknown';
      }

      final userModel = UserModel(
        id: userId,
        username: json['username'] ?? 'unknown',
        email: _parseStringField(json, 'email').toLowerCase().trim(),
        firstName: json['username'] ?? 'Usuario',
        lastName: '',
        role: _parseUserRole(json['role']),
        workArea: json['workRole'] ?? '',
        phoneNumber: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      print(
        '✅ DEBUG fromLoginResponse - UserModel creado con id: ${userModel.id}, role: ${userModel.role}',
      );
      return userModel;
    } catch (e, stackTrace) {
      print('❌ ERROR deserializando respuesta de login: $e');
      print('❌ StackTrace: $stackTrace');
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
      'uuid': uuid,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roleName': role.value,
      'workRoleName': workArea,
      'workType': workType,
      'documentNumber': documentNumber,
      'phone': phoneNumber,
      'active': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLoginAt?.toIso8601String(),
    };
  }

  /// Convierte a JSON solo con campos editables para actualización (PATCH /api/users/me)
  Map<String, dynamic> toUpdateJson() {
    return {'firstName': firstName, 'lastName': lastName, 'phone': phoneNumber};
  }

  // ============================================================================
  // CONVERSIÓN ENTRE MODEL Y ENTITY
  // ============================================================================

  /// Crea UserModel desde una entidad User del dominio
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      uuid: user.uuid,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      workArea: user.workArea,
      workType: user.workType,
      documentNumber: user.documentNumber,
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
      uuid: uuid,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      workArea: workArea,
      workType: workType,
      documentNumber: documentNumber,
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

  /// Parsea ID (puede ser int o string)
  static String _parseId(dynamic value) {
    if (value == null) {
      throw FormatException('Campo "id" es requerido');
    }
    if (value is int) return value.toString();
    if (value is String) return value.trim();
    throw FormatException('Campo "id" tiene formato inválido');
  }

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
      firstName: '',
      lastName: '',
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
      firstName: 'Usuario',
      lastName: 'de Prueba',
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
