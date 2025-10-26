// notification_badge.dart
//
// Widget de badge para mostrar contador de notificaciones no leídas
//
// PROPÓSITO:
// - Mostrar el número de notificaciones no leídas
// - Usarse en el botón de notificaciones del AppBar o BottomNav
// - Actualizarse automáticamente con el provider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/notification_provider.dart';

/// Badge de notificaciones no leídas
///
/// Muestra un pequeño círculo con el número de notificaciones
/// sin leer sobre el widget hijo (típicamente un icono)
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final int userId;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.userId,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider(userId));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0 || showZero)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Badge simple (solo punto) para indicar que hay notificaciones
///
/// Útil cuando no se quiere mostrar el número exacto
class NotificationDotBadge extends ConsumerWidget {
  final Widget child;
  final int userId;

  const NotificationDotBadge({
    super.key,
    required this.child,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider(userId));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (hasUnread)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para mostrar el contador en formato de texto
///
/// Útil para mostrar en listas o áreas donde no se use badge circular
class NotificationCounter extends ConsumerWidget {
  final int userId;

  const NotificationCounter({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider(userId));

    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
