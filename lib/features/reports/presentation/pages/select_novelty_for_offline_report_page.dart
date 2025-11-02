// select_novelty_for_offline_report_page.dart
//
// Página para seleccionar novedad para crear reporte offline
//
// PROPÓSITO:
// - Permitir seleccionar una novedad (online o caché) para crear reporte offline
// - Mostrar novedades del servidor (EN_CURSO) y novedades en caché
// - Navegar a la página de crear reporte offline con el ID seleccionado
//
// CAPA: PRESENTATION LAYER

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../config/database/database_provider.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../incidents/data/offline_sync_service.dart';
import '../../../incidents/presentation/providers/assignments_provider.dart';

/// Página para seleccionar novedad para crear reporte offline
class SelectNoveltyForOfflineReportPage extends ConsumerStatefulWidget {
  const SelectNoveltyForOfflineReportPage({super.key});

  @override
  ConsumerState<SelectNoveltyForOfflineReportPage> createState() =>
      _SelectNoveltyForOfflineReportPageState();
}

class _SelectNoveltyForOfflineReportPageState
    extends ConsumerState<SelectNoveltyForOfflineReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _cachedNovelties = [];
  bool _isLoadingCache = true;
  String? _cacheError;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOnlineNovelties();
      _loadCachedNovelties();
      _cacheEnCursoNovelties(); // Cachear novedades EN_CURSO para reportes offline
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOnlineNovelties() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId != null) {
      ref.read(assignmentsProvider.notifier).loadUserNovelties(userId);
    }
  }

  /// Cachea novedades EN_CURSO del servidor para reportes offline
  Future<void> _cacheEnCursoNovelties() async {
    print('🔵 === INICIO _cacheEnCursoNovelties ===');

    // Mostrar loading
    setState(() {
      _isLoadingCache = true;
      _cacheError = null;
    });

    try {
      print('📥 Verificando conexión...');

      // Verificar si hay conexión
      final hasConnection = await _checkInternetConnection();
      print('📡 Conexión: ${hasConnection ? "SÍ" : "NO"}');

      if (!hasConnection) {
        print('⚠️ Sin conexión - mostrando solo novedades ya cacheadas');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Sin conexión a internet'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Sin conexión, solo cargar las que ya están en caché
        await _loadCachedNovelties();
        return;
      }

      print('✅ Hay conexión - intentando cachear novedades...');

      // NUEVA ESTRATEGIA: Usar las novedades ya cargadas en el provider
      // en lugar de hacer una nueva llamada al servidor

      // Capturar providers ANTES de operaciones asíncronas
      final assignmentsNotifier = ref.read(assignmentsProvider.notifier);
      final authState = ref.read(authNotifierProvider);

      final assignmentsState = ref.read(assignmentsProvider);

      print('� Novedades en provider: ${assignmentsState.novelties.length}');

      // Si no hay novedades cargadas, cargar primero
      if (assignmentsState.novelties.isEmpty) {
        print('⚠️ No hay novedades en provider, cargando primero...');

        final userId = authState.user?.id;

        if (userId == null) {
          throw Exception('Usuario no autenticado');
        }

        // Cargar novedades del usuario
        await assignmentsNotifier.loadUserNovelties(userId);

        // Obtener el estado actualizado
        final updatedState = ref.read(assignmentsProvider);
        print('📋 Novedades cargadas: ${updatedState.novelties.length}');

        if (updatedState.hasError) {
          throw Exception(
            updatedState.errorMessage ?? 'Error cargando novedades',
          );
        }
      }

      // Ahora cachear las novedades EN_CURSO con cuadrilla asignada
      final state = ref.read(assignmentsProvider);
      final enCursoNovelties = state.novelties
          .where((n) => n.status == 'EN_CURSO' && n.crewId != null)
          .toList();

      print('📋 Novedades EN_CURSO con cuadrilla: ${enCursoNovelties.length}');

      if (enCursoNovelties.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ No hay novedades EN_CURSO para cachear'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        await _loadCachedNovelties();
        return;
      }

      // Cachear cada novedad
      final db = ref.read(databaseProvider);
      final offlineSyncService = sl<OfflineSyncService>();
      int cachedCount = 0;

      for (final novelty in enCursoNovelties) {
        try {
          print('📦 Cacheando novedad ${novelty.id}...');

          // Convertir novedad a Map para guardar como JSON completo
          final noveltyJson = {
            'id': novelty.id,
            'areaId': novelty.areaId,
            'reason': novelty.reason,
            'accountNumber': novelty.accountNumber,
            'meterNumber': novelty.meterNumber,
            'activeReading': novelty.activeReading,
            'reactiveReading': novelty.reactiveReading,
            'municipality': novelty.municipality,
            'address': novelty.address,
            'description': novelty.description,
            'observations': novelty.observations,
            'status': novelty.status,
            'createdBy': novelty.createdBy,
            'crewId': novelty.crewId,
            'createdAt': novelty.createdAt.toIso8601String(),
            'updatedAt': novelty.updatedAt.toIso8601String(),
            'completedAt': novelty.completedAt?.toIso8601String(),
            'closedAt': novelty.closedAt?.toIso8601String(),
            'cancelledAt': novelty.cancelledAt?.toIso8601String(),
            'from_server': true,
            'cached_for_offline_reports': true,
            'cached_at': DateTime.now().toIso8601String(),
          };

          await db.upsertNoveltyCache(
            NoveltyCacheTableCompanion(
              noveltyId: drift.Value(novelty.id),
              areaId: drift.Value(novelty.areaId),
              reason: drift.Value(novelty.reason),
              accountNumber: drift.Value(novelty.accountNumber),
              meterNumber: drift.Value(novelty.meterNumber),
              activeReading: drift.Value(novelty.activeReading),
              reactiveReading: drift.Value(novelty.reactiveReading),
              municipality: drift.Value(novelty.municipality),
              address: drift.Value(novelty.address),
              description: drift.Value(novelty.description),
              observations: drift.Value(novelty.observations),
              status: drift.Value(novelty.status),
              createdBy: drift.Value(novelty.createdBy),
              crewId: drift.Value(novelty.crewId),
              createdAt: drift.Value(novelty.createdAt),
              updatedAt: drift.Value(novelty.updatedAt),
              completedAt: novelty.completedAt != null
                  ? drift.Value(novelty.completedAt!)
                  : const drift.Value.absent(),
              closedAt: novelty.closedAt != null
                  ? drift.Value(novelty.closedAt!)
                  : const drift.Value.absent(),
              cancelledAt: novelty.cancelledAt != null
                  ? drift.Value(novelty.cancelledAt!)
                  : const drift.Value.absent(),
              cachedAt: drift.Value(DateTime.now()),
              rawJson: drift.Value(jsonEncode(noveltyJson)), // ✅ JSON COMPLETO
            ),
          );

          print('✅ Novedad ${novelty.id} cacheada en BD');

          // Si tiene cuadrilla, cachearla también con sus miembros
          if (novelty.crewId != null) {
            print(
              '👥 Novedad tiene crewId: ${novelty.crewId}, cacheando cuadrilla...',
            );
            try {
              await offlineSyncService.cacheCrewWithMembers(novelty.crewId!);
              print('✅ Cuadrilla ${novelty.crewId} cacheada con miembros');
            } catch (e) {
              print('⚠️ Error cacheando cuadrilla ${novelty.crewId}: $e');
              // No fallar todo el proceso por esto
            }
          }

          cachedCount++;
          print('✅ Novedad ${novelty.id} completamente cacheada');
        } catch (e) {
          print('❌ Error cacheando novedad ${novelty.id}: $e');
        }
      }

      print('✅ Total cacheadas: $cachedCount novedades');

      // Mostrar mensaje al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cacheadas $cachedCount novedad(es)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Recargar lista de caché para mostrar las nuevas
      print('🔄 Recargando lista de caché...');
      await _loadCachedNovelties();
      print('✅ Lista recargada');
    } catch (e, stackTrace) {
      print('❌ Error cacheando novedades EN_CURSO: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Aún con error, intentamos cargar las que están en caché
      await _loadCachedNovelties();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCache = false;
        });
      }
    }

    print('🔵 === FIN _cacheEnCursoNovelties ===');
  }

  Future<void> _loadCachedNovelties() async {
    print('🔵 === INICIO _loadCachedNovelties ===');

    setState(() {
      _isLoadingCache = true;
      _cacheError = null;
    });

    try {
      final db = ref.read(databaseProvider);
      print('🔵 Obteniendo novedades de BD...');
      final novelties = await db.getAllCachedNovelties();
      print('🔵 Total novedades en BD: ${novelties.length}');

      // Debug: mostrar todas las novedades
      for (var i = 0; i < novelties.length; i++) {
        final nov = novelties[i];
        print('');
        print('📄 Novedad ${i + 1}/${novelties.length}:');
        print('  - ID: ${nov.noveltyId}');
        print('  - Status: ${nov.status}');
        print('  - CrewId: ${nov.crewId}');
        print('  - Cuenta: ${nov.accountNumber}');
        print('  - Cached: ${nov.cachedAt}');
      }

      setState(() {
        _cachedNovelties = novelties;
        _isLoadingCache = false;
      });

      print('✅ Lista actualizada con ${novelties.length} novedades');
    } catch (e, stackTrace) {
      print('❌ Error en _loadCachedNovelties: $e');
      print('Stack: $stackTrace');

      setState(() {
        _cacheError = 'Error al cargar novedades: $e';
        _isLoadingCache = false;
      });
    }

    print('🔵 === FIN _loadCachedNovelties ===');
  }

  Future<void> _handleRefresh() async {
    // Capturar providers ANTES de cualquier operación asíncrona
    final authState = ref.read(authNotifierProvider);
    final notifier = ref.read(assignmentsProvider.notifier);
    final userId = authState.user?.id;

    if (userId != null) {
      await notifier.refreshNovelties(userId);
    }
    await _loadCachedNovelties();
  }

  void _onNoveltySelected(String noveltyId, bool isFromCache) async {
    print('🎯 === NOVEDAD SELECCIONADA ===');
    print('🎯 noveltyId: $noveltyId');
    print('🎯 isFromCache: $isFromCache');

    // Verificar conexión a internet
    final hasConnection = await _checkInternetConnection();
    print('🎯 hasConnection: $hasConnection');

    if (hasConnection && !isFromCache) {
      // Tiene conexión y la novedad es del servidor -> ir a reporte ONLINE
      print('🎯 Navegando a reporte ONLINE: /novelty-report/$noveltyId');
      if (mounted) {
        context.push('/novelty-report/$noveltyId');
      }
    } else {
      // Sin conexión o novedad de caché -> ir a reporte OFFLINE
      print(
        '🎯 Navegando a reporte OFFLINE: /reports/offline/create/$noveltyId',
      );
      if (mounted) {
        context.push('/reports/offline/create/$noveltyId');
      }
    }

    print('🎯 === FIN NOVEDAD SELECCIONADA ===');
  }

  /// Verifica si hay conexión a internet
  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error verificando conexión: $e');
      return false; // Asumir sin conexión si hay error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Novedad'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.cloud_queue), text: 'Del Servidor'),
            Tab(icon: Icon(Icons.cloud_off), text: 'En Caché'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOnlineNoveltiesTab(), _buildCachedNoveltiesTab()],
      ),
    );
  }

  Widget _buildOnlineNoveltiesTab() {
    final state = ref.watch(assignmentsProvider);

    if (state.isLoading) {
      return const LoadingIndicator(
        message: 'Cargando novedades del servidor...',
      );
    }

    if (state.hasError) {
      return _buildErrorView(
        state.errorMessage ?? 'Error desconocido',
        _loadOnlineNovelties,
      );
    }

    // Filtrar solo novedades EN_CURSO con cuadrilla asignada
    final enCursoNovelties = state.novelties
        .where(
          (novelty) => novelty.status == 'EN_CURSO' && novelty.crewId != null,
        )
        .toList();

    if (enCursoNovelties.isEmpty) {
      return _buildEmptyState(
        'Sin Novedades Disponibles',
        'No tienes novedades EN_CURSO con cuadrilla asignada.\n\nSolo puedes reportar sobre novedades que tengan una cuadrilla asignada.',
        Icons.assignment_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enCursoNovelties.length,
        itemBuilder: (context, index) {
          final novelty = enCursoNovelties[index];
          return _buildNoveltyCard(
            accountNumber: novelty.accountNumber,
            areaName: novelty.areaName,
            reason: novelty.reason,
            municipality: novelty.municipality,
            status: novelty.status,
            onTap: () => _onNoveltySelected(novelty.id.toString(), false),
            isFromCache: false,
          );
        },
      ),
    );
  }

  Widget _buildCachedNoveltiesTab() {
    if (_isLoadingCache) {
      return const LoadingIndicator(message: 'Cargando novedades en caché...');
    }

    if (_cacheError != null) {
      return _buildErrorView(_cacheError!, _loadCachedNovelties);
    }

    print('🟡 === INICIO _buildCachedNoveltiesTab ===');
    print('🟡 Total novedades en _cachedNovelties: ${_cachedNovelties.length}');

    // Filtrar:
    // 1. Solo novedades EN_CURSO con cuadrilla asignada
    // 2. Excluir novedades offline (ID negativo)
    final validCachedNovelties = _cachedNovelties.where((novelty) {
      final isEnCurso = novelty.status == 'EN_CURSO';
      final hasCrewAssigned = novelty.crewId != null;
      final isNotOffline = novelty.noveltyId > 0; // Excluir ID negativos

      print('');
      print('🟡 Evaluando novedad ${novelty.noveltyId}:');
      print('  - Status: ${novelty.status} (EN_CURSO: $isEnCurso)');
      print('  - CrewId: ${novelty.crewId} (Assigned: $hasCrewAssigned)');
      print('  - ID: ${novelty.noveltyId} (Not offline: $isNotOffline)');
      print('  - Incluir: ${isEnCurso && hasCrewAssigned && isNotOffline}');

      return isEnCurso && hasCrewAssigned && isNotOffline;
    }).toList();

    print('🟡 Total novedades válidas: ${validCachedNovelties.length}');
    print('🟡 === FIN _buildCachedNoveltiesTab ===');

    if (validCachedNovelties.isEmpty) {
      return Column(
        children: [
          // Banner con botón de cachear
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Presiona el botón para cachear novedades',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _cacheEnCursoNovelties();
                  },
                  icon: const Icon(Icons.cloud_download, size: 18),
                  label: const Text('Cachear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildEmptyState(
              'Sin Novedades en Caché',
              'No hay novedades EN_CURSO cacheadas todavía.\n\nPara cachear novedades:\n1. Conéctate a internet\n2. Presiona "Cachear" arriba\n3. Las novedades se guardarán para uso offline',
              Icons.cloud_off,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Banner informativo con contador y botón
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${validCachedNovelties.length} novedad(es) disponible(s) offline',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _cacheEnCursoNovelties();
                },
                icon: Icon(Icons.refresh, color: Colors.blue.shade700),
                tooltip: 'Actualizar caché',
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cacheEnCursoNovelties,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validCachedNovelties.length,
              itemBuilder: (context, index) {
                final novelty = validCachedNovelties[index];
                final areaName =
                    _areaNames[novelty.areaId] ?? 'Área ${novelty.areaId}';
                return _buildNoveltyCard(
                  accountNumber: novelty.accountNumber ?? 'N/A',
                  areaName: areaName,
                  reason: novelty.reason ?? 'N/A',
                  municipality: novelty.municipality ?? 'N/A',
                  status: novelty.status ?? 'DESCONOCIDO',
                  onTap: () =>
                      _onNoveltySelected(novelty.noveltyId.toString(), true),
                  isFromCache: true,
                  cachedAt: novelty.cachedAt,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoveltyCard({
    required String accountNumber,
    required String areaName,
    required String reason,
    required String municipality,
    required String status,
    required VoidCallback onTap,
    required bool isFromCache,
    DateTime? cachedAt,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      'Cuenta: $accountNumber',
                      style: AppTextStyles.heading4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.business, 'Área', areaName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.assignment, 'Motivo', reason),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_city, 'Municipio', municipality),
              if (isFromCache && cachedAt != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'En caché desde: ${DateFormat('dd/MM/yyyy HH:mm').format(cachedAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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

  Widget _buildErrorView(String message, VoidCallback onRetry) {
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

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              title,
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
          ],
        ),
      ),
    );
  }
}
