// offline_sync_service.dart
//
// Servicio de sincronización de novedades offline
//
// PROPÓSITO:
// - Sincronizar novedades creadas offline cuando hay conexión
// - Cachear novedades EN_CURSO del servidor para reportes offline
// - Gestionar estado de sincronización
//
// CAPA: DATA LAYER - SERVICES

import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/errors/exceptions.dart';
import '../../crews/data/datasources/crew_remote_datasource.dart';
import 'services/novelty_report_service.dart';
import 'models/novelty_report_model.dart';
import 'novelty_service.dart';

/// Servicio para sincronizar novedades offline con el servidor
class OfflineSyncService {
  final AppDatabase _database;
  final NoveltyService _noveltyService;
  final NoveltyReportService _reportService;
  final Connectivity _connectivity;
  final CrewRemoteDataSource _crewRemoteDataSource;

  OfflineSyncService(
    this._database,
    this._noveltyService,
    this._reportService,
    this._connectivity,
    this._crewRemoteDataSource,
  );

  /// Verifica si hay conexión a internet
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Verificar conexión real
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    } catch (e) {
      AppLogger.error('Error verificando conexión', error: e);
      return false;
    }
  }

  /// Obtiene todas las novedades creadas offline (ID negativos)
  Future<List<NoveltyCacheTableData>> getPendingOfflineNovelties() async {
    final allNovelties = await _database.getAllCachedNovelties();
    return allNovelties.where((novelty) => novelty.noveltyId < 0).toList();
  }

  /// Sincroniza todas las novedades offline pendientes
  Future<Map<String, dynamic>> syncAllOfflineNovelties() async {
    int successCount = 0;
    int failedCount = 0;
    List<String> errors = [];

    try {
      // Verificar conexión
      print('📡 PASO 1: Verificando conexión a internet...');
      final hasConnection = await hasInternetConnection();
      print(
        '📡 Resultado: ${hasConnection ? "CONECTADO ✅" : "SIN CONEXIÓN ❌"}',
      );

      if (!hasConnection) {
        AppLogger.warning('❌ Sin conexión a internet');
        print('❌ Abortando sincronización: sin conexión');
        return {
          'success': 0,
          'failed': 0,
          'errors': ['Sin conexión a internet'],
        };
      }

      // Obtener novedades offline pendientes
      print('📋 PASO 2: Obteniendo novedades offline pendientes...');
      final offlineNovelties = await getPendingOfflineNovelties();
      print('📋 Total de novedades pendientes: ${offlineNovelties.length}');

      if (offlineNovelties.isEmpty) {
        AppLogger.info('✅ No hay novedades offline para sincronizar');
        print('ℹ️ No hay nada que sincronizar');
        return {'success': 0, 'failed': 0, 'errors': []};
      }

      print(
        '📤 PASO 3: Sincronizando ${offlineNovelties.length} novedad(es)...',
      );
      AppLogger.info('📤 Sincronizando ${offlineNovelties.length} novedad(es)');

      // Sincronizar cada novedad
      for (int i = 0; i < offlineNovelties.length; i++) {
        final novelty = offlineNovelties[i];
        print('');
        print('───────────────────────────────────────────────────');
        print('🔄 Novedad ${i + 1}/${offlineNovelties.length}');
        print('───────────────────────────────────────────────────');

        try {
          final success = await _syncSingleNovelty(novelty);
          if (success) {
            successCount++;
            print('✅ Novedad sincronizada correctamente');
          } else {
            failedCount++;
            final errorMsg = 'Novedad ${novelty.noveltyId}: Error desconocido';
            errors.add(errorMsg);
            print('❌ Falló la sincronización');
          }
        } on NetworkException catch (e) {
          // Si hay error de conexión, abortar el resto
          failedCount += (offlineNovelties.length - i);
          final errorMsg = 'Sin conexión a Internet';
          errors.add(errorMsg);
          print('❌ Error de conexión - Abortando sincronización');
          AppLogger.error('Error de conexión durante sincronización', error: e);
          break; // Salir del loop
        } catch (e) {
          failedCount++;
          final errorMsg = 'Novedad ${novelty.noveltyId}: ${e.toString()}';
          errors.add(errorMsg);
          print('❌ EXCEPCIÓN durante sincronización: $e');
          AppLogger.error(
            'Error sincronizando novedad ${novelty.noveltyId}',
            error: e,
          );
          // Continuar con la siguiente novedad
        }
      }

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ FIN DE SINCRONIZACIÓN');
      print('═══════════════════════════════════════════════════');
      print('📊 RESUMEN:');
      print('  ✅ Exitosas: $successCount');
      print('  ❌ Fallidas: $failedCount');
      if (errors.isNotEmpty) {
        print('  📝 Errores:');
        for (final error in errors) {
          print('    - $error');
        }
      }
      print('═══════════════════════════════════════════════════');

      AppLogger.info(
        '✅ Sincronización completa: $successCount exitosas, $failedCount fallidas',
      );

      return {'success': successCount, 'failed': failedCount, 'errors': errors};
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════');
      print('❌ ERROR CRÍTICO EN SINCRONIZACIÓN');
      print('═══════════════════════════════════════════════════');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════');

      AppLogger.error('Error en sincronización general', error: e);
      return {
        'success': successCount,
        'failed': failedCount,
        'errors': [...errors, 'Error general: ${e.toString()}'],
      };
    }
  }

  /// Mapeo de nombres de municipios a IDs (según la tabla de BD)
  static const Map<String, int> _municipioNameToId = {
    'ARCABUCO': 5,
    'CHITARAQUE': 6,
    'GAMBITA': 7,
    'MONIQUIRA': 8,
    'SAN JOSE DE PARE': 9,
    'SANTANA': 10,
    'TOGUI': 11,
  };

  /// Convierte el nombre del municipio a su ID
  String _getMunicipioIdFromName(String municipioName) {
    final normalizedName = municipioName.trim().toUpperCase();
    final id = _municipioNameToId[normalizedName];

    if (id == null) {
      AppLogger.warning(
        '⚠️ Municipio "$municipioName" no encontrado en el mapeo. Usando ID por defecto: 5 (ARCABUCO)',
      );
      return '5'; // ID por defecto
    }

    return id.toString();
  }

  /// Sincroniza una sola novedad offline al servidor
  Future<bool> _syncSingleNovelty(NoveltyCacheTableData novelty) async {
    try {
      AppLogger.info(
        '📤 Sincronizando novedad offline ID: ${novelty.noveltyId}',
      );

      // Debug: Imprimir datos de la novedad
      print('📋 DATOS DE LA NOVEDAD A SINCRONIZAR:');
      print('  ID Local: ${novelty.noveltyId}');
      print('  Area ID: ${novelty.areaId}');
      print('  Motivo: ${novelty.reason}');
      print('  Cuenta: ${novelty.accountNumber}');
      print('  Medidor: ${novelty.meterNumber}');
      print('  Municipio (nombre): ${novelty.municipality}');
      print('  Dirección: ${novelty.address}');

      // Validar que los campos requeridos no estén vacíos
      if (novelty.areaId == 0) {
        print('❌ ERROR: areaId es 0');
        throw Exception('areaId inválido');
      }
      if (novelty.reason.isEmpty) {
        print('❌ ERROR: reason está vacío');
        throw Exception('reason no puede estar vacío');
      }
      if (novelty.accountNumber.isEmpty) {
        print('❌ ERROR: accountNumber está vacío');
        throw Exception('accountNumber no puede estar vacío');
      }
      if (novelty.meterNumber.isEmpty) {
        print('❌ ERROR: meterNumber está vacío');
        throw Exception('meterNumber no puede estar vacío');
      }

      // Extraer datos del rawJson
      String locationId = '';
      String activeReadingText = novelty.activeReading.toString();
      String reactiveReadingText = novelty.reactiveReading.toString();
      List<File> imageFiles = [];

      try {
        print('📦 Extrayendo datos del rawJson...');
        final rawJsonMap = jsonDecode(novelty.rawJson) as Map<String, dynamic>;
        print('  - rawJson parseado correctamente');

        // Extraer locationId (guardado durante la creación offline)
        if (rawJsonMap.containsKey('locationId')) {
          locationId = rawJsonMap['locationId']?.toString() ?? '';
          print('  - locationId encontrado: $locationId');
        }

        // Si no hay locationId en rawJson, intentar convertir desde nombre
        if (locationId.isEmpty) {
          print(
            '  ⚠️ locationId no encontrado en rawJson, convirtiendo desde nombre...',
          );
          locationId = _getMunicipioIdFromName(novelty.municipality);
          print('  - locationId convertido: $locationId');
        }

        // Extraer valores de texto de lecturas (si existen)
        if (rawJsonMap.containsKey('activeReadingText')) {
          activeReadingText =
              rawJsonMap['activeReadingText']?.toString() ?? activeReadingText;
        }
        if (rawJsonMap.containsKey('reactiveReadingText')) {
          reactiveReadingText =
              rawJsonMap['reactiveReadingText']?.toString() ??
              reactiveReadingText;
        }

        // Extraer rutas de imágenes
        if (rawJsonMap.containsKey('image_paths')) {
          final imagePaths = rawJsonMap['image_paths'];
          print('📸 Extrayendo imágenes...');
          print('  - Tipo de image_paths: ${imagePaths.runtimeType}');

          // Convertir a List<String> de manera segura
          List<String> pathsList = [];
          if (imagePaths is List) {
            pathsList = imagePaths.map((path) => path.toString()).toList();
          }

          print('  - Rutas de imágenes encontradas: ${pathsList.length}');

          // Convertir rutas a File objects
          for (final path in pathsList) {
            final file = File(path);
            if (await file.exists()) {
              imageFiles.add(file);
              print('    ✓ Imagen encontrada: $path');
            } else {
              print('    ✗ Imagen no encontrada: $path');
            }
          }

          print('  - Total de imágenes válidas: ${imageFiles.length}');
        } else {
          print('  - No hay image_paths en rawJson');
        }
      } catch (e) {
        print('⚠️ Error al extraer datos del rawJson: $e');
        print('  Intentando continuar con datos básicos...');

        // Si falla la extracción, usar conversión de nombre como fallback
        if (locationId.isEmpty) {
          locationId = _getMunicipioIdFromName(novelty.municipality);
          print('  - locationId convertido (fallback): $locationId');
        }
      }

      // Validar locationId
      if (locationId.isEmpty || locationId == '0') {
        print('❌ ERROR: locationId inválido');
        throw Exception('locationId no puede ser 0 o vacío');
      }

      print('');
      print('📋 DATOS FINALES PARA ENVIAR AL BACKEND:');
      print('  - areaId: ${novelty.areaId}');
      print('  - reason: ${novelty.reason}');
      print('  - accountNumber: ${novelty.accountNumber}');
      print('  - meterNumber: ${novelty.meterNumber}');
      print('  - activeReading: $activeReadingText');
      print('  - reactiveReading: $reactiveReadingText');
      print('  - locationId: $locationId');
      print('  - municipality: ${novelty.municipality}');
      print('  - address: ${novelty.address}');
      print('  - description: ${novelty.description}');
      print('  - observations: ${novelty.observations}');
      print('  - images: ${imageFiles.length}');

      // Crear novedad en el servidor (MISMO LLAMADO QUE CREACIÓN NORMAL)
      print('🌐 Llamando al backend con createNovelty...');
      final response = await _noveltyService.createNovelty(
        areaId: novelty.areaId.toString(),
        reason: novelty.reason,
        accountNumber: novelty.accountNumber,
        meterNumber: novelty.meterNumber,
        activeReading: activeReadingText, // Usar texto original
        reactiveReading: reactiveReadingText, // Usar texto original
        locationId: locationId, // ID del municipio (guardado en rawJson)
        municipality: novelty.municipality, // NOMBRE del municipio
        address: novelty.address, // Coordenadas GPS (formato: "lat,lon")
        description: novelty.description,
        observations: novelty.observations,
        images: imageFiles, // Imágenes extraídas del rawJson
      );

      print('📡 Respuesta del backend:');
      print('  Status Code: ${response.statusCode}');
      print('  Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Eliminar la novedad offline del caché
        print('🗑️ Eliminando novedad del caché local...');
        final deletedRows = await (_database.delete(
          _database.noveltyCacheTable,
        )..where((tbl) => tbl.noveltyId.equals(novelty.noveltyId))).go();

        print('✅ Filas eliminadas: $deletedRows');
        AppLogger.info(
          '✅ Novedad ${novelty.noveltyId} sincronizada exitosamente',
        );
        return true;
      } else {
        final errorMsg = 'Error del servidor (${response.statusCode})';
        AppLogger.error('❌ $errorMsg');
        print('❌ Response body: ${response.data}');
        throw Exception(errorMsg);
      }
    } on NetworkException catch (e) {
      AppLogger.error('❌ Error de conexión al sincronizar novedad', error: e);
      print('❌ NetworkException: ${e.message}');
      throw Exception('Sin conexión a Internet: ${e.message}');
    } on FormatException catch (e) {
      AppLogger.error('❌ Error de formato de datos', error: e);
      print('❌ FormatException: $e');
      throw Exception('Error en el formato de los datos: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error sincronizando novedad', error: e);
      print('❌ EXCEPCIÓN COMPLETA:');
      print('  Error: $e');
      print('  Stack trace: $stackTrace');

      // Intentar extraer un mensaje más amigable
      String friendlyMessage = e.toString();
      if (friendlyMessage.contains('type \'List<dynamic>\' is not a subtype')) {
        friendlyMessage = 'Error en el formato de los datos almacenados';
      } else if (friendlyMessage.contains('Connection')) {
        friendlyMessage = 'Error de conexión a Internet';
      } else if (friendlyMessage.contains('Timeout')) {
        friendlyMessage = 'Tiempo de espera agotado';
      }

      throw Exception(friendlyMessage);
    }
  }

  /// Cachea las últimas N novedades EN_CURSO para reportes offline
  Future<int> cacheEnCursoNoveltiesForOfflineReports({int count = 5}) async {
    try {
      print('🟢 === INICIO cacheEnCursoNoveltiesForOfflineReports ===');
      print('🟢 Count solicitado: $count');
      AppLogger.info('📥 Cacheando últimas $count novedades EN_CURSO');

      // Verificar conexión
      print('🟢 Verificando conexión...');
      final hasConnection = await hasInternetConnection();
      print('🟢 Conexión: ${hasConnection ? "SÍ" : "NO"}');

      if (!hasConnection) {
        AppLogger.warning('❌ Sin conexión, no se pueden cachear novedades');
        print('❌ Sin conexión, abortando');
        return 0;
      }

      // Obtener novedades EN_CURSO del servidor
      print('🟢 Llamando a _noveltyService.getNovelties...');
      print('🟢 Parámetros: status=EN_CURSO, page=0, size=$count');

      final response = await _noveltyService.getNovelties(
        status: 'EN_CURSO',
        page: 0,
        size: count,
        sort: 'updatedAt',
        direction: 'DESC',
      );

      print('🟢 Respuesta recibida: statusCode=${response.statusCode}');

      if (response.statusCode != 200) {
        AppLogger.error('❌ Error obteniendo novedades: ${response.statusCode}');
        print('❌ Status code no es 200: ${response.statusCode}');
        print('❌ Data: ${response.data}');
        return 0;
      }

      // Parsear respuesta
      final data = response.data;
      print('🟢 Parseando respuesta...');
      print('🟢 Tipo de data: ${data.runtimeType}');

      List<dynamic> novelties = [];

      if (data is Map && data['content'] != null) {
        novelties = data['content'] as List<dynamic>;
        print('🟢 Extraídas ${novelties.length} novedades de data["content"]');
      } else if (data is List) {
        novelties = data;
        print('🟢 Data es lista directa: ${novelties.length} elementos');
      } else {
        print('⚠️ Formato de data no reconocido');
      }

      if (novelties.isEmpty) {
        AppLogger.info('ℹ️ No hay novedades EN_CURSO para cachear');
        print('⚠️ Lista de novedades vacía');
        return 0;
      }

      print('🟢 Cacheando ${novelties.length} novedad(es)...');
      int cachedCount = 0;

      // Guardar cada novedad en caché
      for (int i = 0; i < novelties.length; i++) {
        final noveltyData = novelties[i];
        print('');
        print('═══════════════════════════════════════════════════');
        print('🟢 Cacheando novedad ${i + 1}/${novelties.length}');
        print('═══════════════════════════════════════════════════');
        print('📋 Datos completos:');
        print('  - ID: ${noveltyData['id']}');
        print('  - Status: ${noveltyData['status']}');
        print('  - CrewId: ${noveltyData['crewId']}');
        print('  - AreaId: ${noveltyData['areaId']}');
        print('  - Cuenta: ${noveltyData['accountNumber']}');
        print('  - Medidor: ${noveltyData['meterNumber']}');
        print('  - LocationId: ${noveltyData['locationId']}');
        print('  - LocationName: ${noveltyData['locationName']}');
        print('  - CreatedBy: ${noveltyData['createdBy']}');
        print('  - CreatedAt: ${noveltyData['createdAt']}');
        print('  - UpdatedAt: ${noveltyData['updatedAt']}');

        try {
          await _cacheNoveltyFromServer(noveltyData);
          cachedCount++;
          print('✅ Novedad ${noveltyData['id']} cacheada exitosamente');
        } catch (e, stackTrace) {
          print('❌ Error cacheando novedad ${noveltyData['id']}: $e');
          print('Stack: $stackTrace');
          AppLogger.error('Error cacheando novedad', error: e);
        }
        print('═══════════════════════════════════════════════════');
      }

      AppLogger.info('✅ Cacheadas $cachedCount novedad(es) EN_CURSO');
      print('🟢 === FIN cacheEnCursoNoveltiesForOfflineReports ===');
      print('✅ Total cacheadas: $cachedCount');
      return cachedCount;
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN en cacheEnCursoNoveltiesForOfflineReports: $e');
      print('Stack: $stackTrace');
      AppLogger.error('Error en cacheo de novedades', error: e);
      return 0;
    }
  }

  /// Guarda una novedad del servidor en caché
  Future<void> _cacheNoveltyFromServer(dynamic noveltyData) async {
    print('🟢 === INICIO _cacheNoveltyFromServer ===');
    print('🟢 noveltyData recibido: $noveltyData');

    final now = DateTime.now();

    try {
      print('🟢 Creando NoveltyCacheTableCompanion...');

      // IMPORTANTE: Guardar los datos completos en rawJson para uso posterior
      final rawJsonData = {
        ...noveltyData,
        'from_server': true,
        'cached_for_offline_reports': true,
        'cached_at': now.toIso8601String(),
      };

      final companion = NoveltyCacheTableCompanion(
        noveltyId: drift.Value(noveltyData['id'] as int),
        areaId: drift.Value(noveltyData['areaId'] as int),
        reason: drift.Value(noveltyData['reason'] as String),
        accountNumber: drift.Value(noveltyData['accountNumber'] as String),
        meterNumber: drift.Value(noveltyData['meterNumber'] as String),
        activeReading: drift.Value(
          (noveltyData['activeReading'] as num).toDouble(),
        ),
        reactiveReading: drift.Value(
          (noveltyData['reactiveReading'] as num).toDouble(),
        ),
        municipality: drift.Value(
          noveltyData['locationName'] as String? ??
              '', // Ahora viene como locationName
        ),
        address: drift.Value(noveltyData['address'] as String),
        description: drift.Value(noveltyData['description'] as String),
        observations: drift.Value(noveltyData['observations']),
        status: drift.Value(noveltyData['status'] as String),
        createdBy: drift.Value(noveltyData['createdBy'] as int),
        crewId: drift.Value(noveltyData['crewId']),
        createdAt: drift.Value(
          DateTime.parse(noveltyData['createdAt'] as String),
        ),
        updatedAt: drift.Value(
          DateTime.parse(noveltyData['updatedAt'] as String),
        ),
        completedAt: noveltyData['completedAt'] != null
            ? drift.Value(DateTime.parse(noveltyData['completedAt'] as String))
            : const drift.Value.absent(),
        closedAt: noveltyData['closedAt'] != null
            ? drift.Value(DateTime.parse(noveltyData['closedAt'] as String))
            : const drift.Value.absent(),
        cancelledAt: noveltyData['cancelledAt'] != null
            ? drift.Value(DateTime.parse(noveltyData['cancelledAt'] as String))
            : const drift.Value.absent(),
        cachedAt: drift.Value(now),
        rawJson: drift.Value(jsonEncode(rawJsonData)),
      );

      print('🟢 Companion creado. Valores:');
      print('  - ID: ${noveltyData['id']}');
      print('  - Status: ${noveltyData['status']}');
      print('  - CrewId: ${noveltyData['crewId']}');
      print('  - Cuenta: ${noveltyData['accountNumber']}');
      print('  - CachedAt: $now');
      print('  - RawJson size: ${jsonEncode(rawJsonData).length} bytes');

      print('🟢 Llamando a upsertNoveltyCache...');
      final result = await _database.upsertNoveltyCache(companion);
      print('🟢 Resultado de upsert: $result');

      // Verificar que se guardó correctamente
      final savedNovelty = await _database.getCachedNoveltyById(
        noveltyData['id'] as int,
      );
      if (savedNovelty != null) {
        print('✅ VERIFICACIÓN: Novedad guardada correctamente');
        print('   - ID: ${savedNovelty.noveltyId}');
        print('   - CrewId guardado: ${savedNovelty.crewId}');
      }

      // Si la novedad tiene una cuadrilla asignada, cachear también la cuadrilla
      print('🔍 Verificando si hay cuadrilla para cachear...');
      print('   - noveltyData["crewId"]: ${noveltyData['crewId']}');
      print(
        '   - noveltyData["crewId"] != null: ${noveltyData['crewId'] != null}',
      );

      if (noveltyData['crewId'] != null) {
        print(
          '🟢 ✅ Novedad tiene cuadrilla asignada (ID: ${noveltyData['crewId']})',
        );
        print('🟢 Iniciando caché de cuadrilla con sus miembros...');
        try {
          await _cacheCrewWithMembers(noveltyData['crewId'] as int);
          print('🟢 ✅ Caché de cuadrilla completado');
        } catch (e, stackTrace) {
          print('🟢 ❌ ERROR cacheando cuadrilla: $e');
          print('Stack: $stackTrace');
        }
      } else {
        print('⚠️ Novedad sin cuadrilla asignada (crewId es null)');
      }

      // Verificar que se guardó
      print('🟢 Verificando que se guardó...');
      final saved = await _database.getCachedNoveltyById(
        noveltyData['id'] as int,
      );
      if (saved != null) {
        print('✅ Novedad guardada correctamente:');
        print('  - ID: ${saved.noveltyId}');
        print('  - Status: ${saved.status}');
        print('  - CrewId: ${saved.crewId}');
        print(
          '  - RawJson: ${saved.rawJson.substring(0, saved.rawJson.length > 100 ? 100 : saved.rawJson.length)}...',
        );
      } else {
        print('❌ ERROR: Novedad NO se guardó en BD');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN en _cacheNoveltyFromServer: $e');
      print('Stack: $stackTrace');
      rethrow;
    }

    print('🟢 === FIN _cacheNoveltyFromServer ===');
  }

  /// Cachea una cuadrilla con sus miembros (método público para uso desde UI)
  Future<void> cacheCrewWithMembers(int crewId) async {
    await _cacheCrewWithMembers(crewId);
  }

  /// Cachea una cuadrilla con sus miembros (método interno)
  Future<void> _cacheCrewWithMembers(int crewId) async {
    print('👥 === INICIO _cacheCrewWithMembers ===');
    print('👥 crewId: $crewId');

    try {
      // Verificar si ya está en caché
      final existingCrew = await _database.getCachedCrewById(crewId);

      if (existingCrew != null) {
        // Verificar si ya tiene miembros en el JSON
        try {
          final crewData =
              jsonDecode(existingCrew.rawJson) as Map<String, dynamic>;
          if (crewData.containsKey('members') &&
              crewData['members'] is List &&
              (crewData['members'] as List).isNotEmpty) {
            print(
              '✅ Cuadrilla $crewId ya tiene miembros en caché (${(crewData['members'] as List).length} miembros)',
            );
            print('👥 === FIN _cacheCrewWithMembers ===');
            return;
          }
        } catch (e) {
          print('⚠️ Error parseando rawJson de cuadrilla existente: $e');
        }
      }

      // Obtener la cuadrilla con sus miembros del servidor
      print('👥 Obteniendo cuadrilla con miembros del servidor...');

      final crewWithMembers = await _crewRemoteDataSource.getCrewWithMembers(
        crewId,
      );

      final crew = crewWithMembers.crewDetail;
      final members = crewWithMembers.members;

      print('👥 Cuadrilla obtenida: ${crew.name}');
      print('👥 Miembros obtenidos: ${members.length}');

      // Convertir a Map para guardar en JSON
      final crewData = {
        'id': crew.id,
        'name': crew.name,
        'description': crew.description,
        'status': crew.status,
        'createdBy': crew.createdBy,
        'createdAt': crew.createdAt.toIso8601String(),
        'updatedAt': crew.updatedAt.toIso8601String(),
        'deletedAt': crew.deletedAt?.toIso8601String(),
        'hasActiveAssignments': crew.hasActiveAssignments,
        'members': members
            .map(
              (member) => {
                'id': member.id,
                'crewId': member.crewId,
                'userId': member.userId,
                'isLeader': member.isLeader,
                'joinedAt': member.joinedAt.toIso8601String(),
                'leftAt': member.leftAt?.toIso8601String(),
                'notes': member.notes,
                'userUuid': member.userUuid,
                'username': member.username,
                'email': member.email,
                'firstName': member.firstName,
                'lastName': member.lastName,
                'roleName': member.roleName,
                'workRoleName': member.workRoleName,
                'workType': member.workType,
                'documentNumber': member.documentNumber,
                'phone': member.phone,
                'active': member.active,
              },
            )
            .toList(),
      };

      // Guardar la cuadrilla con sus miembros en caché
      final rawJsonString = jsonEncode(crewData);
      print(
        '💾 JSON a guardar (primeros 500 chars): ${rawJsonString.substring(0, rawJsonString.length > 500 ? 500 : rawJsonString.length)}',
      );
      print('💾 Número de miembros en JSON: ${members.length}');

      final companion = CrewCacheTableCompanion(
        crewId: drift.Value(crewData['id'] as int),
        name: drift.Value(crewData['name'] as String),
        description: drift.Value(crewData['description'] as String),
        status: drift.Value(crewData['status'] as String),
        createdBy: drift.Value(crewData['createdBy'] as int),
        activeMemberCount: drift.Value(members.length),
        hasActiveAssignments: drift.Value(
          crewData['hasActiveAssignments'] as bool?,
        ),
        createdAt: drift.Value(DateTime.parse(crewData['createdAt'] as String)),
        updatedAt: drift.Value(DateTime.parse(crewData['updatedAt'] as String)),
        deletedAt: drift.Value(
          crewData['deletedAt'] != null
              ? DateTime.parse(crewData['deletedAt'] as String)
              : null,
        ),
        cachedAt: drift.Value(DateTime.now()),
        rawJson: drift.Value(rawJsonString), // Incluye los miembros
      );

      await _database.upsertCrewCache(companion);

      // Verificar que se guardó correctamente
      final savedCrew = await _database.getCachedCrewById(crewId);
      if (savedCrew != null) {
        final savedData = jsonDecode(savedCrew.rawJson) as Map<String, dynamic>;
        final savedMembers = savedData['members'] as List?;
        print('✅ Verificación post-guardado:');
        print('   - Cuadrilla ID: ${savedCrew.crewId}');
        print('   - Nombre: ${savedCrew.name}');
        print('   - Miembros en JSON: ${savedMembers?.length ?? 0}');
        if (savedMembers != null && savedMembers.isNotEmpty) {
          print('   - Primer miembro: ${savedMembers.first}');
        }
      }

      print('✅ Cuadrilla $crewId cacheada con ${members.length} miembros');
      AppLogger.info(
        'Cuadrilla $crewId cacheada con ${members.length} miembros',
      );
    } catch (e, stackTrace) {
      print('❌ Error cacheando cuadrilla: $e');
      print('Stack: $stackTrace');
      // No lanzar error, solo loguearlo para no bloquear el caché de la novedad
      AppLogger.warning('Error cacheando cuadrilla $crewId: $e', error: e);
    }

    print('👥 === FIN _cacheCrewWithMembers ===');
  }

  /// Sincroniza todos los reportes offline pendientes
  Future<Map<String, dynamic>> syncAllOfflineReports() async {
    print('═══════════════════════════════════════════════════');
    print('🔄 INICIO DE SINCRONIZACIÓN DE REPORTES');
    print('═══════════════════════════════════════════════════');
    AppLogger.info('🔄 Iniciando sincronización de reportes offline');

    int successCount = 0;
    int failedCount = 0;
    List<String> errors = [];

    try {
      // Verificar conexión
      print('📡 PASO 1: Verificando conexión a internet...');
      final hasConnection = await hasInternetConnection();
      print(
        '📡 Resultado: ${hasConnection ? "CONECTADO ✅" : "SIN CONEXIÓN ❌"}',
      );

      if (!hasConnection) {
        AppLogger.warning('❌ Sin conexión a internet');
        print('❌ Abortando sincronización: sin conexión');
        return {
          'success': 0,
          'failed': 0,
          'errors': ['Sin conexión a internet'],
        };
      }

      // Obtener reportes offline pendientes
      print('📋 PASO 2: Obteniendo reportes offline pendientes...');
      final offlineReports = await _database.getPendingSyncReports();
      print('📋 Total de reportes pendientes: ${offlineReports.length}');

      if (offlineReports.isEmpty) {
        AppLogger.info('✅ No hay reportes offline para sincronizar');
        print('ℹ️ No hay reportes que sincronizar');
        return {'success': 0, 'failed': 0, 'errors': []};
      }

      print('📤 PASO 3: Sincronizando ${offlineReports.length} reporte(s)...');

      // Sincronizar cada reporte
      for (var i = 0; i < offlineReports.length; i++) {
        final report = offlineReports[i];
        print('');
        print('📄 ─────────────────────────────────────────────');
        print('📄 Sincronizando reporte ${i + 1}/${offlineReports.length}');
        print('📄 ID local: ${report.id}');
        print('📄 Novedad ID: ${report.noveltyId}');
        print('📄 ─────────────────────────────────────────────');

        try {
          await _syncSingleReport(report);
          successCount++;
          print('✅ Reporte ${i + 1} sincronizado exitosamente');
        } catch (e) {
          failedCount++;
          final errorMsg = 'Reporte ${report.id}: $e';
          errors.add(errorMsg);
          print('❌ Error en reporte ${i + 1}: $e');
          AppLogger.error('Error sincronizando reporte', error: e);

          // Actualizar contador de intentos fallidos
          await _database.updateReportSyncAttempt(report.id, e.toString());
        }
      }

      print('');
      print('═══════════════════════════════════════════════════');
      print('📊 RESULTADO FINAL DE SINCRONIZACIÓN DE REPORTES');
      print('═══════════════════════════════════════════════════');
      print('✅ Exitosos: $successCount');
      print('❌ Fallidos: $failedCount');
      if (errors.isNotEmpty) {
        print('⚠️ Errores:');
        for (var error in errors) {
          print('  - $error');
        }
      }
      print('═══════════════════════════════════════════════════');

      AppLogger.info(
        'Sincronización de reportes completada: $successCount exitosos, $failedCount fallidos',
      );

      return {'success': successCount, 'failed': failedCount, 'errors': errors};
    } catch (e, stackTrace) {
      print('❌ ERROR GENERAL EN SINCRONIZACIÓN DE REPORTES: $e');
      print('Stack: $stackTrace');
      AppLogger.error(
        'Error en sincronización de reportes',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'success': successCount,
        'failed': failedCount + 1,
        'errors': [...errors, 'Error general: $e'],
      };
    }
  }

  /// Sincroniza un reporte individual con el servidor
  Future<void> _syncSingleReport(ReportTableData report) async {
    print('📝 === INICIO _syncSingleReport ===');
    print('📝 Reporte ID: ${report.id}');
    print('📝 Novedad ID: ${report.noveltyId}');

    try {
      // Preparar datos del reporte para enviar al servidor
      final participantIds = (jsonDecode(report.participantIds) as List)
          .map((id) => id as int)
          .toList();

      print('📝 Datos del reporte:');
      print('  - Descripción: ${report.workDescription}');
      print('  - Observaciones: ${report.observations}');
      print('  - Tiempo de trabajo: ${report.workTime} minutos');
      print('  - Estado: ${report.resolutionStatus}');
      print('  - Participantes: $participantIds');

      // Validar datos antes de enviar
      if (report.noveltyId <= 0) {
        throw Exception(
          'El reporte está asociado a una novedad offline (ID: ${report.noveltyId}). '
          'Debes sincronizar la novedad primero.',
        );
      }

      if (participantIds.isEmpty) {
        throw Exception('El reporte debe tener al menos un participante');
      }

      // Validar que la descripción no esté vacía
      if (report.workDescription.trim().isEmpty) {
        throw Exception(
          'El reporte debe tener una descripción del trabajo realizado',
        );
      }

      // Validar tiempo de trabajo
      if (report.workTime <= 0) {
        throw Exception('El tiempo de trabajo debe ser mayor a 0 minutos');
      }

      // Mapear estado local al esperado por el API
      // BD local usa: "COMPLETADO" y "NO_COMPLETADO"
      // API espera: "COMPLETADA" y "NO_COMPLETADA"
      final apiResolutionStatus = _mapResolutionStatusToApi(
        report.resolutionStatus,
      );
      print('  - Estado mapeado para API: $apiResolutionStatus');

      // Validar que el estado mapeado no esté vacío
      if (apiResolutionStatus.isEmpty) {
        throw Exception(
          'Estado de resolución inválido: ${report.resolutionStatus}',
        );
      }

      // Calcular fechas de inicio y fin basadas en el tiempo de trabajo
      // workEndDate es cuando se creó el reporte
      final workEndDate = report.createdAt;
      // workStartDate se calcula restando el tiempo de trabajo
      final workStartDate = workEndDate.subtract(
        Duration(minutes: report.workTime),
      );

      print('  - Fecha inicio calculada: $workStartDate');
      print('  - Fecha fin: $workEndDate');

      // Crear request para el API
      final request = CreateNoveltyReportRequest(
        noveltyId: report.noveltyId,
        reportContent: report.workDescription,
        observations: report.observations,
        workStartDate: workStartDate,
        workEndDate: workEndDate,
        resolutionStatus: apiResolutionStatus,
        participants: participantIds
            .map((id) => ParticipantRequest(userId: id))
            .toList(),
      );

      // Convertir a JSON para logging y verificación
      final requestJson = request.toJson();

      print('📤 Enviando reporte al API...');
      print('📤 ========================================');
      print('📤 Request Object:');
      print(
        '   - noveltyId: ${request.noveltyId} (${request.noveltyId.runtimeType})',
      );
      print(
        '   - reportContent: "${request.reportContent}" (length: ${request.reportContent.length})',
      );
      print('   - observations: ${request.observations}');
      print('   - workStartDate: ${request.workStartDate.toIso8601String()}');
      print('   - workEndDate: ${request.workEndDate.toIso8601String()}');
      print('   - resolutionStatus: "${request.resolutionStatus}"');
      print(
        '   - participants: ${request.participants.length} participante(s)',
      );
      for (var i = 0; i < request.participants.length; i++) {
        print('     [$i] userId: ${request.participants[i].userId}');
      }
      print('📤 ========================================');
      print('📤 Request JSON:');
      print(jsonEncode(requestJson));
      print('📤 ========================================');

      // Llamar al API para crear el reporte
      final createdReport = await _reportService.createReport(request);

      print('✅ Reporte creado en servidor exitosamente');
      print('  - ID del servidor: ${createdReport.id}');
      print('  - Novedad ID: ${createdReport.noveltyId}');
      print('  - Estado: ${createdReport.resolutionStatus}');

      // Marcar como sincronizado en la BD local
      await _database.markReportAsSynced(report.id, createdReport.id);

      print('✅ Reporte marcado como sincronizado en BD local');
      print('📝 === FIN _syncSingleReport ===');
    } on Exception catch (e) {
      print('❌ Error de validación o API: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Error inesperado en _syncSingleReport: $e');
      print('Stack: $stackTrace');
      throw Exception('Error sincronizando reporte: $e');
    }
  }

  /// Mapea el estado de resolución local al formato esperado por el API
  String _mapResolutionStatusToApi(String localStatus) {
    switch (localStatus) {
      case 'COMPLETADO':
        return 'COMPLETADA';
      case 'NO_COMPLETADO':
        return 'NO_COMPLETADA';
      default:
        // Por si acaso viene otro formato, intentar usar el mismo
        return localStatus;
    }
  }
}
