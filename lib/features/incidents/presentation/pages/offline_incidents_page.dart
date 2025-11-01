// offline_incidents_page.dart
//
// Página para gestionar contenido offline pendiente de sincronización
//
// PROPÓSITO:
// - Mostrar novedades y reportes creados offline (pendientes de sincronizar)
// - Permitir acceso rápido a la página de sincronización manual
// - Gestionar contenido creado sin conexión
//
// CAPA: PRESENTATION LAYER

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/database/database_provider.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/offline_sync_service.dart';
import 'offline_sync_page.dart';

/// Página para gestionar contenido offline pendiente de sincronización
class OfflineIncidentsPage extends ConsumerStatefulWidget {
  const OfflineIncidentsPage({super.key});

  @override
  ConsumerState<OfflineIncidentsPage> createState() =>
      _OfflineIncidentsPageState();
}

class _OfflineIncidentsPageState extends ConsumerState<OfflineIncidentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  bool _isLoadingReports = true;
  List<dynamic> _offlineNovelties = [];
  List<ReportTableData> _offlineReports = [];
  String? _errorMessage;
  String? _reportsErrorMessage;
  OfflineSyncService? _syncService;

  // Mapeo de IDs de área a nombres
  final Map<int, String> _areaNames = {
    1: 'FACTURACIÓN',
    2: 'CARTERA',
    3: 'PÉRDIDAS',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Inicializa el servicio de sincronización
  Future<void> _initService() async {
    try {
      _syncService = di.sl<OfflineSyncService>();
      await Future.wait([_loadOfflineNovelties(), _loadOfflineReports()]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al inicializar servicio: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Carga SOLO las novedades creadas offline (pendientes de sincronizar)
  Future<void> _loadOfflineNovelties() async {
    print('🟦 === INICIO _loadOfflineNovelties ===');

    if (_syncService == null) {
      print('❌ _syncService es null');
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🟦 Llamando a getPendingOfflineNovelties()...');
      // Obtener SOLO las novedades offline (ID negativo + created_offline)
      final novelties = await _syncService!.getPendingOfflineNovelties();
      print('🟦 Novedades recibidas: ${novelties.length}');

      // Debug: mostrar detalles de cada novedad recibida
      for (var i = 0; i < novelties.length; i++) {
        final nov = novelties[i];
        print('🟦 Novedad $i recibida en página:');
        print('  - ID: ${nov.noveltyId}');
        print('  - Cuenta: ${nov.accountNumber}');
        print('  - Status: ${nov.status}');
      }

      if (mounted) {
        setState(() {
          _offlineNovelties = novelties;
          _isLoading = false;
        });
        print('✅ Estado actualizado con ${novelties.length} novedades');
        print('✅ _offlineNovelties.length = ${_offlineNovelties.length}');
      } else {
        print('⚠️ Widget no mounted, no se actualiza estado');
      }
    } catch (e, stackTrace) {
      print('❌ Error en _loadOfflineNovelties: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar novedades offline: $e';
          _isLoading = false;
        });
      }
    }

    print('🟦 === FIN _loadOfflineNovelties ===');
  }

  /// Carga los reportes offline pendientes de sincronización
  Future<void> _loadOfflineReports() async {
    print('🟦 === INICIO _loadOfflineReports ===');

    setState(() {
      _isLoadingReports = true;
      _reportsErrorMessage = null;
    });

    try {
      final db = ref.read(databaseProvider);
      print('🟦 Llamando a getPendingSyncReports()...');

      // Obtener SOLO los reportes no sincronizados
      final reports = await db.getPendingSyncReports();
      print('🟦 Reportes recibidos: ${reports.length}');

      // Debug: mostrar detalles de cada reporte
      for (var i = 0; i < reports.length; i++) {
        final report = reports[i];
        print('🟦 Reporte $i:');
        print('  - ID: ${report.id}');
        print('  - NoveltyID: ${report.noveltyId}');
        print('  - CreatedAt: ${report.createdAt}');
        print('  - IsSynced: ${report.isSynced}');
      }

      if (mounted) {
        setState(() {
          _offlineReports = reports;
          _isLoadingReports = false;
        });
        print('✅ Estado actualizado con ${reports.length} reportes');
      }
    } catch (e, stackTrace) {
      print('❌ Error en _loadOfflineReports: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        setState(() {
          _reportsErrorMessage = 'Error al cargar reportes offline: $e';
          _isLoadingReports = false;
        });
      }
    }

    print('🟦 === FIN _loadOfflineReports ===');
  }

  @override
  Widget build(BuildContext context) {
    print('🟦 BUILD - Estado actual:');
    print('  - _isLoading: $_isLoading');
    print('  - _errorMessage: $_errorMessage');
    print('  - _offlineNovelties.length: ${_offlineNovelties.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido Offline'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Novedades (${_offlineNovelties.length})',
              icon: const Icon(Icons.report_problem, size: 20),
            ),
            Tab(
              text: 'Reportes (${_offlineReports.length})',
              icon: const Icon(Icons.description, size: 20),
            ),
          ],
        ),
        actions: [
          if (_offlineNovelties.isNotEmpty || _offlineReports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cloud_sync),
              onPressed: () async {
                // Navegar a página de sincronización
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OfflineSyncPage(),
                  ),
                );
                // Recargar listas después de sincronizar
                _loadOfflineNovelties();
                _loadOfflineReports();
              },
              tooltip: 'Sincronizar contenido offline',
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNoveltiesTab(), _buildReportsTab()],
      ),
    );
  }

  Widget _buildNoveltiesTab() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Cargando novedades offline...');
    }

    if (_errorMessage != null) {
      return _buildErrorView(
        message: _errorMessage!,
        onRetry: _loadOfflineNovelties,
      );
    }

    if (_offlineNovelties.isEmpty) {
      return _buildEmptyState(
        type: 'novedades',
        onRefresh: _loadOfflineNovelties,
      );
    }

    return _buildNoveltyList();
  }

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const LoadingIndicator(message: 'Cargando reportes offline...');
    }

    if (_reportsErrorMessage != null) {
      return _buildErrorView(
        message: _reportsErrorMessage!,
        onRetry: _loadOfflineReports,
      );
    }

    if (_offlineReports.isEmpty) {
      return _buildEmptyState(type: 'reportes', onRefresh: _loadOfflineReports);
    }

    return _buildReportsList();
  }

  Widget _buildErrorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String type,
    required VoidCallback onRefresh,
  }) {
    final isNovelties = type == 'novedades';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              isNovelties ? 'Sin Novedades Offline' : 'Sin Reportes Offline',
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isNovelties
                  ? 'No hay novedades creadas sin conexión pendientes de sincronizar.\n\nLas novedades se guardarán aquí automáticamente cuando crees una sin conexión a internet.'
                  : 'No hay reportes creados sin conexión pendientes de sincronizar.\n\nLos reportes se guardarán aquí automáticamente cuando crees uno sin conexión a internet.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoveltyList() {
    return RefreshIndicator(
      onRefresh: _loadOfflineNovelties,
      child: Column(
        children: [
          // Información del caché
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.warning.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mostrando ${_offlineNovelties.length} novedad(es) pendiente(s) de sincronizar',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de novedades
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offlineNovelties.length,
              itemBuilder: (context, index) {
                final novelty = _offlineNovelties[index];
                return _buildNoveltyCard(novelty);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadOfflineReports,
      child: Column(
        children: [
          // Información del caché
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.info.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mostrando ${_offlineReports.length} reporte(s) pendiente(s) de sincronizar',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de reportes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offlineReports.length,
              itemBuilder: (context, index) {
                final report = _offlineReports[index];
                return _buildReportCard(report);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    // Parse participant count from JSON array
    int participantCount = 0;
    try {
      if (report.participantIds != null && report.participantIds.isNotEmpty) {
        final List<dynamic> ids = jsonDecode(report.participantIds);
        participantCount = ids.length;
      }
    } catch (e) {
      print('Error parsing participant IDs: $e');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Reporte #${report.id.substring(0, 8)}...',
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 14, color: AppColors.info),
                      const SizedBox(width: 4),
                      Text(
                        'OFFLINE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.description,
              'Descripción',
              report.workDescription,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.category,
              'Novedad ID',
              report.noveltyId.toString(),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.people,
              'Participantes',
              participantCount.toString(),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.timer, 'Tiempo', '${report.workTime} minutos'),
            if (report.observations != null &&
                report.observations!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.notes, 'Observaciones', report.observations!),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este reporte fue creado sin conexión. Presiona el botón de sincronización arriba para subirlo al servidor.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoveltyCard(dynamic novelty) {
    final areaName = _areaNames[novelty.areaId] ?? 'Área ${novelty.areaId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Cuenta: ${novelty.accountNumber ?? 'N/A'}',
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'OFFLINE',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(novelty.status ?? 'PENDIENTE'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business, 'Área', areaName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.assignment, 'Motivo', novelty.reason ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_city,
              'Municipio',
              novelty.municipality ?? 'N/A',
            ),
            if (novelty.cachedAt != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(novelty.cachedAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta novedad fue creada sin conexión. Presiona el botón de sincronización arriba para subirla al servidor.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        label = 'Pendiente';
        break;
      case 'EN_CURSO':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        label = 'En Curso';
        break;
      case 'COMPLETADA':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        label = 'Completada';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
