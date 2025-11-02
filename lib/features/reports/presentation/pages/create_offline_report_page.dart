// create_offline_report_page.dart
//
// Página para crear reportes offline
//
// PROPÓSITO:
// - Crear reportes sin conexión a internet (100% offline)
// - Cargar datos de novedad y cuadrilla desde caché local
// - Capturar ubicación GPS del dispositivo
// - Guardar en SQLite para posterior sincronización
//
// CAPA: PRESENTATION LAYER

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../config/database/database_provider.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../crews/domain/entities/crew_member_detail.dart';
import '../../../crews/data/models/crew_member_detail_model.dart';
import '../../../crews/domain/usecases/get_crew_with_members_usecase.dart';
import '../providers/offline_reports_provider.dart';

/// Página para crear reportes offline
///
/// Funciona 100% offline cargando datos desde caché SQLite
class CreateOfflineReportPage extends ConsumerStatefulWidget {
  final String noveltyId;

  const CreateOfflineReportPage({super.key, required this.noveltyId});

  @override
  ConsumerState<CreateOfflineReportPage> createState() =>
      _CreateOfflineReportPageState();
}

class _CreateOfflineReportPageState
    extends ConsumerState<CreateOfflineReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _reportContentController = TextEditingController();
  final _observationsController = TextEditingController();

  DateTime? _workStartDate;
  DateTime? _workEndDate;
  String _resolutionStatus = 'COMPLETADO';

  // Estado para datos offline
  bool _isLoadingOfflineData = true;
  bool _isSaving = false;
  bool _isLoadingCrewMembers = false;
  String? _offlineError;
  NoveltyCacheTableData? _cachedNovelty;
  CrewCacheTableData? _cachedCrew;
  List<CrewMemberDetail> _crewMembers = [];
  Set<int> _selectedParticipants = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOfflineData();
    });
  }

  @override
  void dispose() {
    _reportContentController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  /// Carga los datos desde el caché local (funciona 100% offline)
  Future<void> _loadOfflineData() async {
    print('🔵 === CARGANDO DATOS OFFLINE ===');
    print('🔵 noveltyId: ${widget.noveltyId}');

    setState(() {
      _isLoadingOfflineData = true;
      _offlineError = null;
    });

    try {
      final noveltyId = int.tryParse(widget.noveltyId);
      if (noveltyId == null) {
        throw Exception('ID de novedad inválido');
      }

      final db = ref.read(databaseProvider);

      // 1. Cargar novedad del caché
      print('📥 Cargando novedad desde caché...');
      final novelty = await db.getCachedNoveltyById(noveltyId);

      if (novelty == null) {
        throw Exception(
          'Novedad no encontrada en caché.\n\n'
          'Por favor, asegúrate de cachear la novedad primero '
          'desde la lista de novedades.',
        );
      }

      print('✅ Novedad cargada:');
      print('  - ID: ${novelty.noveltyId}');
      print('  - Status: ${novelty.status}');
      print('  - CrewId: ${novelty.crewId}');
      print('  - Cuenta: ${novelty.accountNumber}');

      // 2. Cargar cuadrilla del caché (si existe)
      CrewCacheTableData? crew;
      List<CrewMemberDetail> members = [];

      if (novelty.crewId != null) {
        print('📥 Cargando cuadrilla ${novelty.crewId} desde caché...');
        crew = await db.getCachedCrewById(novelty.crewId!);

        if (crew != null) {
          print('✅ Cuadrilla cargada: ${crew.name}');
          print(
            '📋 RawJson de cuadrilla (primeros 500 chars): ${crew.rawJson.substring(0, crew.rawJson.length > 500 ? 500 : crew.rawJson.length)}',
          );

          // 3. Intentar parsear miembros del rawJson
          try {
            final crewData = jsonDecode(crew.rawJson) as Map<String, dynamic>;
            print('🔍 Keys en crewData: ${crewData.keys.toList()}');

            if (crewData.containsKey('members') &&
                crewData['members'] is List) {
              final membersList = crewData['members'] as List;
              print(
                '📥 Parseando ${membersList.length} miembros desde JSON...',
              );

              for (var memberJson in membersList) {
                try {
                  print('👤 Parseando miembro: $memberJson');
                  final member = CrewMemberDetailModel.fromJson(
                    memberJson as Map<String, dynamic>,
                  );
                  members.add(member);
                  print('✅ Miembro parseado: ${member.fullName}');
                } catch (e) {
                  print('⚠️ Error parseando miembro: $e');
                  print('   JSON problemático: $memberJson');
                }
              }

              print('✅ ${members.length} miembros cargados exitosamente');
            } else {
              print('⚠️ No se encontraron miembros en el JSON');
              print(
                '⚠️ crewData.containsKey("members"): ${crewData.containsKey('members')}',
              );
              if (crewData.containsKey('members')) {
                print('⚠️ Tipo de members: ${crewData['members'].runtimeType}');
                print('⚠️ Valor de members: ${crewData['members']}');
              }
            }
          } catch (e, stackTrace) {
            print('⚠️ Error parseando JSON de cuadrilla: $e');
            print('Stack trace: $stackTrace');
            print('RawJson completo: ${crew.rawJson}');
          }
        } else {
          print('⚠️ Cuadrilla no encontrada en caché');
        }
      } else {
        print('⚠️ Novedad sin cuadrilla asignada');
      }

      if (mounted) {
        setState(() {
          _cachedNovelty = novelty;
          _cachedCrew = crew;
          _crewMembers = members;
          _isLoadingOfflineData = false;
        });

        // Si hay cuadrilla pero no hay miembros en caché, intentar cargarlos automáticamente
        print('🔍 Verificando carga automática de miembros...');
        print('   - crew != null: ${crew != null}');
        print('   - members.isEmpty: ${members.isEmpty}');

        if (crew != null && members.isEmpty) {
          print(
            '⚠️ Cuadrilla sin miembros en caché. Intentando cargar automáticamente...',
          );
          print('⚠️ crewId: ${crew.crewId}');
          // Dar tiempo para que se renderice la UI antes de cargar
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              print('🌐 Iniciando carga automática de miembros...');
              _loadCrewMembersFromServer();
            } else {
              print('⚠️ Widget no montado, cancelando carga automática');
            }
          });
        } else {
          if (crew == null) {
            print('ℹ️ No hay cuadrilla asignada, no se cargarán miembros');
          } else {
            print(
              '✅ Miembros ya disponibles (${members.length}), no se requiere carga automática',
            );
          }
        }
      }

      print('✅ Datos offline cargados exitosamente');
      print('  - Novedad: ✓');
      print('  - Cuadrilla: ${crew != null ? '✓' : '✗'}');
      print('  - Miembros: ${members.length}');
    } catch (e, stackTrace) {
      print('❌ Error cargando datos offline: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        setState(() {
          _offlineError = e.toString();
          _isLoadingOfflineData = false;
        });
      }
    }

    print('🔵 === FIN CARGANDO DATOS OFFLINE ===');
  }

  /// Guarda el reporte offline en la base de datos local
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_workStartDate == null || _workEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar las fechas de inicio y fin del trabajo',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_cachedNovelty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron datos de la novedad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // VALIDACIÓN CRÍTICA: Al menos un participante debe estar seleccionado
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Debes seleccionar al menos un participante que resolvió la novedad',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('💾 === GUARDANDO REPORTE OFFLINE ===');

      final db = ref.read(databaseProvider);
      final reportId = const Uuid().v4();

      print('📝 Datos del reporte:');
      print('  - ID: $reportId');
      print('  - NoveltyID: ${_cachedNovelty!.noveltyId}');
      print('  - Status: $_resolutionStatus');
      print('  - Participantes: ${_selectedParticipants.length}');

      // Calcular tiempo de trabajo en minutos
      final workTimeMinutes = _workEndDate!
          .difference(_workStartDate!)
          .inMinutes;

      print('📅 Fechas del trabajo:');
      print('  - Inicio: ${_workStartDate!.toIso8601String()}');
      print('  - Fin: ${_workEndDate!.toIso8601String()}');
      print('  - Duración: $workTimeMinutes minutos');

      // Guardar en la base de datos
      final reportCompanion = ReportTableCompanion(
        id: drift.Value(reportId),
        noveltyId: drift.Value(_cachedNovelty!.noveltyId),
        workDescription: drift.Value(_reportContentController.text.trim()),
        observations: drift.Value(
          _observationsController.text.trim().isEmpty
              ? null
              : _observationsController.text.trim(),
        ),
        workTime: drift.Value(workTimeMinutes),
        workStartDate: drift.Value(_workStartDate!),
        workEndDate: drift.Value(_workEndDate!),
        participantIds: drift.Value(jsonEncode(_selectedParticipants.toList())),
        resolutionStatus: drift.Value(_resolutionStatus),
        latitude: const drift.Value(0.0), // Se extrae de la novedad
        longitude: const drift.Value(0.0), // Se extrae de la novedad
        isSynced: const drift.Value(false),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      );

      await db.insertReport(reportCompanion);

      print('✅ Reporte guardado exitosamente en SQLite');
      print('💾 === FIN GUARDANDO REPORTE OFFLINE ===');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte guardado offline exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Refrescar lista de reportes offline
        ref.read(offlineReportsProvider.notifier).refresh();

        // Navegar de vuelta
        context.pop();
      }
    } catch (e, stackTrace) {
      print('❌ Error guardando reporte: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar reporte: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _toggleParticipant(int userId) {
    setState(() {
      if (_selectedParticipants.contains(userId)) {
        _selectedParticipants.remove(userId);
      } else {
        _selectedParticipants.add(userId);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _workStartDate : _workEndDate;
    final firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 365))
        : _workStartDate ?? DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartDate) {
            _workStartDate = dateTime;
            // Si la fecha de fin es anterior a la de inicio, resetearla
            if (_workEndDate != null && _workEndDate!.isBefore(dateTime)) {
              _workEndDate = null;
            }
          } else {
            _workEndDate = dateTime;
          }
        });
      }
    }
  }

  /// Carga los miembros de la cuadrilla desde el servidor y los guarda en caché
  Future<void> _loadCrewMembersFromServer() async {
    if (_cachedNovelty?.crewId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta novedad no tiene cuadrilla asignada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingCrewMembers = true);

    try {
      print('🌐 === CARGANDO MIEMBROS DESDE SERVIDOR ===');
      print('🌐 crewId: ${_cachedNovelty!.crewId}');

      final usecase = sl<GetCrewWithMembersUseCase>();
      final result = await usecase(_cachedNovelty!.crewId!);

      await result.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (crewWithMembers) async {
          print(
            '✅ Cuadrilla obtenida: ${crewWithMembers.members.length} miembros',
          );

          // Actualizar el caché con los miembros
          final db = ref.read(databaseProvider);

          // Obtener el caché actual de la cuadrilla
          final currentCache = await db.getCachedCrewById(
            _cachedNovelty!.crewId!,
          );

          if (currentCache != null) {
            // Parsear el JSON actual y agregar los miembros
            final crewData =
                jsonDecode(currentCache.rawJson) as Map<String, dynamic>;
            crewData['members'] = crewWithMembers.members.map((m) {
              return {
                'id': m.id,
                'crewId': m.crewId,
                'userId': m.userId,
                'isLeader': m.isLeader,
                'joinedAt': m.joinedAt.toIso8601String(),
                'leftAt': m.leftAt?.toIso8601String(),
                'notes': m.notes,
                'userUuid': m.userUuid,
                'username': m.username,
                'email': m.email,
                'firstName': m.firstName,
                'lastName': m.lastName,
                'roleName': m.roleName,
                'workRoleName': m.workRoleName,
                'workType': m.workType,
                'documentNumber': m.documentNumber,
                'phone': m.phone,
                'active': m.active,
              };
            }).toList();

            // Actualizar el caché con los nuevos datos
            await db.upsertCrewCache(
              CrewCacheTableCompanion(
                crewId: drift.Value(_cachedNovelty!.crewId!),
                name: drift.Value(currentCache.name),
                description: drift.Value(currentCache.description),
                status: drift.Value(currentCache.status),
                createdBy: drift.Value(currentCache.createdBy),
                activeMemberCount: drift.Value(currentCache.activeMemberCount),
                hasActiveAssignments: drift.Value(
                  currentCache.hasActiveAssignments,
                ),
                createdAt: drift.Value(currentCache.createdAt),
                updatedAt: drift.Value(currentCache.updatedAt),
                deletedAt: drift.Value(currentCache.deletedAt),
                cachedAt: drift.Value(DateTime.now()),
                rawJson: drift.Value(jsonEncode(crewData)),
              ),
            );

            print('✅ Miembros guardados en caché');
          }

          // Actualizar el estado local
          if (mounted) {
            setState(() {
              _crewMembers = crewWithMembers.members;
              _isLoadingCrewMembers = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${crewWithMembers.members.length} miembros cargados y guardados en caché',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );

      print('🌐 === FIN CARGANDO MIEMBROS ===');
    } catch (e, stackTrace) {
      print('❌ Error cargando miembros: $e');
      print('Stack: $stackTrace');

      if (mounted) {
        setState(() => _isLoadingCrewMembers = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando miembros: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte Offline'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Mostrar loading mientras se cargan datos offline
    if (_isLoadingOfflineData) {
      return const Center(
        child: LoadingIndicator(message: 'Cargando datos desde caché...'),
      );
    }

    // Mostrar error si hay algún problema
    if (_offlineError != null) {
      return _buildErrorView(_offlineError!);
    }

    // Mostrar formulario si los datos fueron cargados
    if (_cachedNovelty != null) {
      return _buildForm();
    }

    // Estado inicial - mostrar loading
    return const Center(child: LoadingIndicator(message: 'Inicializando...'));
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: _loadOfflineData,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de modo offline
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modo Offline: El reporte se guardará localmente para sincronizar más tarde',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Información de la Novedad
            _buildNoveltyInfo(),
            const SizedBox(height: 24),

            // Contenido del reporte
            Text(
              'Contenido del Reporte',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reportContentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe el trabajo realizado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El contenido del reporte es obligatorio';
                }
                if (value.trim().length < 10) {
                  return 'El reporte debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Observaciones
            Text(
              'Observaciones (Opcional)',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observationsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Observaciones adicionales...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Fechas de trabajo
            Text(
              'Fechas de Trabajo',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'Inicio',
                    date: _workStartDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    label: 'Fin',
                    date: _workEndDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Estado de resolución
            Text(
              'Estado de Resolución',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _resolutionStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'COMPLETADO',
                  child: Text('Completado'),
                ),
                DropdownMenuItem(
                  value: 'NO_COMPLETADO',
                  child: Text('No Completado'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _resolutionStatus = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Participantes
            _buildParticipantsSection(),
            const SizedBox(height: 32),

            // Botón de enviar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(
                text: _isSaving ? 'Guardando...' : 'Guardar Reporte Offline',
                onPressed: _isSaving ? null : _handleSubmit,
                type: ButtonType.primary,
                isLoading: _isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoveltyInfo() {
    if (_cachedNovelty == null) return const SizedBox.shrink();

    final noveltyData =
        jsonDecode(_cachedNovelty!.rawJson) as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Información de la Novedad',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ID:', '#${_cachedNovelty!.noveltyId}'),
          _buildInfoRow('Estado:', _cachedNovelty!.status),
          if (noveltyData['accountNumber'] != null)
            _buildInfoRow('Cuenta:', noveltyData['accountNumber'].toString()),
          if (_cachedCrew != null)
            _buildInfoRow('Cuadrilla:', _cachedCrew!.name),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                  : 'Seleccionar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Participantes',
                        style: AppTextStyles.heading4.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Obligatorio',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona quién resolvió la novedad',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_crewMembers.isEmpty && _cachedCrew != null)
              TextButton.icon(
                onPressed: _isLoadingCrewMembers
                    ? null
                    : _loadCrewMembersFromServer,
                icon: _isLoadingCrewMembers
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download, size: 20),
                label: Text(
                  _isLoadingCrewMembers ? 'Cargando...' : 'Cargar Miembros',
                  style: const TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Mostrar contador de participantes seleccionados
        if (_selectedParticipants.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedParticipants.length} participante(s) seleccionado(s)',
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        if (_crewMembers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade400, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¡Atención! No hay participantes disponibles',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _cachedCrew != null
                      ? '⚠️ IMPORTANTE: Debes cargar los miembros de la cuadrilla para poder crear el reporte.\n\n'
                            'El backend requiere que especifiques al menos un participante que resolvió la novedad.\n\n'
                            '👉 Toca el botón "Cargar Miembros" para descargarlos desde el servidor y guardarlos en caché para uso offline.'
                      : '⚠️ Esta novedad no tiene cuadrilla asignada.\n\n'
                            'No podrás crear el reporte hasta que se asigne una cuadrilla en el sistema.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                if (_cachedCrew != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingCrewMembers
                          ? null
                          : _loadCrewMembersFromServer,
                      icon: _isLoadingCrewMembers
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        _isLoadingCrewMembers
                            ? 'Cargando miembros...'
                            : 'Cargar Miembros de la Cuadrilla',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_crewMembers.length} miembro(s) disponible(s). Selecciona quién resolvió la novedad.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _crewMembers.map((member) {
                    final isSelected = _selectedParticipants.contains(
                      member.userId,
                    );
                    return CheckboxListTile(
                      title: Text(
                        member.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cédula: ${member.documentNumber}'),
                          if (member.isLeader)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Líder de Cuadrilla',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      value: isSelected,
                      onChanged: (value) => _toggleParticipant(member.userId),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
