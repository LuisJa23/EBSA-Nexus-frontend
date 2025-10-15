// change_password_dialog.dart
//
// Diálogo para cambiar contraseña del usuario
//
// PROPÓSITO:
// - Interfaz amigable para cambio de contraseña
// - Validación en tiempo real
// - Feedback visual claro
// - Manejo de errores descriptivo
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/change_password_provider.dart';

/// Diálogo modal para cambiar la contraseña del usuario
///
/// **Características**:
/// - Validación en tiempo real
/// - Indicadores de fortaleza de contraseña
/// - Manejo de errores descriptivo
/// - Diseño limpio y amigable
/// - Loading states apropiados
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  // Controladores de texto
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Clave del formulario
  final _formKey = GlobalKey<FormState>();

  // Estado de visibilidad de contraseñas
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Envía el cambio de contraseña
  Future<void> _submitChangePassword() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ejecutar cambio de contraseña
    final result = await ref
        .read(changePasswordProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    if (!mounted) return;

    // Manejar resultado
    result.fold(
      (failure) {
        // El error ya se muestra en el diálogo mediante el estado
        // Solo necesitamos mantener el diálogo abierto
      },
      (_) {
        // Éxito - cerrar diálogo y mostrar mensaje
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Contraseña cambiada exitosamente')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final isLoading = state.status == ChangePasswordStatus.loading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCurrentPasswordField(),
                const SizedBox(height: 16),
                _buildNewPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                if (state.status == ChangePasswordStatus.error) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(state.errorMessage),
                ],
                const SizedBox(height: 24),
                _buildPasswordRequirements(),
                const SizedBox(height: 24),
                _buildActionButtons(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset, size: 32, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Cambiar Contraseña',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Asegúrate de usar una contraseña segura',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentPasswordField() {
    return TextFormField(
      controller: _currentPasswordController,
      obscureText: !_showCurrentPassword,
      decoration: InputDecoration(
        labelText: 'Contraseña Actual *',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showCurrentPassword = !_showCurrentPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese su contraseña actual';
        }
        return null;
      },
      enabled:
          ref.watch(changePasswordProvider).status !=
          ChangePasswordStatus.loading,
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_showNewPassword,
      decoration: InputDecoration(
        labelText: 'Nueva Contraseña *',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _showNewPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showNewPassword = !_showNewPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese la nueva contraseña';
        }
        if (value.length < 6) {
          return 'Debe tener al menos 6 caracteres';
        }
        if (value == _currentPasswordController.text) {
          return 'Debe ser diferente a la contraseña actual';
        }
        return null;
      },
      onChanged: (value) {
        // Revalidar campo de confirmación si ya tiene contenido
        if (_confirmPasswordController.text.isNotEmpty) {
          _formKey.currentState?.validate();
        }
      },
      enabled:
          ref.watch(changePasswordProvider).status !=
          ChangePasswordStatus.loading,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirmar Nueva Contraseña *',
        prefixIcon: const Icon(Icons.lock_clock),
        suffixIcon: IconButton(
          icon: Icon(
            _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirme la nueva contraseña';
        }
        if (value != _newPasswordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
      enabled:
          ref.watch(changePasswordProvider).status !=
          ChangePasswordStatus.loading,
    );
  }

  Widget _buildErrorMessage(String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Requisitos de contraseña:',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('• Mínimo 6 caracteres'),
          _buildRequirementItem('• Diferente a la contraseña actual'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        // Botón Cancelar
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Cambiar Contraseña
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitChangePassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isLoading ? 0 : 2,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Cambiar Contraseña',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
