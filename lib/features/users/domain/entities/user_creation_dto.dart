// user_creation_dto.dart
//
// DTO para creación de usuarios
//
// PROPÓSITO:
// - Transportar datos de creación de usuario
// - Validar campos antes de enviar al servidor
// - Generar JSON para la API
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';
import '../../../../core/utils/validators.dart';

/// DTO para crear un nuevo usuario en el sistema
///
/// Contiene todos los campos necesarios para la creación
/// de un usuario, incluyendo información personal, credenciales
/// y asignación de roles.
class UserCreationDto extends Equatable {
  /// Nombre de usuario único (generado: nombre.apellido)
  final String username;

  /// Correo electrónico único
  final String email;

  /// Contraseña (será el número de documento)
  final String password;

  /// Nombre del usuario
  final String firstName;

  /// Apellido del usuario
  final String lastName;

  /// Nombre del rol del sistema (ADMIN, TRABAJADOR, JEFE_AREA)
  final String roleName;

  /// Tipo de trabajador (intern/extern) - Opcional para Jefe de Área
  final String? workType;

  /// Nombre del rol de trabajo - Opcional para Jefe de Área
  final String? workRoleName;

  /// Número de documento de identidad (único)
  final String documentNumber;

  /// Número de teléfono (único)
  final String phone;

  const UserCreationDto({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.roleName,
    this.workType,
    this.workRoleName,
    required this.documentNumber,
    required this.phone,
  });

  /// Convierte el DTO a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    final json = {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'roleName': roleName,
      'documentNumber': documentNumber,
      'phone': phone,
    };

    // Solo agregar workType y workRoleName si no es Jefe de Área
    if (workType != null) {
      json['workType'] = workType!;
    }
    if (workRoleName != null) {
      // IMPORTANTE: Normalizar acentos antes de enviar al backend
      json['workRoleName'] = Validators.normalizeAccents(workRoleName!);
    }

    return json;
  }

  /// Factory para crear desde formulario
  factory UserCreationDto.fromForm({
    required String firstName,
    required String lastName,
    required String email,
    required String documentNumber,
    required String phone,
    required String username,
    required String roleName,
    String? workType,
    String? workRoleName,
  }) {
    // La contraseña es el número de documento
    final password = documentNumber;

    return UserCreationDto(
      username: username,
      email: email.toLowerCase(),
      password: password,
      firstName: firstName,
      lastName: lastName,
      roleName: roleName,
      workType: workType,
      workRoleName: workRoleName,
      documentNumber: documentNumber,
      phone: phone,
    );
  }

  @override
  List<Object?> get props => [
    username,
    email,
    password,
    firstName,
    lastName,
    roleName,
    workType,
    workRoleName,
    documentNumber,
    phone,
  ];

  @override
  String toString() =>
      'UserCreationDto(username: $username, email: $email, roleName: $roleName)';
}
