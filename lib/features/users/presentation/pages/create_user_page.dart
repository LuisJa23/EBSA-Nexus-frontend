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
import '../../domain/entities/work_role.dart';
import '../providers/create_user_provider.dart';
import '../providers/work_roles_provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: state.isLoading
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
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Crear Usuario',
        style: AppTextStyles.heading3.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nuevo Usuario',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete la información del usuario',
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
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Personal',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _firstNameController,
          label: 'Nombre',
          hint: 'Ingrese el nombre',
          icon: Icons.person,
          fieldName: 'firstName',
          errorText: state.getFieldError('firstName'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 2) return 'Mínimo 2 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Apellido',
          hint: 'Ingrese el apellido',
          icon: Icons.person_outline,
          fieldName: 'lastName',
          errorText: state.getFieldError('lastName'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Contacto',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hint: 'usuario@ebsa.com',
          icon: Icons.email,
          fieldName: 'email',
          keyboardType: TextInputType.emailAddress,
          errorText: state.getFieldError('email'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value!)) return 'Email inválido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _documentController,
          label: 'Número de Documento',
          hint: '1234567890',
          icon: Icons.badge,
          fieldName: 'documentNumber',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: state.getFieldError('documentNumber'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 6 || value.length > 12) {
              return 'Entre 6 y 12 dígitos';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: '3001234567',
          icon: Icons.phone,
          fieldName: 'phone',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: state.getFieldError('phone'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length != 10) return 'Debe tener 10 dígitos';
            if (!value.startsWith('3')) return 'Debe iniciar con 3';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _usernameController,
          label: 'Nombre de Usuario',
          hint: 'usuario.ebsa',
          icon: Icons.account_circle,
          fieldName: 'username',
          errorText: state.getFieldError('username'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 4) return 'Mínimo 4 caracteres';
            // Validar caracteres permitidos (alfanuméricos, puntos, guiones bajos)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rol y Funciones',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildRoleSelector(),
        if (_selectedRoleName == 'TRABAJADOR') ...[
          const SizedBox(height: 16),
          _buildWorkTypeSelector(),
          if (_selectedWorkType != null) ...[
            const SizedBox(height: 16),
            _buildWorkRoleDropdown(),
          ],
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String
    fieldName, // Identificador del campo para limpiar su error específico
    String? errorText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        // Limpiar SOLO el error de este campo específico cuando el usuario escribe
        if (errorText != null) {
          ref.read(createUserProvider.notifier).clearFieldError(fieldName);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedRoleName,
      decoration: InputDecoration(
        labelText: 'Rol del Sistema',
        prefixIcon: Icon(Icons.admin_panel_settings, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'TRABAJADOR', child: Text('Trabajador')),
        DropdownMenuItem(value: 'JEFE_AREA', child: Text('Jefe de Área')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRoleName = value!;
          _selectedWorkType = null;
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
            Expanded(child: _buildWorkTypeButton(WorkType.intern, 'Interno')),
            const SizedBox(width: 12),
            Expanded(child: _buildWorkTypeButton(WorkType.extern, 'Externo')),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkTypeButton(WorkType type, String label) {
    final isSelected = _selectedWorkType == type;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedWorkType = type;
          _selectedWorkRoleName = null;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFFFFC107)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWorkRoleDropdown() {
    final roles = ref.watch(workRolesByTypeProvider(_selectedWorkType));

    return DropdownButtonFormField<String>(
      value: _selectedWorkRoleName,
      decoration: InputDecoration(
        labelText: 'Rol de Trabajo',
        prefixIcon: Icon(Icons.work, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: roles
          .map(
            (role) =>
                DropdownMenuItem(value: role.name, child: Text(role.name)),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedWorkRoleName = value),
      validator: (value) => value == null ? 'Seleccione un rol' : null,
    );
  }

  Widget _buildCreateButton(CreateUserState state) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: state.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Crear Usuario',
              style: AppTextStyles.heading4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Validar rol de trabajo si es necesario
    if (_selectedRoleName == 'TRABAJADOR') {
      if (_selectedWorkType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione el tipo de trabajador')),
        );
        return;
      }
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
