// notifications_page.dart
//
// Página de notificaciones del usuario
//
// PROPÓSITO:
// - Mostrar todas las notificaciones del usuario autenticado
// - Permitir filtrar por leídas/no leídas
// - Marcar como leídas y eliminar notificaciones
// - Actualización automática mediante polling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/providers/notification_polling_service.dart';
import '../../../notifications/presentation/widgets/notification_card.dart';
import '../providers/auth_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _filter = 'all'; // 'all', 'unread', 'read'
  int? _cachedUserId; // Guardar userId para usar en dispose

  @override
  void initState() {
    super.initState();
    // Cargar notificaciones al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cachear el userId para usar en dispose
      final authState = ref.read(authNotifierProvider);
      if (authState.user != null) {
        _cachedUserId = _parseUserId(authState.user!.id);
      }

      _loadNotifications();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _loadNotifications() {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      final userId = _parseUserId(authState.user!.id);
      if (userId != null) {
        ref.read(notificationProvider(userId).notifier).loadNotifications();
      }
    }
  }

  void _startPolling() {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null) {
      final userId = _parseUserId(authState.user!.id);
      if (userId != null) {
        ref.read(notificationPollingServiceProvider(userId)).start();
      }
    }
  }

  void _stopPolling() {
    // Usar userId cacheado en lugar de leer ref después de dispose
    if (_cachedUserId != null) {
      try {
        ref.read(notificationPollingServiceProvider(_cachedUserId!)).stop();
      } catch (e) {
        // Si falla, no hacer nada (widget ya disposed)
        print('Info: No se pudo detener polling, widget ya disposed');
      }
    }
  }

  /// Intenta parsear el userId del user.id
  /// Retorna null si no es un número válido
  int? _parseUserId(String id) {
    try {
      return int.parse(id);
    } catch (e) {
      print('⚠️ Error: user.id no es numérico: "$id"');
      print(
        '⚠️ El backend debe enviar un campo "id" numérico en la respuesta de login',
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Si no hay usuario autenticado, mostrar mensaje
    if (authState.user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No hay usuario autenticado',
            style: AppTextStyles.bodyLarge,
          ),
        ),
      );
    }

    final userId = authState.user!.id;
    final userIdInt = _parseUserId(userId);

    // Si el ID no es numérico, mostrar mensaje de error
    if (userIdInt == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error de configuración',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El usuario no tiene un ID numérico válido.\n\n'
                  'ID recibido: "$userId"\n\n'
                  'El backend debe enviar un campo "id" numérico en la respuesta de login.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final notificationState = ref.watch(notificationProvider(userIdInt));

    // Filtrar notificaciones según selección
    final filteredNotifications = _filter == 'all'
        ? notificationState.notifications
        : _filter == 'unread'
        ? notificationState.unreadNotifications
        : notificationState.notifications.where((n) => n.isRead).toList();

    return Scaffold(
      body: Column(
        children: [
          // Barra de filtros y acciones
          _buildFilterBar(notificationState, userIdInt),

          // Lista de notificaciones
          Expanded(
            child: notificationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : notificationState.error != null
                ? _buildErrorView(notificationState.error!)
                : filteredNotifications.isEmpty
                ? _buildEmptyView()
                : RefreshIndicator(
                    onRefresh: () async => _loadNotifications(),
                    child: ListView.builder(
                      itemCount: filteredNotifications.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () {
                            // Marcar como leída al tocar
                            if (!notification.isRead) {
                              ref
                                  .read(
                                    notificationProvider(userIdInt).notifier,
                                  )
                                  .markAsRead(notification.id);
                            }
                            // TODO: Navegar al detalle si tiene noveltyId
                          },
                          onMarkAsRead: () {
                            ref
                                .read(notificationProvider(userIdInt).notifier)
                                .markAsRead(notification.id);
                          },
                          onDelete: () {
                            _showDeleteConfirmation(
                              context,
                              userIdInt,
                              notification.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(NotificationState state, int userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contador y botón marcar todas como leídas
          Row(
            children: [
              Expanded(
                child: Text(
                  '${state.notifications.length} notificaciones',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.unreadCount > 0)
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(notificationProvider(userId).notifier)
                        .markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Marcar todas'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Chips de filtro
          Row(
            children: [
              _buildFilterChip('Todas', 'all', state.notifications.length),
              const SizedBox(width: 8),
              _buildFilterChip('No leídas', 'unread', state.unreadCount),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Leídas',
                'read',
                state.notifications.length - state.unreadCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyView() {
    String message = 'No hay notificaciones';
    if (_filter == 'unread') {
      message = '¡Todo al día! No hay notificaciones sin leer';
    } else if (_filter == 'read') {
      message = 'No hay notificaciones leídas';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar notificaciones',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int userId,
    int notificationId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta notificación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(notificationProvider(userId).notifier)
                  .deleteNotification(notificationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
