// novelty_detail_page.dart
//
// Página de detalle de novedad
//
// PROPÓSITO:
// - Mostrar información completa de una novedad
// - Visualizar imágenes de la novedad
// - Permitir asignar cuadrilla a la novedad
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../crews/data/models/crew_model.dart';
import '../../../crews/data/datasources/crew_remote_datasource.dart';
import '../../data/models/novelty_model.dart';
import '../../data/novelty_service.dart';

class NoveltyDetailPage extends StatefulWidget {
  final String noveltyId;

  const NoveltyDetailPage({super.key, required this.noveltyId});

  @override
  State<NoveltyDetailPage> createState() => _NoveltyDetailPageState();
}

class _NoveltyDetailPageState extends State<NoveltyDetailPage> {
  bool _isLoading = true;
  NoveltyModel? _novelty;
  String? _errorMessage;
  int _currentImageIndex = 0; // Para el indicador de posición
  final PageController _pageController =
      PageController(); // Controlador del carrusel

  @override
  void initState() {
    super.initState();
    _loadNoveltyDetail();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Liberar recursos
    super.dispose();
  }

  Future<void> _loadNoveltyDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final noveltyService = di.sl<NoveltyService>();
      final response = await noveltyService.getNoveltyById(widget.noveltyId);

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _novelty = NoveltyModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar detalle de novedad';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _openMap() async {
    if (_novelty == null) return;

    final coordinates = _novelty!.address.split(',');
    if (coordinates.length != 2) return;

    final lat = coordinates[0];
    final lon = coordinates[1];
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAssignCrewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignCrewBottomSheet(
        noveltyId: widget.noveltyId,
        onAssigned: () {
          _loadNoveltyDetail();
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Novedad'),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _novelty != null && _novelty!.crewId == null
          ? _buildAssignButton()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNoveltyDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_novelty == null) {
      return const Center(child: Text('Novedad no encontrada'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imágenes
          if (_novelty!.images.isNotEmpty) _buildImagesSection(),

          // Información principal
          _buildInfoSection(),

          // Lecturas
          _buildReadingsSection(),

          // Ubicación
          _buildLocationSection(),

          // Descripción y observaciones
          _buildDescriptionSection(),

          // Estado y fechas
          _buildStatusSection(),

          const SizedBox(height: 20), // Reducir espacio para el botón
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    final imageCount = _novelty!.images.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Carrusel de imágenes
            PageView.builder(
              controller: _pageController,
              itemCount: imageCount,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final image = _novelty!.images[index];
                return GestureDetector(
                  onTap: () => _showImageFullscreen(image.imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      16,
                    ), // Aplicar borde directamente a la imagen
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceElevated,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.surfaceElevated,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            // Flechas de navegación (solo si hay más de 1 imagen)
            if (imageCount > 1) ...[
              // Flecha izquierda
              if (_currentImageIndex > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Flecha derecha
              if (_currentImageIndex < imageCount - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],

            // Indicador de posición (número de imagen)
            if (imageCount > 1)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / $imageCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImageFullscreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información General',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.account_circle,
              'Cuenta',
              _novelty!.accountNumber,
              AppColors.primary,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.speed,
              'Medidor',
              _novelty!.meterNumber,
              AppColors.secondary,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.report_problem,
              'Motivo',
              _getReasonLabel(_novelty!.reason),
              _getReasonColor(_novelty!.reason),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lecturas',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text('Activa', style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _novelty!.activeReading.toStringAsFixed(2),
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text('Reactiva', style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _novelty!.reactiveReading.toStringAsFixed(2),
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _openMap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubicación',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Municipio', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          _novelty!.municipality,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 20, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para ver en el mapa',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Descripción',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _novelty!.description,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
            if (_novelty!.observations != null &&
                _novelty!.observations!.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.note, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Observaciones',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _novelty!.observations!,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusChip(_novelty!.status),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Creada: ${_formatDate(_novelty!.createdAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAssignButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showAssignCrewDialog,
        icon: const Icon(Icons.group_add, size: 22),
        label: const Text(
          'Asignar Cuadrilla',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'ERROR_LECTURA':
        return AppColors.error;
      case 'MEDIDOR_DANIADO':
        return AppColors.warning;
      case 'RECONEXION':
        return AppColors.success;
      case 'CAMBIO_MEDIDOR':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getReasonLabel(String reason) {
    switch (reason) {
      case 'ERROR_LECTURA':
        return 'Error de Lectura';
      case 'MEDIDOR_DANIADO':
        return 'Medidor Dañado';
      case 'RECONEXION':
        return 'Reconexión';
      case 'CAMBIO_MEDIDOR':
        return 'Cambio de Medidor';
      default:
        return reason;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREADA':
        return AppColors.warning;
      case 'ASIGNADA':
        return AppColors.info;
      case 'EN_PROGRESO':
        return AppColors.primary;
      case 'COMPLETADA':
        return AppColors.success;
      case 'CANCELADA':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Bottom Sheet para asignar cuadrilla
class _AssignCrewBottomSheet extends StatefulWidget {
  final String noveltyId;
  final VoidCallback onAssigned;

  const _AssignCrewBottomSheet({
    required this.noveltyId,
    required this.onAssigned,
  });

  @override
  State<_AssignCrewBottomSheet> createState() => _AssignCrewBottomSheetState();
}

class _AssignCrewBottomSheetState extends State<_AssignCrewBottomSheet> {
  bool _isLoading = true;
  List<CrewModel> _crews = [];
  CrewModel? _selectedCrew;
  String _priority = 'MEDIA';
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCrews();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadCrews() async {
    setState(() => _isLoading = true);

    try {
      final crewDataSource = di.sl<CrewRemoteDataSource>();
      final crews = await crewDataSource.getAllCrews();

      setState(() {
        _crews = crews.where((crew) => crew.status == 'DISPONIBLE').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cuadrillas: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _assignCrew() async {
    if (_selectedCrew == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una cuadrilla')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final noveltyService = di.sl<NoveltyService>();
      await noveltyService.assignCrewToNovelty(
        noveltyId: widget.noveltyId,
        assignedCrewId: _selectedCrew!.id,
        priority: _priority,
        instructions: _instructionsController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuadrilla asignada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onAssigned();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar cuadrilla: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 300,
              child: Center(child: LoadingIndicator()),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asignar Cuadrilla', style: AppTextStyles.heading2),
                  const SizedBox(height: 24),

                  // Selección de cuadrilla
                  Text('Cuadrilla', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  ...(_crews.map((crew) => _buildCrewOption(crew))),

                  const SizedBox(height: 16),

                  // Prioridad
                  Text('Prioridad', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('BAJA', 'Baja'),
                      const SizedBox(width: 8),
                      _buildPriorityChip('MEDIA', 'Media'),
                      const SizedBox(width: 8),
                      _buildPriorityChip('ALTA', 'Alta'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Instrucciones
                  Text('Instrucciones', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Instrucciones para la cuadrilla...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón asignar
                  CustomButton(text: 'Asignar', onPressed: _assignCrew),
                ],
              ),
            ),
    );
  }

  Widget _buildCrewOption(CrewModel crew) {
    final isSelected = _selectedCrew?.id == crew.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCrew = crew),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crew.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(crew.description, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _getPriorityColor(value)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'BAJA':
        return AppColors.success;
      case 'MEDIA':
        return AppColors.warning;
      case 'ALTA':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
