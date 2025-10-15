// api_client.dart
//
// Cliente HTTP configurado para la API de Nexus EBSA
//
// PROPÓSITO:
// - Configurar Dio con interceptors personalizados
// - Manejo automático de autenticación (tokens JWT)
// - Logging de requests y responses
// - Retry automático en fallos de red
// - Timeout y configuraciones de seguridad

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../errors/exceptions.dart';

/// Cliente HTTP configurado para la API de Nexus EBSA
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  ApiClient({Dio? dio, FlutterSecureStorage? secureStorage, Logger? logger})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      _logger = logger ?? Logger() {
    _dio = dio ?? Dio();
    _setupDio();
  }

  /// Configuración inicial del cliente Dio
  void _setupDio() {
    // Configuración base
    _dio.options.baseUrl = ApiConstants.currentBaseUrl;
    _dio.options.connectTimeout = Duration(
      milliseconds: ApiConstants.connectTimeout,
    );
    _dio.options.receiveTimeout = Duration(
      milliseconds: ApiConstants.receiveTimeout,
    );
    _dio.options.sendTimeout = Duration(milliseconds: ApiConstants.sendTimeout);

    // Headers por defecto
    _dio.options.headers = {
      ApiConstants.authorizationHeader.replaceAll(
        'Content-Type',
        'content-type',
      ): ApiConstants.contentTypeJson,
      'Accept': ApiConstants.acceptJson,
      'User-Agent': 'NexusEBSA/1.0.0',
    };

    // Interceptors
    _dio.interceptors.add(_AuthInterceptor(_secureStorage, _logger));
    _dio.interceptors.add(_LoggingInterceptor(_logger));
    _dio.interceptors.add(_ErrorInterceptor(_logger));
  }

  /// Getter del cliente Dio configurado
  Dio get client => _dio;

  /// Realiza petición GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Realiza petición POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Realiza petición PUT
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Realiza petición PATCH
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Realiza petición DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Convierte DioException a nuestras excepciones personalizadas
  BaseException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Tiempo de espera agotado',
          timeoutDuration: ApiConstants.connectTimeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Error del servidor';

        if (statusCode == ApiConstants.httpUnauthorized) {
          return AuthenticationException(message: message);
        } else if (statusCode == ApiConstants.httpForbidden) {
          return AuthorizationException(message: message);
        } else {
          return ServerException(
            message: message,
            statusCode: statusCode,
            response: error.response?.data,
          );
        }

      case DioExceptionType.cancel:
        return ServerException(message: 'Petición cancelada');

      case DioExceptionType.connectionError:
      default:
        return NetworkException(message: 'Error de conexión');
    }
  }
}

