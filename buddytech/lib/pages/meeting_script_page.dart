// ============================================================================
// meeting_script_page.dart
// Página: Gerar / Visualizar roteiro de reunião
// ============================================================================
//
// Agora totalmente integrado ao AppTheme:
//  • Usa Theme.of(context).textTheme
//  • Usa AppColors apenas onde necessário
//  • Remove hardcoded styles
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
//import '../config/theme.dart';

class MeetingScriptPage extends StatelessWidget {
  const MeetingScriptPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Argument "clientId" opcional
    final args = ModalRoute.of(context)?.settings.arguments;
    final clientId = (args is Map && args['clientId'] != null)
        ? args['clientId'] as String
        : "mock-client";

    final script = [
      "1) Abertura e rapport",
      "2) Confirmar agenda e tempo disponível",
      "3) Descobrir dores e prioridades",
      "4) Apresentar proposta de valor",
      "5) Próximos passos e responsabilidades",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting Script"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // Client ID (texto secundário)
            // -------------------------
            Text(
              "Client ID: $clientId",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Título da lista
            // -------------------------
            Text(
              "Suggested script:",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // -------------------------
            // Lista com o roteiro
            // -------------------------
            Expanded(
              child: ListView.builder(
                itemCount: script.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      script[i],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // -------------------------
            // Botões (usar tema global)
            // -------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = script.join("\n");
                      Clipboard.setData(ClipboardData(text: text));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Script copied to clipboard"),
                        ),
                      );
                    },
                    child: const Text("Copy script"),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Export not implemented")),
                    );
                  },
                  child: const Text("Export"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
