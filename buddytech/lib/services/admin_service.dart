import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para gerenciar funcionalidades administrativas
class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ============================================
  /// CONTA DE TESTE PARA ACESSAR ÁREA ADMIN
  /// ============================================
  /// Email: admin.teste@buddytech.com
  /// Senha: Admin@123
  /// ============================================

  /// Lista local de emails admin (fallback caso backend falhe)
  static final List<String> _localAdminEmails = [
    'admin@buddytech.com',
    'gestor@buddytech.com',
    'admin.teste@buddytech.com', // Conta de teste
  ];

  /// Cache de emails admin vindos do backend
  static List<String>? _cachedAdminEmails;

  /// Busca emails de admin do backend
  Future<List<String>> _fetchAdminEmailsFromBackend() async {
    try {
      // TODO: Descomentar quando tabela admin_users existir no Supabase
      // final response = await _supabase
      //     .from('admin_users')
      //     .select('email')
      //     .eq('is_active', true);
      // 
      // return (response as List)
      //     .map((row) => (row['email'] as String).toLowerCase())
      //     .toList();

      // Por enquanto, retorna lista local
      return _localAdminEmails;
    } catch (e) {
      print('Erro ao buscar admins do backend: $e');
      return _localAdminEmails;
    }
  }

  /// Obtém lista de emails admin (com cache)
  Future<List<String>> getAdminEmails() async {
    _cachedAdminEmails ??= await _fetchAdminEmailsFromBackend();
    return _cachedAdminEmails!;
  }

  /// Força atualização do cache de admins
  Future<void> refreshAdminEmails() async {
    _cachedAdminEmails = await _fetchAdminEmailsFromBackend();
  }

  /// Verifica se o usuário atual tem acesso administrativo
  Future<bool> isCurrentUserAdminAsync() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    
    final email = user.email?.toLowerCase() ?? '';
    final adminEmails = await getAdminEmails();
    return adminEmails.contains(email);
  }

  /// Verifica se o usuário atual tem acesso administrativo (síncrono - usa cache ou local)
  bool isCurrentUserAdmin() {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    
    final email = user.email?.toLowerCase() ?? '';
    // Usa cache se disponível, senão usa lista local
    final adminEmails = _cachedAdminEmails ?? _localAdminEmails;
    return adminEmails.contains(email);
  }

  /// Verifica se um email específico tem acesso admin
  Future<bool> isEmailAdminAsync(String email) async {
    final adminEmails = await getAdminEmails();
    return adminEmails.contains(email.toLowerCase());
  }

  /// Verifica se um email específico tem acesso admin (síncrono)
  bool isEmailAdmin(String email) {
    final adminEmails = _cachedAdminEmails ?? _localAdminEmails;
    return adminEmails.contains(email.toLowerCase());
  }

  /// Cria a conta de teste no Supabase (chamar uma vez para setup)
  Future<String?> createTestAdminAccount() async {
    try {
      final response = await _supabase.auth.signUp(
        email: 'admin.teste@buddytech.com',
        password: 'Admin@123',
        data: {
          'name': 'Admin Teste',
          'role': 'Administrador',
        },
      );
      
      if (response.user != null) {
        return 'Conta de teste criada com sucesso!';
      }
      return 'Erro ao criar conta de teste';
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return 'Conta de teste já existe. Use: admin.teste@buddytech.com / Admin@123';
      }
      return 'Erro: ${e.message}';
    } catch (e) {
      return 'Erro: $e';
    }
  }

  /// Busca estatísticas do dashboard
  Future<AdminDashboardStats> getDashboardStats() async {
    // TODO: Buscar dados reais do Supabase
    // final leadsResponse = await _supabase.from('leads').select('id');
    // final clientsResponse = await _supabase.from('clients').select('id');
    
    // Dados mock para demonstração
    await Future.delayed(const Duration(milliseconds: 500));
    
    return AdminDashboardStats(
      totalLeads: 192000,
      totalRevenue: 3200.00,
      revenueGrowth: 6.7,
      newClients: 67,
      newClientsGrowth: 6.7,
      conversionRate: 71,
      conversionRateGrowth: 6.7,
      recentClients: [
        'Cliente 01',
        'Cliente 02',
        'Cliente 03',
        'Cliente 04',
      ],
      monthlyAverages: {
        'Jan': 150,
        'Fev': 200,
        'Mar': 180,
        'Abr': 220,
        'Mai': 350,
        'Jun': 280,
        'Jul': 320,
        'Ago': 380,
        'Set': 300,
        'Out': 350,
        'Nov': 420,
        'Dez': 280,
      },
    );
  }

  /// Busca lista de usuários cadastrados
  Future<List<UserAccount>> getUsers() async {
    // TODO: Buscar do Supabase
    // final response = await _supabase.from('profiles').select();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      UserAccount(
        id: '1',
        name: 'João Silva',
        email: 'joao@empresa.com',
        role: 'Vendedor',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserAccount(
        id: '2',
        name: 'Maria Santos',
        email: 'maria@empresa.com',
        role: 'Vendedor',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      UserAccount(
        id: '3',
        name: 'Carlos Oliveira',
        email: 'carlos@empresa.com',
        role: 'Gestor',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Cria uma nova conta de usuário
  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // TODO: Criar usuário no Supabase Auth e perfil
      // final authResponse = await _supabase.auth.admin.createUser(
      //   AdminUserAttributes(email: email, password: password),
      // );
      // 
      // await _supabase.from('profiles').insert({
      //   'id': authResponse.user!.id,
      //   'name': name,
      //   'email': email,
      //   'role': role,
      // });
      
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return false;
    }
  }

  /// Atualiza status de um usuário (ativar/desativar)
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      // TODO: Atualizar no Supabase
      // await _supabase.from('profiles').update({'is_active': isActive}).eq('id', userId);
      
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      print('Erro ao atualizar status: $e');
      return false;
    }
  }

  /// Deleta um usuário
  Future<bool> deleteUser(String userId) async {
    try {
      // TODO: Deletar do Supabase
      // await _supabase.from('profiles').delete().eq('id', userId);
      // await _supabase.auth.admin.deleteUser(userId);
      
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      return false;
    }
  }
}

/// Modelo para estatísticas do dashboard
class AdminDashboardStats {
  final int totalLeads;
  final double totalRevenue;
  final double revenueGrowth;
  final int newClients;
  final double newClientsGrowth;
  final int conversionRate;
  final double conversionRateGrowth;
  final List<String> recentClients;
  final Map<String, double> monthlyAverages;

  AdminDashboardStats({
    required this.totalLeads,
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.newClients,
    required this.newClientsGrowth,
    required this.conversionRate,
    required this.conversionRateGrowth,
    required this.recentClients,
    required this.monthlyAverages,
  });
}

/// Modelo para conta de usuário
class UserAccount {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
}
