// novelty_page_response.dart
//
// Modelo de respuesta paginada para novedades
//
// PROPÓSITO:
// - Mapear la respuesta JSON paginada del endpoint de novedades
// - Incluir metadatos de paginación
//
// CAPA: DATA LAYER - MODELS

import 'novelty_response.dart';

/// Modelo de respuesta paginada para novedades
class NoveltyPageResponse {
  final List<NoveltyResponse> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final bool empty;

  NoveltyPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.empty,
  });

  /// Crea una instancia desde JSON
  factory NoveltyPageResponse.fromJson(Map<String, dynamic> json) {
    // El backend devuelve "novelties" en lugar de "content"
    final noveltiesList =
        json['novelties'] as List<dynamic>? ??
        json['content'] as List<dynamic>?;

    return NoveltyPageResponse(
      content: (noveltiesList ?? [])
          .map((item) => NoveltyResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      size: json['pageSize'] as int? ?? json['size'] as int? ?? 20,
      number: json['currentPage'] as int? ?? json['number'] as int? ?? 0,
      first: json['first'] as bool? ?? (json['currentPage'] as int? ?? 0) == 0,
      last:
          json['last'] as bool? ??
          (json['currentPage'] as int? ?? 0) >=
              ((json['totalPages'] as int? ?? 1) - 1),
      empty: json['empty'] as bool? ?? (noveltiesList?.isEmpty ?? true),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'size': size,
      'number': number,
      'first': first,
      'last': last,
      'empty': empty,
    };
  }

  /// Verifica si hay más páginas disponibles
  bool get hasMore => !last;

  /// Obtiene el número de la siguiente página
  int? get nextPage => hasMore ? number + 1 : null;
}
