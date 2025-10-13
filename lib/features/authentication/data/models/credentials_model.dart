// credentials_model.dart
//
// Modelo de datos para Credenciales (Data Layer)
//
// PROPÓSITO:
// - Representar credenciales de login
// - Transformación de datos de formularios
// - Extensión de Credentials entity del dominio
// - Validación y sanitización
//
// CAPA: DATA LAYER
// HERENCIA: extends Credentials (domain entity)

import '../../domain/entities/credentials.dart';

/// Modelo de datos para Credenciales que extiende la entidad del dominio
///
/// Actúa como adaptador entre los formularios de la UI y los datos
/// que se envían a la API. Maneja la transformación y validación
/// de credenciales de autenticación.
///
/// **Responsabilidades**:
/// - Recibir datos de formularios de login
/// - Sanitizar y validar credenciales
/// - Convertir entre Model y Entity
/// - Preparar datos para envío a la API
/// - Manejar campos adicionales de dispositivo/sesión
class CredentialsModel extends Credentials {
  /// Identificador único del dispositivo (opcional)
  final String? deviceId;

  /// Token de dispositivo para notificaciones (opcional)
  final String? deviceToken;

  /// Información del dispositivo (opcional)
  final String? deviceInfo;

  /// Constructor que inicializa el modelo con credenciales
  const CredentialsModel({
    required super.email,
    required super.password,
    super.rememberMe = false,
    this.deviceId,
    this.deviceToken,
    this.deviceInfo,
  });

  // ============================================================================
  // DESERIALIZACIÓN DESDE JSON (Formularios → Model)
  // ============================================================================

  /// Crea CredentialsModel desde datos de formulario
  ///
  /// **Formato esperado**:
  /// ```json
  /// {
  ///   "email": "usuario@ebsa.com.co",
  ///   "password": "miPassword123",
  ///   "remember_me": true,
  ///   "device_id": "device_123",
  ///   "device_token": "fcm_token_456"
  /// }
  /// ```
  factory CredentialsModel.fromJson(Map<String, dynamic> json) {
    try {
      final email = _parseEmail(json['email']);
      final password = _parsePassword(json['password']);

      return CredentialsModel(
        email: email,
        password: password,
        rememberMe: _parseRememberMe(json['remember_me']),
        deviceId: _parseOptionalString(json, 'device_id'),
        deviceToken: _parseOptionalString(json, 'device_token'),
        deviceInfo: _parseOptionalString(json, 'device_info'),
      );
    } catch (e) {
      throw FormatException('Error deserializando CredentialsModel: $e');
    }
  }

  /// Crea CredentialsModel desde formulario web/móvil
  factory CredentialsModel.fromFormData({
    required String email,
    required String password,
    bool rememberMe = false,
    String? deviceId,
    String? deviceToken,
  }) {
    return CredentialsModel(
      email: email.trim().toLowerCase(),
      password: password,
      rememberMe: rememberMe,
      deviceId: deviceId,
      deviceToken: deviceToken,
      deviceInfo: _getDeviceInfo(),
    );
  }

  // ============================================================================
  // SERIALIZACIÓN A JSON (Model → API)
  // ============================================================================

  /// Convierte CredentialsModel a JSON para la API de login
  ///
  /// **Nota**: Solo incluye los campos necesarios para autenticación
  @override
  Map<String, dynamic> toApiMap() {
    final apiData = <String, dynamic>{'email': email, 'password': password};

    // Agregar campos opcionales si están disponibles
    if (deviceId != null) {
      apiData['device_id'] = deviceId;
    }

    if (deviceToken != null) {
      apiData['device_token'] = deviceToken;
    }

    if (deviceInfo != null) {
      apiData['device_info'] = deviceInfo;
    }

    return apiData;
  }

