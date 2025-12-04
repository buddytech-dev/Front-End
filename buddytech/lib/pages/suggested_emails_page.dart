// ============================================================================
// suggested_emails_page.dart
// Página: Emails sugeridos para follow-up
// ============================================================================
//
// Responsável por:
//  • Exibir templates de e-mail prontos ou sugeridos
//  • Permitir que o usuário copie o texto para o clipboard
//  • Futuramente, poderá integrar IA para gerar e-mails personalizados
//
// Observação:
//  • Atualmente usa templates fixos (mock).
//  • Ideal para ser integrado ao Supabase + IA no futuro.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';

class SuggestedEmailsPage extends StatelessWidget {
  const SuggestedEmailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------------------
    // Templates mockados de email
    // ------------------------------------------------------------------------
    final suggestions = [
      """
Olá {nome},

Obrigado pelo seu tempo hoje! Conforme conversamos, estou enviando o resumo com os próximos passos e o material complementar.

Fico à disposição para dúvidas!
""",
      """
Oi {nome},

Passando para reforçar nossa proposta e verificar se podemos avançar com a próxima etapa.

Se quiser, posso ajustar algo conforme sua necessidade.
""",
      """
Olá {nome},

Parabéns pelos resultados recentes! Aproveito para sugerir uma breve reunião para alinharmos como podemos ajudar ainda mais no seu crescimento.

Quando seria um bom horário?
""",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emails sugeridos"),
        backgroundColor: AppColors.primary,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),

        itemBuilder: (context, i) {
          final text = suggestions[i];

          return Card(
            elevation: 2,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Copiado para a área de transferência",
                                ),
                              ),
                            );
                          },
                          child: const Text("Copiar"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Ideal: abrir editor de email personalizado
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Editor não implementado"),
                              ),
                            );
                          },
                          child: const Text("Editar"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
