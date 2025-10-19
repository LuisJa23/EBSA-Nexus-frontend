// crew_member_list.dart
//
// Widget de lista de miembros de cuadrilla
//
// PROPÓSITO:
// - Mostrar miembros de una cuadrilla con opciones de gestión
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crew_member_detail.dart';
import '../providers/crew_detail_provider.dart';

/// Lista de miembros de cuadrilla
class CrewMemberList extends ConsumerWidget {
  final int crewId;
  final List<CrewMemberDetail> members;

  const CrewMemberList({
    super.key,
    required this.crewId,
    required this.members,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (members.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay miembros en esta cuadrilla',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar: líder primero
    final sortedMembers = List<CrewMemberDetail>.from(members);
    sortedMembers.sort((a, b) {
      if (a.isLeader && !b.isLeader) return -1;
      if (!a.isLeader && b.isLeader) return 1;
      return a.fullName.compareTo(b.fullName);
    });

    return Column(
      children: sortedMembers.map((member) {
        return _MemberCard(
          crewId: crewId,
          member: member,
          hasLeader: members.any((m) => m.isLeader),
        );
      }).toList(),
    );
  }
}

class _MemberCard extends ConsumerWidget {
  final int crewId;
  final CrewMemberDetail member;
  final bool hasLeader;

  const _MemberCard({
    required this.crewId,
    required this.member,
    required this.hasLeader,
  });

  Future<void> _confirmPromote(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover a Líder'),
        content: Text(
          hasLeader
              ? 'El líder actual será degradado. ¿Desea promover a ${member.fullName} como nuevo líder?'
              : '¿Desea promover a ${member.fullName} como líder de la cuadrilla?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Promover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Usar userId según el nuevo endpoint del API
      final success = await ref
          .read(crewDetailProvider.notifier)
          .promoteMember(crewId, member.userId);

      if (!success && context.mounted) {
        // El error ya se muestra en el snackbar del listener
      }
    }
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    // No permitir eliminar líder - siempre debe haber un líder
    if (member.isLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede eliminar el líder. Primero promueve a otro miembro como líder.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🔍 Intentando eliminar miembro:');
    print('   - User ID (usado en API): ${member.userId}');
    print('   - Member ID (crew_member): ${member.id}');
    print('   - Crew ID: ${member.crewId}');
    print('   - Nombre: ${member.fullName}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Miembro'),
        content: Text(
          '¿Está seguro de eliminar a ${member.fullName} de la cuadrilla?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Usar userId según el nuevo endpoint del API
      final success = await ref
          .read(crewDetailProvider.notifier)
          .removeMember(crewId, member.userId);

      if (!success && context.mounted) {
        // El error ya se muestra en el snackbar del listener
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPerformingAction = ref.watch(crewDetailProvider).isPerformingAction;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: member.isLeader
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: member.isLeader
                  ? AppColors.primary
                  : Colors.grey[300],
              child: Text(
                member.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: member.isLeader ? Colors.white : Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LÍDER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.workRoleName ?? 'Sin rol asignado',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Menú de opciones
            PopupMenuButton<String>(
              enabled: !isPerformingAction,
              onSelected: (value) {
                switch (value) {
                  case 'promote':
                    _confirmPromote(context, ref);
                    break;
                  case 'remove':
                    _confirmRemove(context, ref);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!member.isLeader)
                  const PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 8),
                        Text('Promover a líder'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
