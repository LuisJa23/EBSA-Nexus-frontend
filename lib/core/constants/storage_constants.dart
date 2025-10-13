// storage_constants.dart
//
// Constantes para almacenamiento local y base de datos
//
// PROPÓSITO:
// - Nombres de tablas de la base de datos local
// - Claves para SharedPreferences y SecureStorage
// - Nombres de archivos y directorios
// - Configuraciones de cache

/// Constantes para almacenamiento y persistencia de datos
class StorageConstants {
  // ============================================================================
  // CONFIGURACIÓN DE BASE DE DATOS
  // ============================================================================

  /// Nombre del archivo de base de datos
  static const String databaseName = 'nexus_ebsa.db';

  /// Versión de la base de datos
  static const int databaseVersion = 1;

  // ============================================================================
  // NOMBRES DE TABLAS
  // ============================================================================

  /// Tabla de usuarios
  static const String usersTable = 'users';

  /// Tabla de reportes
  static const String reportsTable = 'reports';

  /// Tabla de incidentes
  static const String incidentsTable = 'incidents';

  /// Tabla de evidencias
  static const String evidenceTable = 'evidence';

  /// Tabla de cuadrillas de trabajo
  static const String workCrewsTable = 'work_crews';

  /// Tabla de notificaciones
  static const String notificationsTable = 'notifications';

  /// Tabla de cola de sincronización
  static const String syncQueueTable = 'sync_queue';

  // ============================================================================
  // CLAVES DE SHARED PREFERENCES
  // ============================================================================

  /// Clave para el último timestamp de sincronización
  static const String lastSyncKey = 'last_sync_timestamp';

  /// Clave para configuración de usuario
  static const String userSettingsKey = 'user_settings';

  /// Clave para tema de la app
  static const String themeKey = 'app_theme';

  /// Clave para idioma de la app
  static const String languageKey = 'app_language';

  /// Clave para onboarding completado
  static const String onboardingCompletedKey = 'onboarding_completed';

  /// Clave para recordar sesión
  static const String rememberSessionKey = 'remember_session';

  /// Clave para configuración de notificaciones
  static const String notificationSettingsKey = 'notification_settings';

  // ============================================================================
  // CLAVES DE SECURE STORAGE (información sensible)
  // ============================================================================

  /// Clave para token de autenticación
  static const String userTokenKey = 'user_token';
  static const String accessTokenKey = 'access_token';

  /// Clave para refresh token
  static const String refreshTokenKey = 'refresh_token';

  /// Clave para ID de usuario
  static const String userIdKey = 'user_id';

  /// Clave para email del usuario
  static const String userEmailKey = 'user_email';

  /// Clave para timestamp del token
  static const String tokenTimestampKey = 'token_timestamp';

  /// Clave para cache del usuario
  static const String cachedUserKey = 'cached_user';

  /// Clave para timestamp del cache de usuario
  static const String userCacheTimestampKey = 'user_cache_timestamp';

  /// Clave para timestamp de último login
  static const String lastLoginTimestampKey = 'last_login_timestamp';

  /// Clave para email recordado
  static const String rememberedEmailKey = 'remembered_email';

  /// Clave para preferencia "recordarme"
  static const String rememberMeKey = 'remember_me';

  /// Clave para credenciales guardadas
  static const String savedCredentialsKey = 'saved_credentials';

  /// Clave para PIN de la aplicación
  static const String appPinKey = 'app_pin';

  /// Clave para configuración biométrica
  static const String biometricConfigKey = 'biometric_config';

  // ============================================================================
  // DIRECTORIOS Y ARCHIVOS
  // ============================================================================

  /// Directorio para cache de imágenes
  static const String imagesCacheDir = 'images_cache';

  /// Directorio para archivos temporales
  static const String tempDir = 'temp';

  /// Directorio para evidencias
  static const String evidenceDir = 'evidence';

  /// Directorio para logs
  static const String logsDir = 'logs';

  /// Nombre del archivo de logs
  static const String logFileName = 'nexus_ebsa_logs.txt';

  // ============================================================================
  // CONFIGURACIÓN DE CACHE
  // ============================================================================

  /// Tamaño máximo del cache en MB
  static const int maxCacheSizeMB = 100;

  /// Tiempo de vida del cache en horas
  static const int cacheExpirationHours = 24;

  /// Número máximo de archivos en cache
  static const int maxCacheFiles = 1000;

  // ============================================================================
  // PREFIJOS Y SUFIJOS
  // ============================================================================

  /// Prefijo para claves de cache
  static const String cacheKeyPrefix = 'cache_';

  /// Prefijo para claves de configuración
  static const String configKeyPrefix = 'config_';

  /// Sufijo para archivos temporales
  static const String tempFileSuffix = '.tmp';

  /// Sufijo para archivos de backup
  static const String backupFileSuffix = '.bak';
}
