import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/work_role.dart';

class WorkRoleModel extends WorkRole {
  const WorkRoleModel({
    required super.id,
    required super.name,
    required super.workType,
    super.description,
  });

  factory WorkRoleModel.fromJson(Map<String, dynamic> json) {
    return WorkRoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      workType: WorkType.fromString(
        json['type'] as String,
      ), // Cambio: 'type' en lugar de 'workType'
      description: json['description'] as String?,
    );
  }
}

class WorkRolesService {
  static final Dio _dio = Dio();

  static Future<List<WorkRoleModel>> fetchByType(WorkType type) async {
    final endpoint = '${ApiConstants.workroles}/type/${type.value}';
    final url = ApiConstants.buildUrl(endpoint);

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': ApiConstants.contentTypeJson,
            'Accept': ApiConstants.acceptJson,
          },
        ),
      );

      if (response.statusCode == ApiConstants.httpSuccess) {
        final List<dynamic> data = response.data;
        return data.map((json) => WorkRoleModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al obtener roles de trabajo: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error de red al obtener roles de trabajo: ${e.message}');
    }
  }
}
