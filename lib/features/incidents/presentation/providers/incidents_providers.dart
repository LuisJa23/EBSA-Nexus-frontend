// incidents_providers.dart
//
// Configuración de providers para el módulo de incidentes/novedades
//
// PROPÓSITO:
// - Inicializar providers de Riverpod
// - Gestionar dependencias e inyección
//
// CAPA: PRESENTATION LAYER - PROVIDERS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/novelty_service.dart';
import '../../data/repositories/novelty_repository_impl.dart';
import '../../domain/repositories/novelty_repository.dart';
import '../../domain/usecases/get_novelties.dart';
import '../../domain/usecases/get_novelty_by_id.dart';
import 'novelty_list_provider.dart';

// ============================================================================
// PROVIDERS DE SERVICIOS E INFRAESTRUCTURA
// ============================================================================

/// Provider del cliente API (debe estar definido en core)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider del servicio de novedades
final noveltyServiceProvider = Provider<NoveltyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NoveltyService(apiClient);
});

// ============================================================================
// PROVIDERS DE REPOSITORIOS
// ============================================================================

/// Provider del repositorio de novedades
final noveltyRepositoryProvider = Provider<NoveltyRepository>((ref) {
  final noveltyService = ref.watch(noveltyServiceProvider);
  return NoveltyRepositoryImpl(noveltyService);
});

// ============================================================================
// PROVIDERS DE CASOS DE USO
// ============================================================================

/// Provider del caso de uso para obtener novedades
final getNoveltiesUseCaseProvider = Provider<GetNovelties>((ref) {
  final repository = ref.watch(noveltyRepositoryProvider);
  return GetNovelties(repository);
});

/// Provider del caso de uso para obtener novedad por ID
final getNoveltyByIdUseCaseProvider = Provider<GetNoveltyById>((ref) {
  final repository = ref.watch(noveltyRepositoryProvider);
  return GetNoveltyById(repository);
});

// ============================================================================
// PROVIDERS DE ESTADO (NOTIFIERS)
// ============================================================================

/// Provider de estado para la lista de novedades
final noveltyListProvider =
    StateNotifierProvider<NoveltyListNotifier, NoveltyListState>((ref) {
      final getNovelties = ref.watch(getNoveltiesUseCaseProvider);
      return NoveltyListNotifier(getNovelties);
    });
