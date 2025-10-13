// home_action_card.dart
//
// Widget reutilizable para las tarjetas de acción del home
//
// PROPÓSITO:
// - Tarjeta con icono, título y subtítulo
// - Diseño consistente con la imagen de referencia
// - Interacción con onTap para navegación
//
// CAPA: PRESENTATION LAYER - Widgets compartidos

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget de tarjeta de acción para el home
///
/// Muestra una tarjeta con icono, título y subtítulo
/// siguiendo el diseño corporativo de EBSA.
///
/// **Características**:
/// - Icono con fondo amarillo/dorado
/// - Título y subtítulo personalizables
/// - Animación al hacer tap
/// - Elevación y sombras suaves
class HomeActionCard extends StatelessWidget {
  /// Icono a mostrar en la tarjeta
  final IconData icon;

  /// Título principal de la acción
  final String title;

  /// Subtítulo descriptivo de la acción
  final String subtitle;

  /// Callback cuando se hace tap en la tarjeta
  final VoidCallback onTap;

  /// Color del fondo del icono (por defecto amarillo)
  final Color? iconBackgroundColor;

  /// Color del icono (por defecto blanco)
  final Color? iconColor;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono con fondo amarillo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: iconColor ?? Colors.white),
              ),

              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      title,
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
