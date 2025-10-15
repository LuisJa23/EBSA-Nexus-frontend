// user_created_success_card.dart
//
// Widget de tarjeta flotante para mostrar usuario creado
//
// PROPÓSITO:
// - Mostrar datos del usuario recién creado
// - Confirmación visual elegante
// - Verificación de datos
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/domain/entities/user.dart';

/// Muestra un diálogo flotante con los datos del usuario creado
void showUserCreatedSuccessDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: UserCreatedSuccessCard(user: user),
    ),
  );
}

/// Tarjeta flotante que muestra los datos del usuario creado
class UserCreatedSuccessCard extends StatelessWidget {
  final User user;

  const UserCreatedSuccessCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), _buildUserInfo(), _buildActions(context)],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono de éxito
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            '¡Usuario Creado!',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'El usuario ha sido registrado exitosamente',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre completo
          _buildInfoRow(
            icon: Icons.person,
            label: 'Nombre Completo',
            value: user.fullName,
            isPrimary: true,
          ),
          const Divider(height: 24),

          // Email
          _buildInfoRow(
            icon: Icons.email,
            label: 'Correo Electrónico',
            value: user.email,
            canCopy: true,
          ),
          const SizedBox(height: 16),

          // Username
          if (user.username != null) ...[
            _buildInfoRow(
              icon: Icons.account_circle,
              label: 'Usuario',
              value: user.username!,
              canCopy: true,
            ),
            const SizedBox(height: 16),
          ],

          // Documento
          if (user.documentNumber != null) ...[
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Documento',
              value: user.documentNumber!,
            ),
            const SizedBox(height: 16),
          ],

          // Teléfono
          if (user.phoneNumber != null) ...[
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Teléfono',
              value: user.phoneNumber!,
            ),
            const SizedBox(height: 16),
          ],

          // Rol
          _buildInfoRow(
            icon: Icons.work,
            label: 'Rol del Sistema',
            value: _getRoleDisplayName(user.role),
          ),
          const SizedBox(height: 16),

          // Tipo de trabajo y área
          if (user.workType != null && user.workArea != null) ...[
            _buildInfoRow(
              icon: Icons.business_center,
              label: 'Área de Trabajo',
              value:
                  '${user.workArea} (${_getWorkTypeDisplayName(user.workType!)})',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPrimary = false,
    bool canCopy = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícono
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isPrimary ? AppColors.primary : Colors.grey.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: isPrimary
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      )
                    : AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
              ),
            ],
          ),
        ),
        // Botón copiar
        if (canCopy) ...[
          const SizedBox(width: 8),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copiado al portapapeles'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: 'Copiar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar diálogo
            Navigator.of(context).pop(); // Volver a página anterior
          },
          icon: const Icon(Icons.check),
          label: const Text('Entendido'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.fieldWorker:
        return 'Trabajador';
      case UserRole.areaManager:
        return 'Jefe de Área';
      case UserRole.contractor:
        return 'Contratista';
    }
  }

  String _getWorkTypeDisplayName(String workType) {
    switch (workType.toLowerCase()) {
      case 'intern':
        return 'Interno';
      case 'extern':
        return 'Externo';
      default:
        return workType;
    }
  }
}
