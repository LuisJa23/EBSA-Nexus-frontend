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
      final current = state.matchedLocation;

      if (current == RouteNames.login && isLoading) return null;
      if (isInitial && current != RouteNames.splash) return RouteNames.splash;
      if (isLoading) return null;
      if (hasError && current == RouteNames.splash) return RouteNames.login;
      if (hasError && current == RouteNames.login) return null;
      if (current == RouteNames.splash && !isLoading && !hasError) {
        return isAuthenticated ? RouteNames.home : RouteNames.login;
      }
      if (!isAuthenticated && RouteNames.requiresAuth(current))
        return RouteNames.login;
      if (isAuthenticated && current == RouteNames.login)
        return RouteNames.home;

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
