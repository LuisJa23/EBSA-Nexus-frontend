// novelty_repository.dart
//
// Contrato de repositorio para novedades
//
// PROPÓSITO:
// - Definir operaciones para gestión de novedades
// - Abstracción entre capa de datos y dominio
//
// CAPA: DOMAIN LAYER - REPOSITORIES

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/novelty.dart';

/// Parámetros de filtro para consulta de novedades
class NoveltyFilters {
  final int page;
  final int size;
  final String? sort;
  final String? direction;
  final NoveltyStatus? status;
  final NoveltyPriority? priority;
  final int? areaId;
  final int? crewId;
  final int? creatorId;
  final DateTime? startDate;
  final DateTime? endDate;

  const NoveltyFilters({
    this.page = 0,
    this.size = 10,
    this.sort,
    this.direction,
    this.status,
    this.priority,
    this.areaId,
    this.crewId,
    this.creatorId,
    this.startDate,
    this.endDate,
  });

  NoveltyFilters copyWith({
    int? page,
    int? size,
    String? sort,
    String? direction,
    NoveltyStatus? status,
    NoveltyPriority? priority,
    int? areaId,
    int? crewId,
    int? creatorId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return NoveltyFilters(
      page: page ?? this.page,
      size: size ?? this.size,
      sort: sort ?? this.sort,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      areaId: areaId ?? this.areaId,
      crewId: crewId ?? this.crewId,
      creatorId: creatorId ?? this.creatorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Resultado paginado de novedades
class NoveltyPage {
  final List<Novelty> novelties;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  const NoveltyPage({
    required this.novelties,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });

  bool get hasMore => !isLast;
  int? get nextPage => hasMore ? currentPage + 1 : null;
}

/// Repositorio de novedades
abstract class NoveltyRepository {
  /// Obtiene lista paginada de novedades con filtros
  Future<Either<Failure, NoveltyPage>> getNovelties(NoveltyFilters filters);

  /// Obtiene una novedad por ID
  Future<Either<Failure, Novelty>> getNoveltyById(int id);
}
