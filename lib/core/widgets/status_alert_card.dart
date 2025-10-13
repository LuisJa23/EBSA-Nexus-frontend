import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum StatusType { alerta, atencion, verificacion }

class StatusCard extends StatelessWidget {
  final StatusType type;
  final String title;
  final String subtitle;

  const StatusCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = {
      StatusType.alerta: {
        "color": AppColors.warning,
        "icon": Icons.info_outline,
      },
      StatusType.atencion: {
        "color": AppColors.error,
        "icon": Icons.info_outline,
      },
      StatusType.verificacion: {
        "color": AppColors.success,
        "icon": Icons.info_outline,
      },
    };

    final color = statusConfig[type]!['color'] as Color;
    final icon = statusConfig[type]!['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surfaceElevated,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.heading4),
              Text(subtitle, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
