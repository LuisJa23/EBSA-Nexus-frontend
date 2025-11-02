// sync_status_indicator.dart
//
// Widget para indicar el estado de sincronización
//
// PROPÓSITO:
// - Chip visual de estado de sync
// - Colores según estado (pendiente/sincronizado/error)
// - Íconos descriptivos
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';

/// Indicador de estado de sincronización
///
/// Muestra un chip con:
/// - Color según estado
/// - Ícono descriptivo
/// - Texto de estado
class SyncStatusIndicator extends StatelessWidget {
  final bool isSynced;
  final bool hasError;

  const SyncStatusIndicator({
    super.key,
    required this.isSynced,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    final text = _getText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según el estado
  Color _getColor() {
    if (hasError) return Colors.red;
    if (isSynced) return Colors.green;
    return Colors.orange;
  }

  /// Obtiene el ícono según el estado
  IconData _getIcon() {
    if (hasError) return Icons.error_outline;
    if (isSynced) return Icons.check_circle_outline;
    return Icons.sync;
  }

  /// Obtiene el texto según el estado
  String _getText() {
    if (hasError) return 'Error';
    if (isSynced) return 'Sincronizado';
    return 'Pendiente';
  }
}
