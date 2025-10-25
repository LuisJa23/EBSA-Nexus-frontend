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
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
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

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista de novedades
  Future<Response> getNovelties({int? page, int? limit, String? status}) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (page != null) queryParameters['page'] = page;
      if (limit != null) queryParameters['limit'] = limit;
      if (status != null) queryParameters['status'] = status;

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
        '${ApiConstants.noveltiesEndpoint}/$id',
      );

      return response;
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
        '${ApiConstants.noveltiesEndpoint}/search',
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

      final response = await _apiClient.post(
        '${ApiConstants.noveltiesEndpoint}/$noveltyId/assign',
        data: data,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
