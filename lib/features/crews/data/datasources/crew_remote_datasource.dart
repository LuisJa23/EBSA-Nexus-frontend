// crew_remote_datasource.dart
//
// Fuente de datos remota para cuadrillas
//
// PROPÓSITO:
// - Comunicación con API de cuadrillas
// - Obtener usuarios disponibles
// - Crear cuadrillas
// - Gestión de miembros de cuadrilla
//
// CAPA: DATA LAYER

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/available_user_model.dart';
import '../models/crew_model.dart';
import '../models/crew_with_members_model.dart';

abstract class CrewRemoteDataSource {
  /// Obtener todas las cuadrillas
  Future<List<CrewModel>> getAllCrews();

  /// Obtener detalle de una cuadrilla con sus miembros
  Future<CrewWithMembersModel> getCrewWithMembers(int crewId);

  /// Obtener usuarios disponibles
  Future<List<AvailableUserModel>> getAvailableUsers();

  /// Crear cuadrilla
  Future<void> createCrew({
    required String name,
    required String description,
    required int createdBy,
    required List<Map<String, dynamic>> members,
  });

  /// Agregar miembro a cuadrilla
  Future<void> addMemberToCrew({
    required int crewId,
    required int userId,
    required bool isLeader,
  });

  /// Eliminar miembro de cuadrilla
  Future<void> removeMemberFromCrew({
    required int crewId,
    required int memberId,
  });

  /// Promover miembro a líder
  Future<void> promoteMemberToLeader({
    required int crewId,
    required int memberId,
  });
}

class CrewRemoteDataSourceImpl implements CrewRemoteDataSource {
  final ApiClient apiClient;

  CrewRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CrewModel>> getAllCrews() async {
    try {
      final response = await apiClient.get('/api/crews');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final List<dynamic> data = responseData['data'] as List<dynamic>;
        return data.map((json) => CrewModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Error al obtener cuadrillas',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<CrewWithMembersModel> getCrewWithMembers(int crewId) async {
    try {
      print('📡 Obteniendo cuadrilla con miembros - CrewId: $crewId');
      final response = await apiClient.get('/api/crews/$crewId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> data =
            responseData['data'] as Map<String, dynamic>;

        print(
          '✅ Datos recibidos - Miembros: ${(data['members'] as List).length}',
        );

        // Log de un miembro de ejemplo para verificar estructura
        if ((data['members'] as List).isNotEmpty) {
          final firstMember = (data['members'] as List)[0];
          print('📋 Estructura del primer miembro:');
          print('   - id: ${firstMember['id']}');
          print('   - userId: ${firstMember['userId']}');
          print('   - username: ${firstMember['username']}');
          print('   - fullName: ${firstMember['fullName']}');
          print('   - isLeader: ${firstMember['isLeader']}');
        }

        return CrewWithMembersModel.fromJson(data);
      } else {
        throw ServerException(
          message: 'Error al obtener detalle de cuadrilla',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error al obtener cuadrilla: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<List<AvailableUserModel>> getAvailableUsers() async {
    try {
      final response = await apiClient.get('/api/users/available-for-crew');

      if (response.statusCode == 200) {
        // El API retorna un array directo, no un objeto con propiedad 'data'
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => AvailableUserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Error al obtener usuarios disponibles',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> createCrew({
    required String name,
    required String description,
    required int createdBy,
    required List<Map<String, dynamic>> members,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/crews',
        data: {
          'name': name,
          'description': description,
          'createdBy': createdBy,
          'members': members,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error al crear cuadrilla',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> addMemberToCrew({
    required int crewId,
    required int userId,
    required bool isLeader,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/crews/$crewId/members',
        data: {'userId': userId, 'isLeader': isLeader},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error al agregar miembro a cuadrilla',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> removeMemberFromCrew({
    required int crewId,
    required int memberId,
  }) async {
    try {
      // Nota: memberId ahora representa userId según el nuevo endpoint del API
      print('🗑️ Eliminando miembro - CrewId: $crewId, UserId: $memberId');
      print('📡 Endpoint: DELETE /api/crews/$crewId/members/$memberId');
      final response = await apiClient.delete(
        '/api/crews/$crewId/members/$memberId',
      );

      print('📡 Respuesta DELETE - StatusCode: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMessage = response.data != null
            ? (response.data['message'] ??
                  'Error al eliminar miembro de cuadrilla')
            : 'Error al eliminar miembro de cuadrilla';
        print('❌ Error en DELETE: $errorMessage');
        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }

      print('✅ Miembro eliminado exitosamente');
    } catch (e) {
      print('❌ Excepción en removeMemberFromCrew: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> promoteMemberToLeader({
    required int crewId,
    required int memberId,
  }) async {
    try {
      // Nota: memberId ahora representa userId según el nuevo endpoint del API
      print(
        '👑 Promoviendo miembro a líder - CrewId: $crewId, UserId: $memberId',
      );
      print('📡 Endpoint: PATCH /api/crews/$crewId/members/$memberId/promote');

      final response = await apiClient.patch(
        '/api/crews/$crewId/members/$memberId/promote',
      );

      print('📡 Respuesta PATCH - StatusCode: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorMessage = response.data != null
            ? (response.data['message'] ?? 'Error al promover miembro a líder')
            : 'Error al promover miembro a líder';
        print('❌ Error en PATCH: $errorMessage');
        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }

      print('✅ Miembro promovido a líder exitosamente');
    } catch (e) {
      print('❌ Excepción en promoteMemberToLeader: $e');
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error de conexión: ${e.toString()}');
    }
  }
}
