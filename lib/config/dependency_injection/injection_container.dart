// injection_container.dart
//
// Configuración de inyección de dependencias con get_it
//
// PROPÓSITO:
// - Configurar Service Locator pattern
// - Registro de todas las dependencias
// - Inversión de control total
// - Facilitar testing con mocks

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

// Core
import '../../core/network/network_info.dart';
import '../../core/network/api_client.dart';

// Authentication Feature - Data Layer
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';

// Authentication Feature - Domain Layer
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/get_user_profile_usecase.dart';
import '../../features/authentication/domain/usecases/update_user_profile_usecase.dart';
import '../../features/authentication/domain/usecases/change_password_usecase.dart';

// Users Feature - Data Layer
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';

// Users Feature - Domain Layer
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/create_user_usecase.dart';
import '../../features/users/domain/usecases/get_workers_usecase.dart';

// Crews Feature - Data Layer
import '../../features/crews/data/datasources/crew_remote_datasource.dart';
import '../../features/crews/data/repositories/crew_repository_impl.dart';

// Crews Feature - Domain Layer
import '../../features/crews/domain/repositories/crew_repository.dart';
import '../../features/crews/domain/usecases/get_all_crews_usecase.dart';
import '../../features/crews/domain/usecases/get_crew_with_members_usecase.dart';
import '../../features/crews/domain/usecases/get_available_users_usecase.dart';
import '../../features/crews/domain/usecases/add_member_to_crew_usecase.dart';
import '../../features/crews/domain/usecases/remove_member_from_crew_usecase.dart';
import '../../features/crews/domain/usecases/promote_member_to_leader_usecase.dart';

// Incidents Feature - Data Layer
import '../../features/incidents/data/novelty_service.dart';
import '../../features/incidents/data/offline_sync_service.dart';
import '../../features/incidents/data/services/novelty_report_service.dart';

// Reports Feature - Data Layer
import '../../features/reports/data/datasources/report_local_datasource.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';

// Reports Feature - Domain Layer
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/create_report_offline_usecase.dart';
import '../../features/reports/domain/usecases/sync_reports_usecase.dart';
import '../../features/reports/domain/usecases/get_pending_reports_usecase.dart';
import '../../features/reports/domain/usecases/get_pending_reports_count_usecase.dart';
import '../../features/reports/domain/usecases/cache_dependencies_usecase.dart';

// Database
import '../../core/database/app_database.dart';

