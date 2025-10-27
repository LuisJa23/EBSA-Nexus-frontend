// notification_card.dart
//
// Widget de tarjeta individual de notificación
//
// PROPÓSITO:
// - Mostrar una notificación con su icono, título, mensaje y tiempo
// - Permitir marcar como leída y eliminar
// - Estilo visual según tipo y estado de lectura

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/notification_model.dart';

/// Tarjeta de notificación individual
///
/// Muestra la información completa de una notificación con
/// opciones para marcar como leída, eliminar, y navegar al detalle
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool showActions;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isUnread ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread
            ? BorderSide(color: notification.type.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icono, título y tiempo
              Row(
                children: [
                  // Icono del tipo de notificación
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notification.type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notification.type.iconData,
                      color: notification.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Título y tiempo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: notification.type.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón de menú de acciones
                  if (showActions)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'read':
                            onMarkAsRead?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (isUnread)
                          const PopupMenuItem(
                            value: 'read',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                SizedBox(width: 8),
                                Text('Marcar como leída'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Mensaje
              Text(
                notification.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUnread
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Badge del tipo de notificación
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: notification.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: notification.type.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  notification.type.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: notification.type.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Versión compacta de la tarjeta de notificación
///
/// Útil para listas cortas o previews
class NotificationCardCompact extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCardCompact({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notification.type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          notification.type.iconData,
          color: notification.type.color,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.message,
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            notification.timeAgo,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isUnread) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: notification.type.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
