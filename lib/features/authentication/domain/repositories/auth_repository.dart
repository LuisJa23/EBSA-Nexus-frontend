// auth_repository.dart
//
// Interfaz del repositorio de autenticación (Contrato)
//
// PROPÓSITO:
// - Definir contrato para operaciones de autenticación
// - Abstraer detalles de implementación de datos
// - Facilitar testing con mocks
// - Inversión de dependencias (Domain ← Data)
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// TIPO: Abstract class/Interface

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/credentials.dart';
import '../entities/user.dart';

/// Contrato del repositorio de autenticación
///
/// Define todas las operaciones relacionadas con autenticación
/// que deben ser implementadas por la capa de datos.
///
/// **IMPORTANTE**: Esta es una interfaz pura (abstract class)
/// sin implementación. La capa de datos proveerá la implementación
/// concreta manejando API remota, almacenamiento local y lógica offline.
abstract class AuthRepository {
  // ============================================================================
  // OPERACIONES DE AUTENTICACIÓN PRINCIPAL
  // ============================================================================

  /// Realiza login del usuario con credenciales
  ///
  /// **Entrada**: Credenciales validadas del dominio
  /// **Salida**: Usuario autenticado o falla específica
  ///
  /// **Comportamiento esperado**:
  /// 1. Validar credenciales en el servidor
  /// 2. Obtener token JWT del servidor
  /// 3. Almacenar token de forma segura (flutter_secure_storage)
  /// 4. Almacenar datos de usuario localmente
  /// 5. Configurar headers de autenticación para futuras requests
  ///
  /// **Casos de error**:
  /// - [AuthFailure.invalidCredentials]: Email/password incorrectos
  /// - [AuthFailure.accountLocked]: Cuenta bloqueada por intentos
  /// - [AuthFailure.serverError]: Error del servidor (5xx)
  /// - [NetworkFailure]: Sin conexión a internet
  /// - [CacheFailure]: Error al guardar token localmente
  Future<Either<Failure, User>> login(Credentials credentials);

  /// Cierra sesión del usuario actual
  ///
  /// **Comportamiento esperado**:
  /// 1. Notificar al servidor del logout (opcional si hay conexión)
  /// 2. Eliminar token JWT del almacenamiento seguro
  /// 3. Limpiar datos de usuario del cache local
  /// 4. Remover headers de autenticación
  /// 5. Actualizar estado de autenticación en streams
  ///
  /// **Casos de error**:
  /// - [CacheFailure]: Error al limpiar almacenamiento local
  /// - [NetworkFailure]: Sin conexión (se permite logout offline)
  Future<Either<Failure, void>> logout();

  // ============================================================================
  // GESTIÓN DE ESTADO DE AUTENTICACIÓN
  // ============================================================================

  /// Obtiene el usuario actualmente autenticado
  ///
  /// **Comportamiento esperado**:
  /// 1. Verificar si existe token válido en almacenamiento
  /// 2. Validar expiración del token
  /// 3. Obtener datos de usuario del cache local
  /// 4. Si token expirado, intentar refresh automático
  ///
  /// **Casos de error**:
  /// - [AuthFailure.tokenExpired]: Token expirado y no se pudo renovar
  /// - [AuthFailure.userNotFound]: No hay usuario autenticado
  /// - [CacheFailure]: Error al leer almacenamiento local
  Future<Either<Failure, User>> getCurrentUser();

  /// Verifica si hay un usuario autenticado
  ///
  /// **Comportamiento esperado**:
  /// 1. Verificar existencia de token en almacenamiento
  /// 2. Validar que el token no esté expirado
  /// 3. Retornar true/false sin cargar datos completos del usuario
  ///
  /// Esta operación debe ser rápida y usada para navegación inicial.
  Future<Either<Failure, bool>> isUserLoggedIn();

  // ============================================================================
  // GESTIÓN DE TOKENS
  // ============================================================================

