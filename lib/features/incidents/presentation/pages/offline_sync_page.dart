// offline_sync_page.dart
//
// Página para sincronizar novedades creadas offline
//
// PROPÓSITO:
// - Mostrar lista de novedades creadas offline pendientes de sincronizar
// - Permitir sincronización manual de novedades con el servidor
// - Mostrar estado de sincronización
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/database/app_database.dart';
import '../../../../config/database/database_provider.dart';
import '../../data/offline_sync_service.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;

/// Página para gestionar sincronización de novedades offline
class OfflineSyncPage extends ConsumerStatefulWidget {
  const OfflineSyncPage({super.key});

  @override
  ConsumerState<OfflineSyncPage> createState() => _OfflineSyncPageState();
}

class _OfflineSyncPageState extends ConsumerState<OfflineSyncPage> {
  OfflineSyncService? _syncService;
  List<NoveltyCacheTableData> _offlineNovelties = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  // Mapeo de IDs a nombres de áreas
  final Map<int, String> _areaNames = {
    1: 'FACTURACIÓN',
    2: 'CARTERA',
    3: 'PÉRDIDAS',
  };

  @override
  void initState() {
    super.initState();
    _initService();
  }

  /// Inicializa el servicio de sincronización
  Future<void> _initService() async {
    try {
      _syncService = di.sl<OfflineSyncService>();
      await _loadOfflineNovelties();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(
          'Error al inicializar',
          'No se pudo cargar el servicio de sincronización: $e',
        );
      }
    }
  }

  /// Carga las novedades offline pendientes
  Future<void> _loadOfflineNovelties() async {
    if (_syncService == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final novelties = await _syncService!.getPendingOfflineNovelties();
      setState(() {
        _offlineNovelties = novelties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Error al cargar novedades offline', e.toString());
      }
    }
  }

  /// Sincroniza todas las novedades offline
  Future<void> _syncAllNovelties() async {
    print('🔵 === INICIO SINCRONIZACIÓN ===');
    print('🔵 Servicio disponible: ${_syncService != null}');
    print('🔵 Cantidad de novedades: ${_offlineNovelties.length}');

    if (_syncService == null) {
      print('❌ Servicio NO disponible');
      _showErrorDialog('Error', 'Servicio no disponible');
      return;
    }

    if (_offlineNovelties.isEmpty) {
      print('⚠️ Lista vacía');
      _showInfoDialog('No hay novedades offline para sincronizar');
      return;
    }

    // Cargar reportes pendientes para mostrar información
    final db = ref.read(databaseProvider);
    final pendingReports = await db.getPendingSyncReports();
    final reportsWithOfflineNovelties = pendingReports
        .where((report) => report.noveltyId < 0)
        .length;

    // Confirmar acción
    print('🔵 Mostrando confirmación...');
    String confirmMessage =
        'Se intentarán sincronizar ${_offlineNovelties.length} novedad(es) con el servidor.';

    if (pendingReports.isNotEmpty) {
      confirmMessage +=
          '\n\nTambién hay ${pendingReports.length} reporte(s) pendiente(s):';
      if (reportsWithOfflineNovelties > 0) {
        confirmMessage +=
            '\n• $reportsWithOfflineNovelties vinculado(s) a novedades offline (se sincronizarán después)';
      }
      if (pendingReports.length - reportsWithOfflineNovelties > 0) {
        confirmMessage +=
            '\n• ${pendingReports.length - reportsWithOfflineNovelties} listo(s) para sincronizar';
      }
    }

    final confirmed = await _showConfirmDialog(
      '¿Sincronizar todo el contenido offline?',
      confirmMessage,
    );

    print('🔵 Usuario confirmó: $confirmed');
    if (!confirmed) {
      print('❌ Usuario canceló');
      return;
    }

    setState(() => _isSyncing = true);
    print('🔵 Estado cambiado a sincronizando...');

    try {
      // PASO 1: Sincronizar novedades primero
      print('🔵 PASO 1: Sincronizando novedades...');
      final noveltiesResult = await _syncService!.syncAllOfflineNovelties();
      print('🔵 Resultado novedades: $noveltiesResult');

      // PASO 2: Sincronizar reportes (solo los que tengan noveltyId > 0)
      print('🔵 PASO 2: Sincronizando reportes...');
      final reportsResult = await _syncService!.syncAllOfflineReports();
      print('🔵 Resultado reportes: $reportsResult');

      setState(() => _isSyncing = false);

      final noveltiesSuccess = noveltiesResult['success'] as int;
      final noveltiesFailed = noveltiesResult['failed'] as int;
      final reportsSuccess = reportsResult['success'] as int;
      final reportsFailed = reportsResult['failed'] as int;

      final noveltiesErrors = noveltiesResult['errors'] as List<String>;
      final reportsErrors = reportsResult['errors'] as List<String>;

      // Recargar lista
      await _loadOfflineNovelties();

      // Construir mensaje de resultado
      String resultMessage = '';
      bool hasErrors = noveltiesFailed > 0 || reportsFailed > 0;

      if (noveltiesSuccess > 0) {
        resultMessage += '✅ Novedades sincronizadas: $noveltiesSuccess\n';
      }
      if (noveltiesFailed > 0) {
        resultMessage += '❌ Novedades fallidas: $noveltiesFailed\n';
      }
      if (reportsSuccess > 0) {
        resultMessage += '✅ Reportes sincronizados: $reportsSuccess\n';
      }
      if (reportsFailed > 0) {
        resultMessage += '❌ Reportes fallidos: $reportsFailed\n';
      }

      // Mostrar resultado
      if (!hasErrors) {
        _showSuccessDialog('Sincronización completada', resultMessage.trim());
      } else {
        final errorMessages = <String>[];
        if (noveltiesErrors.isNotEmpty) {
          errorMessages.add(
            'Novedades:\n${noveltiesErrors.take(3).join('\n')}',
          );
          if (noveltiesErrors.length > 3) {
            errorMessages.add('... y ${noveltiesErrors.length - 3} más');
          }
        }
        if (reportsErrors.isNotEmpty) {
          errorMessages.add('Reportes:\n${reportsErrors.take(3).join('\n')}');
          if (reportsErrors.length > 3) {
            errorMessages.add('... y ${reportsErrors.length - 3} más');
          }
        }

        _showErrorDialog(
          'Sincronización parcial',
          '$resultMessage\nPrimeros errores:\n${errorMessages.join('\n\n')}',
        );
      }
    } catch (e) {
      setState(() => _isSyncing = false);
      _showErrorDialog('Error en sincronización', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronizar Contenido Offline'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSyncing
          ? _buildSyncingView()
          : _offlineNovelties.isEmpty
          ? _buildEmptyView()
          : _buildNoveltyList(),
      floatingActionButton: _offlineNovelties.isNotEmpty && !_isSyncing
          ? FloatingActionButton.extended(
              onPressed: _syncAllNovelties,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Sincronizar Todo'),
            )
          : null,
    );
  }

  /// Vista cuando está sincronizando
  Widget _buildSyncingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Sincronizando novedades...', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Por favor espera',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Vista cuando no hay novedades offline
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay novedades offline',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Todas las novedades están sincronizadas con el servidor',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOfflineNovelties,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de novedades offline
  Widget _buildNoveltyList() {
    return Column(
      children: [
        // Header con información
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.warning.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_off, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Novedades Offline',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_offlineNovelties.length} novedad(es) esperando sincronización',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Lista de novedades
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOfflineNovelties,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offlineNovelties.length,
              itemBuilder: (context, index) {
                final novelty = _offlineNovelties[index];
                return _buildNoveltyCard(novelty);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Card de novedad offline
  Widget _buildNoveltyCard(NoveltyCacheTableData novelty) {
    final areaName = _areaNames[novelty.areaId] ?? 'Área ${novelty.areaId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con área y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, size: 20, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          areaName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OFFLINE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Información de la novedad
            _buildInfoRow('Motivo', novelty.reason),
            _buildInfoRow('Cuenta', novelty.accountNumber),
            _buildInfoRow('Medidor', novelty.meterNumber),
            _buildInfoRow('Municipio', novelty.municipality),
            _buildInfoRow('Dirección', novelty.address),
            if (novelty.description.isNotEmpty)
              _buildInfoRow('Descripción', novelty.description),
            const SizedBox(height: 8),
            Text(
              'Creada: ${_formatDate(novelty.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  /// Formatea fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Diálogos

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.info),
            const SizedBox(width: 8),
            const Text('Información'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
