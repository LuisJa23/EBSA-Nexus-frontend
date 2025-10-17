// empty_state_widget.dart
//
// Widget para estados vacíos (sin datos)
//
// PROPÓSITO:
// - Mostrar cuando no hay reportes, notificaciones, etc.
// - Guiar al usuario sobre próximos pasos
// - Mantener engagement cuando no hay contenido
// - Diferente según contexto (reportes, búsquedas, filtros)

import 'package:flutter/material.dart';

/// Widget genérico para estados vacíos
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? description;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.description,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
