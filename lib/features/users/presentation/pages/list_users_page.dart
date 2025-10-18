// list_users_page.dart
//
// Página para listar usuarios del sistema
//
// PROPÓSITO:
// - Mostrar lista de todos los usuarios registrados
// - Búsqueda y filtrado de usuarios
// - Acceso a detalles y edición de usuarios
// - Solo accesible para usuarios con rol ADMIN
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/workers_provider.dart';
import '../state/workers_state.dart';
import '../widgets/worker_list_tile.dart';

/// Página para visualizar lista de trabajadores del sistema
///
/// Muestra todos los trabajadores registrados con opciones
/// de búsqueda, filtrado y acciones de gestión.
///
/// **Restricción**: Solo accesible para usuarios con rol ADMIN
class ListUsersPage extends ConsumerStatefulWidget {
  const ListUsersPage({super.key});

  @override
  ConsumerState<ListUsersPage> createState() => _ListUsersPageState();
}

class _ListUsersPageState extends ConsumerState<ListUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWorkType;

  @override
  void initState() {
    super.initState();
    // Cargar trabajadores al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workersProvider.notifier).loadWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workersState = ref.watch(workersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Trabajadores'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workersProvider.notifier).refreshWorkers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildBody(workersState)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, usuario, email o documento...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(workersProvider.notifier).searchWorkers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              ref.read(workersProvider.notifier).searchWorkers(value);
            },
          ),
          const SizedBox(height: 12),
          // Filtro por tipo de trabajo
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedWorkType,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por tipo de trabajo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    const DropdownMenuItem(
                      value: 'intern',
                      child: Text('Interno'),
                    ),
                    const DropdownMenuItem(
                      value: 'extern',
                      child: Text('Externo'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkType = value;
                    });
                    ref.read(workersProvider.notifier).filterByWorkType(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedWorkType = null;
                  });
                  _searchController.clear();
                  ref.read(workersProvider.notifier).clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WorkersState state) {
    if (state is WorkersInitial) {
      return _buildInitialState();
    } else if (state is WorkersLoading) {
      return _buildLoadingState();
    } else if (state is WorkersLoaded) {
      return _buildLoadedState(state);
    } else if (state is WorkersError) {
      return _buildErrorState(state);
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildInitialState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando trabajadores...'),
        ],
      ),
    );
  }

  Widget _buildLoadedState(WorkersLoaded state) {
    final workers = state.displayWorkers;

    if (workers.isEmpty) {
      return _buildEmptyState(state);
    }

    return Column(
      children: [
        // Información de resultados
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.background,
          child: Text(
            'Mostrando ${workers.length} de ${state.totalWorkers} trabajadores',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Lista de trabajadores
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(workersProvider.notifier).refreshWorkers();
            },
            child: ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return WorkerListTile(
                  worker: worker,
                  onTap: () {
                    // TODO: Navegar a detalle del trabajador
                    _showWorkerDetails(worker);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(WorkersLoaded state) {
    final hasFilters = state.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters
                  ? 'No se encontraron trabajadores'
                  : 'No hay trabajadores registrados',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Intenta cambiar los filtros de búsqueda.'
                  : 'Los trabajadores aparecerán aquí cuando sean registrados.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedWorkType = null;
                  });
                  _searchController.clear();
                  ref.read(workersProvider.notifier).clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WorkersError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar trabajadores',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(workersProvider.notifier).loadWorkers();
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

  void _showWorkerDetails(worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(worker.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Usuario:', worker.username),
            _buildDetailRow('Email:', worker.email),
            _buildDetailRow('Documento:', worker.documentNumber),
            _buildDetailRow('Teléfono:', worker.phone),
            _buildDetailRow('Tipo de trabajo:', worker.workTypeLocalized),
            _buildDetailRow('Estado:', worker.isActive ? 'Activo' : 'Inactivo'),
            _buildDetailRow('UUID:', worker.uuid),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
