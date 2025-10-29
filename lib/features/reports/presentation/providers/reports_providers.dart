// reports_providers.dart
//
// Proveedores de estado para reportes
//
// PROPÓSITO:
// - Configurar providers de Riverpod para reportes
// - Inyectar dependencias para servicios de reportes
//
// CAPA: PRESENTATION LAYER - PROVIDERS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../incidents/data/novelty_service.dart';
import '../../../crews/data/datasources/crew_remote_datasource.dart';
import '../../data/services/novelty_report_service.dart';
import '../state/create_report_state.dart';
import './create_report_provider.dart';

/// Provider para el servicio de reportes
final noveltyReportServiceProvider = Provider<NoveltyReportService>((ref) {
  return sl<NoveltyReportService>();
});

/// Provider para el servicio de novedades
final noveltyServiceProvider = Provider<NoveltyService>((ref) {
  return sl<NoveltyService>();
});

/// Provider para el data source de crews
final crewDataSourceProvider = Provider<CrewRemoteDataSource>((ref) {
  return sl<CrewRemoteDataSource>();
});

/// Provider para crear reportes
final createReportProvider =
    StateNotifierProvider<CreateReportProvider, CreateReportState>((ref) {
      return CreateReportProvider(
        reportService: ref.watch(noveltyReportServiceProvider),
        crewDataSource: ref.watch(crewDataSourceProvider),
        noveltyService: ref.watch(noveltyServiceProvider),
      );
    });
