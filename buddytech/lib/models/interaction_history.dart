/// Modelo para armazenar histórico de interações com IA
class InteractionHistory {
  final String id;
  final String leadId;
  final String leadName;
  final String interactionType;
  final String content;
  final DateTime date;
  final int? scoreBefore;
  final int? scoreAfter;
  final double? probabilityBefore;
  final double? probabilityAfter;
  final String? aiSuggestion;

  InteractionHistory({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.interactionType,
    required this.content,
    required this.date,
    this.scoreBefore,
    this.scoreAfter,
    this.probabilityBefore,
    this.probabilityAfter,
    this.aiSuggestion,
  });

  /// Converte para JSON para salvar localmente
  Map<String, dynamic> toJson() => {
    'id': id,
    'leadId': leadId,
    'leadName': leadName,
    'interactionType': interactionType,
    'content': content,
    'date': date.toIso8601String(),
    'scoreBefore': scoreBefore,
    'scoreAfter': scoreAfter,
    'probabilityBefore': probabilityBefore,
    'probabilityAfter': probabilityAfter,
    'aiSuggestion': aiSuggestion,
  };

  /// Cria a partir de JSON
  factory InteractionHistory.fromJson(Map<String, dynamic> json) {
    return InteractionHistory(
      id: json['id'] ?? '',
      leadId: json['leadId'] ?? '',
      leadName: json['leadName'] ?? '',
      interactionType: json['interactionType'] ?? '',
      content: json['content'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      scoreBefore: json['scoreBefore'],
      scoreAfter: json['scoreAfter'],
      probabilityBefore: json['probabilityBefore']?.toDouble(),
      probabilityAfter: json['probabilityAfter']?.toDouble(),
      aiSuggestion: json['aiSuggestion'],
    );
  }

  /// Retorna o tipo formatado para exibição
  String get typeLabel {
    switch (interactionType.toLowerCase()) {
      case 'call':
        return 'Ligação';
      case 'email':
        return 'E-mail';
      case 'meeting':
        return 'Reunião';
      case 'visit':
        return 'Visita';
      case 'proposal':
        return 'Proposta';
      case 'negotiation':
        return 'Negociação';
      case 'follow_up':
        return 'Follow-up';
      case 'demo':
        return 'Demonstração';
      default:
        return interactionType;
    }
  }

  /// Retorna o ícone correspondente ao tipo
  String get typeIcon {
    switch (interactionType.toLowerCase()) {
      case 'call':
        return '📞';
      case 'email':
        return '✉️';
      case 'meeting':
        return '📅';
      case 'visit':
        return '📍';
      case 'proposal':
        return '📄';
      case 'negotiation':
        return '🤝';
      case 'follow_up':
        return '🔄';
      case 'demo':
        return '▶️';
      default:
        return '💬';
    }
  }
}