  /// Renueva el token de autenticación
  ///
  /// **Comportamiento esperado**:
  /// 1. Usar refresh token para obtener nuevo JWT
  /// 2. Actualizar token en almacenamiento seguro
  /// 3. Actualizar headers de autenticación
  /// 4. Retornar usuario con datos actualizados
  ///
  /// **Casos de error**:
  /// - [AuthFailure.refreshTokenExpired]: Refresh token expirado
  /// - [AuthFailure.invalidRefreshToken]: Refresh token inválido
  /// - [NetworkFailure]: Sin conexión para renovar
  Future<Either<Failure, User>> refreshToken();

  /// Valida si el token actual es válido
  ///
  /// **Comportamiento esperado**:
  /// 1. Verificar formato del token JWT
  /// 2. Validar expiración del token
  /// 3. Opcionalmente validar con el servidor
  ///
  /// **Usado para**: Decidir si mostrar login o pantalla principal
  Future<Either<Failure, bool>> isTokenValid();

  // ============================================================================
  // STREAMS REACTIVOS
  // ============================================================================

  /// Stream que emite cambios en el estado de autenticación
  ///
  /// **Comportamiento esperado**:
  /// - Emite [User] cuando usuario se autentica
  /// - Emite [null] cuando usuario cierra sesión
  /// - Emite cambios cuando se actualiza perfil de usuario
  /// - Se mantiene activo durante toda la vida de la app
  ///
  /// **Usado para**: Navegación automática y UI reactiva
  Stream<User?> get authStateStream;

  /// Stream que indica el estado de conectividad para autenticación
  ///
  /// **Comportamiento esperado**:
  /// - Emite true cuando hay conexión y se puede autenticar
  /// - Emite false cuando está offline (modo lectura local)
  /// - Se usa para mostrar indicadores de estado offline/online
  Stream<bool> get connectivityStream;

  // ============================================================================
  // OPERACIONES DE PERFIL
  // ============================================================================

  /// Obtiene el perfil completo del usuario desde el servidor
  ///
  /// **Diferencia con getCurrentUser**:
  /// - getCurrentUser: Obtiene datos desde cache local (rápido, offline)
  /// - getUserProfile: Obtiene datos completos desde servidor (actualizado, completo)
  ///
  /// **Comportamiento esperado**:
  /// 1. Validar que el usuario esté autenticado
  /// 2. Hacer request GET a /api/users/me
  /// 3. Obtener datos completos (nombre, apellido, documento, teléfono, etc.)
  /// 4. Actualizar cache local con datos frescos
  /// 5. Retornar usuario con información completa
  ///
  /// **Casos de error**:
  /// - [AuthFailure.userNotAuthenticated]: No hay sesión activa
  /// - [AuthFailure.tokenExpired]: Token expirado
  /// - [NetworkFailure]: Sin conexión a internet
  /// - [ServerFailure]: Error del servidor
  Future<Either<Failure, User>> getUserProfile();

  /// Actualiza el perfil del usuario actual
  ///
  /// **Entrada**: Campos editables del perfil (firstName, lastName, phone)
  /// **Comportamiento esperado**:
  /// 1. Validar que el usuario esté autenticado
  /// 2. Actualizar datos en servidor si hay conexión
  /// 3. Actualizar cache local inmediatamente
  /// 4. Emitir cambios en authStateStream
  ///
  /// **Casos de error**:
  /// - [AuthFailure.userNotAuthenticated]: No hay sesión activa
  /// - [ValidationFailure]: Datos de perfil inválidos
  /// - [NetworkFailure]: Sin conexión (no se permite actualizar offline)
  Future<Either<Failure, User>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
  });

  /// Cambia la contraseña del usuario actual
  ///
  /// **Comportamiento esperado**:
  /// 1. Validar contraseña actual
  /// 2. Validar nueva contraseña según políticas
  /// 3. Actualizar en servidor
  /// 4. Mantener sesión activa (no logout automático)
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

/// Extensiones útiles para el repositorio
extension AuthRepositoryExtensions on AuthRepository {
  /// Verifica si el usuario tiene permisos de administrador
  Future<bool> hasAdminPermissions() async {
    final result = await getCurrentUser();
    return result.fold((failure) => false, (user) => user.hasAdminPermissions);
  }

  /// Obtiene el rol del usuario actual
  Future<UserRole?> getCurrentUserRole() async {
    final result = await getCurrentUser();
    return result.fold((failure) => null, (user) => user.role);
  }
}
