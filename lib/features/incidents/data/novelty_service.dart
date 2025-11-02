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
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
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
  /// - [municipality]: Municipio
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
    required String municipality,
    required String address,
    required String description,
    String? observations,
    required List<File> images,
  }) async {
    try {
      AppLogger.info('🚀 Iniciando creación de novedad');
      AppLogger.debug(
        'URL: ${ApiConstants.currentBaseUrl}${ApiConstants.createNoveltyEndpoint}',
      );
      AppLogger.debug('Parámetros:');
      AppLogger.debug('  - areaId: $areaId');
      AppLogger.debug('  - reason: $reason');
      AppLogger.debug('  - accountNumber: $accountNumber');
      AppLogger.debug('  - municipality: $municipality');
      AppLogger.debug('  - imágenes: ${images.length}');

      // Crear FormData
      final formData = FormData();

      // Agregar campos de texto
      formData.fields.addAll([
        MapEntry('areaId', areaId),
        MapEntry('reason', reason),
        MapEntry('accountNumber', accountNumber),
        MapEntry('meterNumber', meterNumber),
        MapEntry('activeReading', activeReading),
        MapEntry('reactiveReading', reactiveReading),
        MapEntry('municipality', municipality),
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
        }

        throw Exception(errorMessage);
      }

      AppLogger.info(
        '✅ Novedad creada exitosamente en ${duration.inMilliseconds}ms',
      );
      AppLogger.debug('Status Code: ${response.statusCode}');
      AppLogger.debug('Response: ${response.data}');

      return response;
    } catch (e) {
      AppLogger.error('❌ Error al crear novedad', error: e);

      // Log detallado del error
      if (e is DioException) {
        AppLogger.error('Tipo de error: ${e.type}');
        AppLogger.error('Status Code: ${e.response?.statusCode}');
        AppLogger.error('Response data: ${e.response?.data}');
        AppLogger.error('Request: ${e.requestOptions.path}');
        AppLogger.error(
          'Request data type: ${e.requestOptions.data.runtimeType}',
        );

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
      }

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
