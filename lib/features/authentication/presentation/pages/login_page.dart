// login_page.dart
//
// Página de inicio de sesión
//
// PROPÓSITO:
// - Interfaz de usuario para autenticación
// - Formulario de credenciales (email/password)
// - Manejo de estados de UI (loading, error, success)
// - Navegación post-login
//
// CAPA: PRESENTATION LAYER
// DEPENDENCIAS: Puede importar Flutter, providers, widgets

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

/// Página principal de inicio de sesión
///
/// Proporciona la interfaz de usuario para que los usuarios
/// se autentiquen en la aplicación EBSA Nexus.
///
/// **Características**:
/// - Diseño responsive y accesible
/// - Manejo de estados con Riverpod
/// - Formulario validado
/// - Indicadores de loading y error
/// - Navegación automática post-login
/// - Tema corporativo de EBSA
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();

    // NO limpiar errores automáticamente - dejar que se muestren
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(authNotifierProvider.notifier).clearError();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el estado de autenticación
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      print(
        '🔍 LoginPage: Cambio de estado detectado - anterior: ${previous?.status}, nuevo: ${next.status}',
      );
      if (next.hasError) {
        print(
          '🔍 LoginPage: Error detectado en el listener: ${next.errorMessage}',
        );
      }
      _handleAuthStateChange(context, previous, next);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo y encabezado
                  _buildHeader(),

                  const SizedBox(height: 48),

                  // Formulario de login
                  _buildLoginContent(),

                  const SizedBox(height: 32),

                  // Enlaces adicionales
                  _buildFooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el encabezado con logo y título
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo de EBSA (imagen personalizada)
        Container(
          width: 120,
          height: 120,

          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              'assets/ebsa2.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Título principal
        Text(
          'EBSA Nexus',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Subtítulo
        Text(
          'Sistema de Reportes de Incidentes',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construye el contenido principal del login
  Widget _buildLoginContent() {
    final authState = ref.watch(authNotifierProvider);

    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título del formulario
            Text(
              'Iniciar Sesión',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Mostrar indicador de carga o formulario
            if (authState.isLoading) _buildLoadingIndicator() else LoginForm(),

            const SizedBox(height: 16),

            // Mostrar error si existe
            if (authState.hasError)
              _buildErrorDisplay(authState)
            else if (authState.status == AuthStatus.error)
              _buildErrorDisplay(authState),
          ],
        ),
      ),
    );
  }

  /// Construye el indicador de carga
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        LoadingIndicator(),
        SizedBox(height: 16),
        Text(
          'Iniciando sesión...',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Construye la visualización de errores
  Widget _buildErrorDisplay(AuthState authState) {
    print(
      '🔍 LoginPage: Mostrando error: ${authState.errorMessage} (${authState.errorCode})',
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              authState.errorMessage ?? 'Error desconocido',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              print('🔍 LoginPage: Usuario cerró error');
              ref.read(authNotifierProvider.notifier).clearError();
            },
            child: Text('Cerrar', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  /// Construye los enlaces del pie de página
  Widget _buildFooterLinks() {
    return Column(
      children: [
        // Información de ayuda
        TextButton(
          onPressed: _showHelpDialog,
          child: Text(
            '¿Necesitas ayuda?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Información de la aplicación
        Text(
          'EBSA Nexus v1.0.0',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        Text(
          'EBSA S.A.E.S.P. © 2024',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Maneja los cambios de estado de autenticación
  void _handleAuthStateChange(
    BuildContext context,
    AuthState? previous,
    AuthState next,
  ) {
    // Mostrar mensaje de éxito cuando se autentica (el router manejará la navegación)
    if (next.isAuthenticated && previous?.isAuthenticated != true) {
      _showSuccessMessage(context, next.user!.fullName);
      // El GoRouter se encargará automáticamente de la navegación
    }

    // Mostrar errores específicos
    if (next.hasError && previous?.hasError != true) {
      _handleLoginError(context, next);
    }
  }

  /// Muestra mensaje de éxito de login
  void _showSuccessMessage(BuildContext context, String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Bienvenido, $userName!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Maneja errores específicos de login
  void _handleLoginError(BuildContext context, AuthState authState) {
    print(
      '🔍 LoginPage: Manejando error de login: ${authState.errorMessage} (${authState.errorCode})',
    );

    // Los errores se muestran en el widget _buildErrorDisplay
    // Aquí podemos agregar lógica adicional según el tipo de error

    switch (authState.errorCode) {
      case 'INVALID_CREDENTIALS':
        print('🔍 LoginPage: Credenciales inválidas detectadas');
        // Error de credenciales - ya se muestra en pantalla
        break;
      case 'NETWORK_ERROR':
        print('🔍 LoginPage: Error de red detectado');
        // Error de red - mostrar dialog si es necesario
        break;
      case 'ACCOUNT_LOCKED':
        print('🔍 LoginPage: Cuenta bloqueada detectada');
        // Cuenta bloqueada - mostrar información específica
        _showAccountLockedDialog(context);
        break;
      default:
        print('🔍 LoginPage: Error no específico: ${authState.errorCode}');
        break;
    }
  }

  /// Muestra dialog de ayuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Usa tu email corporativo de EBSA'),
            Text('• La contraseña debe tener al menos 6 caracteres'),
            Text('• Verifica tu conexión a internet'),
            SizedBox(height: 16),
            Text('¿Sigues teniendo problemas?'),
            Text('Contacta al administrador del sistema.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Muestra dialog de cuenta bloqueada
  void _showAccountLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cuenta Bloqueada'),
        content: const Text(
          'Tu cuenta ha sido bloqueada temporalmente por seguridad. '
          'Espera 15 minutos e intenta nuevamente, o contacta al administrador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
