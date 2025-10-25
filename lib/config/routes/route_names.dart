// route_names.dart
//
// Constantes de nombres de rutas
// Optimizadas para navegación con GoRouter + BottomNavigation

class RouteNames {
  RouteNames._();

  // ============================================================================
  // RUTAS DE AUTENTICACIÓN (PÚBLICAS)
  // ============================================================================

  static const String splash = '/';
  static const String login = '/login';

  // ============================================================================
  // RUTAS PRINCIPALES - TABS DEL BOTTOM NAV
  // ============================================================================

  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String assignments = '/assignments';
  static const String profile = '/profile';

  /// Lista de rutas principales usadas en el BottomNavigationBar
  static const List<String> bottomNavRoutes = [
    home,
    notifications,
    assignments,
    profile,
  ];

  // ============================================================================
  // RUTAS DE REPORTES
  // ============================================================================

  static const String reports = '/reports';
  static const String createReport = '/reports/create';
  static String reportDetail(String id) => '/reports/$id';
  static String editReport(String id) => '/reports/$id/edit';

  // ============================================================================
  // RUTAS DE INCIDENTES
  // ============================================================================

  static const String incidents = '/incidents';
  static String incidentDetail(String id) => '/incidents/$id';
  static const String incidentSelector = '/incidents/selector';
  static const String manageIncident = '/manage-incident';
  static const String createIncident = '/manage-incident/create';
  static const String incidentList = '/incident-list';
  static const String offlineIncidents = '/manage-incident/offline';

  // ============================================================================
  // RUTAS DE CUADRILLAS
  // ============================================================================

  static const String crews = '/crews';
  static String crewDetail(String id) => '/crews/$id';
  static const String assignCrew = '/crews/assign';
  static const String manageCrews = '/manage-crews';
  static const String createCrew = '/manage-crews/create';
  static const String listCrews = '/manage-crews/list';

  // ============================================================================
  // RUTAS DE GESTIÓN DE USUARIOS (Solo Admin)
  // ============================================================================

  static const String manageUsers = '/manage-users';
  static const String createUser = '/manage-users/create';
  static const String listUsers = '/manage-users/list';

  // ============================================================================
  // RUTAS DE PERFIL Y CONFIGURACIÓN
  // ============================================================================

  static const String settings = '/settings';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String about = '/about';

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  /// Rutas públicas (no requieren autenticación)
  static bool isPublicRoute(String location) {
    return location == splash || location == login;
  }

  /// Define si una ruta requiere autenticación
  static bool requiresAuth(String location) {
    // Todo lo que no sea público es privado
    return !isPublicRoute(location);
  }

  /// Limpia parámetros dinámicos para comparar rutas
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
