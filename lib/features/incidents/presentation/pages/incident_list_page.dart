// incident_list_page.dart
//
// Página para consultar novedades asignadas
//
// PROPÓSITO:
// - Listar novedades/incidentes asignados al usuario
// - Filtrar y buscar novedades
// - Ver detalles de cada novedad
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/incidents_providers.dart';
import '../providers/novelty_list_provider.dart';
import '../widgets/novelty_filters_bottom_sheet.dart';
import '../widgets/novelty_list_item.dart';

/// Página para consultar novedades/incidentes asignados
///
/// Muestra un listado de todas las novedades asignadas
/// al usuario actual, con opciones de filtrado y búsqueda.
class IncidentListPage extends ConsumerStatefulWidget {
  const IncidentListPage({super.key});

  @override
  ConsumerState<IncidentListPage> createState() => _IncidentListPageState();
}

class _IncidentListPageState extends ConsumerState<IncidentListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar novedades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(noveltyListProvider.notifier).loadNovelties();
    });

    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Cargar más cuando llegue al 90% del scroll
      ref.read(noveltyListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noveltyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar Novedades'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Botón de filtros
          IconButton(
            onPressed: _showFilters,
            icon: Badge(
              isLabelVisible: state.hasFilters,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NoveltyListState state) {
    // Estado de carga inicial
    if (state.status == NoveltyListStatus.loading && state.novelties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado de error
    if (state.status == NoveltyListStatus.error && state.novelties.isEmpty) {
      return _buildErrorView(state.errorMessage);
    }

    // Estado vacío
    if (state.isEmpty) {
      return _buildEmptyView();
    }

    // Lista de novedades
    return RefreshIndicator(
      onRefresh: () => ref.read(noveltyListProvider.notifier).refresh(),
      color: AppColors.primary,
      child: Column(
        children: [
          // Información de resultados y filtros
          _buildInfoBar(state),

          // Lista
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.novelties.length + 1,
              itemBuilder: (context, index) {
                if (index == state.novelties.length) {
                  // Indicador de carga al final
                  if (state.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox(height: 16);
                }

                final novelty = state.novelties[index];
                return NoveltyListItem(
                  novelty: novelty,
                  onTap: () => _navigateToDetail(novelty.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la barra de información
  Widget _buildInfoBar(NoveltyListState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '${state.totalElements} ${state.totalElements == 1 ? 'novedad' : 'novedades'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.hasFilters) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Filtrado',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (state.hasFilters)
            TextButton.icon(
              onPressed: () {
                ref.read(noveltyListProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Limpiar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye la vista de error
  Widget _buildErrorView(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar novedades',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Ha ocurrido un error inesperado',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(noveltyListProvider.notifier)
                    .loadNovelties(refresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la vista vacía
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay novedades',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron novedades con los filtros aplicados',
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

  /// Muestra el bottom sheet de filtros
  void _showFilters() {
    final state = ref.read(noveltyListProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoveltyFiltersBottomSheet(
        currentStatus: state.statusFilter,
        currentPriority: state.priorityFilter,
        onStatusChanged: (status) {
          ref.read(noveltyListProvider.notifier).setStatusFilter(status);
        },
        onPriorityChanged: (priority) {
          ref.read(noveltyListProvider.notifier).setPriorityFilter(priority);
        },
        onClearFilters: () {
          ref.read(noveltyListProvider.notifier).clearFilters();
        },
      ),
    );
  }

  /// Navega a la página de detalle
  void _navigateToDetail(int noveltyId) {
    context.push('/novelty-detail/$noveltyId');
  }
}
