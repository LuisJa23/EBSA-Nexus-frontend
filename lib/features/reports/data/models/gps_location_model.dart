// gps_location_model.dart
//
// Modelo de datos para Ubicación GPS (Data Layer)
//
// PROPÓSITO:
// - Representar coordenadas GPS y metadatos de ubicación
// - Transformación entre formatos (decimal, DMS, etc.)
// - Extensión de GPSLocation entity del dominio
// - Integración con servicios de geolocalización
//
// CAPA: DATA LAYER
// HERENCIA: extends GPSLocation (domain entity)
//
// CONTENIDO ESPERADO:
// - class GPSLocationModel extends GPSLocation
// - Constructor que llame super() con parámetros de GPSLocation entity
// - factory GPSLocationModel.fromJson(Map<String, dynamic> json)
// - Map<String, dynamic> toJson()
// - factory GPSLocationModel.fromEntity(GPSLocation location)
// - GPSLocation toEntity()
// - factory GPSLocationModel.fromPosition(Position position) // desde geolocator
// - Campos adicionales de data layer:
//   - double? altitude, double? accuracy, double? speed
//   - String? address, String? locality, String? country
//   - DateTime timestamp
// - Métodos de utilidad:
//   - String get coordinatesString
//   - String get dmsFormat // grados, minutos, segundos
//   - double distanceTo(GPSLocationModel other)
// - Validación de rangos de coordenadas
