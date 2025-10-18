// member_selector_widget.dart
//
// Widget para seleccionar miembros de cuadrilla
//
// PROPÓSITO:
// - Selección de usuarios disponibles
// - Designar líder de cuadrilla
// - Validar límites de miembros
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../../domain/entities/available_user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Representa un miembro seleccionado en el formulario
class SelectedMember {
  final AvailableUser user;
  final bool isLeader;

  SelectedMember({required this.user, required this.isLeader});

  SelectedMember copyWith({bool? isLeader}) {
    return SelectedMember(
      user: user,
      isLeader: isLeader ?? this.isLeader,
    );
  }
}

/// Widget para seleccionar miembros de la cuadrilla
class MemberSelectorWidget extends StatelessWidget {
  final List<AvailableUser> availableUsers;
  final List<SelectedMember> selectedMembers;
  final VoidCallback onAddMember;
  final Function(int index) onRemoveMember;
  final Function(int index) onToggleLeader;
  final String? errorText;

  const MemberSelectorWidget({
    super.key,
    required this.availableUsers,
    required this.selectedMembers,
    required this.onAddMember,
    required this.onRemoveMember,
    required this.onToggleLeader,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildMembersList(),
        const SizedBox(height: 12),
        _buildAddButton(),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Miembros de la Cuadrilla',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '*',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selectedMembers.isEmpty
                ? AppColors.error.withOpacity(0.1)
                : AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${selectedMembers.length}/10',
            style: AppTextStyles.bodySmall.copyWith(
              color: selectedMembers.isEmpty ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    if (selectedMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No hay miembros agregados',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agrega al menos un miembro',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selectedMembers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = selectedMembers[index];
        return _buildMemberCard(member, index);
      },
    );
  }

  Widget _buildMemberCard(SelectedMember member, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.isLeader ? AppColors.primary : AppColors.divider,
          width: member.isLeader ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: member.isLeader
                ? AppColors.primary
                : AppColors.secondary,
            child: Text(
              member.user.firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.user.fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LÍDER',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.user.workRoleName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle leader button
              IconButton(
                icon: Icon(
                  member.isLeader ? Icons.star : Icons.star_border,
                  color: member.isLeader ? AppColors.warning : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => onToggleLeader(index),
                tooltip: member.isLeader ? 'Quitar como líder' : 'Designar como líder',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              
              // Remove button
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => onRemoveMember(index),
                tooltip: 'Eliminar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    final canAddMore = selectedMembers.length < 10;
    final hasAvailableUsers = availableUsers.length > selectedMembers.length;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canAddMore && hasAvailableUsers ? onAddMember : null,
        icon: const Icon(Icons.add),
        label: Text(
          canAddMore
              ? 'Agregar Miembro'
              : 'Límite alcanzado (10 miembros)',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: canAddMore ? AppColors.primary : AppColors.divider,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
