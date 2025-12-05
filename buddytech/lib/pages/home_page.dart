import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_colors.dart';
import '../routes/routes.dart';
import '../models/client_model.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../utils/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  final ApiService _apiService = ApiService();
  final AdminService _adminService = AdminService();
  List<ClientModel> _clients = [];
  bool _isLoading = true;
  String? _error;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadClients();
  }

  void _checkAdminAccess() {
    setState(() {
      _isAdmin = _adminService.isCurrentUserAdmin();
    });
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getLeadsBySeller();
      
      if (response.isSuccess) {
        final leads = response.data ?? [];
        setState(() {
          _clients = leads.map((lead) => ClientModel.fromLeadDto(lead)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar clientes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isMobile ? _buildDrawer() : null,
      body: Column(
        children: [
          // NAVBAR
          _buildNavbar(context),

          // CONTEÚDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              child: _buildMainContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header do drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/Logo.png',
                    height: 40,
                    width: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BuddyTech',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _buildDrawerItem('Home', Icons.home, 0),
            _buildDrawerItem('Histórico', Icons.history, 1),
            _buildDrawerItem('Ranking', Icons.leaderboard, 2),
            _buildDrawerItem('Perfil', Icons.person, 3),

            // Admin - só aparece se for admin
            if (_isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Painel Admin',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.adminDashboard);
                },
              ),
            ],

            const Spacer(),

            // Logout
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                'Sair',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Navigator.pop(context);
                logout(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        _onNavTap(index);
      },
    );
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.history);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.profile);
    } else {
      setState(() {
        _selectedNavIndex = index;
      });
    }
  }

  Widget _buildNavbar(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = Responsive.padding(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu hamburger para mobile
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),

            // Logo + Nome
            Row(
              children: [
                Image.asset(
                  'assets/Logo.png',
                  height: isMobile ? 28 : 36,
                  width: isMobile ? 28 : 36,
                  errorBuilder: (_, __, ___) => Container(
                    width: isMobile ? 28 : 36,
                    height: isMobile ? 28 : 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'BuddyTech',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Menu de navegação (apenas desktop/tablet)
            if (!isMobile)
              Row(
                children: [
                  _navItem('Home', 0),
                  const SizedBox(width: 16),
                  _navItem('Histórico', 1),
                  const SizedBox(width: 16),
                  _navItem('Ranking', 2),
                  const SizedBox(width: 16),
                  _navItem('Perfil', 3),
                  // Botão Admin (só aparece se for admin)
                  if (_isAdmin) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.adminDashboard);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: AppColors.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 24),
                  // Botão de logout
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => logout(context),
                    tooltip: 'Sair',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String text, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: isActive ? const Color(0xFF2563EB) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = Responsive.padding(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24 : 40,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cabeçalho de boas-vindas
              _buildWelcomeHeader(),

              SizedBox(height: isMobile ? 20 : 32),

              // Lista de leads
              _buildLeadsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Olá Fulano',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 28),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'confira seus principais clientes de hoje',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 16),
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadClients,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone ilustrativo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Título
              Text(
                'Você não tem clientes no momento',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Descrição
              Text(
                'Seus leads aparecerão aqui assim que forem atribuídos a você.',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 14),
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Botão de atualizar
              OutlinedButton.icon(
                onPressed: _loadClients,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _clients.map((client) => _buildLeadCard(client)).toList(),
    );
  }

  Widget _buildLeadCard(ClientModel client) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 16 : 24),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: isMobile ? _buildMobileCard(client) : _buildDesktopCard(client),
    );
  }

  Widget _buildMobileCard(ClientModel client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Logo + Info + Ranking
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo da empresa
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: client.logoColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: client.logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        client.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          client.logoIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(
                      client.logoIcon,
                      color: Colors.white,
                      size: 24,
                    ),
            ),

            const SizedBox(width: 12),

            // Nome e email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.companyName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.companyEmail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Ranking badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: client.rankColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${client.rank}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Contato
        Text(
          client.contactName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          client.contactPhone,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),

        const SizedBox(height: 12),

        // Status e link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Última interação: ${client.lastInteraction}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToDetails(client),
              child: const Text(
                'Detalhes',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopCard(ClientModel client) {
    return Row(
      children: [
        // Logo da empresa
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: client.logoColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: client.logoUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    client.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      client.logoIcon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
              : Icon(
                  client.logoIcon,
                  color: Colors.white,
                  size: 32,
                ),
        ),

        const SizedBox(width: 16),

        // Informações da empresa e contato
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.companyName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                client.companyEmail,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                client.contactName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                client.contactPhone,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        // Status e última interação
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.status,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Última interação: ${client.lastInteraction}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _navigateToDetails(client),
                child: const Text(
                  'Detalhes do cliente',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ranking badge
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: client.rankColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '#${client.rank}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(ClientModel client) {
    Navigator.pushNamed(
      context,
      AppRoutes.clientDetails,
      arguments: ClientDetailsArgs.fromClientModel(client),
    );
  }
}
