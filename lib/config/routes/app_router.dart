// app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../features/authentication/presentation/pages/home_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/notifications_page.dart';
import '../../features/authentication/presentation/pages/assignments_page.dart';
import '../../features/authentication/presentation/pages/profile_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/incidents/presentation/pages/manage_incident_page.dart';
import '../../features/incidents/presentation/pages/incident_list_page.dart';
import '../../features/reports/presentation/pages/create_report_page.dart';
import '../../features/users/presentation/pages/manage_users_page.dart';
import 'route_names.dart';

/// Provider global del router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading;
      final isInitial = authState.status == AuthStatus.initial;
      final hasError = authState.status == AuthStatus.error;
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

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),

      /// ShellRoute for Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          final currentPath = state.matchedLocation;

          final tabs = [
            RouteNames.home,
            RouteNames.notifications,
            RouteNames.assignments,
            RouteNames.profile,
          ];

          final currentIndex = tabs.indexWhere((path) => currentPath == path);

          return Scaffold(
            body: child,
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: currentIndex == -1 ? 0 : currentIndex,
              onTabSelected: (index) => context.go(tabs[index]),
            ),
          );
        },
        routes: [
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.assignments,
            name: 'assignments',
            builder: (_, __) => const AssignmentsPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),

      // ========================================================================
      // RUTAS ADICIONALES (Sin Bottom Navigation)
      // ========================================================================

      /// Gestionar Novedad
      GoRoute(
        path: RouteNames.manageIncident,
        name: 'manage-incident',
        builder: (_, __) => const ManageIncidentPage(),
      ),

      /// Consultar Novedades
      GoRoute(
        path: RouteNames.incidentList,
        name: 'incident-list',
        builder: (_, __) => const IncidentListPage(),
      ),

      /// Crear Reporte (ya existe pero puede estar en otra parte)
      GoRoute(
        path: RouteNames.createReport,
        name: 'create-report',
        builder: (_, __) => const CreateReportPage(),
      ),

      /// Gestionar Usuarios (Solo Admin)
      GoRoute(
        path: RouteNames.manageUsers,
        name: 'manage-users',
        builder: (_, __) => const ManageUsersPage(),
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text("Error 404: ${state.uri}"))),
  );
});

/// Navigation extensions
extension NavigationExtension on BuildContext {
  void goToHome() => go(RouteNames.home);
  void goToLogin() => go(RouteNames.login);
  void goToNotifications() => go(RouteNames.notifications);
  void goToAssignments() => go(RouteNames.assignments);
  void goToProfile() => go(RouteNames.profile);
}
