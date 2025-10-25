// location_picker_widget.dart
//
// Widget para seleccionar ubicación GPS
//
// PROPÓSITO:
// - Obtener ubicación actual del dispositivo
// - Permitir abrir Google Maps para ver/seleccionar ubicación
// - Permitir ingresar coordenadas manualmente
// - Devolver coordenadas seleccionadas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resultado de la selección de ubicación
class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });
}

/// Widget para seleccionar ubicación GPS
class LocationPickerWidget extends StatefulWidget {
  /// Ubicación inicial (opcional)
  final LocationResult? initialLocation;

  /// Título del diálogo
  final String title;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    this.title = 'Seleccionar Ubicación',
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  bool _isLoadingLocation = false;
  LocationResult? _currentLocation;
  double? _accuracy;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _latController.text = widget.initialLocation!.latitude.toStringAsFixed(6);
      _lonController.text = widget.initialLocation!.longitude.toStringAsFixed(
        6,
      );
      _currentLocation = widget.initialLocation;
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  /// Obtener ubicación actual del dispositivo
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verificar si el servicio de ubicación está habilitado
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
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isDenied || permission.isPermanentlyDenied) {
        _showMessage('❌ Permiso de ubicación denegado');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentLocation = LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        );
        _accuracy = position.accuracy;
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
        _isLoadingLocation = false;
      });

      _showMessage('✅ Ubicación obtenida correctamente');
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      _showMessage('❌ Error al obtener ubicación: ${e.toString()}');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  /// Abrir Google Maps con la ubicación actual o seleccionada
  Future<void> _openInGoogleMaps() async {
    double? lat = double.tryParse(_latController.text);
    double? lon = double.tryParse(_lonController.text);

    // Si no hay coordenadas, usar ubicación por defecto (Bogotá, Colombia)
    lat ??= 4.7110;
    lon ??= -74.0721;

    // URL para abrir Google Maps en modo navegación/exploración
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        _showMessage('❌ No se pudo abrir Google Maps');
      }
    } catch (e) {
      print('Error abriendo Google Maps: $e');
      _showMessage('❌ Error al abrir Google Maps: ${e.toString()}');
    }
  }

  /// Validar y confirmar ubicación
  void _confirmLocation() {
    double? lat = double.tryParse(_latController.text);
    double? lon = double.tryParse(_lonController.text);

    if (lat == null || lon == null) {
      _showMessage('⚠️ Por favor ingresa coordenadas válidas');
      return;
    }

    if (lat < -90 || lat > 90) {
      _showMessage('⚠️ La latitud debe estar entre -90 y 90');
      return;
    }

    if (lon < -180 || lon > 180) {
      _showMessage('⚠️ La longitud debe estar entre -180 y 180');
      return;
    }

    final result = LocationResult(
      latitude: lat,
      longitude: lon,
      accuracy: _accuracy,
    );

    Navigator.of(context).pop(result);
  }

  /// Mostrar mensaje al usuario
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Botón: Obtener ubicación actual
                    ElevatedButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isLoadingLocation
                            ? 'Obteniendo ubicación...'
                            : 'Obtener Mi Ubicación Actual',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Información de precisión
                    if (_accuracy != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Precisión: ${_accuracy!.toStringAsFixed(2)} metros',
                                style: TextStyle(
                                  color: Colors.green[900],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_accuracy != null) const SizedBox(height: 16),

                    // Campos de coordenadas
                    const Text(
                      'Coordenadas GPS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo Latitud
                    TextField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        hintText: 'Ej: 4.711000',
                        prefixIcon: Icon(Icons.explore),
                        border: OutlineInputBorder(),
                        helperText: 'Valores entre -90 y 90',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Campo Longitud
                    TextField(
                      controller: _lonController,
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        hintText: 'Ej: -74.072100',
                        prefixIcon: Icon(Icons.explore),
                        border: OutlineInputBorder(),
                        helperText: 'Valores entre -180 y 180',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d*'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botón para abrir Google Maps
                    OutlinedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.map, size: 22),
                      label: const Text('Abrir Google Maps'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Instrucciones
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Para explorar ubicaciones:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Presiona "Abrir Google Maps" para explorar\n'
                            '2. Luego ingresa las coordenadas manualmente\n'
                            '3. O usa "Obtener Mi Ubicación Actual"',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Función helper para mostrar el selector de ubicación
Future<LocationResult?> showLocationPicker(
  BuildContext context, {
  LocationResult? initialLocation,
  String title = 'Seleccionar Ubicación',
}) async {
  return await showDialog<LocationResult>(
    context: context,
    builder: (context) =>
        LocationPickerWidget(initialLocation: initialLocation, title: title),
  );
}
