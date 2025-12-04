// ============================================================================
// client_details_page.dart
// Página de detalhes do cliente
// ============================================================================
//
// Responsável por:
//  • Exibir informações detalhadas sobre um cliente
//  • Receber um argumento (clientId) via Navigator (settings.arguments)
//  • Oferecer ações rápidas: ligar, enviar e-mail, gerar roteiro, abrir histórico
//
// Observação:
//  • Atualmente usa dados mock quando clientId for nulo.
//  • Integre com Supabase usando clientId para buscar dados reais.
// ============================================================================

import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ClientDetailsPage extends StatelessWidget {
  const ClientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Espera receber um map com os dados via arguments:
    // Navigator.pushNamed(context, AppRoutes.clientDetails, arguments: {"clientId": "abc"})
    final args = ModalRoute.of(context)?.settings.arguments;
    final clientId = (args is Map && args['clientId'] != null)
        ? args['clientId'] as String
        : null;

    // MOCK data enquanto backend não estiver integrado
    final client = clientId == null
        ? {
            "company": "Premiere Soft",
            "contact": "Cleber Machado",
            "email": "contato@premiere.com",
            "phone": "(47) 9 9999-9999",
            "status": "Alta probabilidade",
            "notes": "Interessado em solução X. Agenda reunião.",
          }
        : null; // quando implementar: buscar via Supabase

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do cliente"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: client == null
            ? const Center(child: Text("Carregando..."))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client['company']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    client['email']!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    client['contact']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(client['phone']!),
                  const SizedBox(height: 12),
                  Text(
                    "Status: ${client['status']}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Notas:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(client['notes']!),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // exemplo: abrir tela de meeting script com dados do cliente
                            Navigator.pushNamed(
                              context,
                              '/meeting-script',
                              arguments: {"clientId": clientId ?? "mock"},
                            );
                          },
                          child: const Text("Gerar roteiro"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // ex.: abrir histórico / ações concluídas
                            Navigator.pushNamed(
                              context,
                              '/completed-actions',
                              arguments: {"clientId": clientId ?? "mock"},
                            );
                          },
                          child: const Text("Ações"),
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
