import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

/// Página de Gestão de Usuários (Administrativo).
/// Permite visualizar, criar e editar usuários (Vendedores, Gerentes, Admins) do sistema.
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  List<SellerDto> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Carrega a lista de todos os usuários cadastrados via API.
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _apiService.getAllSellers();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _users = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Erro ao carregar usuários';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  String _getRoleName(int? role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Vendedor';
      case 3:
        return 'Gerente';
      default:
        return 'Usuário';
    }
  }

  Color _getRoleColor(int? role) {
    switch (role) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: _buildContent(),
                  ),
          ),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho da página.
  Widget _buildHeader() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context),
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            Icon(
              Icons.people,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Gerenciar Usuários',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da página.
  ///
  /// Exibe estatísticas e a lista de usuários.
  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e estatísticas
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuários Cadastrados',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_users.length} usuários no sistema',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Atualizar lista',
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // Lista de usuários
            if (_users.isEmpty)
              _buildEmptyState()
            else
              ..._users.map((user) => _buildUserCard(user)),

            const SizedBox(height: 80), // Espaço para o FAB
          ],
        ),
      ),
    );
  }

  /// Constrói o estado vazio (sem usuários).
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum usuário cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão abaixo para criar o primeiro usuário',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói o card de usuário (wrapper para mobile/desktop).
  Widget _buildUserCard(SellerDto user) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile ? _buildMobileUserCard(user) : _buildDesktopUserCard(user),
    );
  }

  /// Constrói o card de usuário para mobile.
  Widget _buildMobileUserCard(SellerDto user) {
    final userName = user.name ?? 'Sem nome';
    final userEmail = user.email ?? '';
    final roleColor = _getRoleColor(user.role);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Role badge
            _buildRoleBadge(user.role),
          ],
        ),
        const SizedBox(height: 12),
        // Pontos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                '${user.currentPoints ?? 0} pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o card de usuário para desktop.
  Widget _buildDesktopUserCard(SellerDto user) {
    final userName = user.name ?? 'Sem nome';
    final userEmail = user.email ?? '';
    final userPhone = user.phoneNumber ?? '';
    final roleColor = _getRoleColor(user.role);
    
    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (userPhone.isNotEmpty)
                Text(
                  userPhone,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ),
        // Role
        _buildRoleBadge(user.role),
        const SizedBox(width: 16),
        // Pontos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                '${user.currentPoints ?? 0} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o badge de função (Admin, Vendedor, etc.).
  Widget _buildRoleBadge(int? role) {
    final roleName = _getRoleName(role);
    final roleColor = _getRoleColor(role);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        roleName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: roleColor,
        ),
      ),
    );
  }
}
