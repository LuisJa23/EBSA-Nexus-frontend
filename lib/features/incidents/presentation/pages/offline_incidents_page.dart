// offline_incidents_page.dart
//
// Página para gestionar novedades creadas sin conexión
//
// PROPÓSITO:
// - Mostrar lista de novedades almacenadas localmente
// - Indicar estado de sincronización
// - Permitir reintento manual de sincronización
// - Eliminar novedades ya sincronizadas
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async' show TimeoutException;
import 'dart:io' show SocketException;

import '../../../../config/database/app_database.dart';
import '../../../../config/database/database_provider.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/offline_sync_service.dart';

/// Página para gestionar novedades offline
class OfflineIncidentsPage extends ConsumerStatefulWidget {
  const OfflineIncidentsPage({super.key});

  @override
  ConsumerState<OfflineIncidentsPage> createState() =>
      _OfflineIncidentsPageState();
}

class _OfflineIncidentsPageState extends ConsumerState<OfflineIncidentsPage> {
  bool _isLoading = true;
  List<OfflineIncidentData> _incidents = [];
  int _pendingCount = 0;
  int _errorCount = 0;
  int _syncedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      final incidents = await db.getAllOfflineIncidents();
      final pending = await db.countPendingIncidents();
      final errors = await db.countErrorIncidents();
      final synced = await db.countSyncedIncidents();

      setState(() {
        _incidents = incidents;
        _pendingCount = pending;
        _errorCount = errors;
        _syncedCount = synced;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar novedades: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _syncIncident(OfflineIncidentData incident) async {
    // Mostrar indicador de carga y guardar su contexto
    BuildContext? loadingDialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingDialogContext = dialogContext;
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sincronizando novedad...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Obtener servicio de sincronización
      final syncService = di.sl<OfflineSyncService>();

      // Sincronizar la novedad
      final success = await syncService.syncIncidentById(incident.id);

      // Cerrar SOLO el diálogo de carga usando su contexto
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Mostrar éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Novedad ${incident.accountNumber} sincronizada correctamente',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
        // Recargar lista
        await _loadIncidents();
      } else {
        // Mostrar error genérico
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al sincronizar la novedad. Intenta de nuevo más tarde.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        await _loadIncidents();
      }
    } on TimeoutException catch (_) {
      // Cerrar SOLO el diálogo de carga
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiempo de espera agotado. Verifica tu conexión.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    } on SocketException catch (_) {
      // Cerrar SOLO el diálogo de carga
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No hay conexión. Verifica tu red e inténtalo de nuevo.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    } catch (e) {
      // Cerrar SOLO el diálogo de carga usando su contexto
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    }
  }

  Future<void> _syncAllPending() async {
    final pendingIncidents = _incidents
        .where((i) => i.syncStatus == 'pending' || i.syncStatus == 'error')
        .toList();

    if (pendingIncidents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay novedades pendientes de sincronizar'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sincronizar Todas'),
        content: Text(
          '¿Deseas sincronizar ${pendingIncidents.length} novedad(es) pendiente(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar indicador de carga y guardar su contexto
    BuildContext? loadingDialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingDialogContext = dialogContext;
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Sincronizando ${pendingIncidents.length} novedad(es)...',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Obtener servicio de sincronización
      final syncService = di.sl<OfflineSyncService>();

      // Sincronizar todas las novedades
      final result = await syncService.syncAllPendingIncidents();

      // Cerrar SOLO el diálogo de carga usando su contexto
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar resultado
      final successCount = result['success'] as int;
      final failedCount = result['failed'] as int;
      final errorsList = result['errors'] as List<dynamic>;
      final errors = errorsList.map((e) => e.toString()).toList();

      if (mounted) {
        String message;
        Color backgroundColor;

        if (failedCount == 0) {
          message =
              '✅ Se sincronizaron correctamente $successCount novedad(es)';
          backgroundColor = AppColors.success;
        } else if (successCount == 0) {
          message = '❌ Error al sincronizar $failedCount novedad(es)';
          backgroundColor = AppColors.error;
        } else {
          message = '⚠️ $successCount exitosas, $failedCount fallidas';
          backgroundColor = AppColors.warning;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );

        // Mostrar errores detallados si hay
        if (errors.isNotEmpty) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Errores de sincronización'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: errors
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('• $e'),
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      }

      // Recargar lista
      await _loadIncidents();
    } on TimeoutException catch (_) {
      // Cerrar SOLO el diálogo de carga usando su contexto
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiempo de espera agotado. Verifica tu conexión.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    } on SocketException catch (_) {
      // Cerrar SOLO el diálogo de carga usando su contexto
      if (loadingDialogContext != null) {
        Navigator.of(loadingDialogContext!).pop();
      } else if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No hay conexión. Verifica tu red e inténtalo de nuevo.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    } catch (e) {
      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al sincronizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      await _loadIncidents();
    }
  }

