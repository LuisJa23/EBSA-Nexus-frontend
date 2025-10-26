// Ejemplo de integración del badge de notificaciones en app_router.dart
//
// INSTRUCCIONES:
// 1. Importar los widgets necesarios
// 2. Agregar el badge en el método _buildAppBar
// 3. Configurar el polling en las rutas principales

// ============================================================================
// IMPORTS NECESARIOS (agregar al inicio de app_router.dart)
// ============================================================================

import '../../features/notifications/presentation/widgets/notification_badge.dart';

// ============================================================================
// MODIFICAR EL MÉTODO _buildAppBar
// ============================================================================

PreferredSizeWidget? _buildAppBar(
  BuildContext context,
  GoRouterState state,
  WidgetRef ref,
) {
  final currentPath = state.matchedLocation;
  final title = _getTitleForRoute(currentPath);
  final authState = ref.watch(authNotifierProvider);

  // Obtener userId si el usuario está autenticado
  final userId = authState.user != null ? int.tryParse(authState.user!.id) : null;

  // Rutas principales que NO deberían mostrar botón de retroceso
  final mainRoutes = [
    RouteNames.home,
    RouteNames.notifications,
    RouteNames.assignments,
    RouteNames.profile,
  ];

  final isMainRoute = mainRoutes.contains(currentPath);
  final canPop = GoRouter.of(context).canPop();

  // Definir leading (botón izquierdo)
  Widget? leading;
  if (!isMainRoute && canPop) {
    leading = IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      tooltip: 'Volver',
    );
  }

  // Definir actions según la ruta
  List<Widget>? actions = [];

  // ============================================================================
  // NUEVO: Botón de notificaciones con badge (visible en todas las rutas)
  // ============================================================================
  if (userId != null && currentPath != RouteNames.notifications) {
    actions.add(
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: NotificationBadge(
          userId: userId,
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => context.go(RouteNames.notifications),
            tooltip: 'Notificaciones',
          ),
        ),
      ),
    );
  }

  // Botón de logout solo en HomePage
  if (currentPath == RouteNames.home) {
    actions.add(
      IconButton(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout, color: Colors.white),
        tooltip: 'Cerrar Sesión',
      ),
    );
  }

  return AppBar(
    leading: leading,
    automaticallyImplyLeading: !isMainRoute,
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
    actions: actions.isEmpty ? null : actions,
  );
}

// ============================================================================
// INICIAR POLLING EN LA HOMEPAGE
// ============================================================================

// En HomePage (home_page.dart), agregar:

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifications/presentation/providers/notification_polling_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    
    // Iniciar polling de notificaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState.user != null) {
        final userId = int.tryParse(authState.user!.id);
        if (userId != null) {
          // Iniciar actualización automática cada 30 segundos
          ref.read(notificationPollingServiceProvider(userId)).start();
          print('🚀 Polling de notificaciones iniciado para usuario $userId');
        }
      }
    });
  }

  @override
  void dispose() {
    // Detener polling al salir
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      final userId = int.tryParse(authState.user!.id);
      if (userId != null) {
        ref.read(notificationPollingServiceProvider(userId)).stop();
        print('⏸️ Polling de notificaciones detenido');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... resto del código
  }
}

// ============================================================================
// ALTERNATIVA: INICIAR POLLING EN EL APP.DART (RECOMENDADO)
// ============================================================================

// En app.dart, si usas un ConsumerWidget:

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Cargar notificaciones cuando se autentique
    ref.listenManual(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        final userId = int.tryParse(next.user!.id);
        if (userId != null) {
          // Cargar notificaciones inicialmente
          ref.read(notificationProvider(userId).notifier).loadNotifications();
          
          // Iniciar polling
          ref.read(notificationPollingServiceProvider(userId)).start();
          print('🔔 Sistema de notificaciones iniciado para usuario $userId');
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        // Detener polling al cerrar sesión
        if (previous?.user != null) {
          final userId = int.tryParse(previous!.user!.id);
          if (userId != null) {
            ref.read(notificationPollingServiceProvider(userId)).stop();
            print('🔕 Sistema de notificaciones detenido');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      final userId = int.tryParse(authState.user!.id);
      if (userId != null) {
        final pollingService = ref.read(notificationPollingServiceProvider(userId));
        
        switch (state) {
          case AppLifecycleState.resumed:
            // App vuelve al foreground - reanudar polling
            pollingService.resume();
            pollingService.forceRefresh(); // Actualizar inmediatamente
            print('▶️ App en foreground - polling resumido');
            break;
          case AppLifecycleState.paused:
            // App va al background - pausar polling para ahorrar batería
            pollingService.pause();
            print('⏸️ App en background - polling pausado');
            break;
          default:
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'EBSA Nexus',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============================================================================
// USO DEL BADGE EN BOTTOM NAVIGATION BAR
// ============================================================================

// Si usas BottomNavigationBar en lugar de AppBar:

BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() => _currentIndex = index);
    // Navegar según el índice
  },
  items: [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: userId != null
          ? NotificationDotBadge(
              userId: userId,
              child: const Icon(Icons.notifications),
            )
          : const Icon(Icons.notifications),
      label: 'Notificaciones',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Asignaciones',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ],
)

// ============================================================================
// RESUMEN DE INTEGRACIÓN
// ============================================================================

/**
 * PASO 1: Agregar badge al AppBar
 * - Importar NotificationBadge
 * - Modificar _buildAppBar para incluir el botón con badge
 * 
 * PASO 2: Iniciar polling automático
 * - Opción A: En HomePage (solo cuando esté en home)
 * - Opción B: En App.dart (recomendado - funciona en toda la app)
 * 
 * PASO 3: Manejar ciclo de vida
 * - Pausar polling cuando la app va al background
 * - Reanudar y actualizar cuando vuelve al foreground
 * 
 * PASO 4: Detener polling al cerrar sesión
 * - Escuchar cambios en authNotifierProvider
 * - Detener el servicio cuando el usuario hace logout
 */
