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
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = file.path.split('/').last;
        
        formData.files.add(
          MapEntry(
            'images', // El backend espera "images" como nombre del campo
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      // Realizar petición POST con form-data
      final response = await _apiClient.post(
        ApiConstants.createNoveltyEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      return response;
    } catch (e) {
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
}
