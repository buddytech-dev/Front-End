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
  final String logoUrl;
  final String logoColorHex;
  final String logoIconName;
  final String aiSummary;
  final List<String> recommendedActions;
  final String? suggestedEmail;
  final String? meetingScript;
  final ClientMetrics? metrics;

  // Campos extras da Lead
  final String? title;
  final String? description;
  final String? leadSource;
  final String? priority;
  final int? currentScore;
  final int? leadScore;
  final double? probabilityOfClosing;
  final String? nextStepSuggestion;
  final String? suggestedContactType;
  final int? interactionsCount;
  final DateTime? expectedCloseDate;

  // Dados da empresa
  final String? companyCNPJ;
  final String? companyLocation;
  final String? industry;

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
    this.title,
    this.description,
    this.leadSource,
    this.priority,
    this.currentScore,
    this.leadScore,
    this.probabilityOfClosing,
    this.nextStepSuggestion,
    this.suggestedContactType,
    this.interactionsCount,
    this.expectedCloseDate,
    this.companyCNPJ,
    this.companyLocation,
    this.industry,
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
      case 'calendar_view_month':
        return Icons.calendar_view_month;
      case 'fiber_new':
        return Icons.fiber_new;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'corporate_fare':
        return Icons.corporate_fare;
      case 'domain':
        return Icons.domain;
      default:
        return Icons.corporate_fare; // Ícone padrão de empresa
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
      lastInteraction:
          json['last_interaction'] ?? json['lastInteraction'] ?? '',
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
    // Gera cor baseada no título da lead (para variedade visual)
    final colors = ['3B82F6', 'EF4444', '10B981', 'F59E0B', '8B5CF6', 'EC4899'];
    final displayName = lead.displayName;
    final colorIndex = displayName.length % colors.length;

    // Gera ícone baseado no status
    String iconName = 'business';
    final statusLower = lead.status?.toLowerCase() ?? '';
    if (statusLower == 'negotiation' ||
        statusLower == 'closed' ||
        statusLower == 'won') {
      iconName = 'local_fire_department';
    } else if (statusLower == 'new') {
      iconName = 'fiber_new';
    }

    // Formata a última interação baseado na contagem de interações ou data esperada
    String lastInteractionStr = 'Sem interações';
    if (lead.interactionsCount != null && lead.interactionsCount! > 0) {
      lastInteractionStr = '${lead.interactionsCount} interações';
    } else if (lead.expectedCloseDate != null) {
      // Formata a data esperada de fechamento
      final now = DateTime.now();
      final daysRemaining = lead.expectedCloseDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        lastInteractionStr = 'Fecha em $daysRemaining dias';
      } else if (daysRemaining == 0) {
        lastInteractionStr = 'Vence hoje';
      } else {
        lastInteractionStr = 'Vencido há ${-daysRemaining} dias';
      }
    }

    // Rank será calculado no home_page baseado em percentuais da quantidade de leads
    // Por enquanto, usa um valor padrão
    int calculatedRank = 1;

    return ClientModel(
      id: lead.id,
      rank: calculatedRank,
      companyName: lead.companyName ?? displayName,
      companyEmail: lead.companyEmail ?? '',
      contactName: lead.sellerName ?? '',
      contactPhone: lead.companyPhone ?? '',
      status: lead.statusText,
      lastInteraction: lastInteractionStr,
      logoColorHex: colors[colorIndex],
      logoIconName: iconName,
      logoUrl: lead.logoUrl ?? '',
      aiSummary:
          lead.nextStepSuggestion ??
          lead.description ??
          'Análise de IA ainda não disponível para este lead.',
      recommendedActions: lead.suggestedContactType != null
          ? [lead.suggestedContactType!, 'Agendar reunião']
          : ['Fazer primeiro contato', 'Agendar reunião'],
      // Campos extras da lead
      title: lead.title,
      description: lead.description,
      leadSource: lead.leadSource,
      priority: lead.priorityText,
      currentScore: lead.currentScore,
      leadScore: lead.leadScore,
      probabilityOfClosing: lead.probabilityOfClosing,
      nextStepSuggestion: lead.nextStepSuggestion,
      suggestedContactType: lead.suggestedContactType,
      interactionsCount: lead.interactionsCount,
      expectedCloseDate: lead.expectedCloseDate,
      // Dados da empresa
      companyCNPJ: lead.companyCNPJ,
      companyLocation: lead.companyLocation,
      industry: lead.industry,
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
      conversionProbability:
          (json['conversion_probability'] ?? json['conversionProbability'])
              ?.toDouble(),
      interactionCount: json['interaction_count'] ?? json['interactionCount'],
      dealValue: (json['deal_value'] ?? json['dealValue'])?.toDouble(),
      stage: json['stage'],
      daysInPipeline: json['days_in_pipeline'] ?? json['daysInPipeline'],
      engagementScore: (json['engagement_score'] ?? json['engagementScore'])
          ?.toDouble(),
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
