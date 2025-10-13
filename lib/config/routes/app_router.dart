// app_router.dart
//
// Configuración de rutas de la aplicación
//
// PROPÓSITO:
// - Definir todas las rutas de navegación
// - Guards de autenticación
// - Navegación declarativa
// - Deep linking support
//
// CAPA: CONFIG
// DEPENDENCIAS: go_router, riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/home_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import 'route_names.dart';

/// Provider del router global de la aplicación
///
/// Configura GoRouter con:
/// - Rutas públicas y protegidas
/// - Redirect automático según estado de autenticación
/// - Integración reactiva con AuthState
/// - Error handling
///
/// **Uso**:
/// ```dart
/// final router = ref.watch(routerProvider);
/// // Usado en MaterialApp.router
/// ```
final routerProvider = Provider<GoRouter>((ref) {
  // Obtener estado de autenticación reactivamente
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    // Ruta inicial
    initialLocation: RouteNames.splash,

    // Debug logs en desarrollo
    debugLogDiagnostics: true,

    // =========================================================================
    // REDIRECT LOGIC - GUARDS DE AUTENTICACIÓN
    // =========================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isInitial = authState.isInitial;
      final hasError = authState.hasError;
      final currentLocation = state.matchedLocation;

      print(
        '🔄 Router redirect: location=$currentLocation, auth=${authState.status}, loading=$isLoading, error=$hasError',
      );

      // REGLA #1: Si estás en LOGIN y está LOADING, NO MOVER - quedarse en login
      if (currentLocation == RouteNames.login && isLoading) {
        print('🔄 EN LOGIN + LOADING = NO REDIRIGIR, quedarse en login');
        return null;
      }

      // REGLA #2: Si está en estado inicial (solo al abrir la app), ir a splash
      if (isInitial && currentLocation != RouteNames.splash) {
        print('🔄 Estado inicial - redirigiendo a splash');
        return RouteNames.splash;
      }

      // REGLA #3: Si está loading PERO NO está en login, no hacer nada tampoco
      if (isLoading) {
        print('🔄 Loading en otra ubicación - no redirigir');
        return null;
      }

      // Si hay error y está en splash, redirigir a login para mostrar el error
      if (hasError && currentLocation == RouteNames.splash) {
        print('🔄 Error detectado - redirigiendo a login para mostrar error');
        return RouteNames.login;
      }

      // Si hay error y ya está en login, no redirigir (mantener en login)
      if (hasError && currentLocation == RouteNames.login) {
        print('🔄 Error en login - manteniéndose en login');
        return null;
      }

      // Si está en splash y ya terminó de cargar (sin error), redirigir según autenticación
      if (currentLocation == RouteNames.splash && !isLoading && !hasError) {
        if (isAuthenticated) {
          print('🔄 Usuario autenticado - redirigiendo a home');
          return RouteNames.home;
        } else {
          print('🔄 Usuario no autenticado - redirigiendo a login');
          return RouteNames.login;
        }
      }

      // Si no está autenticado y trata de acceder a ruta protegida
      if (!isAuthenticated && RouteNames.requiresAuth(currentLocation)) {
        print('🔄 Acceso negado a ruta protegida - redirigiendo a login');
        return RouteNames.login;
      }

      // Si está autenticado y trata de acceder a login, redirigir a home
      if (isAuthenticated && currentLocation == RouteNames.login) {
        print('🔄 Usuario ya autenticado - redirigiendo a home');
        return RouteNames.home;
      }

      // No hay redirección necesaria
      return null;
    },

    // =========================================================================
    // RUTAS DE LA APLICACIÓN
    // =========================================================================
    routes: [
      // =======================================================================
      // SPLASH PAGE - Ruta inicial
      // =======================================================================
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // =======================================================================
      // LOGIN PAGE - Autenticación
      // =======================================================================
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // =======================================================================
      // HOME PAGE - Dashboard principal
      // =======================================================================
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // =======================================================================
      // REPORTES - Gestión de reportes
      // =======================================================================
      // GoRoute(
      //   path: RouteNames.reports,
      //   name: 'reports',
      //   builder: (context, state) => const ReportsPage(),
      //   routes: [
      //     // Crear reporte
      //     GoRoute(
      //       path: 'create',
      //       name: 'createReport',
      //       builder: (context, state) => const CreateReportPage(),
      //     ),
      //     // Detalle de reporte
      //     GoRoute(
      //       path: ':id',
      //       name: 'reportDetail',
      //       builder: (context, state) {
      //         final id = state.pathParameters['id']!;
      //         return ReportDetailPage(reportId: id);
      //       },
      //     ),
      //   ],
      // ),

      // =======================================================================
      // INCIDENTES - Gestión de incidentes
      // =======================================================================
      // GoRoute(
      //   path: RouteNames.incidents,
      //   name: 'incidents',
      //   builder: (context, state) => const IncidentsPage(),
      // ),

      // =======================================================================
      // CUADRILLAS - Gestión de cuadrillas
      // =======================================================================
      // GoRoute(
      //   path: RouteNames.crews,
      //   name: 'crews',
      //   builder: (context, state) => const CrewsPage(),
      // ),

      // =======================================================================
      // NOTIFICACIONES
      // =======================================================================
      // GoRoute(
      //   path: RouteNames.notifications,
      //   name: 'notifications',
      //   builder: (context, state) => const NotificationsPage(),
      // ),

      // =======================================================================
      // PERFIL Y CONFIGURACIÓN
      // =======================================================================
      // GoRoute(
      //   path: RouteNames.profile,
      //   name: 'profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
      // GoRoute(
      //   path: RouteNames.settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsPage(),
      // ),
    ],

    // =========================================================================
    // ERROR HANDLING - Página de error
    // =========================================================================
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: Página no encontrada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.home),
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

/// Extensiones de navegación para BuildContext
///
/// Proporciona métodos convenientes para navegar usando route names.
///
/// **Uso**:
/// ```dart
/// context.goToHome();
/// context.goToReportDetail('123');
/// ```
extension NavigationExtension on BuildContext {
  /// Navega a la página de inicio
  void goToHome() => go(RouteNames.home);

  /// Navega a la página de login
  void goToLogin() => go(RouteNames.login);

  /// Navega a la lista de reportes
  void goToReports() => go(RouteNames.reports);

  /// Navega al detalle de un reporte
  void goToReportDetail(String id) => go(RouteNames.reportDetail(id));

  /// Navega a crear nuevo reporte
  void goToCreateReport() => go(RouteNames.createReport);

  /// Navega a la lista de incidentes
  void goToIncidents() => go(RouteNames.incidents);

  /// Navega a la lista de cuadrillas
  void goToCrews() => go(RouteNames.crews);

  /// Navega a las notificaciones
  void goToNotifications() => go(RouteNames.notifications);

  /// Navega al perfil de usuario
  void goToProfile() => go(RouteNames.profile);

  /// Navega a configuración
  void goToSettings() => go(RouteNames.settings);
}
