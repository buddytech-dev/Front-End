// ============================================================================
// ranking_page.dart
// Página de Ranking gamificado - BuddyTech
// ============================================================================
//
// Responsável por:
//  • Exibir o ranking dos usuários (top 3 em destaque + lista)
//  • Apresentar abas (filtros) e o pódio visual
//  • Servir como template: os dados atualmente são mock/placeholders
//
// Observações:
//  • Importa as cores do AppColors (lib/config/app_colors.dart).
//  • Widgets privados (_TopUser e _PodiumBox) estão no mesmo arquivo.
//  • Tradução/documentação em português.
// ============================================================================

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Página principal do ranking.
/// Mostra: AppBar customizada, abas, top 3 com avatar circular, pódio visual e lista de posições.
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final bg = AppColors.background;
    final surface = AppColors.surface;
    final textPrimary = AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Ranking",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ---------- ABAS (filtros) ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    _buildTab("Label 2", false),
                    _buildTab("Label 1", true),
                    _buildTab("Label 3", false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------- TOP 3 (circulares) ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _TopUser(position: 2, points: 8999, highlighted: false),
                _TopUser(position: 1, points: 9999, highlighted: true),
                _TopUser(position: 3, points: 7999, highlighted: false),
              ],
            ),

            const SizedBox(height: 24),

            // ---------- PÓDIO ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _PodiumBox(label: "2°", height: 120),
                  SizedBox(width: 10),
                  _PodiumBox(label: "1°", height: 155),
                  SizedBox(width: 10),
                  _PodiumBox(label: "3°", height: 100),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ---------- LISTA COMPLETA ----------
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.only(top: 14, bottom: 10),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho da tabela
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Colocação",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Nome do Usuário",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Pontos",
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.white.withOpacity(.4)),

                  // Linhas mock (4° ao 9°)
                  ...List.generate(6, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${i + 4}°",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Nome do Usuário",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${(1000 - i * 100)}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Aba individual (botão estilizado)
  Widget _buildTab(String text, bool active) {
    return Expanded(
      child: Container(
        height: 44,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? AppColors.surface : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Widget privado que representa um dos top users (1°, 2° ou 3°).
/// - [position]: posição do usuário (1,2,3)
/// - [points]: pontos do usuário
/// - [highlighted]: quando true, mostra ícone de troféu e estilo em destaque
class _TopUser extends StatelessWidget {
  final int position;
  final int points;
  final bool highlighted;

  const _TopUser({
    super.key,
    required this.position,
    required this.points,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (highlighted)
          const Icon(Icons.emoji_events, color: Colors.orange, size: 28),

        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: highlighted ? Colors.orange : AppColors.primary,
              width: highlighted ? 2.5 : 1.5,
            ),
            color: AppColors.surface, // fundo branco do círculo
          ),
          child: Icon(Icons.person, size: 40, color: AppColors.primary),
        ),

        const SizedBox(height: 8),

        // Nome (placeholder)
        Text(
          "Nome do Usuário",
          style: TextStyle(
            fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),

        // Pontuação
        Text(
          "$points Pts",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Caixa do pódio (1°, 2°, 3°)
class _PodiumBox extends StatelessWidget {
  final String label;
  final double height;

  const _PodiumBox({super.key, required this.label, required this.height});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.surface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
