// app_logger.dart
//
// Sistema centralizado de logging
//
// PROPÓSITO:
// - Logging estructurado y consistente
// - Diferentes niveles de log (DEBUG, INFO, WARNING, ERROR)
// - Facilitar debugging de flujos críticos
// - Registro de eventos de autenticación
//
// CAPA: CORE UTILITIES

import 'package:logger/logger.dart';

/// Logger centralizado de la aplicación
///
/// Proporciona métodos para logging estructurado con diferentes
/// niveles de severidad y formateo consistente.
class AppLogger {
  // Instancia singleton del logger
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Prefijos por categoría
  static const String _authPrefix = '🔐 [AUTH]';
  static const String _networkPrefix = '🌐 [NETWORK]';
  static const String _cachePrefix = '💾 [CACHE]';
  static const String _syncPrefix = '🔄 [SYNC]';
  static const String _tokenPrefix = '🎫 [TOKEN]';

  // Constructor privado
  AppLogger._();

  // ============================================================================
  // MÉTODOS GENERALES
  // ============================================================================

  /// Log de debug (desarrollo)
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log informativo
  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de advertencia
  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // ============================================================================
  // MÉTODOS ESPECIALIZADOS - AUTENTICACIÓN
  // ============================================================================

  /// Log de inicio de sesión
  static void loginAttempt(String email) {
    info('$_authPrefix Intento de login para: $email');
  }

  /// Log de login exitoso
  static void loginSuccess(String email, String userId) {
    info('$_authPrefix ✅ Login exitoso - Usuario: $email (ID: $userId)');
  }

  /// Log de login fallido
  static void loginFailure(String email, String reason) {
    warning('$_authPrefix ❌ Login fallido para $email - Razón: $reason');
  }

  /// Log de logout
  static void logout(String userId) {
    info('$_authPrefix Logout ejecutado - Usuario ID: $userId');
  }

  /// Log de verificación de estado
  static void checkAuthStatus() {
    debug('$_authPrefix Verificando estado de autenticación...');
  }

  /// Log de estado autenticado
  static void authStateAuthenticated(String email) {
    info('$_authPrefix Estado: AUTENTICADO - Usuario: $email');
  }

  /// Log de estado no autenticado
  static void authStateUnauthenticated() {
    info('$_authPrefix Estado: NO AUTENTICADO');
  }

  // ============================================================================
  // MÉTODOS ESPECIALIZADOS - TOKENS
  // ============================================================================

  /// Log de guardado de token
  static void tokenSaved(String tokenType) {
    debug('$_tokenPrefix Token guardado: $tokenType');
  }

  /// Log de lectura de token
  static void tokenRead(String tokenType, bool found) {
    if (found) {
      debug('$_tokenPrefix ✅ Token encontrado: $tokenType');
    } else {
      debug('$_tokenPrefix ❌ Token NO encontrado: $tokenType');
    }
  }

  /// Log de validación de token
  static void tokenValidation(bool isValid, {int? secondsToExpire}) {
    if (isValid) {
      final expiryInfo = secondsToExpire != null
          ? ' (expira en ${secondsToExpire}s)'
          : '';
      info('$_tokenPrefix ✅ Token VÁLIDO$expiryInfo');
    } else {
      warning('$_tokenPrefix ❌ Token INVÁLIDO o EXPIRADO');
    }
  }

  /// Log de refresh de token
  static void tokenRefreshAttempt() {
    info('$_tokenPrefix Intentando refresh de token...');
  }

  /// Log de refresh exitoso
  static void tokenRefreshSuccess() {
    info('$_tokenPrefix ✅ Token renovado exitosamente');
  }

  /// Log de refresh fallido
  static void tokenRefreshFailure(String reason) {
    warning('$_tokenPrefix ❌ Refresh fallido - Razón: $reason');
  }

  // ============================================================================
  // MÉTODOS ESPECIALIZADOS - CACHE
  // ============================================================================

  /// Log de guardado en cache
  static void cacheSaved(String dataType) {
    debug('$_cachePrefix Datos guardados en cache: $dataType');
  }

  /// Log de lectura de cache
  static void cacheRead(String dataType, bool found) {
    if (found) {
      debug('$_cachePrefix ✅ Datos encontrados en cache: $dataType');
    } else {
      debug('$_cachePrefix ❌ Datos NO encontrados en cache: $dataType');
    }
  }

  /// Log de limpieza de cache
  static void cacheCleared(String? dataType) {
    final type = dataType ?? 'TODOS';
    debug('$_cachePrefix Cache limpiado: $type');
  }

  /// Log de error de cache
  static void cacheError(String operation, dynamic error) {
    error('$_cachePrefix ❌ Error en $operation', error: error);
  }

  // ============================================================================
  // MÉTODOS ESPECIALIZADOS - RED
  // ============================================================================

  /// Log de petición de red
  static void networkRequest(String method, String endpoint) {
    debug('$_networkPrefix $method $endpoint');
  }

  /// Log de respuesta exitosa
  static void networkSuccess(String endpoint, int statusCode) {
    debug('$_networkPrefix ✅ $endpoint - Status: $statusCode');
  }

  /// Log de error de red
  static void networkError(String endpoint, dynamic error) {
    AppLogger.error('$_networkPrefix ❌ Error en $endpoint', error: error);
  }

  /// Log de conectividad
  static void connectivityChanged(bool isConnected) {
    if (isConnected) {
      info('$_networkPrefix ✅ Conexión DISPONIBLE');
    } else {
      warning('$_networkPrefix ❌ SIN CONEXIÓN');
    }
  }

  // ============================================================================
  // MÉTODOS ESPECIALIZADOS - SINCRONIZACIÓN
  // ============================================================================

  /// Log de sincronización iniciada
  static void syncStarted(String dataType) {
    info('$_syncPrefix Iniciando sincronización: $dataType');
  }

  /// Log de sincronización exitosa
  static void syncSuccess(String dataType, int itemsCount) {
    info('$_syncPrefix ✅ Sincronizado: $dataType ($itemsCount items)');
  }

  /// Log de sincronización fallida
  static void syncFailure(String dataType, String reason) {
    warning(
      '$_syncPrefix ❌ Falló sincronización de $dataType - Razón: $reason',
    );
  }

  // ============================================================================
  // MÉTODOS DE DIAGNÓSTICO
  // ============================================================================

  /// Log de estado completo de almacenamiento
  static void storageDebugInfo(Map<String, dynamic> info) {
    debug('$_cachePrefix Estado del almacenamiento:\n${_formatMap(info)}');
  }

  /// Formatea un mapa para mejor visualización
  static String _formatMap(Map<String, dynamic> map, [int indent = 0]) {
    final buffer = StringBuffer();
    final prefix = '  ' * indent;

    map.forEach((key, value) {
      if (value is Map) {
        buffer.writeln('$prefix$key:');
        buffer.write(_formatMap(value as Map<String, dynamic>, indent + 1));
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    });

    return buffer.toString();
  }
}
