// auth_remote_datasource.dart
//
// Fuente de datos remota para autenticación
//
// PROPÓSITO:
// - Comunicación con API de autenticación
// - Login, logout, refresh token
// - Validación de credenciales remotas
// - Manejo de tokens JWT
//
// CAPA: DATA LAYER
// DEPENDENCIAS: Puede importar Dio, ApiClient, exceptions

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/credentials_model.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

/// Contrato para la fuente de datos remota de autenticación
///
/// Define las operaciones que deben ser implementadas para
/// comunicarse con la API de autenticación del servidor.
abstract class AuthRemoteDataSource {
  /// Realiza login con credenciales del usuario
  ///
  /// **Entrada**: Credenciales validadas
  /// **Salida**: Usuario autenticado con tokens
  /// **Excepciones**:
  /// - [AuthenticationException]: Credenciales inválidas
  /// - [ServerException]: Error del servidor
  /// - [NetworkException]: Sin conexión
  Future<UserModel> login(CredentialsModel credentials);

  /// Cierra sesión del usuario
  ///
  /// **Entrada**: Token de acceso actual
  /// **Comportamiento**: Invalida token en el servidor
  Future<void> logout(String token);

  /// Renueva el token de acceso
  ///
  /// **Entrada**: Refresh token válido
  /// **Salida**: Usuario con nuevos tokens
  Future<UserModel> refreshToken(String refreshToken);

  /// Obtiene datos del usuario actual
  ///
  /// **Entrada**: Token de acceso válido
  /// **Salida**: Datos actualizados del usuario
  Future<UserModel> getCurrentUser(String token);

  /// Obtiene perfil completo del usuario actual desde /api/users/me
  ///
  /// **Entrada**: Token de acceso válido
  /// **Salida**: Usuario con datos completos del perfil
  /// **Excepciones**:
  /// - [AuthenticationException]: Token inválido o expirado
  /// - [ServerException]: Error del servidor
  Future<UserModel> getUserProfile(String token);

  /// Actualiza perfil del usuario actual en /api/users/me
  ///
  /// **Entrada**: Token y datos a actualizar (firstName, lastName, phone)
  /// **Salida**: Usuario actualizado
  /// **Excepciones**:
  /// - [AuthenticationException]: Token inválido
  /// - [ValidationException]: Datos inválidos
  /// - [ServerException]: Error del servidor
  Future<UserModel> updateUserProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  });

  /// Cambia la contraseña del usuario actual
  ///
  /// **Entrada**: Token, contraseña actual y nueva contraseña
  /// **Salida**: void (respuesta 204 No Content)
  /// **Excepciones**:
  /// - [AuthenticationException]: Token inválido o contraseña actual incorrecta
  /// - [ValidationException]: Datos inválidos
  /// - [ServerException]: Error del servidor
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