/// Service Locator global
final GetIt sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
///
/// **Orden de registro**:
/// 1. External packages (SharedPreferences, Dio, etc.)
/// 2. Core services (NetworkInfo, ApiClient)
/// 3. Data sources (Remote, Local)
/// 4. Repositories (Implementation)
/// 5. Use cases
///
/// **Lifecycle**:
/// - Singleton: Una instancia durante toda la app
/// - LazySingleton: Se crea al ser usada por primera vez
/// - Factory: Nueva instancia cada vez que se solicite
Future<void> init() async {
  // ============================================================================
  // EXTERNAL DEPENDENCIES
  // ============================================================================

  // SharedPreferences - Para caché local y configuraciones
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // FlutterSecureStorage - Para almacenamiento seguro de tokens
  // Configurado con opciones de compatibilidad para Android
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true, // Fallback si no hay keystore
        resetOnError: true, // Limpiar storage corrupto automáticamente
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  // Dio HTTP Client - Para requests HTTP
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    return dio;
  });

  // Connectivity Plus - Para verificar conectividad
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ============================================================================
  // CORE SERVICES
  // ============================================================================

  // Network Info - Verificación de conectividad
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // API Client - Cliente HTTP configurado
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl(), secureStorage: sl()),
  );

  // App Database - Base de datos local con Drift
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ============================================================================
  // AUTHENTICATION FEATURE - DATA LAYER
  // ============================================================================

  // Local Data Source - Caché local de autenticación (se registra primero)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl(), sl()),
  );

  // Remote Data Source - API calls de autenticación (recibe local datasource)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository Implementation - Coordina remote y local
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ============================================================================
  // AUTHENTICATION FEATURE - DOMAIN LAYER (USE CASES)
  // ============================================================================

  // Login Use Case
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  // Logout Use Case
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));

  // Get Current User Use Case
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );

  // Get User Profile Use Case (obtiene perfil completo desde servidor)
  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl()),
  );

  // Update User Profile Use Case
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl()),
  );

  // Change Password Use Case
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(sl()),
  );

  // ============================================================================
  // USERS FEATURE - DATA LAYER
  // ============================================================================

  // Remote Data Source - API calls de usuarios
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // Repository Implementation - Coordina remote
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // ============================================================================
  // USERS FEATURE - DOMAIN LAYER (USE CASES)
  // ============================================================================

  // Create User Use Case
  sl.registerLazySingleton<CreateUserUseCase>(() => CreateUserUseCase(sl()));

  // Get Workers Use Case
  sl.registerLazySingleton<GetWorkersUseCase>(
    () => GetWorkersUseCase(repository: sl()),
  );

  // ============================================================================
  // CREWS FEATURE - DATA LAYER
  // ============================================================================

  // Remote Data Source - API calls de cuadrillas
  sl.registerLazySingleton<CrewRemoteDataSource>(
    () => CrewRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository Implementation - Coordina remote
  sl.registerLazySingleton<CrewRepository>(
    () => CrewRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // ============================================================================
  // CREWS FEATURE - DOMAIN LAYER (USE CASES)
  // ============================================================================

  // Get All Crews Use Case
  sl.registerLazySingleton<GetAllCrewsUseCase>(() => GetAllCrewsUseCase(sl()));

  // Get Crew With Members Use Case
  sl.registerLazySingleton<GetCrewWithMembersUseCase>(
    () => GetCrewWithMembersUseCase(sl()),
  );

  // Get Available Users Use Case
  sl.registerLazySingleton<GetAvailableUsersUseCase>(
    () => GetAvailableUsersUseCase(sl()),
  );

  // Add Member To Crew Use Case
  sl.registerLazySingleton<AddMemberToCrewUseCase>(
    () => AddMemberToCrewUseCase(sl()),
  );

  // Remove Member From Crew Use Case
  sl.registerLazySingleton<RemoveMemberFromCrewUseCase>(
    () => RemoveMemberFromCrewUseCase(sl()),
  );

  // Promote Member To Leader Use Case
  sl.registerLazySingleton<PromoteMemberToLeaderUseCase>(
    () => PromoteMemberToLeaderUseCase(sl()),
  );

  // ============================================================================
  // INCIDENTS/NOVELTIES FEATURE - DATA LAYER
  // ============================================================================

  // Novelty Service - API calls de novedades
  sl.registerLazySingleton<NoveltyService>(() => NoveltyService(sl()));

  // Offline Sync Service - Sincronización de novedades offline
  sl.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(
      sl<AppDatabase>(), // Base de datos
      sl<NoveltyService>(), // Servicio de novedades
      sl<NoveltyReportService>(), // Servicio de reportes
      sl<Connectivity>(), // Conectividad
      sl<
        CrewRemoteDataSource
      >(), // Servicio de cuadrillas (para cachear miembros)
    ),
  );

  // Novelty Report Service - API calls de reportes de resolución de novedades
  sl.registerLazySingleton<NoveltyReportService>(
    () => NoveltyReportService(apiClient: sl()),
  );

  // ============================================================================
  // REPORTS FEATURE - DATA LAYER
  // ============================================================================

  // Local Data Source - Caché local de reportes
  sl.registerLazySingleton<ReportLocalDataSource>(
    () => ReportLocalDataSourceImpl(sl()),
  );

  // Remote Data Source - API calls de reportes
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(sl()),
  );

  // Repository Implementation - Coordina remote y local
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ============================================================================
  // REPORTS FEATURE - DOMAIN LAYER (USE CASES)
  // ============================================================================

  // UUID Generator - Para IDs locales de reportes
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Create Report Offline Use Case
  sl.registerLazySingleton<CreateReportOfflineUseCase>(
    () => CreateReportOfflineUseCase(sl(), sl()),
  );

  // Sync Reports Use Case
  sl.registerLazySingleton<SyncReportsUseCase>(() => SyncReportsUseCase(sl()));

  // Get Pending Reports Use Case
  sl.registerLazySingleton<GetPendingReportsUseCase>(
    () => GetPendingReportsUseCase(sl()),
  );

  // Get Pending Reports Count Use Case
  sl.registerLazySingleton<GetPendingReportsCountUseCase>(
    () => GetPendingReportsCountUseCase(sl()),
  );

  // Cache Dependencies Use Case
  sl.registerLazySingleton<CacheDependenciesUseCase>(
    () => CacheDependenciesUseCase(sl()),
  );
}

/// Reinicia el container de dependencias
///
/// Usado principalmente para testing para limpiar
/// el estado entre tests.
Future<void> reset() async {
  await sl.reset();
}

/// Registra mocks para testing
///
/// Permite reemplazar dependencias reales con mocks
/// durante los tests.
void registerTestDependencies() {
  // Este método se puede usar en tests para registrar mocks
  // sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
}
