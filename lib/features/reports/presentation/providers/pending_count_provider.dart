// pending_count_provider.dart
//
// Provider para contador de reportes pendientes
//
// PROPÓSITO:
// - Mostrar cantidad de reportes pendientes
// - Badge en UI con número de reportes
// - Auto-refresh cuando se crea o sincroniza un reporte
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../domain/usecases/get_pending_reports_count_usecase.dart';

/// Provider para obtener la cantidad de reportes pendientes
///
/// Retorna el número de reportes que aún no se han sincronizado.
/// Útil para mostrar badges en la UI.
final pendingCountProvider = FutureProvider<int>((ref) async {
  final useCase = sl<GetPendingReportsCountUseCase>();
  final result = await useCase();

  return result.fold(
    (failure) => 0, // Si falla, retornar 0
    (count) => count,
  );
});

/// Provider para forzar refresh del contador
///
/// Cambiar el valor de este provider fuerza la re-ejecución
/// del pendingCountProvider.
final pendingCountRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider que se auto-refresca cuando cambia el refresh trigger
final autoRefreshPendingCountProvider = FutureProvider<int>((ref) async {
  // Escuchar cambios en el refresh trigger
  ref.watch(pendingCountRefreshProvider);

  // Ejecutar el use case
  final useCase = sl<GetPendingReportsCountUseCase>();
  final result = await useCase();

  return result.fold((failure) => 0, (count) => count);
});
