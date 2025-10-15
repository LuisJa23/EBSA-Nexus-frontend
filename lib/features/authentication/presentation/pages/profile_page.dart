// profile_page.dart
//
// Página de perfil de usuario
//
// PROPÓSITO:
// - Mostrar información completa del usuario
// - Permitir edición de campos actualizables
// - Validar y guardar cambios
// - Proporcionar feedback visual
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user.dart';
import '../providers/profile_provider.dart';

/// Página que muestra y permite editar el perfil del usuario
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Controladores de texto
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Scroll controller para navegación automática
  final _scrollController = ScrollController();

  // Claves de formulario
  final _formKey = GlobalKey<FormState>();

  // GlobalKey para la sección editable (para hacer scroll)
  final _editableSectionKey = GlobalKey();

  // Estado de edición
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Cargar perfil al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Inicializa controladores con datos del usuario
  void _initializeControllers() {
    final user = ref.read(profileProvider).user;
    if (user != null && !_isEditing) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
      _hasChanges = false;
    }
  }

  /// Detecta si hay cambios sin guardar
  void _onFieldChanged() {
    final user = ref.read(profileProvider).user;
    if (user != null) {
      final hasChanges =
          _firstNameController.text != user.firstName ||
          _lastNameController.text != user.lastName ||
          _phoneController.text != (user.phoneNumber ?? '');

      if (_hasChanges != hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  /// Guarda cambios del perfil
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(profileProvider.notifier)
        .updateProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
        );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Cancela edición
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });
    _initializeControllers();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    _initializeControllers();

    return Stack(
      children: [
        _buildBody(profileState),
        // Botón flotante de editar solo si no está en modo edición y hay usuario
        if (!_isEditing && profileState.user != null)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
                // Hacer scroll al formulario de edición después de un pequeño delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_editableSectionKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _editableSectionKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      alignment: 0.1,
                    );
                  }
                });
              },
              child: const Icon(Icons.edit),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ProfileStatus.error) {
      // Detectar si es un error de autenticación (sesión expirada/token inválido)
      final isAuthError =
          state.errorCode == 'auth/session-expired' ||
          state.errorCode == 'auth/unauthorized' ||
          state.errorCode == 'auth/invalid-token' ||
          state.errorMessage?.toLowerCase().contains('sesión') == true ||
          state.errorMessage?.toLowerCase().contains('token') == true;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Error cargando perfil',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (isAuthError) {
                  // Si es error de autenticación, reintentar carga (el token local será validado)
                  ref.read(profileProvider.notifier).loadUserProfile();
                } else {
                  // Si es otro tipo de error, reintentar carga
                  ref.read(profileProvider.notifier).loadUserProfile();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.user == null) {
      return const Center(child: Text('No se pudo cargar el perfil'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(profileProvider.notifier).refreshProfile(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(state.user!),
              const SizedBox(height: 24),
              _buildInfoSection(state.user!),
              const SizedBox(height: 24),
              if (_isEditing) ...[
                _buildEditableSection(),
                const SizedBox(height: 24),
                _buildActionButtons(state),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                user.initials,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role.displayName),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(User user) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.badge,
              'Documento',
              user.documentNumber ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Teléfono', user.phoneNumber ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.work,
              'Área de Trabajo',
              user.workArea ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.business_center,
              'Tipo de Contrato',
              user.workType == 'intern'
                  ? 'Interno'
                  : user.workType == 'extern'
                  ? 'Externo'
                  : 'N/A',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha de Registro',
              _formatDate(user.createdAt),
            ),
            if (user.lastLoginAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.access_time,
                'Último Acceso',
                _formatDate(user.lastLoginAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableSection() {
    return Card(
      key: _editableSectionKey, // Key para hacer scroll
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Perfil',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Nombres *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los nombres son requeridos';
                }
                if (value.trim().length < 2) {
                  return 'Debe tener al menos 2 caracteres';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Apellidos *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Los apellidos son requeridos';
                }
                if (value.trim().length < 2) {
                  return 'Debe tener al menos 2 caracteres';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '3001234567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es requerido';
                }
                final cleanPhone = value.replaceAll(RegExp(r'[\s\-()]'), '');
                final phoneRegex = RegExp(
                  r'^(\+57|57)?[3][0-9]{9}$|^[3][0-9]{9}$',
                );
                if (!phoneRegex.hasMatch(cleanPhone)) {
                  return 'Teléfono inválido (10 dígitos, inicia con 3)';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ProfileState state) {
    final isUpdating = state.status == ProfileStatus.updating;

    return Column(
      children: [
        if (state.status == ProfileStatus.error)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage ?? 'Error desconocido',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isUpdating ? null : _cancelEdit,
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: (isUpdating || !_hasChanges) ? null : _saveChanges,
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
