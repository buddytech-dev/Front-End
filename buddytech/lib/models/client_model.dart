import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Modelo de dados do Cliente/Lead
/// Preparado para receber dados de API/Supabase
class ClientModel {
  final String id;
  final int rank;
  final String companyName;
  final String companyEmail;
  final String contactName;
  final String contactPhone;
  final String status;
  final String lastInteraction;
  final String logoUrl; // URL da logo da empresa (se disponivel)
  final String logoColorHex; // Cor em hexadecimal para fallback
  final String logoIconName; // Nome do ícone para fallback
  final String aiSummary;
  final List<String> recommendedActions;
  final String? suggestedEmail; // E-mail sugerido pela IA
  final String? meetingScript; // Roteiro de reunião gerado pela IA
  final ClientMetrics? metrics; // Métricas adicionais do cliente

  ClientModel({
    required this.id,
    required this.rank,
    required this.companyName,
    required this.companyEmail,
    required this.contactName,
    required this.contactPhone,
    required this.status,
    required this.lastInteraction,
    this.logoUrl = '',
    required this.logoColorHex,
    required this.logoIconName,
    required this.aiSummary,
    required this.recommendedActions,
    this.suggestedEmail,
    this.meetingScript,
    this.metrics,
  });

  /// Converte cor hex string para Color
  Color get logoColor {
    try {
      final hexColor = logoColorHex.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return const Color(0xFF3B82F6); // Cor padrão azul
    }
  }

  /// Retorna o ícone baseado no nome
  IconData get logoIcon {
    switch (logoIconName.toLowerCase()) {
      case 'water_drop':
        return Icons.water_drop;
      case 'settings':
        return Icons.settings;
      case 'square':
        return Icons.square_rounded;
      case 'business':
        return Icons.business;
      case 'code':
        return Icons.code;
      case 'cloud':
        return Icons.cloud;
      case 'analytics':
        return Icons.analytics;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'build':
        return Icons.build;
      case 'devices':
        return Icons.devices;
      default:
        return Icons.business;
    }
  }

  /// Cor do badge de ranking (azul padrão)
  Color get rankColor => const Color(0xFF3B82F6);

  /// Factory para criar a partir de JSON (API response)
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']?.toString() ?? '',
      rank: json['rank'] ?? 0,
      companyName: json['company_name'] ?? json['companyName'] ?? '',
      companyEmail: json['company_email'] ?? json['companyEmail'] ?? '',
      contactName: json['contact_name'] ?? json['contactName'] ?? '',
      contactPhone: json['contact_phone'] ?? json['contactPhone'] ?? '',
      status: json['status'] ?? '',
      lastInteraction: json['last_interaction'] ?? json['lastInteraction'] ?? '',
      logoUrl: json['logo_url'] ?? json['logoUrl'] ?? '',
      logoColorHex: json['logo_color'] ?? json['logoColorHex'] ?? '3B82F6',
      logoIconName: json['logo_icon'] ?? json['logoIconName'] ?? 'business',
      aiSummary: json['ai_summary'] ?? json['aiSummary'] ?? '',
      recommendedActions: List<String>.from(
        json['recommended_actions'] ?? json['recommendedActions'] ?? [],
      ),
      suggestedEmail: json['suggested_email'] ?? json['suggestedEmail'],
      meetingScript: json['meeting_script'] ?? json['meetingScript'],
      metrics: json['metrics'] != null
          ? ClientMetrics.fromJson(json['metrics'])
          : null,
    );
  }

  /// Factory para criar a partir de LeadDto da API
  factory ClientModel.fromLeadDto(LeadDto lead) {
    // Gera cor baseada no nome da empresa (para variedade visual)
    final colors = ['3B82F6', 'EF4444', '10B981', 'F59E0B', '8B5CF6', 'EC4899'];
    final colorIndex = lead.companyName.length % colors.length;
    
    // Gera ícone baseado no status ou nome
    String iconName = 'business';
    if (lead.status?.toLowerCase().contains('hot') == true) {
      iconName = 'local_fire_department';
    } else if (lead.status?.toLowerCase().contains('cold') == true) {
      iconName = 'ac_unit';
    }

    // Formata a última interação
    String lastInteractionStr = 'Sem interações';
    if (lead.lastInteraction != null) {
      final diff = DateTime.now().difference(lead.lastInteraction!);
      if (diff.inDays == 0) {
        lastInteractionStr = 'Hoje';
      } else if (diff.inDays == 1) {
        lastInteractionStr = 'Ontem';
      } else if (diff.inDays < 7) {
        lastInteractionStr = 'Há ${diff.inDays} dias';
      } else if (diff.inDays < 30) {
        lastInteractionStr = 'Há ${(diff.inDays / 7).floor()} semanas';
      } else {
        lastInteractionStr = 'Há ${(diff.inDays / 30).floor()} meses';
      }
    }

    return ClientModel(
      id: lead.id,
      rank: lead.rank ?? 0,
      companyName: lead.companyName,
      companyEmail: lead.companyEmail ?? '',
      contactName: lead.contactName ?? '',
      contactPhone: lead.contactPhone ?? '',
      status: lead.status ?? 'Novo',
      lastInteraction: lastInteractionStr,
      logoColorHex: colors[colorIndex],
      logoIconName: iconName,
      aiSummary: lead.aiSummary ?? 'Análise de IA ainda não disponível para este lead.',
      recommendedActions: lead.recommendedActions ?? ['Fazer primeiro contato', 'Agendar reunião'],
    );
  }

  /// Converte para JSON (para enviar à API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rank': rank,
      'company_name': companyName,
      'company_email': companyEmail,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'status': status,
      'last_interaction': lastInteraction,
      'logo_url': logoUrl,
      'logo_color': logoColorHex,
      'logo_icon': logoIconName,
      'ai_summary': aiSummary,
      'recommended_actions': recommendedActions,
      'suggested_email': suggestedEmail,
      'meeting_script': meetingScript,
      'metrics': metrics?.toJson(),
    };
  }
}

/// Métricas adicionais do cliente
class ClientMetrics {
  final double? conversionProbability; // Probabilidade de conversão (0-100)
  final int? interactionCount; // Número de interações
  final double? dealValue; // Valor potencial do negócio
  final String? stage; // Estágio do funil (lead, prospect, qualified, etc)
  final int? daysInPipeline; // Dias no pipeline
  final double? engagementScore; // Score de engajamento (0-100)

  ClientMetrics({
    this.conversionProbability,
    this.interactionCount,
    this.dealValue,
    this.stage,
    this.daysInPipeline,
    this.engagementScore,
  });

  factory ClientMetrics.fromJson(Map<String, dynamic> json) {
    return ClientMetrics(
      conversionProbability: (json['conversion_probability'] ?? json['conversionProbability'])?.toDouble(),
      interactionCount: json['interaction_count'] ?? json['interactionCount'],
      dealValue: (json['deal_value'] ?? json['dealValue'])?.toDouble(),
      stage: json['stage'],
      daysInPipeline: json['days_in_pipeline'] ?? json['daysInPipeline'],
      engagementScore: (json['engagement_score'] ?? json['engagementScore'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversion_probability': conversionProbability,
      'interaction_count': interactionCount,
      'deal_value': dealValue,
      'stage': stage,
      'days_in_pipeline': daysInPipeline,
      'engagement_score': engagementScore,
    };
  }
}
