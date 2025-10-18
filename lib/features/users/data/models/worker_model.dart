// worker_model.dart
//
// Modelo de datos para Worker (Data Layer)
//
// PROPÓSITO:
// - Representar datos de trabajador del endpoint /api/public/workers
// - Transformación JSON ↔ Objeto
// - Extensión de Worker entity del dominio
//
// CAPA: DATA LAYER

import '../../domain/entities/worker.dart';

/// Modelo de datos para Worker que extiende la entidad del dominio
///
/// Contiene la información básica de un trabajador obtenida del
/// endpoint público /api/public/workers
class WorkerModel extends Worker {
  const WorkerModel({
    required super.id,
    required super.uuid,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.workType,
    required super.documentNumber,
    required super.phone,
    required super.active,
  });

  /// Crea WorkerModel desde respuesta JSON del endpoint /api/public/workers
  ///
  /// **Formato esperado del JSON**:
  /// ```json
  /// {
  ///   "id": 1,
  ///   "uuid": "admin-uuid-001",
  ///   "username": "admin",
  ///   "email": "admin@ebsa.com.co",
  ///   "firstName": "Administrador",
  ///   "lastName": "Sistema",
  ///   "workType": "intern",
  ///   "documentNumber": "12345678",
  ///   "phone": "+57-300-1234567",
  ///   "active": true
  /// }
  /// ```
  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    try {
      return WorkerModel(
        id: json['id'] as int,
        uuid: json['uuid'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        workType: json['workType'] as String,
        documentNumber: json['documentNumber'] as String,
        phone: json['phone'] as String,
        active: json['active'] as bool,
      );
    } catch (e) {
      throw FormatException('Error deserializando WorkerModel: $e');
    }
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'workType': workType,
      'documentNumber': documentNumber,
      'phone': phone,
      'active': active,
    };
  }
}