  Future<void> _deleteIncident(OfflineIncidentData incident) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Novedad'),
        content: Text(
          '¿Estás seguro de eliminar la novedad ${incident.accountNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final db = ref.read(databaseProvider);
      await db.deleteOfflineIncident(incident.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Novedad eliminada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _loadIncidents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novedades Offline'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_pendingCount > 0 || _errorCount > 0)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _syncAllPending,
              tooltip: 'Sincronizar todo',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Cargando novedades...')
          : RefreshIndicator(
              onRefresh: _loadIncidents,
              child: _incidents.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        _buildStatisticsCard(),
                        Expanded(child: _buildIncidentsList()),
                      ],
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay novedades offline',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Las novedades creadas sin conexión aparecerán aquí',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pendientes',
                  _pendingCount,
                  Icons.pending,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Errores',
                  _errorCount,
                  Icons.error,
                  AppColors.error,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Sincronizadas',
                  _syncedCount,
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: AppTextStyles.heading2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIncidentsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _incidents.length,
      itemBuilder: (context, index) {
        final incident = _incidents[index];
        return _buildIncidentCard(incident);
      },
    );
  }

  Widget _buildIncidentCard(OfflineIncidentData incident) {
    final statusColor = _getStatusColor(incident.syncStatus);
    final statusIcon = _getStatusIcon(incident.syncStatus);
    final statusText = _getStatusText(incident.syncStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showIncidentDetails(incident),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(incident.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información principal
              _buildInfoRow(
                Icons.account_circle,
                'Cuenta',
                incident.accountNumber,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.speed, 'Medidor', incident.meterNumber),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_city,
                'Municipio',
                incident.municipio,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.category, 'Área', incident.area),

              // Mensaje de error si existe
              if (incident.errorMessage != null &&
                  incident.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          incident.errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (incident.syncStatus == 'pending' ||
                      incident.syncStatus == 'error')
                    TextButton.icon(
                      onPressed: () => _syncIncident(incident),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Reintentar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteIncident(incident),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'synced':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'synced':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'synced':
        return 'Sincronizada';
      case 'error':
        return 'Error';
      default:
        return 'Desconocido';
    }
  }

  void _showIncidentDetails(OfflineIncidentData incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(incident),
    );
  }

  Widget _buildDetailsSheet(OfflineIncidentData incident) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Detalles de Novedad',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('ID Local', incident.id),
                  _buildDetailItem('Cuenta', incident.accountNumber),
                  _buildDetailItem('Medidor', incident.meterNumber),
                  _buildDetailItem('Área', incident.area),
                  _buildDetailItem('Motivo', incident.motivo),
                  _buildDetailItem('Municipio', incident.municipio),
                  _buildDetailItem('Lectura Activa', incident.activeReading),
                  _buildDetailItem(
                    'Lectura Reactiva',
                    incident.reactiveReading,
                  ),
                  _buildDetailItem('Observaciones', incident.observations),
                  _buildDetailItem(
                    'Creada',
                    DateFormat(
                      'dd/MM/yyyy HH:mm:ss',
                    ).format(incident.createdAt),
                  ),
                  _buildDetailItem(
                    'Estado',
                    _getStatusText(incident.syncStatus),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteIncident(incident);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (incident.syncStatus == 'pending' ||
                    incident.syncStatus == 'error') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Sincronizar',
                      icon: Icons.sync,
                      onPressed: () {
                        Navigator.pop(context);
                        _syncIncident(incident);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
