// jwt_validator.dart
//
// Utilidad para validación de tokens JWT
//
// PROPÓSITO:
// - Decodificar tokens JWT sin verificar firma
// - Validar expiración del token
// - Extraer información del payload
// - Calcular tiempo hasta expiración
//
// CAPA: CORE UTILITIES
// DEPENDENCIAS: dart_jsonwebtoken

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Utilidad para validar y extraer información de tokens JWT
///
/// Proporciona métodos estáticos para trabajar con JSON Web Tokens,
/// incluyendo validación de expiración y extracción de payload.
///
/// **Características**:
/// - Decodifica JWT sin verificar firma (solo validación de estructura)
/// - Verifica expiración contra fecha actual
/// - Extrae payload completo
/// - Calcula tiempo restante hasta expiración
/// - Manejo seguro de errores
class JwtValidator {
  // Constructor privado para prevenir instanciación
  JwtValidator._();

  /// Valida si el token JWT es válido y no ha expirado
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a validar
  ///
  /// **Retorna**:
  /// - `true`: Token válido y no expirado
  /// - `false`: Token inválido, mal formado o expirado
  ///
  /// **Ejemplo**:
  /// ```dart
  /// final token = 'eyJhbGci...';
  /// if (JwtValidator.isTokenValid(token)) {
  ///   print('Token válido');
  /// }
  /// ```
  static bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      // Decodificar sin verificar firma (solo estructura y expiración)
      final jwt = JWT.decode(token);
      final payload = jwt.payload;

      // Verificar que el payload sea un mapa
      if (payload is! Map) {
        return false;
      }

      // Verificar que tenga campo de expiración
      if (!payload.containsKey('exp')) {
        // Si no tiene exp, considerarlo inválido por seguridad
        return false;
      }

      // Obtener expiración
      final exp = payload['exp'];
      if (exp == null) {
        return false;
      }

      // Convertir a int si es necesario
      final expInt = exp is int ? exp : int.tryParse(exp.toString());
      if (expInt == null) {
        return false;
      }

