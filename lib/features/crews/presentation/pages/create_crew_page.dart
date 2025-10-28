// create_crew_page.dart
//
// Página para crear una nueva cuadrilla
//
// PROPÓSITO:
// - Formulario para crear cuadrillas
// - Selección de miembros
// - Designación de líder
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/create_crew_provider.dart';
import '../state/create_crew_state.dart';
import '../widgets/member_selector_widget.dart';

/// Página para crear una nueva cuadrilla
class CreateCrewPage extends ConsumerStatefulWidget {
  const CreateCrewPage({super.key});

  @override
  ConsumerState<CreateCrewPage> createState() => _CreateCrewPageState();
}

class _CreateCrewPageState extends ConsumerState<CreateCrewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<SelectedMember> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    // Cargar usuarios disponibles al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createCrewProvider.notifier).loadAvailableUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createCrewProvider);

    // Listener para cambios de estado
    ref.listen<CreateCrewState>(createCrewProvider, (previous, next) {
      if (next.status == CreateCrewStatus.success) {
        _showSuccessDialog();
      } else if (next.status == CreateCrewStatus.error) {
        _showErrorDialog(next.errorMessage ?? 'Error desconocido');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuadrilla'), centerTitle: true),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CreateCrewState state) {
    if (state.status == CreateCrewStatus.loadingUsers) {
      return const Center(child: LoadingIndicator());
    }

    if (state.status == CreateCrewStatus.error &&
        state.availableUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error al cargar usuarios',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
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
                onPressed: () {
                  ref.read(createCrewProvider.notifier).loadAvailableUsers();
                },
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildMembersSection(state),
            const SizedBox(height: 32),
            _buildSubmitButton(state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completa la información para crear una nueva cuadrilla',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _nameController,
          label: 'Nombre de la Cuadrilla',
          hint: 'Ej: Cuadrilla Alpha',
          icon: Icons.group,
          fieldName: 'name',
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Ej: Cuadrilla de mantenimiento zona norte',
          icon: Icons.description,
          fieldName: 'description',
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es requerida';
            }
            if (value.trim().length < 10) {
              return 'La descripción debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMembersSection(CreateCrewState state) {
    return MemberSelectorWidget(
      availableUsers: state.availableUsers,
      selectedMembers: _selectedMembers,
      onAddMember: () => _showAddMemberDialog(state),
      onRemoveMember: (index) {
        setState(() {
          _selectedMembers.removeAt(index);
          // Si se eliminó el líder, designar al primero como líder
          if (_selectedMembers.isNotEmpty &&
              !_selectedMembers.any((m) => m.isLeader)) {
            _selectedMembers[0] = _selectedMembers[0].copyWith(isLeader: true);
          }
        });
      },
      onToggleLeader: (index) {
        setState(() {
          // Quitar líder a todos
          _selectedMembers = _selectedMembers
              .map((m) => m.copyWith(isLeader: false))
              .toList();
          // Designar nuevo líder
          _selectedMembers[index] = _selectedMembers[index].copyWith(
            isLeader: true,
          );
        });
      },
      errorText: _selectedMembers.isEmpty
          ? 'Debe agregar al menos un miembro'
          : null,
    );
  }

  Widget _buildSubmitButton(CreateCrewState state) {
    final isSubmitting = state.status == CreateCrewStatus.submitting;
    final hasLeader = _selectedMembers.any((m) => m.isLeader);

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Crear Cuadrilla',
        icon: Icons.check,
        onPressed: !isSubmitting && hasLeader ? _handleSubmit : null,
        isLoading: isSubmitting,
      ),
    );
  }

  void _showAddMemberDialog(CreateCrewState state) {
    // Filtrar usuarios que no están seleccionados
    final selectedIds = _selectedMembers.map((m) => m.user.id).toSet();
    final availableUsers = state.availableUsers
        .where((u) => !selectedIds.contains(u.id))
        .toList();

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más usuarios disponibles'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
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
                      'Seleccionar Miembro',
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

              // Lista de usuarios
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: availableUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = availableUsers[index];
                    return _buildUserTile(user);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserTile(user) {
    return InkWell(
      onTap: () {
        setState(() {
          final isFirstMember = _selectedMembers.isEmpty;
          _selectedMembers.add(
            SelectedMember(
              user: user,
              isLeader: isFirstMember, // El primer miembro es líder por defecto
            ),
          );
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                user.firstName[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.workRoleName ?? 'Sin rol asignado',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un miembro'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_selectedMembers.any((m) => m.isLeader)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe designar un líder'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Obtener el usuario actual (createdBy)
    final authState = ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no identificado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Convertir ID de String a int
    final createdById = int.tryParse(currentUserId);
    if (createdById == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de usuario inválido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Convertir miembros a formato JSON
    final members = _selectedMembers
        .map((m) => {'userId': m.user.id, 'isLeader': m.isLeader})
        .toList();

    // Enviar datos
    ref
        .read(createCrewProvider.notifier)
        .createCrew(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          createdBy: createdById,
          members: members,
        );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('¡Éxito!'),
          ],
        ),
        content: const Text('La cuadrilla ha sido creada exitosamente'),
        actions: [
          CustomButton(
            text: 'Aceptar',
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              context.pop(); // Volver a la página anterior
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 32),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          CustomButton(
            text: 'Cerrar',
            type: ButtonType.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
