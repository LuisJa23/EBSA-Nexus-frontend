// credentials.dart
//
// Entidad de dominio para Credenciales de autenticación
//
// PROPÓSITO:
// - Representar credenciales de login en el negocio
// - Validaciones de dominio para email y password
// - Inmutable y seguro
// - Encapsular lógica de autenticación
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// REGLAS CRÍTICAS:
// - NO importar Flutter, Dio, Drift, etc.
// - Solo Dart puro y packages como Equatable
// - Inmutable (final fields)

import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa las credenciales de autenticación
class Credentials extends Equatable {
  /// Email del usuario
  final String email;

  /// Contraseña del usuario
  final String password;

  /// Indica si las credenciales deben ser recordadas
  final bool rememberMe;

  const Credentials({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  /// Factory constructor con validaciones de negocio
  factory Credentials.create({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    // Validaciones de dominio
    if (email.isEmpty) {
      throw ArgumentError('El email no puede estar vacío');
    }

    if (password.isEmpty) {
      throw ArgumentError('La contraseña no puede estar vacía');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('El formato del email no es válido');
    }

    if (password.length < 6) {
      throw ArgumentError('La contraseña debe tener al menos 6 caracteres');
    }

    return Credentials(
      email: email.trim().toLowerCase(),
      password: password,
      rememberMe: rememberMe,
    );
  }

  /// Crea credenciales para login rápido (sin validación de password)
  factory Credentials.forQuickLogin({required String email}) {
    return Credentials(
      email: email.trim().toLowerCase(),
      password: '', // Password vacío para quick login
      rememberMe: true,
    );
  }

  /// Copia las credenciales con campos actualizados
  Credentials copyWith({String? email, String? password, bool? rememberMe}) {
    return Credentials(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  /// Actualiza el estado de "recordar sesión"
  Credentials updateRememberMe(bool remember) {
    return copyWith(rememberMe: remember);
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  /// Verifica si las credenciales son válidas para login
  bool get isValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        _isValidEmail(email) &&
        password.length >= 6;
  }

  /// Verifica si es un login rápido (sin password)
  bool get isQuickLogin {
    return email.isNotEmpty && password.isEmpty && rememberMe;
  }

  /// Obtiene el dominio del email
  String get emailDomain {
    if (!_isValidEmail(email)) return '';
    return email.split('@')[1];
  }

  /// Verifica si es un email corporativo de EBSA
  bool get isEBSAEmail {
    final domain = emailDomain.toLowerCase();
    return domain == 'ebsa.com.co' || domain == 'ebsa.gov.co';
  }

  /// Obtiene información de fortaleza de la contraseña
  PasswordStrength get passwordStrength {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;

    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (hasLower) score++;
    if (hasUpper) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;

    if (password.length >= 12 && score >= 3) return PasswordStrength.strong;
    if (password.length >= 10 && score >= 2) return PasswordStrength.good;
    return PasswordStrength.fair;
  }

  /// Valida el formato del email
  static bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Convierte a mapa para envío a API (sin incluir rememberMe)
  Map<String, dynamic> toApiMap() {
    return {'email': email, 'password': password};
  }

  /// Versión sanitizada para logs (sin password)
  Map<String, dynamic> toLogMap() {
    return {
      'email': email,
      'rememberMe': rememberMe,
      'isValid': isValid,
      'isQuickLogin': isQuickLogin,
      'passwordLength': password.length,
    };
  }

  @override
  List<Object?> get props => [email, password, rememberMe];

  @override
  String toString() {
    return 'Credentials(email: $email, rememberMe: $rememberMe, passwordLength: ${password.length})';
  }
}

/// Enum para representar la fortaleza de la contraseña
enum PasswordStrength {
  none('Sin contraseña', 0),
  weak('Débil', 1),
  fair('Regular', 2),
  good('Buena', 3),
  strong('Fuerte', 4);

  const PasswordStrength(this.description, this.score);

  /// Descripción legible
  final String description;

  /// Puntuación numérica (0-4)
  final int score;

  /// Color sugerido para mostrar la fortaleza
  String get colorHint {
    switch (this) {
      case PasswordStrength.none:
        return 'grey';
      case PasswordStrength.weak:
        return 'red';
      case PasswordStrength.fair:
        return 'orange';
      case PasswordStrength.good:
        return 'yellow';
      case PasswordStrength.strong:
        return 'green';
    }
  }

  /// Porcentaje de fortaleza (0-100)
  double get percentage {
    return (score / 4.0) * 100;
  }
}
//
// CONTENIDO ESPERADO:
// - class Credentials extends Equatable
// - final String email, password
// - final bool rememberMe
// - Constructor con validaciones de dominio
// - @override List<Object?> get props
// - factory Credentials.create() con validaciones
// - bool get isValid
// - Validaciones: email format, password strength
// - toString() sin exponer password (para logs)