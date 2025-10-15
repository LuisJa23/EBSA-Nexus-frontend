// get_user_profile_usecase.dart
//
// Caso de uso para obtener el perfil completo del usuario desde el servidor
//
// PROPÓSITO:
// - Obtener perfil completo desde /api/users/me
// - Actualizar cache local con datos completos
// - Proporcionar información detallada del usuario
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para obtener el perfil completo del usuario desde el servidor
///
/// **Diferencia con GetCurrentUserUseCase**:
/// - GetCurrentUserUseCase: Obtiene usuario desde cache local (rápido, offline)
/// - GetUserProfileUseCase: Obtiene perfil completo desde servidor (completo, actualizado)
///
/// **Cuándo usar este use case**:
/// - Al entrar a la página de perfil
/// - Al refrescar datos del usuario
/// - Después del login para obtener datos completos
/// - Cuando se necesitan todos los campos (documento, teléfono, etc.)
class GetUserProfileUseCase {
  final AuthRepository _repository;

  const GetUserProfileUseCase(this._repository);

  /// Obtiene el perfil completo del usuario desde el servidor
  ///
  /// **Returns**:
  /// - Left(Failure): Si hay error de red, servidor, o autenticación
  /// - Right(User): Usuario con todos los campos completos
  Future<Either<Failure, User>> call() async {
    return await _repository.getUserProfile();
  }
}
