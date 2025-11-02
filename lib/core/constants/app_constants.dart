// app_constants.dart
//
// Constantes generales de la aplicación EBSA Nexus
//
// PROPÓSITO:
// - Definir valores constantes que se usan en toda la aplicación
// - Configuraciones de timeouts, límites, URLs base
// - Versiones de API, códigos de error comunes
// - Configuraciones de cache y almacenamiento

/// Constantes generales de la aplicación EBSA Nexus
class AppConstants {
  // ============================================================================
  // INFORMACIÓN DE LA APP
  // ============================================================================

  /// Nombre de la aplicación
  static const String appName = 'EBSA Nexus';

  /// Versión de la aplicación
  static const String appVersion = '1.0.0';

  /// Empresa desarrolladora
  static const String companyName = 'EBSA S.A.E.S.P.';

  // ============================================================================
  // CONFIGURACIONES DE UI
  // ============================================================================

  /// Radio de bordes por defecto
  static const double defaultBorderRadius = 8.0;

  /// Padding por defecto
  static const double defaultPadding = 16.0;

  /// Margen por defecto
  static const double defaultMargin = 16.0;

  /// Altura de botones por defecto
  static const double defaultButtonHeight = 48.0;

  /// Tamaño de íconos por defecto
  static const double defaultIconSize = 24.0;

  // ============================================================================
  // ANIMACIONES Y DURACIONES
  // ============================================================================

  /// Duración de animaciones cortas (en milisegundos)
  static const int shortAnimationDuration = 200;

  /// Duración de animaciones medianas (en milisegundos)
  static const int mediumAnimationDuration = 400;

  /// Duración de animaciones largas (en milisegundos)
  static const int longAnimationDuration = 800;

  /// Duración del splash screen (en milisegundos)
  static const int splashDuration = 2000;

  // ============================================================================
  // VALIDACIONES DE FORMULARIOS
  // ============================================================================

  /// Longitud mínima de contraseña
  static const int minPasswordLength = 6;

  /// Longitud máxima de contraseña
  static const int maxPasswordLength = 50;

  /// Longitud mínima de nombre
  static const int minNameLength = 2;

  /// Longitud máxima de nombre
  static const int maxNameLength = 50;

  /// Longitud máxima de descripción
  static const int maxDescriptionLength = 500;

  // ============================================================================
  // CONFIGURACIÓN DE ARCHIVOS Y MEDIA
  // ============================================================================

  /// Tamaño máximo de imagen en MB
  static const int maxImageSizeMB = 10;

  /// Tamaño máximo de video en MB
  static const int maxVideoSizeMB = 50;

  /// Tamaño máximo de audio en MB
  static const int maxAudioSizeMB = 20;

  /// Formatos de imagen permitidos
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  /// Formatos de video permitidos
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  /// Formatos de audio permitidos
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'aac'];

  // ============================================================================
  // CONFIGURACIÓN DE GEOLOCALIZACIÓN
  // ============================================================================

  /// Precisión mínima de GPS en metros
  static const double minGpsAccuracy = 10.0;

  /// Timeout para obtener ubicación (en milisegundos)
  static const int locationTimeout = 30000;

  // ============================================================================
  // CONFIGURACIÓN DE SINCRONIZACIÓN
  // ============================================================================

  /// Intervalo de sincronización automática (en milisegundos)
  static const int autoSyncInterval = 300000; // 5 minutos

  /// Intentos máximos de reintento
  static const int maxRetryAttempts = 3;

  /// Delay entre reintentos (en milisegundos)
  static const int retryDelay = 1000;

  // ============================================================================
  // MENSAJES DE ERROR GENÉRICOS
  // ============================================================================

  /// Error de conexión genérico
  static const String connectionError =
      'Error de conexión. Verifique su internet.';

  /// Error desconocido
  static const String unknownError = 'Ha ocurrido un error inesperado.';

  /// Error de autenticación
  static const String authError =
      'Error de autenticación. Inicie sesión nuevamente.';

  /// Error de permisos
  static const String permissionError =
      'Permisos insuficientes para realizar esta acción.';

  // ============================================================================
  // PATRONES DE VALIDACIÓN
  // ============================================================================

  /// Patrón para validar email
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Patrón para validar teléfono colombiano
  static const String phonePattern = r'^(\+57|0057|57)?[1-9][0-9]{9}$';

  // ============================================================================
  // CONFIGURACIÓN DE ANALYTICS
  // ============================================================================

  /// Períodos disponibles para filtros de analytics
  static const String analyticsPeriodDaily = 'daily';
  static const String analyticsPeriodWeekly = 'weekly';
  static const String analyticsPeriodMonthly = 'monthly';

  /// Lista de períodos de analytics
  static const List<String> analyticsPeriods = [
    analyticsPeriodDaily,
    analyticsPeriodWeekly,
    analyticsPeriodMonthly,
  ];

  /// Límite de registros para top performers
  static const int analyticsTopPerformersLimit = 5;

  /// Límite de registros para tendencias
  static const int analyticsTrendsLimit = 30;

  /// Colores para gráficos de estado
  static const Map<String, int> analyticsStatusColors = {
    'pending': 0xFFFFC107, // Amarillo
    'in_progress': 0xFF2196F3, // Azul
    'resolved': 0xFF4CAF50, // Verde
    'rejected': 0xFFE53935, // Rojo
  };

  /// Rango de fechas por defecto (días)
  static const int analyticsDefaultDateRangeDays = 30;

  // ============================================================================
  // NAVEGACIÓN DE ANALYTICS
  // ============================================================================

  /// Ruta del dashboard de analytics
  static const String analyticsRoute = '/analytics/dashboard';

  /// Nombre de la página de analytics para AppBar
  static const String analyticsPageTitle = 'Analytics Dashboard';
}
