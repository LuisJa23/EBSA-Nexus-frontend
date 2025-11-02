import 'package:ebsa_nexus_frontend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  /// Parsea el userId a int
  int? _parseUserId(String id) {
    try {
      return int.parse(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icons = [
      PhosphorIcons.house,
      PhosphorIcons.bell,
      PhosphorIcons.clipboardText,
      PhosphorIcons.user,
    ];

    final labels = ['Home', 'Notificaciones', 'Asignaciones', 'Perfil'];

    // Obtener el número de notificaciones no leídas
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user != null
        ? _parseUserId(authState.user!.id)
        : null;
    final unreadCount = userId != null
        ? ref.watch(notificationProvider(userId)).unreadCount
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[index],
                        size: 22,
                        color: isActive ? Colors.white : Colors.black54,
                      ),
                    ),
                    // Badge de notificaciones no leídas (solo para el ícono de notificaciones)
                    if (index == 1 && unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.black : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
