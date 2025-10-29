// select_novelty_for_report_page.dart
//
// Página para seleccionar novedad a reportar
//
// PROPÓSITO:
// - Permitir seleccionar una novedad para crear reporte de resolución
// - Solo mostrar novedades EN_CURSO donde el usuario puede reportar
// - Validar permisos: líder de cuadrilla, jefe de área o admin
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../crews/domain/repositories/crew_repository.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../providers/assignments_provider.dart';

class SelectNoveltyForReportPage extends ConsumerStatefulWidget {
  const SelectNoveltyForReportPage({super.key});

  @override
  ConsumerState<SelectNoveltyForReportPage> createState() =>
      _SelectNoveltyForReportPageState();
}

class _SelectNoveltyForReportPageState
    extends ConsumerState<SelectNoveltyForReportPage> {
  // Cache para almacenar información de cuadrillas y líderes
  final Map<int, bool> _isUserLeaderCache = {};

  // Variable para controlar el timeout visual
  bool _showTimeoutWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNovelties();

      // Mostrar advertencia después de 5 segundos si aún está cargando
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          final state = ref.read(assignmentsProvider);
          if (state.isLoading) {
            setState(() {
              _showTimeoutWarning = true;
            });
          }
        }
      });
    });
  }

  void _loadNovelties() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    AppLogger.debug(
      'SelectNoveltyForReportPage: Iniciando carga con userId: $userId',
    );

    if (userId != null) {
      ref.read(assignmentsProvider.notifier).loadUserNovelties(userId);
    } else {
      AppLogger.error('SelectNoveltyForReportPage: userId es null');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo identificar el usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId != null) {
      await ref.read(assignmentsProvider.notifier).refreshNovelties(userId);
    }
  }

  /// Verifica si el usuario puede crear reporte para esta novedad (versión síncrona para quick check)
  bool _canQuickCheck(dynamic novelty) {
    final authState = ref.read(authNotifierProvider);
    final currentUser = authState.user;

    if (currentUser == null) return false;

    final userRole = currentUser.role;

    // Admin y jefes de área pueden crear reportes en cualquier novedad EN_CURSO
    if (userRole == UserRole.admin || userRole == UserRole.areaManager) {
      return novelty.status == 'EN_CURSO';
    }

    // Para otros usuarios, la novedad debe estar EN_CURSO y tener cuadrilla asignada
    // La verificación de líder se hará async cuando intenten crear el reporte
    return novelty.status == 'EN_CURSO' && novelty.crewId != null;
  }

  /// Verifica si el usuario puede crear reporte para esta novedad (verificación completa)
  Future<bool> _canCreateReportFull(dynamic novelty) async {
    final authState = ref.read(authNotifierProvider);
    final currentUser = authState.user;

    if (currentUser == null) return false;

    final userRole = currentUser.role;
    final userId = currentUser.id;

    // Admin y jefes de área pueden crear reportes en cualquier novedad EN_CURSO
    if (userRole == UserRole.admin || userRole == UserRole.areaManager) {
      return novelty.status == 'EN_CURSO';
    }

    // Para otros usuarios, verificar:
    // 1. La novedad debe estar EN_CURSO
    // 2. Debe tener una cuadrilla asignada
    // 3. El usuario debe ser el líder de esa cuadrilla
    if (novelty.status != 'EN_CURSO' || novelty.crewId == null) {
      return false;
    }

    // Convertir crewId a int si es necesario
    final crewId = novelty.crewId is int
        ? novelty.crewId as int
        : int.parse(novelty.crewId.toString());

    // Convertir userId a int
    final userIdInt = int.parse(userId);

    // Verificar si el usuario es el líder de la cuadrilla asignada
    return await _isUserCrewLeader(crewId, userIdInt);
  }

  /// Verifica si el usuario es el líder de la cuadrilla especificada
  Future<bool> _isUserCrewLeader(int crewId, int userId) async {
    // Verificar cache primero
    final cacheKey =
        crewId * 10000 + userId; // Clave única combinando ambos IDs
    if (_isUserLeaderCache.containsKey(cacheKey)) {
      return _isUserLeaderCache[cacheKey]!;
    }

    try {
      final crewRepository = di.sl<CrewRepository>();
      final result = await crewRepository.getCrewWithMembers(crewId);

      return result.fold(
        (failure) {
          print('Error al obtener cuadrilla: $failure');
          return false;
        },
        (crewWithMembers) {
          // Buscar si el usuario está en la cuadrilla y es líder
          final member = crewWithMembers.members.firstWhere(
            (m) => m.userId == userId,
            orElse: () => throw Exception('Usuario no encontrado en cuadrilla'),
          );

          final isLeader = member.isLeader;

          // Guardar en cache
          _isUserLeaderCache[cacheKey] = isLeader;

          return isLeader;
        },
      );
    } catch (e) {
      print('Error al verificar líder de cuadrilla: $e');
      return false;
    }
  }

  void _onNoveltySelected(dynamic novelty) async {
    // Guardar contexto antes de la operación async
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final canReport = await _canCreateReportFull(novelty);

    // Cerrar diálogo de carga
    if (mounted) navigator.pop();

    if (!canReport) {
      if (mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text(
              'No tienes permisos para crear reportes en esta novedad. Solo el líder de la cuadrilla asignada, jefes de área o administradores pueden crear reportes.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Navegar a la página de crear reporte con el ID de la novedad
    if (mounted) context.push('/novelty-report/${novelty.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Novedad'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AssignmentsState state) {
    if (state.isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(message: 'Cargando novedades...'),
          if (_showTimeoutWarning) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'La carga está tardando más de lo esperado...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadNovelties,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              'Error al cargar novedades',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Error desconocido',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: _loadNovelties,
              icon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Mostrar detalles técnicos del error
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Detalles del Error'),
                    content: SingleChildScrollView(
                      child: Text(
                        'Mensaje: ${state.errorMessage}\n\n'
                        'Posibles causas:\n'
                        '• Problema de conexión con el servidor\n'
                        '• El servidor no responde\n'
                        '• El endpoint no está disponible\n'
                        '• Permisos insuficientes\n\n'
                        'Verifica tu conexión e intenta nuevamente.',
                        style: AppTextStyles.bodySmall,
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
              },
              child: const Text('Ver detalles del error'),
            ),
          ],
        ),
      );
    }

    final noveltiesEnCurso = state.novelties
        .where((n) => n.status == 'EN_CURSO')
        .toList();

    if (noveltiesEnCurso.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          // Encabezado informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selecciona una novedad en curso para crear su reporte de resolución',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de novedades
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: noveltiesEnCurso.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final novelty = noveltiesEnCurso[index];
                final canQuickCheck = _canQuickCheck(novelty);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: canQuickCheck
                        ? BorderSide.none
                        : BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: InkWell(
                    onTap: canQuickCheck
                        ? () => _onNoveltySelected(novelty)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pending,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'En Curso',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#${novelty.id}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (!canQuickCheck)
                                Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Descripción
                          Text(
                            novelty.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Información adicional
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  novelty.address,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Cuadrilla asignada
                          if (novelty.assignment?.crewName != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.group_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Cuadrilla: ${novelty.assignment!.crewName}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Botón de acción
                          if (canQuickCheck) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _onNoveltySelected(novelty),
                                icon: const Icon(Icons.description, size: 18),
                                label: const Text('Crear Reporte'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay novedades en curso',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes novedades actualmente en proceso que requieran reportes de resolución',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Refrescar',
              onPressed: _handleRefresh,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
