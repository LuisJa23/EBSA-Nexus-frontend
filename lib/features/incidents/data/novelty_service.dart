// novelty_service.dart
//
// Servicio para gestión de novedades
//
// PROPÓSITO:
// - Crear novedades con imágenes (form-data)
// - Obtener lista de novedades
// - Gestión de evidencias adjuntas
//
// CAPA: DATA LAYER - SERVICES

import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/errors/exceptions.dart';
import 'models/novelty_model.dart';

/// Servicio para gestión de novedades
class NoveltyService {
  final ApiClient _apiClient;

  NoveltyService(this._apiClient);

  /// Crea una nueva novedad con imágenes
  ///
  /// Parámetros:
  /// - [areaId]: ID del área
  /// - [reason]: Motivo de la novedad
  /// - [accountNumber]: Número de cuenta
  /// - [meterNumber]: Número de medidor
  /// - [activeReading]: Lectura activa
  /// - [reactiveReading]: Lectura reactiva
  /// - [locationId]: ID del municipio/ubicación
  /// - [municipality]: Nombre del municipio (requerido por backend)
  /// - [address]: Dirección (coordenadas GPS: "lat,lon")
  /// - [description]: Descripción de la novedad
  /// - [observations]: Observaciones adicionales
  /// - [images]: Lista de archivos de imagen
  Future<Response> createNovelty({
    required String areaId,
    required String reason,
    required String accountNumber,
    required String meterNumber,
    required String activeReading,
    required String reactiveReading,
    required String locationId,
    required String municipality,
    required String address,
    required String description,
    String? observations,
    required List<File> images,
  }) async {
    try {
      // Validar que los campos requeridos no estén vacíos
      if (areaId.isEmpty) {
        throw ArgumentError('areaId no puede estar vacío');
      }
      if (reason.isEmpty) {
        throw ArgumentError('reason no puede estar vacío');
      }
      if (accountNumber.isEmpty) {
        throw ArgumentError('accountNumber no puede estar vacío');
      }
      if (meterNumber.isEmpty) {
        throw ArgumentError('meterNumber no puede estar vacío');
      }
      if (activeReading.isEmpty) {
        throw ArgumentError('activeReading no puede estar vacío');
      }
      if (reactiveReading.isEmpty) {
        throw ArgumentError('reactiveReading no puede estar vacío');
      }
      if (locationId.isEmpty) {
        throw ArgumentError('locationId no puede estar vacío');
      }
      if (municipality.isEmpty) {
        throw ArgumentError('municipality no puede estar vacío');
      }
      if (address.isEmpty) {
        throw ArgumentError('address no puede estar vacío');
      }
      if (description.isEmpty) {
        throw ArgumentError('description no puede estar vacío');
      }
      if (images.isEmpty) {
        throw ArgumentError('Se requiere al menos una imagen');
      }

      AppLogger.info('🚀 Iniciando creación de novedad');
      AppLogger.debug(
        'URL: ${ApiConstants.currentBaseUrl}${ApiConstants.createNoveltyEndpoint}',
      );
      AppLogger.debug('Parámetros:');
      AppLogger.debug('  - areaId: $areaId');
      AppLogger.debug('  - reason: $reason');
      AppLogger.debug('  - accountNumber: $accountNumber');
      AppLogger.debug('  - locationId: $locationId');
      AppLogger.debug('  - municipality: $municipality');
      AppLogger.debug('  - imágenes: ${images.length}');

      // Crear FormData
      final formData = FormData();

      // Agregar campos de texto
      // IMPORTANTE: areaId y locationId deben ser números válidos
      formData.fields.addAll([
        MapEntry('areaId', areaId), // Backend espera Long
        MapEntry('reason', reason),
        MapEntry('accountNumber', accountNumber),
        MapEntry('meterNumber', meterNumber),
        MapEntry('activeReading', activeReading),
        MapEntry('reactiveReading', reactiveReading),
        MapEntry('locationId', locationId), // Backend espera Long
        MapEntry(
          'municipality',
          municipality,
        ), // Backend espera String (nombre)
        MapEntry('address', address),
        MapEntry('description', description),
      ]);

      // Agregar observaciones si existe
      if (observations != null && observations.isNotEmpty) {
        formData.fields.add(MapEntry('observations', observations));
      }

      // Agregar imágenes
      AppLogger.debug('Agregando ${images.length} imágenes al FormData...');
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();

        AppLogger.debug('  Imagen ${i + 1}: $fileName (${fileSize} bytes)');

        formData.files.add(
          MapEntry(
            'images', // El backend espera "images" como nombre del campo
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      AppLogger.info('📤 Enviando petición al servidor...');
      final startTime = DateTime.now();

      // Log detallado de los datos que se enviarán
      AppLogger.debug('📋 Datos del FormData:');
      AppLogger.debug('  Fields:');
      for (var field in formData.fields) {
        AppLogger.debug(
          '    ${field.key}: ${field.value} (${field.value.runtimeType})',
        );
      }
      AppLogger.debug('  Files: ${formData.files.length} imágenes');
      for (var i = 0; i < formData.files.length; i++) {
        AppLogger.debug(
          '    Imagen ${i + 1}: ${formData.files[i].value.filename}',
        );
      }

      // Realizar petición POST con form-data
      final response = await _apiClient.post(
        ApiConstants.createNoveltyEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );

      final duration = DateTime.now().difference(startTime);

      // Verificar que la respuesta sea exitosa
      if (response.statusCode != 200 && response.statusCode != 201) {
        AppLogger.error('❌ Respuesta no exitosa del servidor');
        AppLogger.error('  - Status Code: ${response.statusCode}');
        AppLogger.error('  - Response: ${response.data}');

        // Extraer mensaje de error del backend si existe
        String errorMessage = 'Error al crear novedad';
        if (response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              'Error del servidor (${response.statusCode})';
        } else if (response.data is String) {
          errorMessage = response.data;
        }

        // Para error 400, agregar contexto adicional
        if (response.statusCode == 400) {
          errorMessage = 'Datos de entrada inválidos: $errorMessage';
          AppLogger.error('⚠️ ERROR 400 - Validar que:');
          AppLogger.error('  - areaId sea un número válido');
          AppLogger.error('  - locationId sea un número válido (5-11)');
          AppLogger.error('  - Todos los campos requeridos estén completos');
          AppLogger.error('  - Las imágenes se estén enviando correctamente');
        }

        throw Exception(errorMessage);
      }

      AppLogger.info(
        '✅ Novedad creada exitosamente en ${duration.inMilliseconds}ms',
      );
      AppLogger.debug('Status Code: ${response.statusCode}');
      AppLogger.debug('Response: ${response.data}');

      return response;
    } on SocketException catch (e) {
      AppLogger.error('❌ SocketException: Sin conexión a Internet', error: e);
      throw NetworkException(
        message: 'Sin conexión a Internet. La novedad se guardará localmente.',
      );
    } on TimeoutException catch (e) {
      AppLogger.error('❌ TimeoutException: Tiempo de espera agotado', error: e);
      throw NetworkException(
        message: 'Tiempo de espera agotado. Verifica tu conexión a Internet.',
      );
    } on DioException catch (e) {
      AppLogger.error('❌ DioException al crear novedad', error: e);

      // Log detallado del error
      AppLogger.error('Tipo de error: ${e.type}');
      AppLogger.error('Status Code: ${e.response?.statusCode}');
      AppLogger.error('Response data: ${e.response?.data}');
      AppLogger.error('Request: ${e.requestOptions.path}');
      AppLogger.error(
        'Request data type: ${e.requestOptions.data.runtimeType}',
      );

      // Detectar errores de conexión
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        AppLogger.error('⚠️ Error de timeout detectado');
        throw NetworkException(
          message: 'Tiempo de espera agotado. Verifica tu conexión.',
        );
      }

      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        AppLogger.error('⚠️ Error de conexión detectado');
        throw NetworkException(
          message:
              'Sin conexión a Internet. La novedad se guardará localmente.',
        );
      }

      // Si es error 500 o 403, dar más contexto
      if (e.response?.statusCode == 500) {
        AppLogger.error('⚠️ Error 500: Problema en el servidor');
        AppLogger.error('Posibles causas:');
        AppLogger.error('  - Permisos insuficientes del usuario');
        AppLogger.error('  - Validación fallida en el backend');
        AppLogger.error('  - Error en base de datos');
        AppLogger.error('Response completa: ${e.response?.data}');
      } else if (e.response?.statusCode == 403) {
        AppLogger.error('⚠️ Error 403: Acceso denegado');
        AppLogger.error('El usuario no tiene permisos para crear novedades');
      }

      rethrow;
    } catch (e) {
      AppLogger.error('❌ Error inesperado al crear novedad', error: e);
      rethrow;
    }
  }

