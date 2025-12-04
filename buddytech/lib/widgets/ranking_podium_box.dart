// ============================================================================
// ranking_podium_box.dart
// Widget: Renderiza o bloco numérico do pódio (1º, 2º, 3º lugar)
// ============================================================================
//
// Este widget exibe:
//  • A colocação do usuário (1º, 2º, 3º)
//  • Um container estilizado como barra do pódio
//
// Usado abaixo dos avatars do pódio principal.
//
// ============================================================================

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class RankingPodiumBox extends StatelessWidget {
  final int position;
  final bool isSelected;

  const RankingPodiumBox({
    super.key,
    required this.position,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (position) {
      1 => 140.0,
      2 => 110.0,
      3 => 95.0,
      _ => 100.0,
    };

    return Container(
      width: 85,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "$position°",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
    );
  }
}
