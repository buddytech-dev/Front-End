// ============================================================================
// ranking_page.dart
// Tela de Ranking utilizando widgets customizados para Top Users e Pódio
// ============================================================================
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/theme.dart';
import '../widgets/ranking_top_user.dart';
import '../widgets/ranking_podium_box.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final bg = AppColors.background;

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

            // ---------------------------
            //  ABAS (Label1, Label2, Label3)
            // ---------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.2),
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

            // ---------------------------
            //  Top 3 Circular Photos
            // ---------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                RankingTopUser(position: 2, points: 8999, highlighted: false),
                RankingTopUser(position: 1, points: 9999, highlighted: true),
                RankingTopUser(position: 3, points: 7999, highlighted: false),
              ],
            ),

            const SizedBox(height: 24),

            // ---------------------------
            //  Podium
            // ---------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  RankingPodiumBox(position: 2, isSelected: false),
                  SizedBox(width: 10),
                  RankingPodiumBox(position: 1, isSelected: true),
                  SizedBox(width: 10),
                  RankingPodiumBox(position: 3, isSelected: false),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ---------------------------
            //  Lista completa
            // ---------------------------
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
                  // Cabeçalho
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Colocação",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Nome do Usuário",
                            style: TextStyle(
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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.white.withOpacity(.4)),

                  // Mock list
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
                              "${1000 - i * 100}",
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
            color: active ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
