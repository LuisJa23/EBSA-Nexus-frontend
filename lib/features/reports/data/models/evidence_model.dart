// evidence_model.dart
//
// Modelo de datos para Evidencia multimedia (Data Layer)
//
// PROPÓSITO:
// - Representar archivos de evidencia (fotos, videos, audio)
// - Transformación entre diferentes representaciones
// - Manejo de rutas locales y URLs remotas
//
// CAPA: DATA LAYER

import 'dart:io';

/// Tipo de evidencia
enum EvidenceType { photo, video, audio }

/// Modelo de evidencia multimedia
///
/// Representa archivos de fotos, videos o audio asociados a reportes
class EvidenceModel {
  /// Tipo de evidencia
  final EvidenceType type;

  /// Ruta local del archivo (cuando está almacenado localmente)
  final String? localPath;

  /// URL remota del archivo (cuando está en el servidor)
  final String? url;

  /// Nombre del archivo
  final String? fileName;

  /// Tamaño del archivo en bytes
  final int? fileSize;

  /// MIME type del archivo
  final String? mimeType;

  /// Fecha de subida al servidor
  final DateTime? uploadedAt;

  const EvidenceModel({
    required this.type,
    this.localPath,
    this.url,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.uploadedAt,
  });

  /// Está almacenado localmente
  bool get isLocal => localPath != null && localPath!.isNotEmpty;

  /// Está en el servidor
  bool get isRemote => url != null && url!.isNotEmpty;

  /// Está subido al servidor
  bool get isUploaded => isRemote;

  /// Obtiene el archivo local
  File? getLocalFile() {
    if (!isLocal) return null;
    return File(localPath!);
  }

  /// Crea desde JSON
  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    EvidenceType type = EvidenceType.photo;
    final typeStr = json['type'] as String?;
    if (typeStr == 'VIDEO') type = EvidenceType.video;
    if (typeStr == 'AUDIO') type = EvidenceType.audio;

    return EvidenceModel(
      type: type,
      localPath: json['localPath'] as String?,
      url: json['url'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last.toUpperCase(),
      'localPath': localPath,
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  /// Crea desde archivo local
  factory EvidenceModel.fromFile(File file, EvidenceType type) {
    return EvidenceModel(
      type: type,
      localPath: file.path,
      fileName: file.path.split('/').last,
      fileSize: file.lengthSync(),
      mimeType: _getMimeType(file.path, type),
    );
  }

  /// Obtiene el MIME type basado en la extensión
  static String _getMimeType(String path, EvidenceType type) {
    final extension = path.split('.').last.toLowerCase();

    switch (type) {
      case EvidenceType.photo:
        if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
        if (extension == 'png') return 'image/png';
        return 'image/jpeg';

      case EvidenceType.video:
        if (extension == 'mp4') return 'video/mp4';
        if (extension == 'mov') return 'video/quicktime';
        return 'video/mp4';

      case EvidenceType.audio:
        if (extension == 'mp3') return 'audio/mpeg';
        if (extension == 'm4a') return 'audio/mp4';
        return 'audio/mpeg';
    }
  }

  /// Copia con cambios
  EvidenceModel copyWith({
    EvidenceType? type,
    String? localPath,
    String? url,
    String? fileName,
    int? fileSize,
    String? mimeType,
    DateTime? uploadedAt,
  }) {
    return EvidenceModel(
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
