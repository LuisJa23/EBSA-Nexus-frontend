// novelty_model.dart
//
// Modelo de novedad
//
// PROPÓSITO:
// - Representar una novedad del sistema
// - Serialización/deserialización JSON
//
// CAPA: DATA LAYER - MODELS

class NoveltyModel {
  final int id;
  final int areaId;
  final String reason;
  final String accountNumber;
  final String meterNumber;
  final double activeReading;
  final double reactiveReading;
  final String municipality;
  final String address;
  final String description;
  final String? observations;
  final String status;
  final int createdBy;
  final int? crewId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? closedAt;
  final DateTime? cancelledAt;
  final List<NoveltyImageModel> images;
  final NoveltyAssignmentModel? assignment;

  NoveltyModel({
    required this.id,
    required this.areaId,
    required this.reason,
    required this.accountNumber,
    required this.meterNumber,
    required this.activeReading,
    required this.reactiveReading,
    required this.municipality,
    required this.address,
    required this.description,
    this.observations,
    required this.status,
    required this.createdBy,
    this.crewId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.closedAt,
    this.cancelledAt,
    required this.images,
    this.assignment,
  });

  factory NoveltyModel.fromJson(Map<String, dynamic> json) {
    // Manejar tanto el formato con 'images' (array) como 'imageCount' (número)
    List<NoveltyImageModel> imagesList = [];
    if (json.containsKey('images') && json['images'] is List) {
      imagesList = (json['images'] as List<dynamic>)
          .map((e) => NoveltyImageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return NoveltyModel(
      id: json['id'] as int,
      areaId: json['areaId'] as int,
      reason: json['reason'] as String,
      accountNumber: json['accountNumber'] as String,
      meterNumber: json['meterNumber'] as String,
      activeReading: (json['activeReading'] as num).toDouble(),
      reactiveReading: (json['reactiveReading'] as num).toDouble(),
      municipality: json['municipality'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      observations: json['observations'] as String?,
      status: json['status'] as String,
      createdBy: json['createdBy'] as int,
      crewId: json['crewId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      images: imagesList,
      assignment: json['assignment'] != null
          ? NoveltyAssignmentModel.fromJson(
              json['assignment'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'areaId': areaId,
      'reason': reason,
      'accountNumber': accountNumber,
      'meterNumber': meterNumber,
      'activeReading': activeReading,
      'reactiveReading': reactiveReading,
      'municipality': municipality,
      'address': address,
      'description': description,
      'observations': observations,
      'status': status,
      'createdBy': createdBy,
      'crewId': crewId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'images': images.map((e) => e.toJson()).toList(),
      'assignment': assignment?.toJson(),
    };
  }
}

class NoveltyImageModel {
  final int id;
  final String imageUrl;
  final int uploadedByUserId;
  final DateTime uploadedAt;

  NoveltyImageModel({
    required this.id,
    required this.imageUrl,
    required this.uploadedByUserId,
    required this.uploadedAt,
  });

  factory NoveltyImageModel.fromJson(Map<String, dynamic> json) {
    return NoveltyImageModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      uploadedByUserId: json['uploadedByUserId'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'uploadedByUserId': uploadedByUserId,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class NoveltyAssignmentModel {
  final int? id;
  final int? crewId;
  final String? crewName;
  final String? priority;
  final String? instructions;
  final DateTime? assignedAt;

  NoveltyAssignmentModel({
    this.id,
    this.crewId,
    this.crewName,
    this.priority,
    this.instructions,
    this.assignedAt,
  });

  factory NoveltyAssignmentModel.fromJson(Map<String, dynamic> json) {
    return NoveltyAssignmentModel(
      id: json['id'] as int?,
      crewId: json['crewId'] as int?,
      crewName: json['crewName'] as String?,
      priority: json['priority'] as String?,
      instructions: json['instructions'] as String?,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crewId': crewId,
      'crewName': crewName,
      'priority': priority,
      'instructions': instructions,
      'assignedAt': assignedAt?.toIso8601String(),
    };
  }
}
