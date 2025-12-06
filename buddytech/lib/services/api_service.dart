import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';

/// Serviço para comunicação com a API BuddyTech
class ApiService {
  // URL base da API vem do config
  String get _baseUrl => ApiConfig.baseUrl;

  // Headers padrão para requisições
  Map<String, String> get _headers => ApiConfig.headers;

  /// Obtém o ID do vendedor logado
  String? get currentSellerId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  // ==================== LEAD ====================

  /// Busca todos os leads (sem filtro)
  Future<ApiResponse<List<LeadDto>>> getAllLeads() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Lead'),
        headers: _headers,
      );

      print('📋 GET Leads - Status: ${response.statusCode}');
      print('📋 GET Leads - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leads = data.map((json) => LeadDto.fromJson(json)).toList();

        // Debug: Verifica dados da IA em cada lead
        for (var lead in leads) {
          print('🤖 Lead "${lead.displayName}" - Dados IA:');
          print('   currentScore: ${lead.currentScore}');
          print('   probabilityOfClosing: ${lead.probabilityOfClosing}');
          print('   nextStepSuggestion: ${lead.nextStepSuggestion}');
          print('   suggestedContactType: ${lead.suggestedContactType}');
          print('   priority: ${lead.priority}');
        }

        return ApiResponse.success(leads);
      } else if (response.statusCode == 404) {
        return ApiResponse.success([]);
      } else {
        return ApiResponse.error(
          'Erro ao buscar leads: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erro getAllLeads: $e');
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Busca todos os leads do vendedor logado
  Future<ApiResponse<List<LeadDto>>> getLeadsBySeller() async {
    final sellerId = currentSellerId;
    if (sellerId == null) {
      return ApiResponse.error('Usuário não autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Lead/seller/$sellerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leads = data.map((json) => LeadDto.fromJson(json)).toList();
        return ApiResponse.success(leads);
      } else if (response.statusCode == 404) {
        return ApiResponse.success([]); // Sem leads
      } else {
        return ApiResponse.error(
          'Erro ao buscar leads: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Busca um lead por ID
  Future<ApiResponse<LeadDto>> getLeadById(String id) async {
    try {
      print('🔍 Buscando lead ID: $id');
      final response = await http.get(
        Uri.parse('$_baseUrl/Lead/$id'),
        headers: _headers,
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Dados parseados:');
        print(
          '   - currentScore: ${data['currentScore'] ?? data['CurrentScore']}',
        );
        print(
          '   - probabilityOfClosing: ${data['probabilityOfClosing'] ?? data['ProbabilityOfClosing']}',
        );
        print(
          '   - interactionsCount: ${data['interactionsCount'] ?? data['InteractionsCount']}',
        );
        print('   - priority: ${data['priority'] ?? data['Priority']}');
        return ApiResponse.success(LeadDto.fromJson(data));
      } else {
        return ApiResponse.error('Lead não encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar lead: $e');
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Cria um novo lead
  Future<ApiResponse<LeadDto>> createLead(CreateLeadDto lead) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Lead'),
        headers: _headers,
        body: json.encode(lead.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse.success(LeadDto.fromJson(data));
      } else {
        return ApiResponse.error(
          'Erro ao criar lead: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Atualiza um lead (PUT /api/Lead/{id})
  Future<ApiResponse<LeadDto>> updateLead(String id, UpdateLeadDto lead) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Lead/$id'),
        headers: _headers,
        body: json.encode(lead.toJson()),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          return ApiResponse.success(LeadDto.fromJson(data));
        }
        return ApiResponse.success(
          LeadDto(
            id: id,
            title: lead.title,
            description: lead.description,
            sellerId: lead.sellerId,
          ),
        );
      } else {
        return ApiResponse.error(
          'Erro ao atualizar lead: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Exclui um lead
  Future<ApiResponse<bool>> deleteLead(String id) async {
    try {
      final cleanId = id.trim();

      if (cleanId.isEmpty) {
        return ApiResponse.error('ID do lead não foi fornecido.');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/Lead/$cleanId'),
        headers: _headers,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse.success(true);
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Lead não encontrado.');
      } else {
        return ApiResponse.error('Erro ao excluir: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Adiciona uma interação ao lead - retorna o Lead atualizado com dados da IA
  Future<ApiResponse<LeadDto?>> addInteraction(
    String leadId,
    InteractionDto interaction,
  ) async {
    try {
      // Formato para o endpoint /Lead/{id}/interact
      // Campo obrigatório: InteractionContent
      final interactionData = {
        'InteractionType': interaction.type,
        'InteractionContent':
            interaction.notes ?? 'Interação registrada via app',
        'InteractionDate': (interaction.date ?? DateTime.now())
            .toIso8601String(),
      };

      print('🔄 Registrando interação para lead: $leadId');
      print('📤 URL: $_baseUrl/Lead/$leadId/interact');
      print('📤 Dados: $interactionData');

      final response = await http.post(
        Uri.parse('$_baseUrl/Lead/$leadId/interact'),
        headers: _headers,
        body: json.encode(interactionData),
      );

      print('📥 Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Interação registrada com sucesso!');

        // Tenta parsear a resposta como Lead (pode vir com dados atualizados da IA)
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            print('📊 Dados retornados pela API:');
            print(
              '   - currentScore: ${data['currentScore'] ?? data['CurrentScore']}',
            );
            print(
              '   - probabilityOfClosing: ${data['probabilityOfClosing'] ?? data['ProbabilityOfClosing']}',
            );
            print(
              '   - interactionsCount: ${data['interactionsCount'] ?? data['InteractionsCount']}',
            );

            // Se veio um objeto com dados de lead, retorna o lead atualizado
            if (data is Map<String, dynamic> &&
                (data.containsKey('leadId') ||
                    data.containsKey('LeadId') ||
                    data.containsKey('id'))) {
              return ApiResponse.success(LeadDto.fromJson(data));
            }
          } catch (e) {
            print('⚠️ Não foi possível parsear resposta como Lead: $e');
          }
        }

        return ApiResponse.success(null);
      } else {
        print('❌ Erro: ${response.statusCode} - ${response.body}');
        return ApiResponse.error(
          'Erro ao adicionar interação: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Exceção: $e');
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // ==================== MISSION ====================

  /// Busca missões do vendedor
  Future<ApiResponse<List<MissionDto>>> getMissionsBySeller() async {
    final sellerId = currentSellerId;
    if (sellerId == null) {
      return ApiResponse.error('Usuário não autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Mission/seller/$sellerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final missions = data.map((json) => MissionDto.fromJson(json)).toList();
        return ApiResponse.success(missions);
      } else if (response.statusCode == 404) {
        return ApiResponse.success([]);
      } else {
        return ApiResponse.error(
          'Erro ao buscar missões: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  // ==================== SELLER ====================

  /// Busca dados do vendedor logado
  Future<ApiResponse<SellerDto>> getCurrentSeller() async {
    final sellerId = currentSellerId;
    if (sellerId == null) {
      return ApiResponse.error('Usuário não autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Seller/$sellerId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SellerDto.fromJson(data));
      } else {
        return ApiResponse.error('Vendedor não encontrado');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Busca todos os vendedores (Admin)
  Future<ApiResponse<List<SellerDto>>> getAllSellers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Seller'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final sellers = data.map((json) => SellerDto.fromJson(json)).toList();
        return ApiResponse.success(sellers);
      } else if (response.statusCode == 404) {
        return ApiResponse.success([]);
      } else {
        return ApiResponse.error(
          'Erro ao buscar vendedores: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Cria um novo vendedor (Admin)
  Future<ApiResponse<SellerDto>> createSeller(CreateSellerDto seller) async {
    try {
      final url = '$_baseUrl/Seller';
      final body = json.encode(seller.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse.success(SellerDto.fromJson(data));
      } else {
        return ApiResponse.error(
          'Erro ao criar vendedor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Atualiza um vendedor (Admin)
  Future<ApiResponse<SellerDto>> updateSeller(
    String id,
    CreateSellerDto seller,
  ) async {
    try {
      final jsonData = seller.toJson();
      // Incluir o sellerId no body para update (mesmo nome da API)
      jsonData['sellerId'] = id;

      final url = '$_baseUrl/Seller/$id';

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          return ApiResponse.success(SellerDto.fromJson(data));
        }
        // Se não retornar body, criar um SellerDto com os dados enviados
        return ApiResponse.success(
          SellerDto(
            id: id,
            name: seller.name,
            email: seller.email,
            phoneNumber: seller.phoneNumber,
            role: seller.role,
            currentPoints: seller.currentPoints,
          ),
        );
      } else if (response.statusCode == 405) {
        return ApiResponse.error(
          'Método PUT não permitido. Verifique o endpoint de update no backend.',
        );
      } else {
        return ApiResponse.error(
          'Erro ao atualizar vendedor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Exclui um vendedor (Admin)
  Future<ApiResponse<bool>> deleteSeller(String id) async {
    try {
      final cleanId = id.trim();

      if (cleanId.isEmpty) {
        return ApiResponse.error('ID do vendedor não foi fornecido.');
      }

      final url = '$_baseUrl/Seller/$cleanId';

      final response = await http.delete(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return ApiResponse.success(true);
      } else if (response.statusCode == 405) {
        return ApiResponse.error(
          'Método DELETE não permitido. Verifique CORS no backend.',
        );
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Vendedor não encontrado.');
      } else {
        return ApiResponse.error('Erro ao excluir: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }
}

/// Wrapper para respostas da API
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse._({this.data, this.error, required this.isSuccess});

  factory ApiResponse.success(T data) =>
      ApiResponse._(data: data, isSuccess: true);
  factory ApiResponse.error(String message) =>
      ApiResponse._(error: message, isSuccess: false);
}

/// DTO para Lead (baseado na tabela Leads)
/// Campos: Id, SellerId, CompanyId, Title, Description, LeadSource, Status, Won,
/// Campos do GET /api/Lead:
/// leadId, title, status, companyName, sellerName, currentScore,
/// probabilityOfClosing, priority, nextStepSuggestion, suggestedContactType,
/// DTO para Lead (Cliente Potencial).
/// Representa os dados de um lead retornados pela API, incluindo informações da empresa e análise da IA.
class LeadDto {
  final String id;
  final String? title;
  final String? description;
  final String? status;
  final String? companyName;
  final String? companyCNPJ;
  final String? companyEmail;
  final String? companyPhone;
  final String? companyLocation;
  final String? industry;
  final String? sellerName;
  final String? sellerId;
  final int? currentScore;
  final int? leadScore;
  final double? probabilityOfClosing;
  final String? priority;
  final String? nextStepSuggestion;
  final String? suggestedContactType;
  final int? interactionsCount;
  final DateTime? expectedCloseDate;
  final String? leadSource;
  final String? logoUrl;

  LeadDto({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.companyName,
    this.companyCNPJ,
    this.companyEmail,
    this.companyPhone,
    this.companyLocation,
    this.industry,
    this.sellerName,
    this.sellerId,
    this.currentScore,
    this.leadScore,
    this.probabilityOfClosing,
    this.priority,
    this.nextStepSuggestion,
    this.suggestedContactType,
    this.interactionsCount,
    this.expectedCloseDate,
    this.leadSource,
    this.logoUrl,
  });

  /// Nome para exibição (usa title ou companyName ou "Lead sem título")
  String get displayName => title ?? companyName ?? 'Lead sem título';

  /// Status formatado para exibição
  String get statusText {
    if (status == null) return 'Novo';
    switch (status!.toLowerCase()) {
      case 'new':
        return 'Novo';
      case 'contacted':
        return 'Em contato';
      case 'qualified':
        return 'Qualificado';
      case 'proposal':
        return 'Proposta';
      case 'negotiation':
        return 'Negociação';
      case 'closed':
        return 'Fechado';
      case 'won':
        return 'Ganho';
      case 'lost':
        return 'Perdido';
      default:
        return status!;
    }
  }

  /// Prioridade formatada para exibição
  String get priorityText {
    if (priority == null) return 'Normal';
    switch (priority!.toLowerCase()) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority!;
    }
  }

  /// Probabilidade formatada como porcentagem
  String get probabilityText {
    if (probabilityOfClosing == null) return '-';
    return '${(probabilityOfClosing! * 100).toInt()}%';
  }

  factory LeadDto.fromJson(Map<String, dynamic> json) {
    // Tenta pegar a URL da logo de várias fontes possíveis
    final logoUrl =
        json['logoUrl'] ??
        json['LogoUrl'] ??
        json['companyLogo'] ??
        json['CompanyLogo'] ??
        json['logo'] ??
        json['Logo'] ??
        json['imageUrl'] ??
        json['ImageUrl'] ??
        json['photo'] ??
        json['Photo'];

    // Verifica se há um objeto company aninhado
    final company = json['company'] ?? json['Company'] ?? {};

    // Pega CNPJ de várias fontes
    final cnpj =
        json['companyCNPJ'] ??
        json['CompanyCNPJ'] ??
        json['cnpj'] ??
        json['CNPJ'] ??
        company['cnpj'] ??
        company['CNPJ'] ??
        company['companyCNPJ'] ??
        company['CompanyCNPJ'];

    // Pega Email de várias fontes
    final email =
        json['companyEmail'] ??
        json['CompanyEmail'] ??
        json['email'] ??
        json['Email'] ??
        company['email'] ??
        company['Email'] ??
        company['companyEmail'] ??
        company['CompanyEmail'];

    // Pega Telefone de várias fontes
    final phone =
        json['companyPhone'] ??
        json['CompanyPhone'] ??
        json['phone'] ??
        json['Phone'] ??
        company['phone'] ??
        company['Phone'] ??
        company['companyPhone'] ??
        company['CompanyPhone'];

    // Pega Localização de várias fontes
    final location =
        json['companyLocation'] ??
        json['CompanyLocation'] ??
        json['location'] ??
        json['Location'] ??
        company['location'] ??
        company['Location'] ??
        company['companyLocation'] ??
        company['CompanyLocation'] ??
        company['address'] ??
        company['Address'] ??
        json['address'] ??
        json['Address'];

    // Pega Indústria/Setor de várias fontes
    final industryValue =
        json['industry'] ??
        json['Industry'] ??
        json['sector'] ??
        json['Sector'] ??
        company['industry'] ??
        company['Industry'] ??
        company['sector'] ??
        company['Sector'];

    // Pega Nome da empresa de várias fontes
    final companyNameValue =
        json['companyName'] ??
        json['CompanyName'] ??
        company['name'] ??
        company['Name'] ??
        company['companyName'] ??
        company['CompanyName'];

    return LeadDto(
      id: (json['leadId'] ?? json['LeadId'] ?? json['id'] ?? json['Id'] ?? '')
          .toString(),
      title: json['title'] ?? json['Title'],
      description: json['description'] ?? json['Description'],
      status: json['status'] ?? json['Status'],
      companyName: companyNameValue,
      companyCNPJ: cnpj,
      companyEmail: email,
      companyPhone: phone,
      companyLocation: location,
      industry: industryValue,
      sellerName: json['sellerName'] ?? json['SellerName'],
      sellerId: json['sellerId'] ?? json['SellerId'],
      currentScore: _parseInt(json['currentScore'] ?? json['CurrentScore']),
      leadScore: _parseInt(
        json['leadScore'] ??
            json['LeadScore'] ??
            json['currentScore'] ??
            json['CurrentScore'],
      ),
      probabilityOfClosing: _parseDouble(
        json['probabilityOfClosing'] ?? json['ProbabilityOfClosing'],
      ),
      priority: json['priority'] ?? json['Priority'],
      nextStepSuggestion:
          json['nextStepSuggestion'] ?? json['NextStepSuggestion'],
      suggestedContactType:
          json['suggestedContactType'] ?? json['SuggestedContactType'],
      interactionsCount: _parseInt(
        json['interactionsCount'] ?? json['InteractionsCount'],
      ),
      expectedCloseDate: _parseDate(
        json['expectedCloseDate'] ?? json['ExpectedCloseDate'],
      ),
      leadSource: json['leadSource'] ?? json['LeadSource'],
      logoUrl: logoUrl,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'leadId': id,
    'title': title,
    'description': description,
    'status': status,
    'companyName': companyName,
    'sellerName': sellerName,
    'sellerId': sellerId,
    'currentScore': currentScore,
    'leadScore': leadScore,
    'probabilityOfClosing': probabilityOfClosing,
    'priority': priority,
    'nextStepSuggestion': nextStepSuggestion,
    'suggestedContactType': suggestedContactType,
    'interactionsCount': interactionsCount,
    'expectedCloseDate': expectedCloseDate?.toIso8601String(),
    'leadSource': leadSource,
    'logoUrl': logoUrl,
  };
}

/// DTO para criar Lead (POST /api/Lead)
/// Campos: sellerId, companyId, companyName, companyCNPJ, companyEmail,
/// companyPhone, companyLocation, companyLogo, industry, revenueRange,
/// title, description, leadSource
class CreateLeadDto {
  final String? sellerId;
  final String? companyId;
  final String? companyName;
  final String? companyCNPJ;
  final String? companyEmail;
  final String? companyPhone;
  final String? companyLocation;
  final String? companyLogo;
  final String? industry;
  final int? revenueRange;
  final String title;
  final String? description;
  final String? leadSource;

  CreateLeadDto({
    this.sellerId,
    this.companyId,
    this.companyName,
    this.companyCNPJ,
    this.companyEmail,
    this.companyPhone,
    this.companyLocation,
    this.companyLogo,
    this.industry,
    this.revenueRange,
    required this.title,
    this.description,
    this.leadSource,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'title': title};

    if (sellerId != null) map['sellerId'] = sellerId;
    if (companyId != null) map['companyId'] = companyId;
    if (companyName != null) map['companyName'] = companyName;
    if (companyCNPJ != null) map['companyCNPJ'] = companyCNPJ;
    if (companyEmail != null) map['companyEmail'] = companyEmail;
    if (companyPhone != null) map['companyPhone'] = companyPhone;
    if (companyLocation != null) map['companyLocation'] = companyLocation;
    if (companyLogo != null) map['companyLogo'] = companyLogo;
    if (industry != null) map['industry'] = industry;
    if (revenueRange != null) map['revenueRange'] = revenueRange;
    if (description != null) map['description'] = description;
    if (leadSource != null) map['leadSource'] = leadSource;

    // DEBUG: Mostra o que está sendo enviado para a API
    print('📤 CreateLeadDto.toJson - Enviando para API: $map');

    return map;
  }
}

/// DTO para atualizar Lead (PUT /api/Lead/{id})
/// Campos: id, sellerId, companyId, title, description, leadSource, status
class UpdateLeadDto {
  final String id;
  final String? sellerId;
  final String? companyId;
  final String? title;
  final String? description;
  final String? leadSource;
  final int? status;

  UpdateLeadDto({
    required this.id,
    this.sellerId,
    this.companyId,
    this.title,
    this.description,
    this.leadSource,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'id': id};

    if (sellerId != null) map['sellerId'] = sellerId;
    if (companyId != null) map['companyId'] = companyId;
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (leadSource != null) map['leadSource'] = leadSource;
    if (status != null) map['status'] = status;

    return map;
  }
}

/// DTO para Interação
class InteractionDto {
  final String type;
  final String? notes;
  final DateTime? date;

  InteractionDto({required this.type, this.notes, this.date});

  Map<String, dynamic> toJson() => {
    'type': type,
    'notes': notes,
    'date': (date ?? DateTime.now()).toIso8601String(),
  };
}

/// DTO para Missão
class MissionDto {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;

  MissionDto({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
  });

  factory MissionDto.fromJson(Map<String, dynamic> json) {
    return MissionDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      dueDate: json['dueDate'] != null || json['due_date'] != null
          ? DateTime.tryParse(json['dueDate'] ?? json['due_date'] ?? '')
          : null,
    );
  }
}

/// DTO para Seller (baseado na tabela Sellers do Supabase)
/// Campos: Id (uuid), Name (text), Email (text), Password (text),
/// PhoneNumber (text), Role (int4), CurrentPoints (int4), PhotoUrl (text)
/// Roles: 0 = Nenhum, 1 = Admin, 2 = Vendedor, 3 = Gerente
class SellerDto {
  final String id;
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final int? role;
  final int? currentPoints;
  final String? photoUrl;

  SellerDto({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.role,
    this.currentPoints,
    this.photoUrl,
  });

  factory SellerDto.fromJson(Map<String, dynamic> json) {
    // O campo do ID é "sellerId" (camelCase) conforme retornado pela API
    final parsedId =
        (json['sellerId'] ?? json['SellerId'] ?? json['id'] ?? json['Id'] ?? '')
            .toString();

    // Tenta pegar a foto de várias fontes possíveis
    final photoUrl =
        json['photoUrl'] ??
        json['PhotoUrl'] ??
        json['photo'] ??
        json['Photo'] ??
        json['imageUrl'] ??
        json['ImageUrl'] ??
        json['avatar'] ??
        json['Avatar'] ??
        json['profilePhoto'] ??
        json['ProfilePhoto'];

    return SellerDto(
      id: parsedId,
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      password: json['password'] ?? json['Password'],
      phoneNumber: json['phoneNumber'] ?? json['PhoneNumber'],
      role: _parseRole(json['role'] ?? json['Role']),
      currentPoints: _parseInt(
        json['totalPoints'] ?? json['currentPoints'] ?? json['CurrentPoints'],
      ),
      photoUrl: photoUrl,
    );
  }

  /// Converte role para int (pode vir como String ou int da API)
  static int? _parseRole(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      // Tenta converter string numérica
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;

      // Converte nomes de role para int
      switch (value.toLowerCase()) {
        case 'admin':
        case 'administrador':
          return 1;
        case 'vendedor':
        case 'seller':
          return 2;
        case 'gerente':
        case 'manager':
          return 3;
        default:
          return 0;
      }
    }
    return 0;
  }

  /// Converte para int (pode vir como String ou int da API)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'sellerId': id,
    'name': name,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'role': role,
    'totalPoints': currentPoints,
    'photoUrl': photoUrl,
  };
}

/// DTO para criar/atualizar Seller
/// Campos da API: sellerId, name, email, password, phoneNumber, role, totalPoints, photoUrl
/// Role: "Seller" = Vendedor, "Admin" = Admin, "Manager" = Gerente
class CreateSellerDto {
  final String name;
  final String email;
  final String? password;
  final String? phoneNumber;
  final int role;
  final int currentPoints;
  final String? photoUrl;

  CreateSellerDto({
    required this.name,
    required this.email,
    this.password,
    this.phoneNumber,
    required this.role,
    this.currentPoints = 0,
    this.photoUrl,
  });

  /// Converte role int para string que a API espera
  String _roleToString() {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Seller';
      case 3:
        return 'Manager';
      default:
        return 'Seller';
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      // Usando camelCase para corresponder à API
      'name': name,
      'email': email,
      'password': password ?? '',
      'role': _roleToString(),
      'totalPoints': currentPoints,
    };

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      map['phoneNumber'] = phoneNumber;
    }

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      map['photoUrl'] = photoUrl;
    }

    return map;
  }
}