      // Convertir timestamp de segundos a milisegundos
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expInt * 1000);

      // Verificar que no haya expirado
      final now = DateTime.now();
      return expirationDate.isAfter(now);
    } catch (e) {
      // Error al decodificar o procesar token
      return false;
    }
  }

  /// Obtiene el tiempo hasta la expiración en segundos
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a analizar
  ///
  /// **Retorna**:
  /// - Número de segundos hasta expiración (puede ser negativo si ya expiró)
  /// - `null` si el token es inválido o no tiene campo `exp`
  ///
  /// **Ejemplo**:
  /// ```dart
  /// final seconds = JwtValidator.getSecondsUntilExpiration(token);
  /// if (seconds != null && seconds < 300) {
  ///   print('Token expira en menos de 5 minutos');
  /// }
  /// ```
  static int? getSecondsUntilExpiration(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final jwt = JWT.decode(token);
      final payload = jwt.payload;

      if (payload is! Map || !payload.containsKey('exp')) {
        return null;
      }

      final exp = payload['exp'];
      if (exp == null) {
        return null;
      }

      final expInt = exp is int ? exp : int.tryParse(exp.toString());
      if (expInt == null) {
        return null;
      }

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expInt * 1000);

      final now = DateTime.now();
      return expirationDate.difference(now).inSeconds;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si el token está próximo a expirar
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a verificar
  /// - [thresholdSeconds]: Umbral en segundos (default: 300 = 5 minutos)
  ///
  /// **Retorna**:
  /// - `true`: Token expira en menos del tiempo especificado
  /// - `false`: Token tiene más tiempo o es inválido
  ///
  /// **Ejemplo**:
  /// ```dart
  /// if (JwtValidator.isTokenExpiringSoon(token, 600)) {
  ///   // Token expira en menos de 10 minutos, refrescar
  ///   await refreshToken();
  /// }
  /// ```
  static bool isTokenExpiringSoon(String? token, {int thresholdSeconds = 300}) {
    final seconds = getSecondsUntilExpiration(token);
    if (seconds == null) {
      return false;
    }

    return seconds > 0 && seconds <= thresholdSeconds;
  }

  /// Extrae el payload completo del JWT
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a decodificar
  ///
  /// **Retorna**:
  /// - Mapa con el contenido del payload
  /// - `null` si el token es inválido
  ///
  /// **Ejemplo**:
  /// ```dart
  /// final payload = JwtValidator.getPayload(token);
  /// if (payload != null) {
  ///   final email = payload['sub'];
  ///   final role = payload['role'];
  ///   print('Usuario: $email, Rol: $role');
  /// }
  /// ```
  static Map<String, dynamic>? getPayload(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final jwt = JWT.decode(token);
      final payload = jwt.payload;

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extrae el subject (usuario) del token
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a decodificar
  ///
  /// **Retorna**:
  /// - String con el subject (generalmente email o username)
  /// - `null` si el token es inválido o no tiene `sub`
  ///
  /// **Ejemplo**:
  /// ```dart
  /// final email = JwtValidator.getSubject(token);
  /// print('Usuario logueado: $email');
  /// ```
  static String? getSubject(String? token) {
    final payload = getPayload(token);
    if (payload == null || !payload.containsKey('sub')) {
      return null;
    }

    return payload['sub']?.toString();
  }

  /// Extrae el issuer (emisor) del token
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a decodificar
  ///
  /// **Retorna**:
  /// - String con el issuer
  /// - `null` si el token es inválido o no tiene `iss`
  ///
  /// **Ejemplo**:
  /// ```dart
  /// final issuer = JwtValidator.getIssuer(token);
  /// if (issuer != 'ebsa-nexus-backend') {
  ///   print('Token de emisor no autorizado');
  /// }
  /// ```
  static String? getIssuer(String? token) {
    final payload = getPayload(token);
    if (payload == null || !payload.containsKey('iss')) {
      return null;
    }

    return payload['iss']?.toString();
  }

  /// Verifica si el token fue emitido por un issuer específico
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a verificar
  /// - [expectedIssuer]: Issuer esperado
  ///
  /// **Retorna**:
  /// - `true`: Token emitido por el issuer esperado
  /// - `false`: Token de otro issuer o inválido
  static bool isFromIssuer(String? token, String expectedIssuer) {
    final issuer = getIssuer(token);
    return issuer == expectedIssuer;
  }

  /// Obtiene información resumida del token para debugging
  ///
  /// **ADVERTENCIA**: No usar en producción, solo para debugging.
  /// No expone información sensible pero puede revelar estructura.
  ///
  /// **Parámetros**:
  /// - [token]: Token JWT a analizar
  ///
  /// **Retorna**:
  /// - String con información del token
  ///
  /// **Ejemplo**:
  /// ```dart
  /// print(JwtValidator.getTokenInfo(token));
  /// // Output: "Token: valid, expires in 3600s, subject: admin@ebsa.com.co"
  /// ```
  static String getTokenInfo(String? token) {
    if (token == null || token.isEmpty) {
      return 'Token: empty or null';
    }

    try {
      final isValid = isTokenValid(token);
      final seconds = getSecondsUntilExpiration(token);
      final subject = getSubject(token);
      final issuer = getIssuer(token);

      final buffer = StringBuffer();
      buffer.write('Token: ${isValid ? 'valid' : 'invalid/expired'}');

      if (seconds != null) {
        if (seconds > 0) {
          buffer.write(', expires in ${seconds}s');
        } else {
          buffer.write(', expired ${seconds.abs()}s ago');
        }
      }

      if (subject != null) {
        buffer.write(', subject: $subject');
      }

      if (issuer != null) {
        buffer.write(', issuer: $issuer');
      }

      return buffer.toString();
    } catch (e) {
      return 'Token: error parsing ($e)';
    }
  }
}
