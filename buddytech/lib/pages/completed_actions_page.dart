// ============================================================================
// completed_actions_page.dart
// Tela de Ações Concluídas (Histórico)
// ============================================================================
//
// Responsável por:
//  • Listar ações finalizadas relacionadas a clientes/contatos
//  • Servir como histórico para follow-ups e KPI
//
// Observação:
//  • Atualmente carrega dados mock. Substituir por consulta ao Supabase conforme necessário.
// ============================================================================

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class CompletedActionsPage extends StatelessWidget {
  const CompletedActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // mock data
    final actions = [
      {"title": "Sent proposal to Acme", "date": "2025-11-10"},
      {"title": "Follow-up call with Beta Ltd", "date": "2025-11-12"},
      {"title": "Demo completed with Gamma", "date": "2025-11-13"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ações concluídas"),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final a = actions[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(a['title']!),
              subtitle: Text(a['date']!),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: actions.length,
      ),
    );
  }
}
