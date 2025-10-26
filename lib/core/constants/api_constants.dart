// api_constants.dart
//
// Constantes relacionadas con API y endpoints
//
// PROPÓSITO:
// - Definir URLs base y endpoints de la API
// - Headers HTTP constantes
// - Códigos de respuesta HTTP
// - Configuraciones de autenticación
//

/// Constantes de configuración para API de Nexus EBSA
class ApiConstants {
  // ============================================================================
  // CONFIGURACIÓN DE ENTORNO
  // ============================================================================

  /// URL base para desarrollo local (localhost - para emulador)
  static const String baseUrlLocalhost = 'http://localhost:8080';

  /// URL base para desarrollo en red local (para dispositivo físico)
  /// IP del hotspot WiFi compartido desde PC
  static const String baseUrlNetwork = 'http://192.168.20.44:8080';

  /// URL base para producción (configurar cuando esté disponible)
  static const String baseUrlProduction = 'https://api.nexusebsa.com';

  /// URL actual basada en el entorno
  /// Se determina dinámicamente según el tipo de dispositivo
  static String get currentBaseUrl {
    // Para desarrollo, puedes cambiar manualmente entre estas opciones:
    // return baseUrlLocalhost;  // Para emulador
    return baseUrlNetwork; // Para dispositivo físico

    // TODO: Implementar detección automática en futuras versiones
    // if (Platform.isAndroid && kIsWeb == false) {
    //   return _isEmulator() ? baseUrlLocalhost : baseUrlNetwork;
    // }
  }

  // ============================================================================
  // ENDPOINTS DE AUTENTICACIÓN
  // ============================================================================

  /// Endpoint para login de usuarios
  static const String loginEndpoint = '/auth/login';

  /// Endpoint para logout
  static const String logoutEndpoint = '/auth/logout';

  /// Endpoint para refresh token
  static const String refreshTokenEndpoint = '/auth/refresh';

  /// Endpoint para obtener/actualizar perfil del usuario (GET/PATCH /api/users/me)
  /// Este endpoint reemplaza /auth/me que no existe en el backend
  static const String currentUserEndpoint = '/api/users/me';

  /// Alias para currentUserEndpoint (mismo endpoint, nombres diferentes para compatibilidad)
  static const String userProfileEndpoint = '/api/users/me';

  /// Endpoint para obtener perfil de usuario
  static const String profileEndpoint = '/auth/profile';
  static const String workroles = '/api/work-roles';

  /// Endpoint para cambiar contraseña del usuario actual
  static const String changePasswordEndpoint = '/api/users/me/change-password';

  // ============================================================================
  // ENDPOINTS DE USUARIOS
  // ============================================================================

  /// Endpoint para gestión de usuarios (CRUD)
  static const String usersEndpoint = '/api/users';

  /// Endpoint para crear usuario
  static const String createUserEndpoint = '/api/users';

  /// Endpoint para obtener lista de trabajadores (público)
  static const String workersEndpoint = '/api/public/workers';

  // ============================================================================
  // ENDPOINTS DE REPORTES (para futuro uso)
  // ============================================================================

  /// Endpoint para obtener reportes
  static const String reportsEndpoint = '/reports';

  /// Endpoint para crear reporte
  static const String createReportEndpoint = '/reports';

  /// Endpoint para subir evidencia
  static const String uploadEvidenceEndpoint = '/reports/evidence';

  // ============================================================================
  // ENDPOINTS DE NOVEDADES
  // ============================================================================

  /// Endpoint para crear novedad (con form-data para imágenes)
  static const String createNoveltyEndpoint = '/api/v1/novelties';

  /// Endpoint para obtener lista de novedades
  static const String noveltiesEndpoint = '/api/v1/novelties';

  /// Endpoint para obtener novedades del usuario
  static String userNoveltiesEndpoint(String userId) =>
      '/api/v1/novelties/user/$userId';

  // ============================================================================
  // HEADERS HTTP
  // ============================================================================

  /// Content-Type para JSON
  static const String contentTypeJson = 'application/json';

  /// Accept header para JSON
  static const String acceptJson = 'application/json';

  /// Authorization header key
  static const String authorizationHeader = 'Authorization';

  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer ';

  // ============================================================================
  // TIMEOUTS Y CONFIGURACIÓN DE RED
  // ============================================================================

  /// Timeout para conexión (en milisegundos)
  static const int connectTimeout = 5000;

  /// Timeout para recepción (en milisegundos)
  static const int receiveTimeout = 3000;

  /// Timeout para envío (en milisegundos)
  static const int sendTimeout = 3000;

  // ============================================================================
  // CÓDIGOS DE RESPUESTA HTTP
  // ============================================================================

  /// Éxito
  static const int httpSuccess = 200;

  /// Creado exitosamente
  static const int httpCreated = 201;

  /// Sin contenido
  static const int httpNoContent = 204;

  /// Petición incorrecta
  static const int httpBadRequest = 400;

  /// No autorizado
  static const int httpUnauthorized = 401;

  /// Prohibido
  static const int httpForbidden = 403;

  /// No encontrado
  static const int httpNotFound = 404;

  /// Error interno del servidor
  static const int httpInternalServerError = 500;

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  /// Construye la URL completa para un endpoint
  static String buildUrl(String endpoint) {
    return '$currentBaseUrl$endpoint';
  }

  /// Construye URL de login
  static String get loginUrl => buildUrl(loginEndpoint);

  /// Construye URL de logout
  static String get logoutUrl => buildUrl(logoutEndpoint);

  /// Construye URL de perfil
  static String get profileUrl => buildUrl(profileEndpoint);

  static String get workrolesUrl => buildUrl(workroles);
}

// CONTENIDO ESPERADO:
// - const String kBaseUrl = 'https://api.nexus-ebsa.com';
// - const String kApiVersion = '/api/v1';
// - const String kLoginEndpoint = '/auth/login';
// - const String kReportsEndpoint = '/reports';
// - const String kIncidentsEndpoint = '/incidents';
// - const String kUsersEndpoint = '/users';
// - const String kSyncEndpoint = '/sync';
// - const Map<String, String> kDefaultHeaders = {...};
// - const int kHttpTimeout = 30;
