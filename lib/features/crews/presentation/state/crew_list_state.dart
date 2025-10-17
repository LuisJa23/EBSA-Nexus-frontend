// crew_list_state.dart
//
// Estado para lista de cuadrillas
//
// PROPÓSITO:
// - Gestionar estado de la lista de cuadrillas
//
// CAPA: PRESENTATION LAYER

import 'package:equatable/equatable.dart';
import '../../domain/entities/crew.dart';

/// Estado de la lista de cuadrillas
class CrewListState extends Equatable {
  final bool isLoading;
  final List<Crew> crews;
  final String? errorMessage;

  const CrewListState({
    this.isLoading = false,
    this.crews = const [],
    this.errorMessage,
  });

  CrewListState copyWith({
    bool? isLoading,
    List<Crew>? crews,
    String? errorMessage,
  }) {
    return CrewListState(
      isLoading: isLoading ?? this.isLoading,
      crews: crews ?? this.crews,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, crews, errorMessage];
}
