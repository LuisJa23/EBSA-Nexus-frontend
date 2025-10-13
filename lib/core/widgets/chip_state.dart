import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ChipState extends StatelessWidget {
  final String state;

  const ChipState({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color colorTexto;
    Color colorBorde;
    String texto;

    switch (state) {
      case 'Por asignar':
        colorTexto = AppColors.statusDraft;
        colorBorde = AppColors.statusDraft;
        texto = 'Por asignar';
        break;
      case 'En curso':
        colorTexto = AppColors.statusPending;
        colorBorde = AppColors.statusPending;
        texto = 'En curso';
        break;
      case 'Completado':
        colorTexto = AppColors.statusSent;
        colorBorde = AppColors.statusSent;
        texto = 'Completado';
        break;
      case 'Cerrada':
        colorTexto = AppColors.statusError;
        colorBorde = AppColors.statusError;
        texto = 'Cerrada';
        break;
      default:
        colorTexto = AppColors.textDisabled;
        colorBorde = AppColors.textDisabled;
        texto = 'Desconocido';
        break;
    }

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colorBorde, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceElevated,
      ),
      child: Text(
        texto,
        style: AppTextStyles.reportStatus.copyWith(color: colorTexto),
      ),
    );
  }
}
