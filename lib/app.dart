// app.dart
//
// Widget principal de la aplicación EBSA Nexus
//
// PROPÓSITO:
// - Configurar MaterialApp o CupertinoApp
// - Integrar router y navegación
// - Configurar tema global
// - Setup de providers globales
// - Localización y internacionalización

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget principal de la aplicación EBSA Nexus
///
/// Configura el MaterialApp con tema corporativo,
/// navegación reactiva y configuraciones globales.
///
/// **Configuraciones incluidas**:
/// - Tema corporativo EBSA (claro/oscuro)
/// - Navegación con GoRouter (reactiva al estado de auth)
/// - Localización en español
/// - Configuraciones de debugging
/// - Manejo global de errores
class NexusEBSAApp extends ConsumerWidget {
  const NexusEBSAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener router configurado con guards de autenticación
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // ========================================================================
      // CONFIGURACIÓN BÁSICA
      // ========================================================================
      title: 'EBSA Nexus',
      debugShowCheckedModeBanner: false,

      // ========================================================================
      // CONFIGURACIÓN DE TEMA
      // ========================================================================
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Usar tema del sistema por defecto
      // ========================================================================
      // LOCALIZACIÓN
      // ========================================================================
      locale: const Locale('es', 'CO'), // Español Colombia
      supportedLocales: const [
        Locale('es', 'CO'), // Español Colombia
        Locale('es', ''), // Español genérico
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ========================================================================
      // NAVEGACIÓN CON GO_ROUTER
      // ========================================================================
      routerConfig: router,

      // ========================================================================
      // CONFIGURACIONES ADICIONALES
      // ========================================================================

      // Configuración de error widgets
      builder: (context, child) {
        // Configurar error widget personalizado
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return _buildErrorWidget(errorDetails);
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }

  /// Construye un widget de error personalizado
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    return Material(
      color: Colors.red.shade50,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error en la aplicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (kDebugMode) ...[
              Text(
                errorDetails.exception.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Ha ocurrido un error inesperado.\nPor favor, reinicia la aplicación.',
                style: TextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
