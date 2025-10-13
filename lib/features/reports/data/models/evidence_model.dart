// evidence_model.dart
//
// Modelo de datos para Evidencia multimedia (Data Layer)
//
// PROPÓSITO:
// - Representar archivos de evidencia (fotos, videos, audio)
// - Transformación entre diferentes representaciones
// - Extensión de Evidence entity del dominio
// - Manejo de rutas locales y URLs remotas
//
// CAPA: DATA LAYER
// HERENCIA: extends Evidence (domain entity)
//
// CONTENIDO ESPERADO:
// - class EvidenceModel extends Evidence
// - Constructor que llame super() con parámetros de Evidence entity
// - factory EvidenceModel.fromJson(Map<String, dynamic> json)
// - Map<String, dynamic> toJson()
// - factory EvidenceModel.fromEntity(Evidence evidence)
// - Evidence toEntity()
// - factory EvidenceModel.fromFile(File file) // crear desde archivo local
// - Campos específicos de data layer:
//   - String? localPath, String? remoteUrl
//   - bool isUploaded, DateTime? uploadedAt
//   - int? fileSizeBytes, String? compression
// - Métodos de utilidad:
//   - bool get isLocal, bool get isRemote
//   - Future<File?> getLocalFile()
// - Validación de tipos de archivo permitidos
