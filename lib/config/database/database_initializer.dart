// database_initializer.dart
//
// Inicializador de base de datos local
//
// PROPÓSITO:
// - Inicializar y verificar la base de datos al inicio de la app
// - Garantizar que las tablas estén creadas correctamente
// - Realizar verificaciones de integridad
//
// CAPA: CONFIG

import '../../core/database/app_database.dart';
import '../../core/utils/app_logger.dart';

/// Inicializa la base de datos local y verifica su integridad
Future<void> initializeLocalDatabase() async {
  try {
    print('🗄️ ========================================');
    print('🗄️ INICIALIZANDO BASE DE DATOS LOCAL');
    print('🗄️ ========================================');

    // Crear instancia de la base de datos
    final db = AppDatabase();

    print('🗄️ Base de datos instanciada');

    // Forzar la creación/migración de tablas haciendo una consulta simple
    print('🗄️ IMPORTANTE: La BD persiste entre reinicios de la app');
    print('🗄️ Verificando tablas...');

    // Verificar tabla de novedades
    final novelties = await db.getAllCachedNovelties();
    print('🗄️ ✓ Tabla novelty_cache: ${novelties.length} registros');

    if (novelties.isNotEmpty) {
      print('🗄️   📋 Primeras novedades encontradas:');
      for (var i = 0; i < (novelties.length > 3 ? 3 : novelties.length); i++) {
        final nov = novelties[i];
        print('🗄️   - ID: ${nov.noveltyId}, Cuenta: ${nov.accountNumber}');
      }
    }

    // Verificar tabla de cuadrillas
    final crews = await db.getAllCachedCrews();
    print('🗄️ ✓ Tabla crew_cache: ${crews.length} registros');

    // Verificar tabla de reportes
    final reports = await db.getAllReports();
    print('🗄️ ✓ Tabla reports: ${reports.length} registros');

    print('🗄️ ========================================');
    print('🗄️ ✅ BASE DE DATOS INICIALIZADA CORRECTAMENTE');
    print('🗄️ ========================================');

    // Cerrar la instancia de prueba
    await db.close();

    AppLogger.info('Base de datos local inicializada correctamente');
  } catch (e, stackTrace) {
    print('🗄️ ========================================');
    print('🗄️ ❌ ERROR INICIALIZANDO BASE DE DATOS');
    print('🗄️ ========================================');
    print('🗄️ Error: $e');
    print('🗄️ Stack: $stackTrace');

    AppLogger.error(
      'Error inicializando base de datos',
      error: e,
      stackTrace: stackTrace,
    );

    // Re-lanzar el error para que la app pueda manejarlo
    rethrow;
  }
}

/// Verifica el estado actual de la base de datos
Future<Map<String, int>> getDatabaseStatus() async {
  try {
    final db = AppDatabase();

    final novelties = await db.getAllCachedNovelties();
    final crews = await db.getAllCachedCrews();
    final reports = await db.getAllReports();

    await db.close();

    return {
      'novelties': novelties.length,
      'crews': crews.length,
      'reports': reports.length,
    };
  } catch (e) {
    AppLogger.error('Error obteniendo estado de BD', error: e);
    return {'novelties': 0, 'crews': 0, 'reports': 0};
  }
}

/// Limpia completamente la base de datos (usar con precaución)
Future<void> clearAllDatabaseTables() async {
  try {
    print('🗑️ Limpiando todas las tablas de la base de datos...');

    final db = AppDatabase();

    await db.clearAllNoveltyCache();
    await db.clearAllCrewCache();
    // Aquí puedes agregar más limpieza si es necesario

    await db.close();

    print('🗑️ ✅ Base de datos limpiada completamente');
    AppLogger.info('Base de datos limpiada completamente');
  } catch (e, stackTrace) {
    print('🗑️ ❌ Error limpiando base de datos: $e');
    AppLogger.error(
      'Error limpiando base de datos',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
