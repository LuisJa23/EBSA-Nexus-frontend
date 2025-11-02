// cache_dependencies_usecase.dart
//
// Caso de uso para cachear dependencias
//
// PROPÓSITO:
// - Cachear novedades y cuadrillas para uso offline
// - Ejecutar en login para preparar datos locales
// - Permitir operación offline-first
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../repositories/report_repository.dart';

/// Caso de uso para cachear dependencias necesarias
///
/// Cachea novedades y cuadrillas en paralelo para uso offline.
/// Debe ejecutarse después de un login exitoso.
class CacheDependenciesUseCase {
  final ReportRepository repository;

  const CacheDependenciesUseCase(this.repository);

  /// Cachea novedades y cuadrillas en paralelo
  ///
  /// Proceso:
  /// 1. Verifica conectividad
  /// 2. Descarga novedades del servidor
  /// 3. Descarga cuadrillas del servidor
  /// 4. Guarda ambas en cache local
  ///
  /// Retorna:
  /// - [Right(void)]: Cache exitoso
  /// - [Left(NetworkFailure)]: Sin conexión
  /// - [Left(ServerFailure)]: Error del servidor
  Future<Either<Failure, void>> call() async {
    AppLogger.debug('🔄 Iniciando cache de dependencias...');

    // Cachear novedades y cuadrillas en paralelo
    final results = await Future.wait([
      repository.cacheNovelties(),
      repository.cacheCrews(),
    ]);

    // Verificar si alguna operación falló
    for (final result in results) {
      if (result.isLeft()) {
        // Extraer el failure
        return result.fold((failure) {
          AppLogger.warning('Error cacheando dependencias: ${failure.message}');
          return Left(failure);
        }, (_) => const Right(null));
      }
    }

    AppLogger.success('✅ Dependencias cacheadas exitosamente');
    return const Right(null);
  }
}
