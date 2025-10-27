// notification_polling_service.dart
//
// Servicio de polling para actualizar notificaciones periódicamente
//
// PROPÓSITO:
// - Actualizar notificaciones cada X segundos automáticamente
// - Gestionar el ciclo de vida del polling (start/stop)
// - Optimizar con actualizaciones silenciosas

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_provider.dart';

/// Servicio para polling de notificaciones
///
/// Actualiza las notificaciones automáticamente cada cierto intervalo
/// sin necesidad de que el usuario refresque manualmente
class NotificationPollingService {
  final Ref ref;
  final int userId;
  final Duration interval;

  Timer? _timer;
  bool _isRunning = false;

  NotificationPollingService({
    required this.ref,
    required this.userId,
    this.interval = const Duration(seconds: 30),
  });

  /// Inicia el polling automático
  void start() {
    if (_isRunning) {
      print('⚠️ Polling ya está corriendo');
      return;
    }

    print(
      '🚀 Iniciando polling de notificaciones cada ${interval.inSeconds}s...',
    );
    _isRunning = true;

    // Cargar inmediatamente
    _loadNotifications();

    // Luego actualizar periódicamente
    _timer = Timer.periodic(interval, (_) {
      if (_isRunning) {
        _loadNotifications();
      }
    });
  }

  /// Detiene el polling
  void stop() {
    if (!_isRunning) return;

    print('⏸️ Deteniendo polling de notificaciones...');
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Pausa temporalmente (mantiene el timer pero no hace peticiones)
  void pause() {
    _isRunning = false;
    print('⏸️ Polling pausado');
  }

  /// Resume después de pausar
  void resume() {
    _isRunning = true;
    print('▶️ Polling resumido');
  }

  /// Carga las notificaciones de forma silenciosa
  Future<void> _loadNotifications() async {
    try {
      // Usar refreshNotifications en lugar de loadNotifications
      // para no mostrar el loading spinner
      await ref
          .read(notificationProvider(userId).notifier)
          .refreshNotifications();
    } catch (e) {
      print('❌ Error en polling: $e');
      // No hacer nada, el siguiente ciclo lo intentará de nuevo
    }
  }

  /// Forzar una actualización inmediata
  Future<void> forceRefresh() async {
    await _loadNotifications();
  }

  /// Libera los recursos
  void dispose() {
    stop();
  }

  /// Verifica si el polling está corriendo
  bool get isRunning => _isRunning;
}

/// Provider del servicio de polling
///
/// Se debe inicializar con el userId del usuario autenticado
final notificationPollingServiceProvider =
    Provider.family<NotificationPollingService, int>((ref, userId) {
      final service = NotificationPollingService(
        ref: ref,
        userId: userId,
        interval: const Duration(seconds: 30), // Actualizar cada 30 segundos
      );

      // Limpiar cuando se destruya el provider
      ref.onDispose(() {
        service.dispose();
      });

      return service;
    });
