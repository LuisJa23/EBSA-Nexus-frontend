// user_creation_model.dart
//
// Modelo de datos para creación de usuarios
//
// PROPÓSITO:
// - Extender UserCreationDto para la capa de datos
// - Serialización y deserialización JSON
// - Conversión entre capas
//
// CAPA: DATA LAYER

import '../../domain/entities/user_creation_dto.dart';

/// Modelo de datos para creación de usuario
///
/// Extiende el DTO del dominio y agrega funcionalidades
/// específicas de la capa de datos como serialización JSON.
class UserCreationModel extends UserCreationDto {
  const UserCreationModel({
    required super.username,
    required super.email,
    required super.password,
    required super.firstName,
    required super.lastName,
    required super.roleName,
    super.workType,
    super.workRoleName,
    required super.documentNumber,
    required super.phone,
  });

  /// Factory desde DTO del dominio
  factory UserCreationModel.fromDto(UserCreationDto dto) {
    return UserCreationModel(
      username: dto.username,
      email: dto.email,
      password: dto.password,
      firstName: dto.firstName,
      lastName: dto.lastName,
      roleName: dto.roleName,
      workType: dto.workType,
      workRoleName: dto.workRoleName,
      documentNumber: dto.documentNumber,
      phone: dto.phone,
    );
  }

  /// Convierte a JSON para enviar a la API
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}
