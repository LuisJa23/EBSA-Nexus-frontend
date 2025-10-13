// error_widget.dart
//
// Widget para mostrar errores de forma consistente
//
// PROPÓSITO:
// - Mostrar errores de red, validación, etc.
// - Botón de retry para operaciones fallidas
// - Diferentes tipos según severidad del error
// - Iconos y colores apropiados por tipo de error

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tipos de error disponibles
enum ErrorType {
  /// Error general
  general,

  /// Error de red/conectividad
  network,

  /// Error de validación
  validation,

  /// Error de autenticación
  authentication,

  /// Error del servidor
  server,
}

/// Widget personalizado para mostrar errores
///
/// Proporciona una interfaz consistente para mostrar errores
/// con iconos apropiados, mensajes descriptivos y acciones.
///
/// **Uso**:
/// ```dart
/// ErrorWidget(message: 'Error al cargar datos')
/// ErrorWidget(
///   message: 'Sin conexión',
///   type: ErrorType.network,
///   onRetry: () => reload(),
/// )
/// ```
class ErrorWidget extends StatelessWidget {
  /// Mensaje de error a mostrar
  final String message;

  /// Tipo de error
  final ErrorType type;

  /// Callback para reintentar
  final VoidCallback? onRetry;

  /// Si mostrar icono
  final bool showIcon;

  /// Icono personalizado (opcional)
  final IconData? customIcon;

  const ErrorWidget({
    super.key,
    required this.message,
    this.type = ErrorType.general,
    this.onRetry,
    this.showIcon = true,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBackgroundColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), color: _getIconColor(), size: 48),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: _getTextColor()),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  /// Obtiene el icono según el tipo de error
  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.validation:
        return Icons.warning_amber;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.general:
        return Icons.error_outline;
    }
  }

  /// Obtiene el color del icono
  Color _getIconColor() {
    switch (type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.validation:
        return AppColors.warning;
      case ErrorType.authentication:
        return AppColors.error;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.general:
        return AppColors.error;
    }
  }

  /// Obtiene el color de fondo
  Color _getBackgroundColor() {
    switch (type) {
      case ErrorType.network:
      case ErrorType.validation:
        return AppColors.warning;
      case ErrorType.authentication:
      case ErrorType.server:
      case ErrorType.general:
        return AppColors.error;
    }
  }

  /// Obtiene el color del texto
  Color _getTextColor() {
    return AppColors.textPrimary;
  }

  /// Construye el botón de reintentar
  Widget _buildRetryButton() {
    return TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Reintentar'),
      style: TextButton.styleFrom(
        foregroundColor: _getIconColor(),
        backgroundColor: _getIconColor().withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Widget de error específico para problemas de red
class NetworkErrorWidget extends StatelessWidget {
  /// Callback para reintentar
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message:
          'Sin conexión a internet.\nVerifica tu conectividad y vuelve a intentar.',
      type: ErrorType.network,
      onRetry: onRetry,
    );
  }
}

/// Widget de error específico para validación
class ValidationErrorWidget extends StatelessWidget {
  /// Mensaje específico de validación
  final String message;

  const ValidationErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: message,
      type: ErrorType.validation,
      showIcon: false,
    );
  }
}

/// Widget de error para autenticación
class AuthenticationErrorWidget extends StatelessWidget {
  /// Callback para reintentar login
  final VoidCallback? onRetry;

  const AuthenticationErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: 'Credenciales inválidas.\nVerifica tu email y contraseña.',
      type: ErrorType.authentication,
      onRetry: onRetry,
    );
  }
}

/// Estado vacío con mensaje personalizado
class EmptyStateWidget extends StatelessWidget {
  /// Mensaje a mostrar
  final String message;

  /// Icono del estado vacío
  final IconData icon;

  /// Callback de acción (opcional)
  final VoidCallback? onAction;

  /// Texto del botón de acción
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}
