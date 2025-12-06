import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission_model.dart';

/// Serviço para gerenciar missões do seller e pontos
class MissionService {
  static const String _missionsKey = 'seller_missions';
  static const String _completedMissionsKey = 'completed_missions';
  static const String _totalPointsKey = 'seller_total_points';

  /// Carrega todas as missões disponíveis
  Future<List<Mission>> getAvailableMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_missionsKey);

      if (raw == null || raw.isEmpty) {
        // Retorna missões padrão
        return _getDefaultMissions();
      }

      final List<dynamic> list = json.decode(raw);
      return list
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getDefaultMissions();
    }
  }

  /// Retorna as missões padrão do sistema
  List<Mission> _getDefaultMissions() {
    return [
      Mission(
        id: 'mission_calls_5',
        title: '5 Ligações Realizadas',
        description: 'Realize 5 ligações para leads para iniciar contato.',
        points: 50,
        category: 'call',
        requiredCount: 5,
        currentProgress: 0,
      ),
      Mission(
        id: 'mission_emails_10',
        title: '10 E-mails Enviados',
        description: 'Envie 10 e-mails de acompanhamento para leads.',
        points: 40,
        category: 'email',
        requiredCount: 10,
        currentProgress: 0,
      ),
      Mission(
        id: 'mission_meetings_3',
        title: '3 Reuniões Agendadas',
        description: 'Agende 3 reuniões com leads potenciais.',
        points: 75,
        category: 'meeting',
        requiredCount: 3,
        currentProgress: 0,
      ),
      Mission(
        id: 'mission_proposals_2',
        title: '2 Propostas Enviadas',
        description: 'Envie 2 propostas comerciais para leads.',
        points: 100,
        category: 'proposal',
        requiredCount: 2,
        currentProgress: 0,
      ),
      Mission(
        id: 'mission_negotiations_1',
        title: '1 Negociação Iniciada',
        description: 'Inicie pelo menos 1 negociação com um lead.',
        points: 150,
        category: 'negotiation',
        requiredCount: 1,
        currentProgress: 0,
      ),
      Mission(
        id: 'mission_daily_5',
        title: 'Atividades Diárias',
        description: 'Complete qualquer 5 interações em um dia.',
        points: 60,
        category: 'call',
        requiredCount: 5,
        currentProgress: 0,
      ),
    ];
  }

  /// Obtém as missões completadas
  Future<List<String>> getCompletedMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_completedMissionsKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Completa uma missão e adiciona pontos
  Future<int> completeMission(Mission mission) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getStringList(_completedMissionsKey) ?? [];

      if (!completed.contains(mission.id)) {
        completed.add(mission.id);
        await prefs.setStringList(_completedMissionsKey, completed);

        // Adiciona os pontos
        final currentPoints = await getTotalPoints();
        final newTotal = currentPoints + mission.points;
        await prefs.setInt(_totalPointsKey, newTotal);

        return newTotal;
      }

      return await getTotalPoints();
    } catch (e) {
      return await getTotalPoints();
    }
  }

  /// Obtém o total de pontos do seller
  Future<int> getTotalPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_totalPointsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Atualiza o progresso de uma missão
  Future<void> updateMissionProgress(String missionId, int progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final missions = await getAvailableMissions();

      final updatedMissions = missions.map((m) {
        if (m.id == missionId) {
          return m.copyWith(currentProgress: progress);
        }
        return m;
      }).toList();

      final jsonList = updatedMissions.map((m) => m.toJson()).toList();
      await prefs.setString(_missionsKey, json.encode(jsonList));
    } catch (e) {
      // Erro ao atualizar
    }
  }

  /// Reseta todas as missões (útil para testes)
  Future<void> resetMissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_missionsKey);
      await prefs.remove(_completedMissionsKey);
      await prefs.remove(_totalPointsKey);
    } catch (e) {
      // Erro ao resetar
    }
  }

  /// Salva missões customizadas
  Future<void> saveMissions(List<Mission> missions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = missions.map((m) => m.toJson()).toList();
      await prefs.setString(_missionsKey, json.encode(jsonList));
    } catch (e) {
      // Erro ao salvar
    }
  }
}
