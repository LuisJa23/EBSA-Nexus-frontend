// network_info.dart
//
// Información y monitoreo de conectividad de red
//
// PROPÓSITO:
// - Detectar estado de conectividad (online/offline)
// - Monitorear cambios en la conexión
// - Proveer información de tipo de red (WiFi, móvil, etc.)
// - Facilitar estrategias offline-first

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tipos de conexión de red disponibles
enum NetworkType { wifi, mobile, ethernet, none, unknown }

/// Interfaz abstracta para información de red
/// Permite mockear fácilmente en tests
abstract class NetworkInfo {
  /// Verifica si hay conexión a internet
  Future<bool> get isConnected;

  /// Stream de cambios de conectividad
  Stream<bool> get onConnectivityChanged;

  /// Obtiene el tipo de red actual
  Future<NetworkType> get currentNetworkType;

  /// Verifica conectividad con el servidor específico
  Future<bool> isServerReachable(String serverUrl);
}

/// Implementación concreta de NetworkInfo usando connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return _isConnectionActive(connectivityResult);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return _isConnectionActive(result);
    });
  }

  @override
  Future<NetworkType> get currentNetworkType async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(connectivityResult);
  }

  @override
  Future<bool> isServerReachable(String serverUrl) async {
    try {
      // Primero verificar conectividad básica
      if (!await isConnected) {
        return false;
      }

      // TODO: Implementar ping real al servidor
      // Por ahora asume que si hay conectividad, el servidor local está disponible
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Determina si el tipo de conexión permite comunicación
  bool _isConnectionActive(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return true;
      case ConnectivityResult.none:
      default:
        return false;
    }
  }

  /// Mapea ConnectivityResult a nuestro NetworkType
  NetworkType _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.none:
        return NetworkType.none;
      default:
        return NetworkType.unknown;
    }
  }
}

// - class NetworkInfoImpl implements NetworkInfo
// - Uso de connectivity_plus package
// - Manejo de diferentes tipos de conexión
// - Cache del último estado conocido
