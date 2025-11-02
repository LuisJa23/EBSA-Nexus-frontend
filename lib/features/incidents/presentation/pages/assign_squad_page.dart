// assign_squad_page.dart
//
// Página para asignar cuadrillas a novedades
//
// PROPÓSITO:
// - Asignar novedades a cuadrillas disponibles
// - Gestionar asignaciones de trabajo
// - Visualizar estado de asignaciones
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/novelty_model.dart';
import '../../data/novelty_service.dart';

/// Página para asignar cuadrillas a novedades
///
/// Muestra las novedades creadas sin asignar y permite
/// asignarlas a cuadrillas disponibles.
class AssignSquadPage extends StatefulWidget {
  const AssignSquadPage({super.key});

  @override
  State<AssignSquadPage> createState() => _AssignSquadPageState();
}

class _AssignSquadPageState extends State<AssignSquadPage> {
  bool _isLoading = true;
  List<NoveltyModel> _novelties = [];
  String? _errorMessage;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadNovelties();
  }

  Future<void> _loadNovelties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final noveltyService = di.sl<NoveltyService>();
      final response = await noveltyService.searchNovelties(
        page: _currentPage,
        size: _pageSize,
        status: 'CREADA',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // La respuesta tiene la estructura: { "novelties": [...], "totalElements": ..., ... }
        final List<dynamic> noveltiesJson = data['novelties'] as List;
        final novelties = noveltiesJson
            .map((json) => NoveltyModel.fromJson(json))
            .toList();

        setState(() {
          _novelties = novelties;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar novedades';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Cuadrilla'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNovelties,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNovelties,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_novelties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay novedades pendientes de asignación',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNovelties,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _novelties.length,
        itemBuilder: (context, index) {
          final novelty = _novelties[index];
          return _NoveltyCard(
            novelty: novelty,
            onTap: () {
              context.push(
                '/manage-incident/assign-squad/novelty/${novelty.id}',
              );
            },
          );
        },
      ),
    );
  }
}

/// Tarjeta de novedad
class _NoveltyCard extends StatelessWidget {
  final NoveltyModel novelty;
  final VoidCallback onTap;

  const _NoveltyCard({required this.novelty, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getReasonColor(novelty.reason).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getReasonLabel(novelty.reason),
                      style: AppTextStyles.caption.copyWith(
                        color: _getReasonColor(novelty.reason),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Indicador de asignación de cuadrilla
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: novelty.crewId != null
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: novelty.crewId != null
                            ? AppColors.success
                            : AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          novelty.crewId != null
                              ? Icons.check_circle
                              : Icons.pending,
                          size: 14,
                          color: novelty.crewId != null
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          novelty.crewId != null ? 'Asignada' : 'Pendiente',
                          style: AppTextStyles.caption.copyWith(
                            color: novelty.crewId != null
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cuenta
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cuenta: ${novelty.accountNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Medidor
              Row(
                children: [
                  Icon(Icons.speed, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Medidor: ${novelty.meterNumber}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ubicación
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      novelty.municipality,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              if (novelty.description.isNotEmpty) ...[
                const Divider(),
                Text(
                  novelty.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Imágenes count
              if (novelty.images.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.image, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${novelty.images.length} imagen(es)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Información de cuadrilla asignada
              if (novelty.crewId != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group, size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          novelty.assignment?.crewName ?? 'Cuadrilla asignada',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'ERROR_LECTURA':
        return AppColors.error;
      case 'MEDIDOR_DANIADO':
        return AppColors.warning;
      case 'RECONEXION':
        return AppColors.success;
      case 'CAMBIO_MEDIDOR':
        return AppColors.info;
      case 'ACTUALIZACION_DATOS':
        return AppColors.primary;
      case 'OTROS':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getReasonLabel(String reason) {
    switch (reason) {
      case 'ERROR_LECTURA':
        return 'Error de Lectura';
      case 'MEDIDOR_DANIADO':
        return 'Medidor Dañado';
      case 'RECONEXION':
        return 'Reconexión';
      case 'CAMBIO_MEDIDOR':
        return 'Cambio de Medidor';
      case 'ACTUALIZACION_DATOS':
        return 'Actualización de Datos';
      case 'OTROS':
        return 'Otros';
      default:
        return reason.replaceAll('_', ' ');
    }
  }
}
