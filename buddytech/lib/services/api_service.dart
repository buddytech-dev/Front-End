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
        return ApiResponse.error('Erro ao buscar leads: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Busca um lead por ID
  Future<ApiResponse<LeadDto>> getLeadById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Lead/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(LeadDto.fromJson(data));
      } else {
        return ApiResponse.error('Lead não encontrado');
      }
    } catch (e) {
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
        return ApiResponse.error('Erro ao criar lead: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Adiciona uma interação ao lead
  Future<ApiResponse<bool>> addInteraction(String leadId, InteractionDto interaction) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Lead/$leadId/interaction'),
        headers: _headers,
        body: json.encode(interaction.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Erro ao adicionar interação: ${response.statusCode}');
      }
    } catch (e) {
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
        return ApiResponse.error('Erro ao buscar missões: ${response.statusCode}');
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
        return ApiResponse.error('Erro ao buscar vendedores: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Cria um novo vendedor (Admin)
  Future<ApiResponse<SellerDto>> createSeller(CreateSellerDto seller) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Seller'),
        headers: _headers,
        body: json.encode(seller.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse.success(SellerDto.fromJson(data));
      } else {
        return ApiResponse.error('Erro ao criar vendedor: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Atualiza um vendedor (Admin)
  Future<ApiResponse<SellerDto>> updateSeller(String id, CreateSellerDto seller) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Seller/$id'),
        headers: _headers,
        body: json.encode(seller.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(SellerDto.fromJson(data));
      } else {
        return ApiResponse.error('Erro ao atualizar vendedor: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Erro de conexão: $e');
    }
  }

  /// Exclui um vendedor (Admin)
  Future<ApiResponse<bool>> deleteSeller(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/Seller/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Erro ao excluir vendedor: ${response.statusCode}');
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

  factory ApiResponse.success(T data) => ApiResponse._(data: data, isSuccess: true);
  factory ApiResponse.error(String message) => ApiResponse._(error: message, isSuccess: false);
}

/// DTO para Lead
class LeadDto {
  final String id;
  final String companyName;
  final String? companyEmail;
  final String? contactName;
  final String? contactPhone;
  final String? status;
  final DateTime? lastInteraction;
  final int? rank;
  final String? aiSummary;
  final List<String>? recommendedActions;
  final String? sellerId;

  LeadDto({
    required this.id,
    required this.companyName,
    this.companyEmail,
    this.contactName,
    this.contactPhone,
    this.status,
    this.lastInteraction,
    this.rank,
    this.aiSummary,
    this.recommendedActions,
    this.sellerId,
  });

  factory LeadDto.fromJson(Map<String, dynamic> json) {
    return LeadDto(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? json['company_name'] ?? 'Sem nome',
      companyEmail: json['companyEmail'] ?? json['company_email'],
      contactName: json['contactName'] ?? json['contact_name'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      status: json['status'],
      lastInteraction: json['lastInteraction'] != null || json['last_interaction'] != null
          ? DateTime.tryParse(json['lastInteraction'] ?? json['last_interaction'] ?? '')
          : null,
      rank: json['rank'],
      aiSummary: json['aiSummary'] ?? json['ai_summary'],
      recommendedActions: json['recommendedActions'] != null
          ? List<String>.from(json['recommendedActions'])
          : json['recommended_actions'] != null
              ? List<String>.from(json['recommended_actions'])
              : null,
      sellerId: json['sellerId'] ?? json['seller_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'companyEmail': companyEmail,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'status': status,
    'lastInteraction': lastInteraction?.toIso8601String(),
    'rank': rank,
    'aiSummary': aiSummary,
    'recommendedActions': recommendedActions,
    'sellerId': sellerId,
  };
}

/// DTO para criar Lead
class CreateLeadDto {
  final String companyName;
  final String? companyEmail;
  final String? contactName;
  final String? contactPhone;
  final String sellerId;

  CreateLeadDto({
    required this.companyName,
    this.companyEmail,
    this.contactName,
    this.contactPhone,
    required this.sellerId,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'companyEmail': companyEmail,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'sellerId': sellerId,
  };
}

/// DTO para Interação
class InteractionDto {
  final String type;
  final String? notes;
  final DateTime? date;

  InteractionDto({
    required this.type,
    this.notes,
    this.date,
  });

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
/// PhoneNumber (text), Role (int4), CurrentPoints (int4)
class SellerDto {
  final String id;
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final int? role;
  final int? currentPoints;

  SellerDto({
    required this.id,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.role,
    this.currentPoints,
  });

  factory SellerDto.fromJson(Map<String, dynamic> json) {
    return SellerDto(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      password: json['password'] ?? json['Password'],
      phoneNumber: json['phoneNumber'] ?? json['PhoneNumber'] ?? json['phone_number'],
      role: json['role'] ?? json['Role'],
      currentPoints: json['currentPoints'] ?? json['CurrentPoints'] ?? json['current_points'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'role': role,
    'currentPoints': currentPoints,
  };
}

/// DTO para criar/atualizar Seller
class CreateSellerDto {
  final String name;
  final String email;
  final String? password;
  final String? phoneNumber;
  final int role;
  final int currentPoints;

  CreateSellerDto({
    required this.name,
    required this.email,
    this.password,
    this.phoneNumber,
    required this.role,
    this.currentPoints = 0, // Pontos padrão = 0
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'currentPoints': currentPoints,
    };
    
    // Só inclui senha se fornecida
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    
    return map;
  }
}
