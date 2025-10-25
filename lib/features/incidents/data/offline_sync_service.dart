// offline_sync_service.dart
//
// Servicio de sincronización de novedades offline
//
// PROPÓSITO:
// - Sincronizar novedades guardadas offline cuando hay conexión
// - Reenviar al servidor usando el mismo endpoint de creación
// - Gestionar estado de sincronización
//
// CAPA: DATA LAYER - SERVICES

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../config/database/app_database.dart';
import 'novelty_service.dart';

/// Servicio para sincronizar novedades offline con el servidor
class OfflineSyncService {
  final AppDatabase _database;
  final NoveltyService _noveltyService;
  final Connectivity _connectivity;

  OfflineSyncService(this._database, this._noveltyService, this._connectivity);

  /// Verifica si hay conexión a internet
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Sin conexión si es none
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Verificar conexión real haciendo ping a un servidor
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    } catch (e) {
      print('❌ Error verificando conexión: $e');
      return false;
    }
  }

  /// Obtiene todas las novedades pendientes de sincronización
  Future<List<OfflineIncidentData>> getPendingIncidents() async {
    return await _database.getPendingIncidents();
  }

  /// Sincroniza todas las novedades pendientes
  ///
  /// Retorna un mapa con:
  /// - 'success': cantidad de novedades sincronizadas exitosamente
  /// - 'failed': cantidad de novedades que fallaron
  /// - 'errors': lista de errores encontrados
  Future<Map<String, dynamic>> syncAllPendingIncidents() async {
    print('🔄 Iniciando sincronización de novedades offline...');

    // Verificar conexión
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      print('❌ Sin conexión a internet');
      return {
        'success': 0,
        'failed': 0,
        'errors': ['Sin conexión a internet'],
      };
    }

    // Obtener novedades pendientes
    final pendingIncidents = await getPendingIncidents();
    print('📋 Novedades pendientes: ${pendingIncidents.length}');

    if (pendingIncidents.isEmpty) {
      return {'success': 0, 'failed': 0, 'errors': []};
    }

    int successCount = 0;
    int failedCount = 0;
    final List<String> errors = [];

    // Sincronizar cada novedad
    for (final incident in pendingIncidents) {
      try {
        print('📤 Sincronizando novedad: ${incident.id}');

        // Obtener imágenes de esta novedad
        final images = await _database.getIncidentImages(incident.id);

        // Convertir rutas a archivos
        final imageFiles = images
            .map((img) => File(img.localPath))
            .where((file) => file.existsSync())
            .toList();

        print('📷 Imágenes encontradas: ${imageFiles.length}');

        // Enviar al servidor usando el mismo endpoint
        await _noveltyService.createNovelty(
          areaId: incident.areaId.toString(),
          reason: incident.reason,
          accountNumber: incident.accountNumber,
          meterNumber: incident.meterNumber,
          activeReading: incident.activeReading,
          reactiveReading: incident.reactiveReading,
          municipality: incident.municipality,
          address: incident.address,
          description: incident.description,
          observations: incident.observations,
          images: imageFiles,
        );

        print('✅ Novedad ${incident.id} sincronizada exitosamente');

        // Eliminar de la base de datos local (cascade eliminará las imágenes)
        await _database.deleteOfflineIncident(incident.id);

        successCount++;
      } catch (e) {
        print('❌ Error sincronizando novedad ${incident.id}: $e');
        failedCount++;
        errors.add('Novedad ${incident.id}: ${e.toString()}');

        // Actualizar estado a error
        await _database.updateIncidentSyncStatus(
          id: incident.id,
          status: 'error',
          errorMessage: e.toString(),
        );
      }
    }

    print(
      '📊 Sincronización completada: $successCount exitosas, $failedCount fallidas',
    );

    return {'success': successCount, 'failed': failedCount, 'errors': errors};
  }

  /// Sincroniza una novedad específica por ID
  Future<bool> syncIncidentById(String incidentId) async {
    print('🔄 Sincronizando novedad específica: $incidentId');

    // Verificar conexión
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      print('❌ Sin conexión a internet');
      return false;
    }

    try {
      // Obtener la novedad
      final incident = await _database.getIncidentById(incidentId);

      if (incident == null) {
        print('❌ Novedad no encontrada: $incidentId');
        return false;
      }

      // Obtener imágenes
      final images = await _database.getIncidentImages(incidentId);

      final imageFiles = images
          .map((img) => File(img.localPath))
          .where((file) => file.existsSync())
          .toList();

      // Enviar al servidor
      await _noveltyService.createNovelty(
        areaId: incident.areaId.toString(),
        reason: incident.reason,
        accountNumber: incident.accountNumber,
        meterNumber: incident.meterNumber,
        activeReading: incident.activeReading,
        reactiveReading: incident.reactiveReading,
        municipality: incident.municipality,
        address: incident.address,
        description: incident.description,
        observations: incident.observations,
        images: imageFiles,
      );

      print('✅ Novedad sincronizada exitosamente');

      // Eliminar de la base de datos local
      await _database.deleteOfflineIncident(incidentId);

      return true;
    } catch (e) {
      print('❌ Error sincronizando novedad: $e');

      // Actualizar estado a error
      await _database.updateIncidentSyncStatus(
        id: incidentId,
        status: 'error',
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  /// Intenta sincronizar automáticamente cuando detecta conexión
  Stream<Map<String, dynamic>> startAutoSync() async* {
    print('🔄 Iniciando sincronización automática...');

    // Escuchar cambios de conectividad
    await for (final result in _connectivity.onConnectivityChanged) {
      // Si hay conexión, intentar sincronizar
      if (result != ConnectivityResult.none) {
        print('📶 Conexión detectada, iniciando sincronización...');

        // Esperar un poco para que la conexión se establezca
        await Future.delayed(const Duration(seconds: 2));

        // Verificar que realmente hay internet
        final hasConnection = await hasInternetConnection();
        if (hasConnection) {
          final syncResult = await syncAllPendingIncidents();
          yield syncResult;
        }
      }
    }
  }
}
