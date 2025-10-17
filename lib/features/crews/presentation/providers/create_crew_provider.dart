// create_crew_provider.dart
//
// Provider para creación de cuadrillas
//
// PROPÓSITO:
// - Gestionar lógica de negocio de creación
// - Cargar usuarios disponibles
// - Enviar datos al servidor
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../data/datasources/crew_remote_datasource.dart';
import '../state/create_crew_state.dart';

/// Provider del ApiClient desde DI
final _apiClientProvider = Provider<ApiClient>((ref) {
  return di.sl<ApiClient>();
});

/// Provider del data source
final crewRemoteDataSourceProvider = Provider<CrewRemoteDataSource>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return CrewRemoteDataSourceImpl(apiClient: apiClient);
});

/// Provider del notifier de creación de cuadrilla
final createCrewProvider =
    StateNotifierProvider<CreateCrewNotifier, CreateCrewState>((ref) {
      final dataSource = ref.watch(crewRemoteDataSourceProvider);
      return CreateCrewNotifier(dataSource: dataSource);
    });

/// Notifier para gestionar la creación de cuadrillas
class CreateCrewNotifier extends StateNotifier<CreateCrewState> {
  final CrewRemoteDataSource dataSource;

  CreateCrewNotifier({required this.dataSource})
    : super(const CreateCrewState());

  /// Cargar usuarios disponibles para agregar a la cuadrilla
  Future<void> loadAvailableUsers() async {
    state = state.copyWith(status: CreateCrewStatus.loadingUsers);

    try {
      final users = await dataSource.getAvailableUsers();
      state = state.copyWith(
        status: CreateCrewStatus.usersLoaded,
        availableUsers: users,
      );
    } catch (e) {
      state = state.copyWith(
        status: CreateCrewStatus.error,
        errorMessage: 'Error al cargar usuarios disponibles: ${e.toString()}',
      );
    }
  }

  /// Crear una nueva cuadrilla
  Future<void> createCrew({
    required String name,
    required String description,
    required int createdBy,
    required List<Map<String, dynamic>> members,
  }) async {
    state = state.copyWith(status: CreateCrewStatus.submitting);

    try {
      await dataSource.createCrew(
        name: name,
        description: description,
        createdBy: createdBy,
        members: members,
      );

      state = state.copyWith(status: CreateCrewStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: CreateCrewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resetear el estado
  void reset() {
    state = const CreateCrewState();
  }
}
