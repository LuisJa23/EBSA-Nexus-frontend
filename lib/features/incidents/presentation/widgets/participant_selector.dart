// participant_selector.dart
//
// Widget para seleccionar participantes del reporte de resolución
//
// PROPÓSITO:
// - Mostrar lista de miembros de cuadrilla
// - Permitir selección múltiple de participantes
// - Botones para seleccionar/deseleccionar todos
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../state/create_report_state.dart';
import '../providers/novelty_resolution_providers.dart';

class ParticipantSelector extends ConsumerWidget {
  final CrewMembersLoaded state;

  const ParticipantSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botones de acción
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(createReportProvider.notifier).selectAll();
                },
                icon: const Icon(Icons.check_box, size: 18),
                label: const Text('Todos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(createReportProvider.notifier).deselectAll();
                },
                icon: const Icon(Icons.check_box_outline_blank, size: 18),
                label: const Text('Ninguno'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contador de seleccionados
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${state.selectedParticipants.length} de ${state.members.length} seleccionados',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista de miembros
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.members.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = state.members[index];
              final isSelected = state.selectedParticipants.contains(
                member.userId,
              );

              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  ref
                      .read(createReportProvider.notifier)
                      .toggleParticipant(member.userId);
                },
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${member.firstName} ${member.lastName}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (member.isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Líder',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (member.workRoleName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member.workRoleName!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
              );
            },
          ),
        ),
      ],
    );
  }
}
