// assignments_page.dart
//
// Página de asignaciones
//
// PROPÓSITO:
// - Mostrar novedades asignadas al usuario
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../../../core/widgets/loading_indicator.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/assignments_provider.dart';
import '../widgets/novelty_card.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar novedades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignments();
    });
  }

  void _loadAssignments() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    AppLogger.debug('AssignmentsPage: Iniciando carga de asignaciones');
    AppLogger.debug('AssignmentsPage: userId obtenido: $userId');

    if (userId != null) {
      AppLogger.debug(
        'AssignmentsPage: Llamando loadUserNovelties con userId: $userId (tipo: ${userId.runtimeType})',
      );
      ref.read(assignmentsProvider.notifier).loadUserNovelties(userId);
    } else {
      AppLogger.error('AssignmentsPage: userId es null');
    }
  }

  Future<void> _handleRefresh() async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;

    if (userId != null) {
      await ref.read(assignmentsProvider.notifier).refreshNovelties(userId);
    }
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
              'No tienes asignaciones',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Las novedades asignadas a tu cuenta aparecerán aquí',
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
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsState = ref.watch(assignmentsProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Asignaciones'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _buildBody(assignmentsState, authState),
    );
  }

  Widget _buildBody(AssignmentsState assignmentsState, AuthState authState) {
    // Usuario no autenticado
    if (authState.user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Usuario no autenticado',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Estado de carga
    if (assignmentsState.isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Cargando asignaciones...'),
      );
    }

    // Estado de error
    if (assignmentsState.hasError) {
      return Center(
        child: core.ErrorWidget(
          message: assignmentsState.errorMessage ?? 'Error desconocido',
          onRetry: _loadAssignments,
        ),
      );
    }

    // Sin novedades
    if (assignmentsState.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildEmptyState(),
      );
    }

    // Lista de novedades
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignmentsState.novelties.length,
        itemBuilder: (context, index) {
          final novelty = assignmentsState.novelties[index];
          return NoveltyCard(
            novelty: novelty,
            onTap: () {
              // Navegar al detalle de la novedad
              context.push('/novelty-detail/${novelty.id}');
            },
          );
        },
      ),
    );
  }
}