/// Interceptor para manejo automático de autenticación con refresh token
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  bool _isRefreshing = false;
  final List<RequestOptions> _requestQueue = [];

  _AuthInterceptor(this._secureStorage, this._logger);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Obtener token del storage seguro (usando la clave correcta)
      final token = await _secureStorage.read(
        key: StorageConstants.accessTokenKey,
      );

      if (token != null && token.isNotEmpty) {
        // Agregar token al header de autorización
        options.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix}$token';
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error adding auth token: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si recibimos 401 (Unauthorized), intentar refresh token
    // PERO NO para endpoints de login o refresh
    if (err.response?.statusCode == ApiConstants.httpUnauthorized) {
      // No interceptar errores 401 del login o refresh token
      final requestPath = err.requestOptions.path;
      if (requestPath == ApiConstants.loginEndpoint ||
          requestPath == ApiConstants.refreshTokenEndpoint) {
        _logger.w('401 on login/refresh endpoint - not intercepting');
        handler.reject(err);
        return;
      }

      try {
        _logger.w('Received 401, attempting token refresh...');

        // Si ya estamos refrescando, encolar la request
        if (_isRefreshing) {
          _logger.d('Token refresh in progress, queueing request');
          _requestQueue.add(err.requestOptions);
          return;
        }

        // Marcar que estamos refrescando
        _isRefreshing = true;

        // Obtener refresh token
        final refreshToken = await _secureStorage.read(
          key: StorageConstants.refreshTokenKey,
        );

        if (refreshToken == null || refreshToken.isEmpty) {
          _logger.e('No refresh token available, clearing auth data');
          await _clearAuthData();
          _isRefreshing = false;
          handler.reject(err);
          return;
        }

        // Intentar refrescar el token
        final dio = Dio(); // Nueva instancia para evitar interceptor loop
        dio.options.baseUrl = ApiConstants.currentBaseUrl;

        try {
          final response = await dio.post(
            ApiConstants.refreshTokenEndpoint,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            // Extraer nuevo token de la respuesta
            final newAccessToken = response.data['token'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;

            if (newAccessToken != null) {
              // Guardar nuevo access token
              await _secureStorage.write(
                key: StorageConstants.accessTokenKey,
                value: newAccessToken,
              );

              // Guardar nuevo refresh token si viene en la respuesta
              if (newRefreshToken != null) {
                await _secureStorage.write(
                  key: StorageConstants.refreshTokenKey,
                  value: newRefreshToken,
                );
              }

              _logger.i('Token refreshed successfully');
              _isRefreshing = false;

              // Reintentar la request original con el nuevo token
              err.requestOptions.headers[ApiConstants.authorizationHeader] =
                  '${ApiConstants.bearerPrefix}$newAccessToken';

              // Crear nueva request con token actualizado
              final retryResponse = await Dio().fetch(err.requestOptions);

              // Procesar requests encoladas
              await _processQueuedRequests(newAccessToken);

              handler.resolve(retryResponse);
              return;
            }
          }

          // Refresh falló - limpiar datos y rechazar
          _logger.e('Token refresh failed: Invalid response');
          await _clearAuthData();
          _isRefreshing = false;
          _requestQueue.clear();
          handler.reject(err);
        } on DioException catch (refreshError) {
          _logger.e('Token refresh failed with error: ${refreshError.message}');
          await _clearAuthData();
          _isRefreshing = false;
          _requestQueue.clear();
          handler.reject(err);
        }
      } catch (e) {
        _logger.e('Unexpected error during token refresh: $e');
        await _clearAuthData();
        _isRefreshing = false;
        _requestQueue.clear();
        handler.reject(err);
      }
    } else {
      // Otro tipo de error - pasar al siguiente handler
      handler.next(err);
    }
  }

  /// Procesa las requests que estaban en cola esperando el refresh
  Future<void> _processQueuedRequests(String newToken) async {
    _logger.d('Processing ${_requestQueue.length} queued requests');

    for (final requestOptions in _requestQueue) {
      try {
        requestOptions.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix}$newToken';

        // Reintentar la request
        await Dio().fetch(requestOptions);
      } catch (e) {
        _logger.e('Error processing queued request: $e');
      }
    }

    _requestQueue.clear();
  }

  /// Limpia todos los datos de autenticación
  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: StorageConstants.accessTokenKey);
      await _secureStorage.delete(key: StorageConstants.refreshTokenKey);
      _logger.i('Auth data cleared');
    } catch (e) {
      _logger.e('Error clearing auth data: $e');
    }
  }
}

/// Interceptor para logging de peticiones y respuestas
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;

  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    _logger.e('Error: ${err.message}');
    if (err.response?.data != null) {
      _logger.e('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

/// Interceptor para manejo centralizado de errores
class _ErrorInterceptor extends Interceptor {
  final Logger _logger;

  _ErrorInterceptor(this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log detallado del error para debugging
    _logger.e('API Error Details:');
    _logger.e('Type: ${err.type}');
    _logger.e('Message: ${err.message}');
    _logger.e('Status Code: ${err.response?.statusCode}');
    _logger.e('Request Path: ${err.requestOptions.path}');

    handler.next(err);
  }
}

// - LoggingInterceptor para debugging
// - RetryInterceptor para reintentos
// - Métodos: get, post, put, delete, upload
// - Manejo de multipart para archivos
// - Certificate pinning para seguridad
// - Error handling centralizado
