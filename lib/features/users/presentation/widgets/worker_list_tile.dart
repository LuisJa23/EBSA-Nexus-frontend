// worker_list_tile.dart
//
// Widget para mostrar un trabajador en la lista
//
// PROPÓSITO:
// - Mostrar información básica del trabajador
// - Diseño consistente y legible
// - Indicadores visuales de estado
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/worker.dart';

/// Widget que muestra la información de un trabajador en formato de lista
class WorkerListTile extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onTap;

  const WorkerListTile({super.key, required this.worker, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildAvatar(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: worker.isActive
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.textSecondary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: worker.isActive ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      worker.fullName,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: worker.isActive
            ? AppColors.textPrimary
            : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.alternate_email,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                worker.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.badge, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              worker.username,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.work, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              worker.workTypeLocalized,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (worker.phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                worker.phone,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: worker.isActive
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            worker.isActive ? 'Activo' : 'Inactivo',
            style: AppTextStyles.caption.copyWith(
              color: worker.isActive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${worker.id}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
