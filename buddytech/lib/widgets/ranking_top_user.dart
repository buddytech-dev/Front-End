// ============================================================================
// ranking_top_user.dart
// Widget: Exibe um usuário no pódio (1º, 2º ou 3º lugar)
// ============================================================================
//
// Este widget representa o card circular com:
//  • Ícone de usuário
//  • Nome
//  • Pontuação
//  • Destaque especial para o 1º lugar (com coroa)
//
// Utilizado na seção superior da tela de Ranking (pódio principal).
//
// ============================================================================

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class RankingTopUser extends StatelessWidget {
  final int position;
  final int points;
  final bool highlighted;

  const RankingTopUser({
    super.key,
    required this.position,
    required this.points,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone da coroa para o campeão
        if (highlighted)
          const Icon(Icons.emoji_events, color: Colors.orange, size: 28),

        // Avatar circular
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: highlighted ? Colors.orange : AppColors.primary,
              width: highlighted ? 2.5 : 1.5,
            ),
          ),
          child: const Icon(Icons.person, size: 40, color: AppColors.primary),
        ),

        const SizedBox(height: 8),

        // Nome
        Text(
          "Nome do Usuário",
          style: TextStyle(
            fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        // Pontos
        Text(
          "$points Pts",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