  /// Convierte a JSON completo (incluye todos los campos)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
      'device_id': deviceId,
      'device_token': deviceToken,
      'device_info': deviceInfo,
    };
  }

  /// Convierte a JSON para almacenamiento local (sin password)
  Map<String, dynamic> toStorageJson() {
    return {
      'email': email,
      'remember_me': rememberMe,
      'device_id': deviceId,
      'device_token': deviceToken,
      'device_info': deviceInfo,
      // Nota: NO incluimos password por seguridad
    };
  }

  // ============================================================================
  // CONVERSIÓN ENTRE MODEL Y ENTITY
  // ============================================================================

  /// Crea CredentialsModel desde una entidad Credentials del dominio
  factory CredentialsModel.fromEntity(
    Credentials credentials, {
    String? deviceId,
    String? deviceToken,
  }) {
    return CredentialsModel(
      email: credentials.email,
      password: credentials.password,
      rememberMe: credentials.rememberMe,
      deviceId: deviceId,
      deviceToken: deviceToken,
      deviceInfo: _getDeviceInfo(),
    );
  }

  /// Convierte a entidad Credentials del dominio
  Credentials toEntity() {
    return Credentials(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  // ============================================================================
  // UTILIDADES DE PARSING Y VALIDACIÓN
  // ============================================================================

  /// Parsea y valida email
  static String _parseEmail(dynamic value) {
    if (value == null || value is! String) {
      throw const FormatException('Email es requerido');
    }

    final email = value.toString().trim().toLowerCase();

    if (email.isEmpty) {
      throw const FormatException('Email no puede estar vacío');
    }

    // Validación básica de formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      throw const FormatException('Formato de email inválido');
    }

    return email;
  }

  /// Parsea y valida password
  static String _parsePassword(dynamic value) {
    if (value == null || value is! String) {
      throw const FormatException('Password es requerido');
    }

    final password = value.toString();

    if (password.isEmpty) {
      throw const FormatException('Password no puede estar vacío');
    }

    if (password.length < 6) {
      throw const FormatException('Password debe tener al menos 6 caracteres');
    }

    return password;
  }

  /// Parsea campo remember me
  static bool _parseRememberMe(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  /// Parsea campo string opcional
  static String? _parseOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  /// Obtiene información básica del dispositivo
  static String? _getDeviceInfo() {
    // TODO: En una implementación completa, aquí se obtendría:
    // - Tipo de dispositivo (móvil, web, desktop)
    // - Versión del SO
    // - Modelo del dispositivo
    // - Versión de la app

    return 'Flutter App v1.0.0';
  }

  // ============================================================================
  // FACTORYS UTILITARIOS
  // ============================================================================

  /// Crea credenciales de prueba para desarrollo
  factory CredentialsModel.mockCredentials({
    String? email,
    String? password,
    bool rememberMe = false,
  }) {
    return CredentialsModel(
      email: email ?? 'admin@ebsa.com.co',
      password: password ?? 'admin123',
      rememberMe: rememberMe,
      deviceId: 'mock_device_123',
      deviceToken: 'mock_fcm_token',
      deviceInfo: 'Flutter Test Device',
    );
  }

  /// Crea credenciales para login rápido desde storage
  factory CredentialsModel.fromStoredCredentials({
    required String email,
    String? deviceId,
    String? deviceToken,
  }) {
    return CredentialsModel(
      email: email,
      password: '', // Password vacío para quick login
      rememberMe: true,
      deviceId: deviceId,
      deviceToken: deviceToken,
      deviceInfo: _getDeviceInfo(),
    );
  }

  // ============================================================================
  // COPYWITH CON CAMPOS ADICIONALES
  // ============================================================================

  /// Crea una copia con campos actualizados
  CredentialsModel copyWithModel({
    String? email,
    String? password,
    bool? rememberMe,
    String? deviceId,
    String? deviceToken,
    String? deviceInfo,
  }) {
    return CredentialsModel(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      deviceId: deviceId ?? this.deviceId,
      deviceToken: deviceToken ?? this.deviceToken,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  // ============================================================================
  // OVERRIDE PARA DEBUGGING
  // ============================================================================

  @override
  String toString() {
    return 'CredentialsModel(email: $email, rememberMe: $rememberMe, '
        'deviceId: $deviceId, hasDeviceToken: ${deviceToken != null})';
  }

  // ============================================================================
  // PROPIEDADES ADICIONALES
  // ============================================================================

  /// Verifica si tiene información completa de dispositivo
  bool get hasDeviceInfo {
    return deviceId != null && deviceToken != null;
  }

  /// Verifica si es válido para envío a API
  bool get isValidForApi {
    return isValid; // Usa la validación de la entidad base
  }
}
