// app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/authentication/presentation/pages/home_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/notifications_page.dart';
import '../../features/incidents/presentation/pages/assignments_page.dart';
import '../../features/authentication/presentation/pages/profile_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/incidents/presentation/pages/manage_incident_page.dart';
import '../../features/incidents/presentation/pages/create_incident_page.dart';
import '../../features/incidents/presentation/pages/assign_squad_page.dart';
import '../../features/incidents/presentation/pages/novelty_detail_page.dart';
import '../../features/incidents/presentation/pages/novelty_report_page.dart';
import '../../features/incidents/presentation/pages/incident_list_page.dart';
import '../../features/incidents/presentation/pages/offline_incidents_page.dart';
import '../../features/reports/presentation/pages/create_report_page.dart';
import '../../features/users/presentation/pages/manage_users_page.dart';
import '../../features/users/presentation/pages/create_user_page.dart';
import '../../features/users/presentation/pages/list_users_page.dart';
import '../../features/crews/presentation/pages/manage_crews_page.dart';
import '../../features/crews/presentation/pages/create_crew_page.dart';
import '../../features/crews/presentation/pages/list_crews_page.dart';
import '../../features/crews/presentation/pages/crew_detail_page.dart';
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
      // ========================================================================
      // RUTAS PÚBLICAS (Sin AppBar ni autenticación)
      // ========================================================================
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const SplashPage()),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const LoginPage()),
      ),

      // ========================================================================
      // SHELL ROUTE GLOBAL - Todas las rutas autenticadas con AppBar
      // ========================================================================
      ShellRoute(
        builder: (context, state, child) {
          final currentPath = state.matchedLocation;

          // Rutas que usan bottom navigation
          final bottomNavRoutes = [
            RouteNames.home,
            RouteNames.notifications,
            RouteNames.assignments,
            RouteNames.profile,
          ];

          // Determinar si mostrar bottom nav
          final showBottomNav = bottomNavRoutes.any(
            (route) => currentPath == route,
          );
          final currentIndex = bottomNavRoutes.indexWhere(
            (path) => currentPath == path,
          );

          return Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                appBar: _buildAppBar(context, state, ref),
                body: child,
                bottomNavigationBar: showBottomNav
                    ? CustomBottomNavBar(
                        currentIndex: currentIndex == -1 ? 0 : currentIndex,
                        onTabSelected: (index) =>
                            context.go(bottomNavRoutes[index]),
                      )
                    : null,
              );
            },
          );
        },
        routes: [
          // ==================================================================
          // RUTAS PRINCIPALES CON BOTTOM NAV
          // ==================================================================
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomePage()),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const NotificationsPage(),
            ),
          ),
          GoRoute(
            path: RouteNames.assignments,
            name: 'assignments',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AssignmentsPage(),
            ),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),

          // ==================================================================
          // RUTAS ADICIONALES (Sin Bottom Nav pero con AppBar)
          // ==================================================================

          /// Gestionar Novedad
          GoRoute(
            path: RouteNames.manageIncident,
            name: 'manage-incident',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ManageIncidentPage(),
            ),
          ),

          /// Crear Incidente
          GoRoute(
            path: RouteNames.createIncident,
            name: 'create-incident',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CreateIncidentPage(),
            ),
          ),

          /// Asignar Cuadrilla
          GoRoute(
            path: RouteNames.assignSquad,
            name: 'assign-squad',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AssignSquadPage(),
            ),
            routes: [
              /// Detalle de Novedad para Asignar
              GoRoute(
                path: 'novelty/:noveltyId',
                name: 'novelty-detail',
                pageBuilder: (context, state) {
                  final noveltyId = state.pathParameters['noveltyId']!;
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: NoveltyDetailPage(noveltyId: noveltyId),
                  );
                },
              ),
            ],
          ),

          /// Consultar Novedades
          GoRoute(
            path: RouteNames.incidentList,
            name: 'incident-list',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IncidentListPage(),
            ),
          ),

          /// Detalle de Novedad (Ruta independiente)
          GoRoute(
            path: '/novelty-detail/:noveltyId',
            name: 'novelty-detail-standalone',
            pageBuilder: (context, state) {
              final noveltyId = state.pathParameters['noveltyId']!;
              return NoTransitionPage(
                key: state.pageKey,
                child: NoveltyDetailPage(noveltyId: noveltyId),
              );
            },
          ),

          /// Reporte de Novedad
          GoRoute(
            path: '/novelty-report/:noveltyId',
            name: 'novelty-report',
            pageBuilder: (context, state) {
              final noveltyId = state.pathParameters['noveltyId']!;
              return NoTransitionPage(
                key: state.pageKey,
                child: NoveltyReportPage(noveltyId: noveltyId),
              );
            },
          ),

          /// Novedades Offline
          GoRoute(
            path: RouteNames.offlineIncidents,
            name: 'offline-incidents',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OfflineIncidentsPage(),
            ),
          ),

          /// Crear Reporte
          GoRoute(
            path: RouteNames.createReport,
            name: 'create-report',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CreateReportPage(),
            ),
          ),

          /// Gestionar Usuarios (Solo Admin)
          GoRoute(
            path: RouteNames.manageUsers,
            name: 'manage-users',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ManageUsersPage(),
            ),
          ),

          /// Crear Usuario (Solo Admin)
          GoRoute(
            path: RouteNames.createUser,
            name: 'create-user',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CreateUserPage(),
            ),
          ),

          /// Lista de Usuarios (Solo Admin)
          GoRoute(
            path: RouteNames.listUsers,
            name: 'list-users',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ListUsersPage(),
            ),
          ),

          /// Gestionar Cuadrillas
          GoRoute(
            path: RouteNames.manageCrews,
            name: 'manage-crews',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ManageCrewsPage(),
            ),
          ),

          /// Crear Cuadrilla
          GoRoute(
            path: RouteNames.createCrew,
            name: 'create-crew',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CreateCrewPage(),
            ),
          ),

          /// Lista de Cuadrillas
          GoRoute(
            path: RouteNames.listCrews,
            name: 'list-crews',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ListCrewsPage(),
            ),
          ),

          /// Detalle de Cuadrilla
          GoRoute(
            path: '/crews/:id',
            name: 'crew-detail',
            pageBuilder: (context, state) {
              final crewId =
                  int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return NoTransitionPage(
                key: state.pageKey,
                child: CrewDetailPage(crewId: crewId),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text("Error 404: ${state.uri}"))),
  );
});

