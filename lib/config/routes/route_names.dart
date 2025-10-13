// route_names.dart
//
// Constantes de nombres de rutas
//
// PROPÓSITO:
// - Definir todas las rutas de la aplicación
// - Centralizar nombres de rutas
// - Evitar strings mágicos
// - Facilitar refactoring
//
// CAPA: CONFIG
// DEPENDENCIAS: Ninguna

/// Constantes de nombres y paths de rutas de la aplicación
///
/// Proporciona una forma centralizada y type-safe de referenciar
/// las rutas de la aplicación en lugar de usar strings directamente.
///
/// **Uso**:
/// ```dart
/// context.go(RouteNames.home);
/// context.go(RouteNames.reportDetail('123'));
/// ```
class RouteNames {
  // Constructor privado para prevenir instanciación
  RouteNames._();

  // ============================================================================
  // RUTAS DE AUTENTICACIÓN
  // ============================================================================

  /// Ruta inicial - Splash screen
  static const String splash = '/';

  /// Ruta de login
  static const String login = '/login';

  // ============================================================================
  // RUTAS PRINCIPALES
  // ============================================================================

  /// Ruta de la página principal (home/dashboard)
  static const String home = '/home';

  // ============================================================================
  // RUTAS DE REPORTES
  // ============================================================================

  /// Ruta de lista de reportes
  static const String reports = '/reports';

  /// Ruta para crear nuevo reporte
  static const String createReport = '/reports/create';

  /// Ruta de detalle de reporte
  ///
  /// **Uso**:
  /// ```dart
  /// final route = RouteNames.reportDetail('abc123');
  /// context.go(route);
  /// ```
  static String reportDetail(String id) => '/reports/$id';

  /// Ruta para editar reporte
  static String editReport(String id) => '/reports/$id/edit';

  // ============================================================================
  // RUTAS DE INCIDENTES
  // ============================================================================

  /// Ruta de lista de incidentes
  static const String incidents = '/incidents';

  /// Ruta de detalle de incidente
  static String incidentDetail(String id) => '/incidents/$id';

  /// Ruta de selector de tipo de incidente
  static const String incidentSelector = '/incidents/selector';

  // ============================================================================
  // RUTAS DE CUADRILLAS
  // ============================================================================

  /// Ruta de lista de cuadrillas
  static const String crews = '/crews';

  /// Ruta de detalle de cuadrilla
  static String crewDetail(String id) => '/crews/$id';

  /// Ruta de asignación de cuadrilla
  static const String assignCrew = '/crews/assign';

  // ============================================================================
  // RUTAS DE NOTIFICACIONES
  // ============================================================================

  /// Ruta de lista de notificaciones
  static const String notifications = '/notifications';

  /// Ruta de detalle de notificación
  static String notificationDetail(String id) => '/notifications/$id';

  // ============================================================================
  // RUTAS DE CONFIGURACIÓN Y PERFIL
  // ============================================================================

  /// Ruta de configuración
  static const String settings = '/settings';

  /// Ruta de perfil de usuario
  static const String profile = '/profile';

  /// Ruta de edición de perfil
  static const String editProfile = '/profile/edit';

  /// Ruta de cambio de contraseña
  static const String changePassword = '/profile/change-password';

  /// Ruta de "Acerca de"
  static const String about = '/about';

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  /// Verifica si una ruta es pública (no requiere autenticación)
  static bool isPublicRoute(String location) {
    return location == splash || location == login;
  }

  /// Verifica si una ruta requiere autenticación
  static bool requiresAuth(String location) {
    return !isPublicRoute(location);
  }

  /// Obtiene el nombre de la ruta sin parámetros
  ///
  /// Ejemplo: `/reports/123` → `/reports/:id`
  static String getRoutePattern(String location) {
    if (location.startsWith('/reports/') && location.split('/').length == 3) {
      return '/reports/:id';
    }
    if (location.startsWith('/incidents/') && location.split('/').length == 3) {
      return '/incidents/:id';
    }
    if (location.startsWith('/crews/') && location.split('/').length == 3) {
      return '/crews/:id';
    }
    if (location.startsWith('/notifications/') &&
        location.split('/').length == 3) {
      return '/notifications/:id';
    }

    return location;
  }
}
