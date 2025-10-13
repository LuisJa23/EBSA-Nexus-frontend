// login_form.dart
//
// Formulario de inicio de sesión
//
// PROPÓSITO:
// - Widget reutilizable del formulario de login
// - Validación en tiempo real de campos
// - Manejo de submit y estados
// - UI/UX optimizada para móvil
//
// CAPA: PRESENTATION LAYER
// DEPENDENCIAS: Puede importar Flutter, form validators

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Formulario de inicio de sesión con validación completa
///
/// Proporciona una interfaz optimizada para que los usuarios
/// ingresen sus credenciales de manera segura y eficiente.
///
/// **Características**:
/// - Validación en tiempo real
/// - Campos específicos para email y contraseña
/// - Botón de submit con estado de loading
/// - Opción de recordar sesión
/// - Manejo de errores inline
/// - Diseño responsive
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // Estado del formulario
  bool _rememberSession = true;
  bool _autoValidate = false;

  // Focus nodes para navegación
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _disposeControllers();
    _disposeFocusNodes();
    super.dispose();
  }

  /// Inicializa los controladores de texto
  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Los campos inician vacíos por seguridad
    // El email se precargará si el usuario eligió recordar sesión
  }

  /// Carga el email recordado si existe
  Future<void> _loadRememberedEmail() async {
    try {
      // Acceder al data source local a través del repositorio inyectado
      final authState = ref.read(authNotifierProvider);

      // Si ya hay un email recordado en el estado, usarlo
      if (authState.rememberedEmail != null &&
          authState.rememberedEmail!.isNotEmpty) {
        _emailController.text = authState.rememberedEmail!;
        setState(() {
          _rememberSession = authState.rememberMe;
        });
      }
    } catch (e) {
      // Error cargando email - no crítico, continuar
      print('Error cargando email recordado: $e');
    }
  }

  /// Inicializa los focus nodes
  void _initializeFocusNodes() {
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  /// Libera los controladores
  void _disposeControllers() {
    _emailController.dispose();
    _passwordController.dispose();
  }

  /// Libera los focus nodes
  void _disposeFocusNodes() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Form(
      key: _formKey,
      autovalidateMode: _autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de email
          _buildEmailField(isLoading),

          const SizedBox(height: 16),

          // Campo de contraseña
          _buildPasswordField(isLoading),

          const SizedBox(height: 16),

          // Opción recordar sesión
          _buildRememberSessionOption(isLoading),

          const SizedBox(height: 24),

          // Botón de iniciar sesión
          _buildLoginButton(isLoading),
        ],
      ),
    );
  }

  /// Construye el campo de email
  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      style: AppTextStyles.input,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'ejemplo@ebsa.com.co',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: Validators.validateEmail,
      onFieldSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
    );
  }

  /// Construye el campo de contraseña
  Widget _buildPasswordField(bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      enabled: !isLoading,
      obscureText: true,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      style: AppTextStyles.input,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: Validators.validatePassword,
      onFieldSubmitted: (_) => _handleSubmit(),
    );
  }

  /// Construye la opción de recordar sesión
  Widget _buildRememberSessionOption(bool isLoading) {
    return Row(
      children: [
        Checkbox(
          value: _rememberSession,
          onChanged: isLoading
              ? null
              : (value) {
                  setState(() {
                    _rememberSession = value ?? false;
                  });
                },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    setState(() {
                      _rememberSession = !_rememberSession;
                    });
                  },
            child: Text(
              'Recordar mi sesión',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLoading
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el botón de iniciar sesión
  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _handleSubmit,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.login, size: 20),
        label: Text(
          isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión',
          style: AppTextStyles.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Maneja el envío del formulario
  void _handleSubmit() {
    // Quitar el foco de todos los campos
    FocusScope.of(context).unfocus();

    // Activar validación automática si no está activada
    if (!_autoValidate) {
      setState(() {
        _autoValidate = true;
      });
    }

    // Validar el formulario
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Realizar login usando el provider
      ref
          .read(authNotifierProvider.notifier)
          .login(
            email: email,
            password: password,
            rememberMe: _rememberSession,
          );
    } else {
      // Mostrar mensaje de validación
      _showValidationError();
    }
  }

  /// Muestra mensaje de error de validación
  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Por favor, corrige los errores en el formulario'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
