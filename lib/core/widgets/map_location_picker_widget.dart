import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
}

/// Selector de ubicación con mapa interactivo
/// Usa OpenStreetMap (gratis, sin API Key)
class MapLocationPickerWidget extends StatefulWidget {
  final LocationResult? initialLocation;

  const MapLocationPickerWidget({Key? key, this.initialLocation})
    : super(key: key);

  @override
  State<MapLocationPickerWidget> createState() =>
      _MapLocationPickerWidgetState();
}

class _MapLocationPickerWidgetState extends State<MapLocationPickerWidget> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;
  bool _isLoadingLocation = false;
  double _currentZoom = 13.0;
  double? _accuracy;

  @override
  void initState() {
    super.initState();
    // Si hay ubicación inicial, usarla
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _accuracy = widget.initialLocation!.accuracy;

      // Mover el mapa a la ubicación inicial después de construir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_selectedLocation, 15.0);
      });
    } else {
      // Bogotá, Colombia por defecto (temporal mientras carga GPS)
      _selectedLocation = LatLng(4.7110, -74.0721);
      // Intentar obtener ubicación actual automáticamente
      _getCurrentLocationOnInit();
    }
  }

  /// Obtener ubicación actual al iniciar (sin bloquear la UI)
  Future<void> _getCurrentLocationOnInit() async {
    try {
      // Verificar servicios de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Actualizar ubicación y mover mapa
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _accuracy = position.accuracy;
        });

        // Mover el mapa a la ubicación actual
        _mapController.move(_selectedLocation, 15.0);
      }
    } catch (e) {
      // Si falla, simplemente mantener la ubicación por defecto
      print('No se pudo obtener ubicación inicial: $e');
    }
  }

  /// Obtener ubicación actual del GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verificar servicios de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(
          '⚠️ GPS desactivado. Activa la ubicación en tu dispositivo.',
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('❌ Permiso de ubicación denegado');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Obtener posición
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _accuracy = position.accuracy;
        _isLoadingLocation = false;
      });

      // Mover el mapa a la ubicación actual
      _mapController.move(_selectedLocation, 15.0);
      _showMessage('✅ Ubicación actual obtenida');
    } catch (e) {
      _showMessage('❌ Error al obtener ubicación: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  /// Confirmar ubicación seleccionada
  void _confirmLocation() {
    Navigator.of(context).pop(
      LocationResult(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        accuracy: _accuracy ?? 0,
      ),
    );
  }

  /// Mostrar mensaje
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botón de confirmar en el AppBar
          TextButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Confirmar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa interactivo
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: _currentZoom,
              onTap: (tapPosition, point) {
                // Al tocar el mapa, seleccionar esa ubicación
                setState(() {
                  _selectedLocation = point;
                  _accuracy =
                      null; // Ubicación manual no tiene accuracy del GPS
                });
              },
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // Capa de tiles (OpenStreetMap - Gratis, sin API Key)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ebsa.nexus.frontend',
              ),
              // Marcador de ubicación seleccionada
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Panel de información superior
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoadingLocation
                              ? Icons.gps_fixed
                              : Icons.info_outline,
                          color: _isLoadingLocation
                              ? Colors.orange
                              : Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoadingLocation
                                ? 'Obteniendo ubicación actual...'
                                : 'Toca el mapa para seleccionar ubicación',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    Text(
                      'Lon: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    if (_accuracy != null)
                      Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Precisión GPS: ${_accuracy!.toStringAsFixed(1)}m',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Botones de control
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                // Zoom in
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(5.0, 18.0);
                    });
                    _mapController.move(_selectedLocation, _currentZoom);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom out
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(5.0, 18.0);
                    });
                    _mapController.move(_selectedLocation, _currentZoom);
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 16),
                // Mi ubicación
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  backgroundColor: Colors.blue,
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
