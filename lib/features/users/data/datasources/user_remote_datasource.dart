// user_remote_datasource.dart
//
// Data source remoto para gestión de usuarios
//
// PROPÓSITO:
// - Comunicación HTTP con la API de usuarios
// - Manejo de peticiones y respuestas
// - Conversión de errores HTTP a excepciones tipadas
//
// CAPA: DATA LAYER

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/user_creation_model.dart';
import '../models/user_error_response_model.dart';

/// Data source remoto para operaciones de usuarios
///
/// Gestiona todas las llamadas HTTP relacionadas con usuarios.
abstract class UserRemoteDataSource {
  /// Crea un nuevo usuario en el servidor
  Future<UserModel> createUser(UserCreationModel user);

  /// Obtiene lista de usuarios
  Future<List<UserModel>> getUsers();

  /// Obtiene un usuario por ID
  Future<UserModel> getUserById(int userId);
}

/// Implementación del data source remoto
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> createUser(UserCreationModel user) async {
    try {
      final jsonData = user.toJson();

      // Log para debugging - Ver exactamente qué se envía
      print('📤 JSON enviado al backend:');
      print(
        '   roleName: ${jsonData['roleName']} (tipo: ${jsonData['roleName'].runtimeType})',
      );
      print(
        '   workRoleName: ${jsonData['workRoleName']} (tipo: ${jsonData['workRoleName'].runtimeType})',
      );
      print('   JSON completo: $jsonData');

      final response = await dio.post(
        ApiConstants.usersEndpoint,
        data: jsonData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Error al crear usuario');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await dio.get(ApiConstants.usersEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(message: 'Error al obtener usuarios');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await dio.get('${ApiConstants.usersEndpoint}/$userId');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Usuario no encontrado');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Maneja errores de Dio y los convierte en excepciones tipadas
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Tiempo de espera agotado');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return ServerException(message: 'Petición cancelada');

      case DioExceptionType.connectionError:
        return NetworkException(message: 'Error de conexión a internet');

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: 'Error de red: ${error.message ?? "Desconocido"}',
        );
    }
  }

  /// Maneja respuestas HTTP con errores
  Exception _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Error 400 - Validación o campos duplicados
    if (statusCode == 400) {
      if (responseData != null && responseData is Map<String, dynamic>) {
        final errorModel = UserErrorResponseModel.fromJson(responseData);
        return ValidationException(
          message: errorModel.message,
          field: errorModel.fieldsWithErrors.isNotEmpty
              ? errorModel.fieldsWithErrors.first
              : null,
          fieldErrors: errorModel.validationErrors, // Pasar el Map completo
        );
      }
      return ValidationException(
        message: 'Error de validación en los datos enviados',
      );
    }

    // Error 401 - No autenticado
    if (statusCode == 401) {
      return AuthenticationException(
        message: 'Sesión expirada. Inicie sesión nuevamente',
      );
    }

    // Error 403 - Sin permisos
    if (statusCode == 403) {
      return AuthorizationException(
        message: 'No tiene permisos para esta acción',
      );
    }

    // Error 404 - No encontrado
    if (statusCode == 404) {
      return ServerException(message: 'Recurso no encontrado');
    }

    // Error 409 - Conflicto (duplicado)
    if (statusCode == 409) {
      return ValidationException(message: 'El recurso ya existe');
    }

    // Error 500+ - Error del servidor
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        message: 'Error del servidor. Intente nuevamente más tarde.',
      );
    }

    return ServerException(
      message:
          'Error del servidor: ${error.response?.statusMessage ?? "Desconocido"}',
    );
  }
}
