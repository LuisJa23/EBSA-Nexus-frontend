// crew_detail_page.dart
//
// Página de detalle de cuadrilla
//
// PROPÓSITO:
// - Mostrar información completa de una cuadrilla
// - Gestionar miembros de la cuadrilla
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../providers/crew_detail_provider.dart';
import '../state/crew_detail_state.dart';
import '../widgets/crew_info_card.dart';
import '../widgets/crew_member_list.dart';
import '../widgets/add_member_dialog.dart';

/// Página de detalle de cuadrilla
class CrewDetailPage extends ConsumerStatefulWidget {
  final int crewId;

  const CrewDetailPage({super.key, required this.crewId});

  @override
  ConsumerState<CrewDetailPage> createState() => _CrewDetailPageState();
}

class _CrewDetailPageState extends ConsumerState<CrewDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(crewDetailProvider.notifier).loadCrewWithMembers(widget.crewId);
  }

  Future<void> _onRefresh() async {
    _loadData();
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMemberDialog(crewId: widget.crewId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crewDetailProvider);

    // Mostrar mensajes
    ref.listen<CrewDetailState>(crewDetailProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(crewDetailProvider.notifier).clearMessages();
      }

      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(crewDetailProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cuadrilla'),
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

  Widget _buildBody(CrewDetailState state) {
    if (state.isLoading && state.crewDetail == null) {
      return const LoadingIndicator(message: 'Cargando información...');
    }

    if (state.errorMessage != null && state.crewDetail == null) {
      return core.ErrorWidget(message: state.errorMessage!, onRetry: _loadData);
    }

    if (state.crewDetail == null) {
      return const core.ErrorWidget(
        message: 'No se pudo cargar la información de la cuadrilla',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la cuadrilla
            CrewInfoCard(crewDetail: state.crewDetail!),

            const SizedBox(height: 24),

            // Título de miembros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Miembros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${state.members.length} miembro${state.members.length != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de miembros
            if (state.isLoadingMembers)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              CrewMemberList(crewId: widget.crewId, members: state.members),

            const SizedBox(height: 24),

            // Botón para agregar miembro al final de la lista
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.person_add, size: 24),
                label: const Text(
                  'Agregar nuevo miembro a la cuadrilla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
