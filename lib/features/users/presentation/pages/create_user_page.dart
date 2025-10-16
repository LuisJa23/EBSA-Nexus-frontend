// create_user_page.dart
//
// Página para crear nuevos usuarios
//
// PROPÓSITO:
// - Formulario completo de creación de usuarios
// - Validaciones en tiempo real
// - Manejo de errores del servidor
// - Roles dinámicos según tipo de trabajador
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/work_role.dart';
import '../providers/create_user_provider.dart';
import '../state/create_user_state.dart';
import '../widgets/user_created_success_card.dart';

/// Página para crear nuevos usuarios del sistema
class CreateUserPage extends ConsumerStatefulWidget {
  const CreateUserPage({super.key});

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  // Estado del formulario
  String _selectedRoleName = 'TRABAJADOR'; // Por defecto: Trabajador
  WorkType? _selectedWorkType;
  String? _selectedWorkRoleName;

  @override
  void initState() {
    super.initState();
    // Cargar datos persistidos si existen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersistedData();
    });
  }

  /// Carga datos del formulario si fueron persistidos
  void _loadPersistedData() {
    final state = ref.read(createUserProvider);
    final formData = state.formData;

    if (formData.isNotEmpty) {
      setState(() {
        _firstNameController.text = formData['firstName'] ?? '';
        _lastNameController.text = formData['lastName'] ?? '';
        _emailController.text = formData['email'] ?? '';
        _documentController.text = formData['documentNumber'] ?? '';
        _phoneController.text = formData['phone'] ?? '';
        _usernameController.text = formData['username'] ?? '';
        _selectedRoleName = formData['roleName'] ?? 'TRABAJADOR';

        final workTypeValue = formData['workType'];
        if (workTypeValue != null) {
          _selectedWorkType = workTypeValue == 'intern'
              ? WorkType.intern
              : WorkType.extern;
        }

        _selectedWorkRoleName = formData['workRoleName'];
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createUserProvider);

    // Escuchar cambios de estado
    ref.listen<CreateUserState>(createUserProvider, (previous, next) {
      if (next.isSuccess) {
        _showSuccessAndNavigate();
      }
    });

    return state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // Solo mostrar banner si es un error general, NO si son errores de campos
                  if (state.shouldShowErrorBanner) ...[
                    _buildErrorBanner(state.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  _buildPersonalInfoSection(state),
                  const SizedBox(height: 24),
                  _buildContactSection(state),
                  const SizedBox(height: 24),
                  _buildRoleSection(state),
                  const SizedBox(height: 32),
                  _buildCreateButton(state),
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
          'Crear Nuevo Usuario',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete el formulario para registrar un nuevo usuario',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(CreateUserState state) {
    return FormSection(
      title: 'Información Personal',
      children: [
        CustomTextField(
          controller: _firstNameController,
          label: 'Nombre',
          hint: 'Ingrese el nombre',
          icon: Icons.person,
          fieldName: 'firstName',
          errorText: state.getFieldError('firstName'),
          onChanged: (value) {
            if (state.getFieldError('firstName') != null) {
              ref
                  .read(createUserProvider.notifier)
                  .clearFieldError('firstName');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 2) return 'Mínimo 2 caracteres';
            return null;
          },
        ),
        CustomTextField(
          controller: _lastNameController,
          label: 'Apellido',
          hint: 'Ingrese el apellido',
          icon: Icons.person_outline,
          fieldName: 'lastName',
          errorText: state.getFieldError('lastName'),
          onChanged: (value) {
            if (state.getFieldError('lastName') != null) {
              ref.read(createUserProvider.notifier).clearFieldError('lastName');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 2) return 'Mínimo 2 caracteres';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactSection(CreateUserState state) {
    return FormSection(
      title: 'Información de Contacto',
      children: [
        CustomTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hint: 'usuario@ebsa.com',
          icon: Icons.email,
          fieldName: 'email',
          keyboardType: TextInputType.emailAddress,
          errorText: state.getFieldError('email'),
          onChanged: (value) {
            if (state.getFieldError('email') != null) {
              ref.read(createUserProvider.notifier).clearFieldError('email');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value!)) return 'Email inválido';
            return null;
          },
        ),
        CustomTextField(
          controller: _documentController,
          label: 'Número de Documento',
          hint: '1234567890',
          icon: Icons.badge,
          fieldName: 'documentNumber',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: state.getFieldError('documentNumber'),
          onChanged: (value) {
            if (state.getFieldError('documentNumber') != null) {
              ref
                  .read(createUserProvider.notifier)
                  .clearFieldError('documentNumber');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 6 || value.length > 12) {
              return 'Entre 6 y 12 dígitos';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '3001234567',
          icon: Icons.phone,
          fieldName: 'phone',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: state.getFieldError('phone'),
          onChanged: (value) {
            if (state.getFieldError('phone') != null) {
              ref.read(createUserProvider.notifier).clearFieldError('phone');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length != 10) return 'Debe tener 10 dígitos';
            if (!value.startsWith('3')) return 'Debe iniciar con 3';
            return null;
          },
        ),
        CustomTextField(
          controller: _usernameController,
          label: 'Nombre de Usuario',
          hint: 'usuario.ebsa',
          icon: Icons.account_circle,
          fieldName: 'username',
          errorText: state.getFieldError('username'),
          onChanged: (value) {
            if (state.getFieldError('username') != null) {
              ref.read(createUserProvider.notifier).clearFieldError('username');
            }
          },
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 4) return 'Mínimo 4 caracteres';
            final usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');
            if (!usernameRegex.hasMatch(value)) {
              return 'Solo letras, números, puntos y guiones bajos';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleSection(CreateUserState state) {
    return FormSection(
      title: 'Rol y Funciones',
      children: [
        _buildRoleSelector(),
        // Para TRABAJADOR: mostrar selector de tipo (interno/externo)
        if (_selectedRoleName == 'TRABAJADOR') ...[
          _buildWorkTypeSelector(),
          if (_selectedWorkType != null)
            WorkRoleDropdown(
              workType: _selectedWorkType,
              selectedValue: _selectedWorkRoleName,
              onChanged: (value) =>
                  setState(() => _selectedWorkRoleName = value),
              validator: (value) => value == null ? 'Seleccione un rol' : null,
            ),
        ],
        // Para JEFE_AREA: mostrar directamente roles internos (sin selector de tipo)
        if (_selectedRoleName == 'JEFE_AREA')
          WorkRoleDropdown(
            workType: WorkType.intern,
            selectedValue: _selectedWorkRoleName,
            onChanged: (value) => setState(() => _selectedWorkRoleName = value),
            validator: (value) => value == null ? 'Seleccione un rol' : null,
          ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return CustomDropdown<String>(
      value: _selectedRoleName,
      label: 'Rol del Sistema',
      icon: Icons.admin_panel_settings,
      items: const [
        DropdownMenuItem(value: 'TRABAJADOR', child: Text('Trabajador')),
        DropdownMenuItem(value: 'JEFE_AREA', child: Text('Jefe de Área')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRoleName = value!;
          // Si es JEFE_AREA, automáticamente establecer como interno
          if (_selectedRoleName == 'JEFE_AREA') {
            _selectedWorkType = WorkType.intern;
          } else {
            _selectedWorkType = null;
          }
          _selectedWorkRoleName = null;
        });
      },
    );
  }

  Widget _buildWorkTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Trabajador',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: WorkTypeButton(
                label: 'Interno',
                isSelected: _selectedWorkType == WorkType.intern,
                onPressed: () {
                  setState(() {
                    _selectedWorkType = WorkType.intern;
                    _selectedWorkRoleName = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WorkTypeButton(
                label: 'Externo',
                isSelected: _selectedWorkType == WorkType.extern,
                onPressed: () {
                  setState(() {
                    _selectedWorkType = WorkType.extern;
                    _selectedWorkRoleName = null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton(CreateUserState state) {
    return CustomButton(
      text: 'Crear Usuario',
      type: ButtonType.primary,
      isLoading: state.isLoading,
      onPressed: state.isLoading ? null : _handleSubmit,
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Validar tipo de trabajador solo para TRABAJADOR (JEFE_AREA es automáticamente interno)
    if (_selectedRoleName == 'TRABAJADOR') {
      if (_selectedWorkType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione el tipo de trabajador')),
        );
        return;
      }
    }

    // Validar rol de trabajo para TRABAJADOR y JEFE_AREA
    if (_selectedRoleName == 'TRABAJADOR' || _selectedRoleName == 'JEFE_AREA') {
      if (_selectedWorkRoleName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione el rol de trabajo')),
        );
        return;
      }
    }

    ref
        .read(createUserProvider.notifier)
        .createUser(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          documentNumber: _documentController.text,
          phone: _phoneController.text,
          username: _usernameController.text,
          roleName: _selectedRoleName,
          workType: _selectedWorkType?.value,
          workRoleName: _selectedWorkRoleName,
        );
  }

  void _showSuccessAndNavigate() {
    final user = ref.read(createUserProvider).createdUser;

    if (user != null) {
      // Mostrar tarjeta flotante con datos del usuario
      showUserCreatedSuccessDialog(context, user);
    } else {
      // Fallback: mostrar snackbar si no hay datos del usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
