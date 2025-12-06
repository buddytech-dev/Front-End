import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interaction_history.dart';

/// Serviço responsável pelo gerenciamento do histórico de interações.
/// Utiliza SharedPreferences para persistência local dos dados.
class InteractionHistoryService {
  static const String _storageKey = 'interaction_history';
  static const int _maxHistoryItems = 100; // Limite de itens salvos

  /// Salva uma nova interação no histórico
  Future<void> saveInteraction(InteractionHistory interaction) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Adiciona no início da lista (mais recentes primeiro)
    history.insert(0, interaction);
    
    // Limita o tamanho do histórico
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Salva a lista atualizada
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
    
    print('💾 Interação salva no histórico: ${interaction.leadName} - ${interaction.typeLabel}');
  }

  /// Carrega todo o histórico de interações
  Future<List<InteractionHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((e) => InteractionHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao carregar histórico: $e');
      return [];
    }
  }

  /// Filtra histórico por lead
  Future<List<InteractionHistory>> getHistoryByLead(String leadId) async {
    final history = await getHistory();
    return history.where((e) => e.leadId == leadId).toList();
  }

  /// Filtra histórico por tipo de interação
  Future<List<InteractionHistory>> getHistoryByType(String type) async {
    final history = await getHistory();
    return history.where((e) => e.interactionType == type).toList();
  }

  /// Filtra histórico por período
  Future<List<InteractionHistory>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final history = await getHistory();
    return history.where((e) => 
      e.date.isAfter(start) && e.date.isBefore(end)
    ).toList();
  }

  /// Limpa todo o histórico
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    print('🗑️ Histórico limpo');
  }

  /// Remove uma interação específica
  Future<void> removeInteraction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.removeWhere((e) => e.id == id);
    
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// Retorna estatísticas do histórico
  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    
    if (history.isEmpty) {
      return {
        'total': 0,
        'byType': <String, int>{},
        'thisWeek': 0,
        'thisMonth': 0,
      };
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final byType = <String, int>{};
    int thisWeek = 0;
    int thisMonth = 0;

    for (final item in history) {
      // Conta por tipo
      byType[item.interactionType] = (byType[item.interactionType] ?? 0) + 1;
      
      // Conta por período
      if (item.date.isAfter(weekAgo)) thisWeek++;
      if (item.date.isAfter(monthAgo)) thisMonth++;
    }

    return {
      'total': history.length,
      'byType': byType,
      'thisWeek': thisWeek,
      'thisMonth': thisMonth,
    };
  }
}
