// loading_indicator.dart
//
// Widget de indicador de carga personalizado
//
// PROPÓSITO:
// - Mostrar estado de carga consistente en toda la app
// - Indicador específico para sincronización
// - Diferentes tipos según contexto (pequeño, grande, overlay)
// - Integración con temas claro/oscuro

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tipos de indicadores de carga disponibles
enum LoadingType {
  /// Indicador circular pequeño
  small,

  /// Indicador circular mediano (default)
  medium,

  /// Indicador circular grande
  large,

  /// Indicador lineal
  linear,
}

/// Widget de indicador de carga personalizado
///
/// Proporciona indicadores de carga consistentes con el tema
/// de la aplicación y diferentes tamaños según el contexto.
///
/// **Uso**:
/// ```dart
/// LoadingIndicator() // Tamaño medium por defecto
/// LoadingIndicator(type: LoadingType.small)
/// LoadingIndicator(message: 'Cargando datos...')
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Tipo de indicador
  final LoadingType type;

  /// Color del indicador (opcional)
  final Color? color;

  /// Mensaje opcional a mostrar debajo del indicador
  final String? message;

  /// Espaciado entre el indicador y el mensaje
  final double spacing;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.medium,
    this.color,
    this.message,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicator(),
        if (message != null) ...[SizedBox(height: spacing), _buildMessage()],
      ],
    );
  }

  /// Construye el indicador según el tipo
  Widget _buildIndicator() {
    final effectiveColor = color ?? AppColors.primary;

    switch (type) {
      case LoadingType.small:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );

      case LoadingType.medium:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );

      case LoadingType.large:
        return SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );

      case LoadingType.linear:
        return LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          backgroundColor: effectiveColor.withOpacity(0.2),
        );
    }
  }

  /// Construye el mensaje de carga
  Widget _buildMessage() {
    return Text(
      message!,
      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

/// Indicador de carga específico para sincronización
///
/// Muestra un indicador con colores y mensajes específicos
/// para operaciones de sincronización.
class SyncLoadingIndicator extends StatelessWidget {
  /// Mensaje personalizado (opcional)
  final String? message;

  const SyncLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicator(
      type: LoadingType.medium,
      color: AppColors.accent,
      message: message ?? 'Sincronizando...',
    );
  }
}

/// Indicador de carga que cubre toda la pantalla
///
/// Usado para operaciones que bloquean la interfaz completa.
class OverlayLoadingIndicator extends StatelessWidget {
  /// Mensaje a mostrar
  final String message;

  /// Si puede cancelarse tocando fuera
  final bool barrierDismissible;

  const OverlayLoadingIndicator({
    super.key,
    required this.message,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LoadingIndicator(
              type: LoadingType.large,
              message: message,
              spacing: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra el overlay de loading sobre la pantalla actual
  static void show(
    BuildContext context, {
    required String message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => OverlayLoadingIndicator(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Oculta el overlay de loading
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
