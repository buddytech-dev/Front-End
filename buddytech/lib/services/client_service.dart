import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';

/// Serviço para gerenciar dados de clientes
/// Preparado para integração com Supabase ou outra API
class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca a lista de clientes/leads prioritários
  /// Retorna os clientes ordenados por rank
  Future<List<ClientModel>> getClients() async {
    try {
      // TODO: Descomentar quando a tabela 'clients' estiver criada no Supabase
      // final response = await _supabase
      //     .from('clients')
      //     .select()
      //     .order('rank', ascending: true);
      // 
      // return (response as List)
      //     .map((json) => ClientModel.fromJson(json))
      //     .toList();

      // Por enquanto, retorna dados mockados
      return _getMockClients();
    } catch (e) {
      print('Erro ao buscar clientes: $e');
      return _getMockClients();
    }
  }

  /// Busca um cliente específico pelo ID
  Future<ClientModel?> getClientById(String id) async {
    try {
      // TODO: Descomentar quando a tabela 'clients' estiver criada no Supabase
      // final response = await _supabase
      //     .from('clients')
      //     .select()
      //     .eq('id', id)
      //     .single();
      // 
      // return ClientModel.fromJson(response);

      // Por enquanto, busca nos dados mockados
      final clients = await _getMockClients();
      return clients.firstWhere(
        (c) => c.id == id,
        orElse: () => clients.first,
      );
    } catch (e) {
      print('Erro ao buscar cliente: $e');
      return null;
    }
  }

  /// Gera resumo de IA para um cliente
  /// TODO: Integrar com API de IA (OpenAI, Gemini, etc.)
  Future<String> generateAISummary(String clientId) async {
    try {
      // TODO: Implementar chamada para API de IA
      // final response = await http.post(
      //   Uri.parse('SUA_API_DE_IA/generate-summary'),
      //   body: jsonEncode({'client_id': clientId}),
      // );
      // return jsonDecode(response.body)['summary'];

      // Por enquanto retorna o resumo existente
      final client = await getClientById(clientId);
      return client?.aiSummary ?? 'Resumo não disponível';
    } catch (e) {
      print('Erro ao gerar resumo IA: $e');
      return 'Erro ao gerar resumo';
    }
  }

  /// Gera ações recomendadas para um cliente
  /// TODO: Integrar com API de IA
  Future<List<String>> generateRecommendedActions(String clientId) async {
    try {
      // TODO: Implementar chamada para API de IA
      // final response = await http.post(
      //   Uri.parse('SUA_API_DE_IA/generate-actions'),
      //   body: jsonEncode({'client_id': clientId}),
      // );
      // return List<String>.from(jsonDecode(response.body)['actions']);

      // Por enquanto retorna as ações existentes
      final client = await getClientById(clientId);
      return client?.recommendedActions ?? [];
    } catch (e) {
      print('Erro ao gerar ações: $e');
      return [];
    }
  }

  /// Gera e-mail sugerido para um cliente
  /// TODO: Integrar com API de IA
  Future<String> generateSuggestedEmail(String clientId) async {
    try {
      // TODO: Implementar chamada para API de IA
      // final response = await http.post(
      //   Uri.parse('SUA_API_DE_IA/generate-email'),
      //   body: jsonEncode({'client_id': clientId}),
      // );
      // return jsonDecode(response.body)['email'];

      // Por enquanto retorna um template
      final client = await getClientById(clientId);
      return '''
Assunto: Proposta Comercial - ${client?.companyName}

Prezado(a) ${client?.contactName},

Espero que esta mensagem o encontre bem.

Conforme nossa última conversa, gostaria de apresentar nossa proposta comercial personalizada para a ${client?.companyName}.

[Conteúdo gerado pela IA baseado no histórico do cliente]

Fico à disposição para agendarmos uma reunião e discutirmos os próximos passos.

Atenciosamente,
Equipe BuddyTech
      ''';
    } catch (e) {
      print('Erro ao gerar e-mail: $e');
      return 'Erro ao gerar e-mail sugerido';
    }
  }

  /// Gera roteiro de reunião para um cliente
  /// TODO: Integrar com API de IA
  Future<String> generateMeetingScript(String clientId) async {
    try {
      // TODO: Implementar chamada para API de IA
      // final response = await http.post(
      //   Uri.parse('SUA_API_DE_IA/generate-meeting-script'),
      //   body: jsonEncode({'client_id': clientId}),
      // );
      // return jsonDecode(response.body)['script'];

      // Por enquanto retorna um template
      final client = await getClientById(clientId);
      return '''
ROTEIRO DE REUNIÃO - ${client?.companyName}

📋 PREPARAÇÃO (5 min antes)
• Revisar histórico de interações
• Verificar status atual: ${client?.status}
• Preparar materiais relevantes

🎯 ABERTURA (5 min)
• Cumprimentar ${client?.contactName}
• Confirmar pauta e tempo disponível
• Estabelecer objetivos da reunião

💼 DESENVOLVIMENTO (20 min)
• Apresentar proposta/solução
• Destacar benefícios específicos
• Abordar possíveis objeções

❓ DISCUSSÃO (10 min)
• Abrir para perguntas
• Esclarecer dúvidas
• Coletar feedback

✅ FECHAMENTO (5 min)
• Resumir principais pontos
• Definir próximos passos
• Agendar follow-up

📝 NOTAS PÓS-REUNIÃO
• Registrar decisões tomadas
• Atualizar CRM
• Enviar e-mail de acompanhamento
      ''';
    } catch (e) {
      print('Erro ao gerar roteiro: $e');
      return 'Erro ao gerar roteiro de reunião';
    }
  }

  /// Marca uma ação como concluída
  Future<bool> markActionAsCompleted(String clientId, String action) async {
    try {
      // TODO: Implementar atualização no Supabase
      // await _supabase
      //     .from('client_actions')
      //     .insert({
      //       'client_id': clientId,
      //       'action': action,
      //       'completed_at': DateTime.now().toIso8601String(),
      //     });

      print('Ação marcada como concluída: $action');
      return true;
    } catch (e) {
      print('Erro ao marcar ação: $e');
      return false;
    }
  }

  /// Dados mockados para desenvolvimento
  List<ClientModel> _getMockClients() {
    return [
      ClientModel(
        id: '1',
        rank: 1,
        companyName: 'teste1',
        companyEmail: 'anacarolina@teste1.com',
        contactName: 'Ana Carolina',
        contactPhone: '+55 47 99999-7777',
        status: 'Quente - Alta probabilidade',
        lastInteraction: '15/04/2024',
        logoColorHex: '3B82F6',
        logoIconName: 'water_drop',
        aiSummary:
            'Texto feito por ia.',
        recommendedActions: [
          'feita por ia;',
          'ia tambem;',
          'papapa vai ser feito por nossa ia.',
        ],
        suggestedEmail: null,
        meetingScript: null,
        metrics: ClientMetrics(
          conversionProbability: 85,
          interactionCount: 12,
          dealValue: 45000,
          stage: 'qualified',
          daysInPipeline: 45,
          engagementScore: 92,
        ),
      ),
      ClientModel(
        id: '2',
        rank: 2,
        companyName: 'bibinha teste2',
        companyEmail: 'bibinha@bibinhateste2.com.br',
        contactName: 'bibinha da Silva',
        contactPhone: '+55 11 98888-5555',
        status: 'Morno - Alta probabilidade',
        lastInteraction: '22/03/2024',
        logoColorHex: 'FFC107',
        logoIconName: 'settings',
        aiSummary:
            'vai vir',
        recommendedActions: [
          'vem por ia;',
          'ia;',
          'ia.',
        ],
        suggestedEmail: null,
        meetingScript: null,
        metrics: ClientMetrics(
          conversionProbability: 65,
          interactionCount: 8,
          dealValue: 78000,
          stage: 'prospect',
          daysInPipeline: 30,
          engagementScore: 75,
        ),
      ),
      ClientModel(
        id: '3',
        rank: 3,
        companyName: 'teste3',
        companyEmail: 'teste3@teste3.com',
        contactName: 'testador Cardoso',
        contactPhone: '+55 11 92222-1111',
        status: 'Morno - Alta estabilidade',
        lastInteraction: '05/02/2024',
        logoColorHex: 'FFC107',
        logoIconName: 'square',
        aiSummary:
            'vem por ia.',
        recommendedActions: [
          'ia;',
          'ia;',
          'IA.',
        ],
        suggestedEmail: null,
        meetingScript: null,
        metrics: ClientMetrics(
          conversionProbability: 90,
          interactionCount: 24,
          dealValue: 120000,
          stage: 'customer',
          daysInPipeline: 0,
          engagementScore: 88,
        ),
      ),
    ];
  }
}
