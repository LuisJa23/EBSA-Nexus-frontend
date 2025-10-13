// auth_local_datasource.dart
//
// Fuente de datos local para autenticación
//
// PROPÓSITO:
// - Almacenamiento seguro de tokens y credenciales
// - Cache de información del usuario
// - Persistencia de estado de login
// - Manejo de datos offline
//
// CAPA: DATA LAYER
// DEPENDENCIAS: Puede importar SharedPreferences, SecureStorage, Drift

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/jwt_validator.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

/// Contrato para la fuente de datos local de autenticación
///
/// Define las operaciones de almacenamiento local para datos
/// de autenticación, tokens y cache de usuario.
abstract class AuthLocalDataSource {
  // ===========================================================================
  // GESTIÓN DE TOKENS
  // ===========================================================================

  /// Almacena el token de acceso de forma segura
  Future<void> saveAccessToken(String token);

  /// Obtiene el token de acceso almacenado
  Future<String?> getAccessToken();

  /// Almacena el refresh token de forma segura
  Future<void> saveRefreshToken(String refreshToken);

  /// Obtiene el refresh token almacenado
  Future<String?> getRefreshToken();

  /// Verifica si existe un token válido
  Future<bool> hasValidToken();

  // ===========================================================================
  // GESTIÓN DE USUARIO
  // ===========================================================================

  /// Almacena datos del usuario en cache
  Future<void> saveUser(UserModel user);

  /// Obtiene datos del usuario desde cache
  Future<UserModel?> getCachedUser();

  /// Actualiza la fecha de último login
  Future<void> updateLastLogin();

  // ===========================================================================
  // GESTIÓN DE CREDENCIALES
  // ===========================================================================

  /// Almacena email para "recordar usuario"
  Future<void> saveRememberedEmail(String email);

  /// Obtiene email recordado
  Future<String?> getRememberedEmail();

  /// Almacena preferencia de "recordar sesión"
  Future<void> saveRememberMe(bool remember);

  /// Obtiene preferencia de "recordar sesión"
  Future<bool> getRememberMe();

  // ===========================================================================
  // LIMPIEZA Y LOGOUT
  // ===========================================================================

  /// Limpia todos los datos de autenticación
  Future<void> clearAuthData();

  /// Limpia solo tokens (mantiene preferencias)
  Future<void> clearTokens();

  /// Limpia cache de usuario
  Future<void> clearUserCache();
}

