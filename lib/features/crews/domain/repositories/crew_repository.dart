// crew_repository.dart
//
// Interfaz del repositorio de cuadrillas
//
// PROPÓSITO:
// - Definir contrato para operaciones de cuadrillas
// - Abstraer fuentes de datos del dominio
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crew.dart';
import '../entities/crew_with_members.dart';
import '../entities/available_user.dart';

/// Repositorio para gestión de cuadrillas
abstract class CrewRepository {
  /// Obtener todas las cuadrillas
  Future<Either<Failure, List<Crew>>> getAllCrews();

  /// Obtener detalle de una cuadrilla con sus miembros
  Future<Either<Failure, CrewWithMembers>> getCrewWithMembers(int crewId);

  /// Obtener usuarios disponibles para agregar a cuadrilla
  Future<Either<Failure, List<AvailableUser>>> getAvailableUsers();

  /// Crear nueva cuadrilla
  Future<Either<Failure, void>> createCrew({
    required String name,
    required String description,
    required int createdBy,
    required List<Map<String, dynamic>> members,
  });

  /// Agregar miembro a cuadrilla
  Future<Either<Failure, void>> addMemberToCrew({
    required int crewId,
    required int userId,
    required bool isLeader,
  });

  /// Eliminar miembro de cuadrilla
  Future<Either<Failure, void>> removeMemberFromCrew({
    required int crewId,
    required int memberId,
  });

  /// Promover miembro a líder
  Future<Either<Failure, void>> promoteMemberToLeader({
    required int crewId,
    required int memberId,
  });
}
