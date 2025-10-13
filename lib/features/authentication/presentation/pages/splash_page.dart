// splash_page.dart
//
// Página de splash/carga inicial
//
// PROPÓSITO:
// - Pantalla inicial mientras se carga la app
// - Verificar estado de autenticación
// - Inicializar servicios necesarios
// - Navegación automática según estado de login
//
// CAPA: PRESENTATION LAYER
// DEPENDENCIAS: Puede importar Flutter, providers, widgets

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// Página de splash con verificación de autenticación
///
/// Proporciona una interfaz de carga inicial mientras la aplicación
/// verifica el estado de autenticación del usuario.
///
/// **Características**:
/// - Animación de fade-in para logo
/// - Verificación automática de token JWT
/// - Navegación automática según resultado
/// - Loading indicator elegante
/// - Manejo de errores
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _checkAuthenticationStatus();
  }

  /// Inicializa la animación de fade-in
  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  /// Verifica el estado de autenticación del usuario
  Future<void> _checkAuthenticationStatus() async {
    // Esperar animación mínima (mejor UX)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar estado de autenticación usando el provider
    // GoRouter manejará automáticamente la redirección
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de EBSA
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.business,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Título principal
              Text(
                'Nexus EBSA',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Sistema de Reportes de Incidentes',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Indicador de carga
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Texto de carga
              Text(
                'Verificando sesión...',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),

              const SizedBox(height: 80),

              // Versión de la app
              Text(
                'v1.0.0',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
              ),

              const SizedBox(height: 8),

              // Copyright
              Text(
                'EBSA S.A.E.S.P. © 2025',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
