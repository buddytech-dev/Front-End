/// Modelo para missões que o seller pode completar para ganhar pontos
class Mission {
  final String id;
  final String title;
  final String description;
  final int points;
  final String
  category; // 'call', 'email', 'meeting', 'proposal', 'negotiation'
  final int? requiredCount; // Quantas ações são necessárias (ex: 5 ligações)
  final bool completed;
  final DateTime? completedAt;
  final int currentProgress; // Progresso atual (ex: 3 de 5)

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.category,
    this.requiredCount,
    this.completed = false,
    this.completedAt,
    this.currentProgress = 0,
  });

  bool get isInProgress =>
      requiredCount != null &&
      currentProgress > 0 &&
      currentProgress < requiredCount!;

  double get progressPercentage {
    if (requiredCount == null || requiredCount! == 0) return 0.0;
    return (currentProgress / requiredCount!) * 100;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'points': points,
    'category': category,
    'requiredCount': requiredCount,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
    'currentProgress': currentProgress,
  };

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      category: json['category'] ?? 'call',
      requiredCount: json['requiredCount'],
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    String? category,
    int? requiredCount,
    bool? completed,
    DateTime? completedAt,
    int? currentProgress,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      category: category ?? this.category,
      requiredCount: requiredCount ?? this.requiredCount,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}