/// Implementación de la fuente de datos local de autenticación
///
/// Utiliza flutter_secure_storage para datos sensibles (tokens)
/// y SharedPreferences para preferencias y cache no sensible.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  /// Almacenamiento seguro para tokens
  final FlutterSecureStorage _secureStorage;

  /// Preferencias compartidas para cache y preferencias
  final SharedPreferences _sharedPreferences;

  /// Constructor que recibe las dependencias
  const AuthLocalDataSourceImpl(this._secureStorage, this._sharedPreferences);

  // ===========================================================================
  // GESTIÓN DE TOKENS
  // ===========================================================================

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      AppLogger.debug('Guardando access token en SecureStorage...');

      await _secureStorage.write(
        key: StorageConstants.accessTokenKey,
        value: token,
      );

      // Guardar timestamp del token para validación de expiración
      await _sharedPreferences.setInt(
        StorageConstants.tokenTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      AppLogger.tokenSaved('ACCESS_TOKEN');

      // Verificar que se guardó correctamente
      final savedToken = await _secureStorage.read(
        key: StorageConstants.accessTokenKey,
      );

      if (savedToken == null || savedToken.isEmpty) {
        AppLogger.error('⚠️ CRITICAL: Token no se guardó correctamente');
        throw CacheException(
          message: 'Fallo crítico: token no persistió',
          code: 'TOKEN_PERSISTENCE_FAILED',
        );
      }

      AppLogger.debug('✅ Verificación: Token guardado correctamente');
    } catch (e) {
      AppLogger.cacheError('saveAccessToken', e);
      throw CacheException(
        message: 'Error guardando token de acceso: $e',
        code: 'SAVE_ACCESS_TOKEN_ERROR',
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      AppLogger.debug('Leyendo access token de SecureStorage...');

      final token = await _secureStorage.read(
        key: StorageConstants.accessTokenKey,
      );

      AppLogger.tokenRead('ACCESS_TOKEN', token != null && token.isNotEmpty);

      return token;
    } catch (e) {
      AppLogger.cacheError('getAccessToken', e);
      throw CacheException(
        message: 'Error leyendo token de acceso: $e',
        code: 'READ_ACCESS_TOKEN_ERROR',
      );
    }
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      AppLogger.debug('Guardando refresh token en SecureStorage...');

      await _secureStorage.write(
        key: StorageConstants.refreshTokenKey,
        value: refreshToken,
      );

      AppLogger.tokenSaved('REFRESH_TOKEN');
    } catch (e) {
      AppLogger.cacheError('saveRefreshToken', e);
      throw CacheException(
        message: 'Error guardando refresh token: $e',
        code: 'SAVE_REFRESH_TOKEN_ERROR',
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      AppLogger.debug('Leyendo refresh token de SecureStorage...');

      final token = await _secureStorage.read(
        key: StorageConstants.refreshTokenKey,
      );

      AppLogger.tokenRead('REFRESH_TOKEN', token != null && token.isNotEmpty);

      return token;
    } catch (e) {
      AppLogger.cacheError('getRefreshToken', e);
      throw CacheException(
        message: 'Error leyendo refresh token: $e',
        code: 'READ_REFRESH_TOKEN_ERROR',
      );
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      AppLogger.debug('Verificando validez del token...');

      final token = await getAccessToken();

      if (token == null || token.isEmpty) {
        AppLogger.tokenRead('ACCESS_TOKEN', false);
        AppLogger.tokenValidation(false);
        return false;
      }

      // Usar validación real del JWT (decodifica y verifica expiración)
      final isValid = JwtValidator.isTokenValid(token);
      final secondsToExpire = isValid
          ? JwtValidator.getSecondsUntilExpiration(token)
          : null;

      AppLogger.tokenValidation(isValid, secondsToExpire: secondsToExpire);

      return isValid;
    } catch (e) {
      AppLogger.error('Error verificando token', error: e);
      return false;
    }
  }

  // ===========================================================================
  // GESTIÓN DE USUARIO
  // ===========================================================================

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      AppLogger.debug('Guardando usuario en cache: ${user.email}');

      final userJson = jsonEncode(user.toCacheJson());

      await _sharedPreferences.setString(
        StorageConstants.cachedUserKey,
        userJson,
      );

      // Actualizar timestamp del cache
      await _sharedPreferences.setInt(
        StorageConstants.userCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      AppLogger.cacheSaved('USER (${user.email})');
    } catch (e) {
      AppLogger.cacheError('saveUser', e);
      throw CacheException(
        message: 'Error guardando usuario en cache: $e',
        code: 'SAVE_USER_CACHE_ERROR',
      );
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      AppLogger.debug('Leyendo usuario de cache...');

      final userJson = _sharedPreferences.getString(
        StorageConstants.cachedUserKey,
      );

      if (userJson == null || userJson.isEmpty) {
        AppLogger.cacheRead('USER', false);
        return null;
      }

      // Verificar que el cache no esté muy viejo
      final timestamp = _sharedPreferences.getInt(
        StorageConstants.userCacheTimestampKey,
      );

      if (timestamp != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(cacheDate);

        // Cache válido por 24 horas
        if (difference.inHours > 24) {
          AppLogger.warning('Cache de usuario expirado (>24h), limpiando...');
          await clearUserCache();
          return null;
        }
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromCache(userMap);

      AppLogger.cacheRead('USER (${user.email})', true);

      return user;
    } catch (e) {
      // Si hay error leyendo cache, limpiar y retornar null
      AppLogger.cacheError('getCachedUser', e);
      await clearUserCache();
      return null;
    }
  }

  @override
  Future<void> updateLastLogin() async {
    try {
      await _sharedPreferences.setInt(
        StorageConstants.lastLoginTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Error no crítico, continuar
      print('Error actualizando último login: $e');
    }
  }

  // ===========================================================================
  // GESTIÓN DE CREDENCIALES
  // ===========================================================================

  @override
  Future<void> saveRememberedEmail(String email) async {
    try {
      await _sharedPreferences.setString(
        StorageConstants.rememberedEmailKey,
        email.toLowerCase().trim(),
      );
    } catch (e) {
      throw CacheException(
        message: 'Error guardando email recordado: $e',
        code: 'SAVE_REMEMBERED_EMAIL_ERROR',
      );
    }
  }

  @override
  Future<String?> getRememberedEmail() async {
    try {
      return _sharedPreferences.getString(StorageConstants.rememberedEmailKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRememberMe(bool remember) async {
    try {
      await _sharedPreferences.setBool(
        StorageConstants.rememberMeKey,
        remember,
      );
    } catch (e) {
      throw CacheException(
        message: 'Error guardando preferencia remember me: $e',
        code: 'SAVE_REMEMBER_ME_ERROR',
      );
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return _sharedPreferences.getBool(StorageConstants.rememberMeKey) ??
          false;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // LIMPIEZA Y LOGOUT
  // ===========================================================================

  @override
  Future<void> clearAuthData() async {
    try {
      AppLogger.debug('Limpiando todos los datos de autenticación...');

      // Limpiar tokens del almacenamiento seguro
      await _secureStorage.delete(key: StorageConstants.accessTokenKey);
      await _secureStorage.delete(key: StorageConstants.refreshTokenKey);

      // Limpiar cache de usuario
      await _sharedPreferences.remove(StorageConstants.cachedUserKey);
      await _sharedPreferences.remove(StorageConstants.userCacheTimestampKey);
      await _sharedPreferences.remove(StorageConstants.tokenTimestampKey);

      // Limpiar timestamps
      await _sharedPreferences.remove(StorageConstants.lastLoginTimestampKey);

      // NO limpiar preferencias del usuario (email recordado, remember me)
      // para mejorar UX en próximo login

      AppLogger.cacheCleared('AUTH_DATA');
    } catch (e) {
      AppLogger.cacheError('clearAuthData', e);
      throw CacheException(
        message: 'Error limpiando datos de autenticación: $e',
        code: 'CLEAR_AUTH_DATA_ERROR',
      );
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: StorageConstants.accessTokenKey);
      await _secureStorage.delete(key: StorageConstants.refreshTokenKey);
      await _sharedPreferences.remove(StorageConstants.tokenTimestampKey);
    } catch (e) {
      throw CacheException(
        message: 'Error limpiando tokens: $e',
        code: 'CLEAR_TOKENS_ERROR',
      );
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _sharedPreferences.remove(StorageConstants.cachedUserKey);
      await _sharedPreferences.remove(StorageConstants.userCacheTimestampKey);
    } catch (e) {
      throw CacheException(
        message: 'Error limpiando cache de usuario: $e',
        code: 'CLEAR_USER_CACHE_ERROR',
      );
    }
  }

  // ===========================================================================
  // MÉTODOS UTILITARIOS
  // ===========================================================================

  /// Obtiene información de debug sobre el estado del almacenamiento
  Future<Map<String, dynamic>> getStorageDebugInfo() async {
    try {
      final hasToken = await hasValidToken();
      final hasUser = await getCachedUser() != null;
      final rememberedEmail = await getRememberedEmail();
      final rememberMe = await getRememberMe();

      return {
        'has_valid_token': hasToken,
        'has_cached_user': hasUser,
        'remembered_email': rememberedEmail,
        'remember_me': rememberMe,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Error obteniendo debug info: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