// ==============================================================================
// FUNCIONES AUXILIARES PARA EL APPBAR GLOBAL
// ==============================================================================

/// Construye el AppBar dinámico según la ruta
///
/// Proporciona un AppBar consistente en todas las rutas autenticadas
/// con título dinámico, color corporativo y botón de retroceso automático
PreferredSizeWidget? _buildAppBar(
  BuildContext context,
  GoRouterState state,
  WidgetRef ref,
) {
  final currentPath = state.matchedLocation;

  // Obtener título según ruta
  final title = _getTitleForRoute(currentPath);

  // Rutas principales que NO deberían mostrar botón de retroceso
  final mainRoutes = [
    RouteNames.home,
    RouteNames.notifications,
    RouteNames.assignments,
    RouteNames.profile,
  ];

  final isMainRoute = mainRoutes.contains(currentPath);

  // Definir leading (botón izquierdo)
  // Forzar la aparición del botón de retroceso en rutas secundarias.
  // Si no es posible hacer pop en el stack, navegar al Home como fallback.
  Widget? leading;
  if (!isMainRoute) {
    leading = IconButton(
      onPressed: () {
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          // Si no hay historial para hacer pop, regresar al Home
          context.go(RouteNames.home);
        }
      },
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      tooltip: 'Volver',
    );
  }

  // Definir actions según la ruta
  List<Widget>? actions;

  // Botón de logout solo en HomePage
  if (currentPath == RouteNames.home) {
    actions = [
      IconButton(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout, color: Colors.white),
        tooltip: 'Cerrar Sesión',
      ),
    ];
  }
  // Nota: El botón de editar perfil se manejará directamente en ProfilePage
  // ya que requiere acceso a su estado local (_isEditing)

  return AppBar(
    leading: leading,
    // Controlamos manualmente el leading para asegurar consistencia
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: AppColors.primary,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions,
  );
}

/// Obtiene el título del AppBar según la ruta actual
///
/// Mapea cada ruta a su título correspondiente para mostrar
/// en el AppBar de forma consistente
String _getTitleForRoute(String path) {
  // Rutas principales con bottom navigation
  if (path == RouteNames.home) return 'Nexus EBSA';
  if (path == RouteNames.notifications) return 'Notificaciones';
  if (path == RouteNames.assignments) return 'Asignaciones';
  if (path == RouteNames.profile) return 'Mi Perfil';

  // Rutas de incidentes y reportes
  if (path == RouteNames.manageIncident) return 'Gestionar Novedad';
  if (path == RouteNames.createIncident) return 'Crear Incidente';
  if (path == RouteNames.assignSquad) return 'Asignar Cuadrilla';
  if (path == RouteNames.incidentList) return 'Consultas';
  if (path == RouteNames.createReport) return 'Hacer Reporte';

  // Rutas de administración de usuarios
  if (path == RouteNames.manageUsers) return 'Gestionar Usuarios';
  if (path == RouteNames.createUser) return 'Crear Usuario';
  if (path == RouteNames.listUsers) return 'Lista de Usuarios';

  // Rutas de cuadrillas
  if (path == RouteNames.manageCrews) return 'Gestionar Cuadrillas';
  if (path == RouteNames.createCrew) return 'Crear Cuadrilla';
  if (path == RouteNames.listCrews) return 'Lista de Cuadrillas';

  // Por defecto
  return 'Nexus EBSA';
}

/// Muestra el diálogo de confirmación para cerrar sesión
///
/// Solo se muestra en la HomePage a través del botón de logout en el AppBar
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar Sesión'),
      content: const Text('¿Está seguro que desea cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(authNotifierProvider.notifier).logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cerrar Sesión'),
        ),
      ],
    ),
  );
}

// ==============================================================================
// PÁGINA SIN TRANSICIÓN (Para evitar lag visual)
// ==============================================================================

/// Página personalizada sin animaciones de transición
///
/// Elimina el efecto de superposición/lag al cambiar entre páginas
/// proporcionando una transición instantánea
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.child, super.key})
    : super(
        transitionsBuilder: _transitionsBuilder,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Sin animación - transición instantánea
    return child;
  }
}

// ==============================================================================
// EXTENSIONES DE NAVEGACIÓN
// ==============================================================================

/// Navigation extensions
extension NavigationExtension on BuildContext {
  void goToHome() => go(RouteNames.home);
  void goToLogin() => go(RouteNames.login);
  void goToNotifications() => go(RouteNames.notifications);
  void goToAssignments() => go(RouteNames.assignments);
  void goToProfile() => go(RouteNames.profile);
}
