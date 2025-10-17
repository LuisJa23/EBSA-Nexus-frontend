// list_crews_page.dart
//
// Página para listar cuadrillas
//
// PROPÓSITO:
// - Mostrar lista de todas las cuadrillas del sistema
// - Navegación a detalle de cuadrilla
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/crew_list_provider.dart';
import '../widgets/crew_card.dart';
import 'crew_detail_page.dart';

/// Página para mostrar la lista de cuadrillas
class ListCrewsPage extends ConsumerStatefulWidget {
  const ListCrewsPage({super.key});

  @override
  ConsumerState<ListCrewsPage> createState() => _ListCrewsPageState();
}

class _ListCrewsPageState extends ConsumerState<ListCrewsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar cuadrillas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crewListProvider.notifier).loadCrews();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(crewListProvider.notifier).refreshCrews();
  }

  void _navigateToCrewDetail(int crewId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CrewDetailPage(crewId: crewId),
          ),
        )
        .then((_) {
          // Refrescar lista al volver
          ref.read(crewListProvider.notifier).refreshCrews();
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crewListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuadrillas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(state) {
    if (state.isLoading && state.crews.isEmpty) {
      return const LoadingIndicator(message: 'Cargando cuadrillas...');
    }

    if (state.errorMessage != null && state.crews.isEmpty) {
      return core.ErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(crewListProvider.notifier).loadCrews(),
      );
    }

    if (state.crews.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.groups,
        message: 'No hay cuadrillas disponibles',
        description: 'Las cuadrillas creadas aparecerán aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.crews.length,
        itemBuilder: (context, index) {
          final crew = state.crews[index];
          return CrewCard(
            crew: crew,
            onTap: () => _navigateToCrewDetail(crew.id),
          );
        },
      ),
    );
  }
}