  /// Obtiene la lista de novedades con filtros y paginación
  ///
  /// Parámetros:
  /// - [page]: Número de página (inicia en 0)
  /// - [size]: Cantidad de elementos por página
  /// - [sort]: Campo para ordenar
  /// - [direction]: Dirección de ordenamiento (ASC o DESC)
  /// - [status]: Filtrar por estado
  /// - [priority]: Filtrar por prioridad
  /// - [areaId]: Filtrar por ID de área
  /// - [crewId]: Filtrar por ID de cuadrilla
  /// - [creatorId]: Filtrar por ID del creador
  /// - [startDate]: Fecha inicio (formato ISO)
  /// - [endDate]: Fecha fin (formato ISO)
  Future<Response> getNovelties({
    int? page,
    int? size,
    String? sort,
    String? direction,
    String? status,
    String? priority,
    int? areaId,
    int? crewId,
    int? creatorId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) queryParameters['page'] = page;
      if (size != null) queryParameters['size'] = size;
      if (sort != null) queryParameters['sort'] = sort;
      if (direction != null) queryParameters['direction'] = direction;
      if (status != null) queryParameters['status'] = status;
      if (priority != null) queryParameters['priority'] = priority;
      if (areaId != null) queryParameters['areaId'] = areaId;
      if (crewId != null) queryParameters['crewId'] = crewId;
      if (creatorId != null) queryParameters['creatorId'] = creatorId;
      if (startDate != null) queryParameters['startDate'] = startDate;
      if (endDate != null) queryParameters['endDate'] = endDate;

      final response = await _apiClient.get(
        ApiConstants.noveltiesEndpoint,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene una novedad por ID
  Future<Response> getNoveltyById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.noveltyByIdEndpoint(id),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene una novedad por ID y la parsea a modelo
  Future<NoveltyModel> getNoveltyByIdParsed(int id) async {
    try {
      final response = await getNoveltyById(id.toString());

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return NoveltyModel.fromJson(data);
      } else {
        throw Exception('Error al obtener novedad');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca novedades con filtros
  Future<Response> searchNovelties({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'size': size};

      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiClient.get(
        '${ApiConstants.noveltiesEndpoint}',
        queryParameters: queryParameters,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Asigna una cuadrilla a una novedad
  Future<Response> assignCrewToNovelty({
    required String noveltyId,
    required int assignedCrewId,
    required String priority,
    String? instructions,
  }) async {
    try {
      final data = {
        'assignedCrewId': assignedCrewId,
        'priority': priority,
        if (instructions != null && instructions.isNotEmpty)
          'instructions': instructions,
      };

      AppLogger.debug(
        'NoveltyService: Asignando cuadrilla $assignedCrewId a novedad $noveltyId',
      );
      AppLogger.debug('NoveltyService: Datos a enviar: $data');

      final response = await _apiClient.post(
        ApiConstants.assignCrewToNoveltyEndpoint(noveltyId),
        data: data,
      );

      AppLogger.debug(
        'NoveltyService: Cuadrilla asignada - Status: ${response.statusCode}',
      );

      return response;
    } catch (e) {
      AppLogger.error('NoveltyService: Error al asignar cuadrilla', error: e);
      rethrow;
    }
  }

  /// Obtiene las novedades asignadas a un usuario
  Future<Response> getUserNovelties(String userId) async {
    try {
      final endpoint = ApiConstants.userNoveltiesEndpoint(userId);
      AppLogger.debug('NoveltyService: Llamando endpoint: $endpoint');

      final response = await _apiClient.get(endpoint);

      AppLogger.debug(
        'NoveltyService: Respuesta obtenida - Status: ${response.statusCode}',
      );
      if (response.data != null) {
        AppLogger.debug('NoveltyService: Datos de respuesta: ${response.data}');
      }

      return response;
    } catch (e) {
      AppLogger.error(
        'NoveltyService: Error al obtener novedades del usuario',
        error: e,
      );

      // Intentar endpoint alternativo usando búsqueda por creador
      try {
        AppLogger.debug(
          'NoveltyService: Intentando endpoint alternativo con búsqueda...',
        );
        final alternativeResponse = await getNovelties(
          creatorId: int.parse(userId),
          size: 100, // Traer más resultados
        );

        AppLogger.info(
          'NoveltyService: ✅ Endpoint alternativo exitoso - Status: ${alternativeResponse.statusCode}',
        );

        return alternativeResponse;
      } catch (altError) {
        AppLogger.error(
          'NoveltyService: Error en endpoint alternativo también',
          error: altError,
        );
        rethrow;
      }
    }
  }

  /// Actualiza el estado de una novedad
  Future<Response> updateNoveltyStatus({
    required int noveltyId,
    required String newStatus,
  }) async {
    try {
      AppLogger.info('🔄 Actualizando estado de novedad #$noveltyId');
      AppLogger.debug('  - Estado nuevo: $newStatus');
      AppLogger.debug(
        '  - URL: ${ApiConstants.currentBaseUrl}/api/v1/novelties/$noveltyId/status',
      );

      final startTime = DateTime.now();

      final response = await _apiClient.patch(
        '/api/v1/novelties/$noveltyId/status',
        data: {'status': newStatus},
      );

      final duration = DateTime.now().difference(startTime);
      AppLogger.info(
        '✅ Estado actualizado exitosamente en ${duration.inMilliseconds}ms',
      );
      AppLogger.debug('  - Status Code: ${response.statusCode}');
      AppLogger.debug('  - Response: ${response.data}');

      return response;
    } catch (e) {
      AppLogger.error(
        '❌ Error al actualizar estado de novedad #$noveltyId',
        error: e,
      );

      // Log detallado del error
      if (e is DioException) {
        AppLogger.error('  - Tipo de error: ${e.type}');
        AppLogger.error('  - Status Code: ${e.response?.statusCode}');
        AppLogger.error('  - Response data: ${e.response?.data}');
        AppLogger.error('  - Request: ${e.requestOptions.path}');
      }

      rethrow;
    }
  }
}