/// Implementación de la fuente de datos remota de autenticación
///
/// Se comunica con la API REST del backend para todas las operaciones
/// relacionadas con autenticación y manejo de sesiones.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Cliente HTTP para comunicación con la API
  final ApiClient _apiClient;

  /// Data source local para almacenar tokens
  final AuthLocalDataSource _localDataSource;

  /// Constructor que recibe el cliente HTTP y el datasource local
  const AuthRemoteDataSourceImpl(this._apiClient, this._localDataSource);

  @override
  Future<UserModel> login(CredentialsModel credentials) async {
    try {
      print(
        '📡 RemoteDataSource: Iniciando llamada de login para ${credentials.email}',
      );

      // Preparar datos para la API
      final requestData = credentials.toApiMap();
      print(
        '📤 RemoteDataSource: Enviando request a ${ApiConstants.loginEndpoint}',
      );

      // Realizar request de login - ESPERAR la respuesta del servidor
      print('⏳ RemoteDataSource: Esperando respuesta del servidor...');
      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        data: requestData,
      );

      print(
        '✅ RemoteDataSource: Respuesta recibida con status ${response.statusCode}',
      );

      // Validar respuesta exitosa
      if (response.statusCode != 200) {
        print(
          '❌ RemoteDataSource: Status code no exitoso: ${response.statusCode}',
        );
        throw ServerException(
          message: 'Error del servidor durante login',
          statusCode: response.statusCode,
        );
      }

      // Parsear respuesta
      final responseData = response.data as Map<String, dynamic>;

      print(
        '🔍 RemoteDataSource: Respuesta de login recibida - campos: ${responseData.keys}',
      );

      // Verificar que contiene los campos necesarios
      if (!responseData.containsKey('token') ||
          !responseData.containsKey('email') ||
          !responseData.containsKey('username') ||
          !responseData.containsKey('role')) {
        print('❌ RemoteDataSource: Respuesta de login incompleta');
        throw AuthenticationException(
          message: 'Credenciales inválidas',
          code: 'INVALID_CREDENTIALS',
        );
      }

      // Crear UserModel desde la respuesta directa del backend
      final token = responseData['token'] as String;
      final user = UserModel.fromLoginResponse(responseData, token);
      print(
        '✅ RemoteDataSource: Usuario creado: ${user.email} con id: ${user.id}',
      );

      // Almacenar token del login
      if (responseData.containsKey('token')) {
        print('🔐 RemoteDataSource: Preparando almacenamiento del token...');
        final token = responseData['token'] as String;

        // Verificar que el token sea válido antes de almacenarlo
        if (token.isNotEmpty) {
          await _localDataSource.saveAccessToken(token);

          // También almacenar el usuario en cache
          await _localDataSource.saveUser(user);
          await _localDataSource.updateLastLogin();

          print('✅ RemoteDataSource: Token y usuario almacenados exitosamente');
        } else {
          print('❌ RemoteDataSource: Token recibido está vacío');
          throw AuthenticationException(
            message: 'Token recibido está vacío',
            code: 'INVALID_TOKEN_RESPONSE',
          );
        }
      } else {
        print('⚠️ RemoteDataSource: No se encontró token en la respuesta');
        throw AuthenticationException(
          message: 'Respuesta de login inválida - sin token',
          code: 'MISSING_TOKEN_IN_RESPONSE',
        );
      }

      print('🎉 RemoteDataSource: Login completado exitosamente');
      return user;
    } on DioException catch (e) {
      print(
        '❌ RemoteDataSource: DioException capturada: ${e.type} - ${e.message}',
      );
      throw _handleDioError(e);
    } catch (e) {
      print('❌ RemoteDataSource: Excepción inesperada: $e');
      if (e is AuthenticationException || e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error inesperado durante login: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      // Realizar request de logout
      final response = await _apiClient.post(
        ApiConstants.logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // El logout puede fallar sin ser crítico
      if (response.statusCode != 200 && response.statusCode != 401) {
        // 401 significa que el token ya expiró, lo cual es aceptable
        throw ServerException(
          message: 'Error del servidor durante logout',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Para logout, algunos errores no son críticos
      if (e.response?.statusCode == 401) {
        // Token ya expirado - logout aceptable
        return;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode != 200) {
        throw AuthenticationException(
          message: 'Token de actualización inválido',
          code: 'INVALID_REFRESH_TOKEN',
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('success') ||
          responseData['success'] != true) {
        throw AuthenticationException(
          message: 'No se pudo renovar el token',
          code: 'REFRESH_TOKEN_FAILED',
        );
      }

      final userData = responseData['data']['user'] as Map<String, dynamic>;
      final tokens = responseData['data']['tokens'] as Map<String, dynamic>?;

      String? accessToken;

      // Almacenar nuevos tokens
      if (tokens != null && tokens.containsKey('access_token')) {
        accessToken = tokens['access_token'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          await _localDataSource.saveAccessToken(accessToken);
        }

        if (tokens.containsKey('refresh_token')) {
          final refreshToken = tokens['refresh_token'] as String?;
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _localDataSource.saveRefreshToken(refreshToken);
          }
        }
      }

      return UserModel.fromLoginResponse(userData, accessToken ?? 'unknown');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException(
        message: 'Error renovando token: $e',
        code: 'REFRESH_TOKEN_ERROR',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.currentUserEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw AuthenticationException(
          message: 'Token inválido',
          code: 'INVALID_TOKEN',
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('success') ||
          responseData['success'] != true) {
        throw AuthenticationException(
          message: 'Usuario no encontrado',
          code: 'USER_NOT_FOUND',
        );
      }

      final userData = responseData['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException(
        message: 'Error obteniendo usuario actual: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UserModel> getUserProfile(String token) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.userProfileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw AuthenticationException(
          message: 'Error obteniendo perfil de usuario',
          code: 'GET_PROFILE_FAILED',
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      return UserModel.fromJson(responseData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException(
        message: 'Error obteniendo perfil: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      // Preparar datos para enviar
      final requestData = {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      };

      print('📤 Actualizando perfil con datos: $requestData');

      // Realizar request PATCH
      final response = await _apiClient.patch(
        ApiConstants.userProfileEndpoint,
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📥 Respuesta de actualización: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Error actualizando perfil',
          statusCode: response.statusCode,
        );
      }

      // Parsear respuesta
      final responseData = response.data as Map<String, dynamic>;
      print('✅ Perfil actualizado exitosamente');

      return UserModel.fromJson(responseData);
    } on DioException catch (e) {
      print('❌ Error Dio actualizando perfil: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ Error inesperado actualizando perfil: $e');
      if (e is ServerException || e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error inesperado actualizando perfil: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Preparar datos para enviar
      final requestData = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };

      print('📤 Cambiando contraseña...');

      // Realizar request PATCH al endpoint de cambio de contraseña
      final response = await _apiClient.patch(
        ApiConstants.changePasswordEndpoint,
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📥 Respuesta de cambio de contraseña: ${response.statusCode}');

      // El servidor responde con 204 No Content si es exitoso
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error cambiando contraseña',
          statusCode: response.statusCode,
        );
      }

      print('✅ Contraseña cambiada exitosamente');
    } on DioException catch (e) {
      print('❌ Error Dio cambiando contraseña: ${e.message}');

      // Manejar casos específicos de cambio de contraseña
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        String errorMessage = 'Datos inválidos';

        if (responseData is Map) {
          errorMessage =
              responseData['message'] ?? responseData['error'] ?? errorMessage;
        }

        throw AuthenticationException(
          message: errorMessage,
          code: 'INVALID_PASSWORD_CHANGE_DATA',
        );
      }

      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data;
        String errorMessage = 'Contraseña actual incorrecta';

        if (responseData is Map) {
          errorMessage =
              responseData['message'] ?? responseData['error'] ?? errorMessage;
        }

        throw AuthenticationException(
          message: errorMessage,
          code: 'INVALID_CURRENT_PASSWORD',
        );
      }

      throw _handleDioError(e);
    } catch (e) {
      print('❌ Error inesperado cambiando contraseña: $e');
      if (e is ServerException || e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error inesperado cambiando contraseña: $e',
        statusCode: 500,
      );
    }
  }

  // ===========================================================================
  // MÉTODOS PRIVADOS DE UTILIDAD
  // ===========================================================================

  /// Maneja errores de Dio y los convierte en excepciones de dominio
  Exception _handleDioError(DioException e) {
    print('🔍 Manejando error Dio: ${e.type} - ${e.response?.statusCode}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message:
              'Tiempo de conexión agotado. Verifique su conexión a internet.',
          code: 'CONNECTION_TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message:
              'Sin conexión al servidor. Verifique su conexión a internet.',
          code: 'NO_CONNECTION',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseData = e.response?.data;

        print(
          '🔍 Respuesta de error: statusCode=$statusCode, data=$responseData',
        );

        if (statusCode == 401) {
          // Intentar extraer mensaje específico del servidor
          String errorMessage = 'Credenciales inválidas';
          if (responseData != null) {
            if (responseData is Map) {
              errorMessage =
                  responseData['message'] ??
                  responseData['error'] ??
                  errorMessage;
            } else if (responseData is String) {
              errorMessage = responseData;
            }
          }

          final errorCode = (responseData is Map)
              ? (responseData['error_code'] ?? 'INVALID_CREDENTIALS')
              : 'INVALID_CREDENTIALS';

          return AuthenticationException(
            message: errorMessage,
            code: errorCode,
          );
        }

        if (statusCode == 400) {
          String errorMessage = 'Datos inválidos';
          if (responseData is Map && responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
          return AuthenticationException(
            message: errorMessage,
            code: 'BAD_REQUEST',
          );
        }

        if (statusCode == 404) {
          return const AuthenticationException(
            message: 'Servicio no encontrado. Verifique la configuración.',
            code: 'SERVICE_NOT_FOUND',
          );
        }

        if (statusCode >= 500) {
          return ServerException(
            message:
                'Error interno del servidor. Intente nuevamente más tarde.',
            statusCode: statusCode,
          );
        }

        // Extraer mensaje de forma segura según el tipo de body
        String extractMessage(
          dynamic data, [
          String defaultMsg = 'Error del servidor',
        ]) {
          if (data == null) return defaultMsg;
          if (data is Map)
            return data['message']?.toString() ??
                data['error']?.toString() ??
                defaultMsg;
          if (data is String) return data;
          return defaultMsg;
        }

        return ServerException(
          message: extractMessage(responseData),
          statusCode: statusCode,
        );

      default:
        return NetworkException(
          message: 'Error de conexión: ${e.message ?? 'Desconocido'}',
          code: 'NETWORK_ERROR',
        );
    }
  }
}
