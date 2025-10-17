// get_available_users_usecase.dart
//
// Caso de uso: Obtener usuarios disponibles
//
// PROPÓSITO:
// - Recuperar lista de usuarios disponibles para agregar a cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/available_user.dart';
import '../repositories/crew_repository.dart';

/// Caso de uso para obtener usuarios disponibles
class GetAvailableUsersUseCase {
  final CrewRepository repository;

  GetAvailableUsersUseCase(this.repository);

  Future<Either<Failure, List<AvailableUser>>> call() async {
    return await repository.getAvailableUsers();
  }
}
