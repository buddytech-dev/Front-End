import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Logo + Nome
          Row(
            children: [
              Image.asset(
                'assets/Logo.png',
                height: 36,
                width: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                'BuddyTech',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Menu de navegação
          Row(
            children: [
              _navItem('Home', 0),
              const SizedBox(width: 16),
              _navItem('Ações', 1),
              const SizedBox(width: 16),
              _navItem('Ranking', 2),
              const SizedBox(width: 16),
              _navItem('Perfil', 3),
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
    );
  }

  Widget _navItem(String text, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cabeçalho de boas-vindas
              _buildWelcomeHeader(),

              const SizedBox(height: 32),

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
          const Text(
            'Olá Fulano',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'confira seus principais clientes de hoje',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    // Dados mockados dos leads
    final leads = [
      LeadData(
        rank: 1,
        rankColor: const Color(0xFF3B82F6),
        companyName: 'Teste1',
        companyEmail: 'contato@teste1.com',
        contactName: 'Beltrano da Silva',
        contactPhone: '+55 11 99999-7777',
        logoColor: const Color(0xFF3B82F6),
        logoIcon: Icons.water_drop,
        status: 'Quente - Alta probabilidade',
        lastInteraction: '15/04/2024',
      ),
      LeadData(
        rank: 2,
        rankColor: const Color(0xFF3B82F6),
        companyName: 'Teste2',
        companyEmail: 'contato@teste2.com',
        contactName: 'Ana Costa',
        contactPhone: '+55 11 98888-5555',
        logoColor: const Color(0xFFFFC107),
        logoIcon: Icons.settings,
        status: 'Morno - Alta probabilidade',
        lastInteraction: '22/03/2024',
      ),
      LeadData(
        rank: 3,
        rankColor: const Color(0xFF3B82F6),
        companyName: 'Teste3',
        companyEmail: 'contato@ambertech.com',
        contactName: 'Paula Cardoso',
        contactPhone: '+55 11 92222-1111',
        logoColor: const Color(0xFFFFC107),
        logoIcon: Icons.square_rounded,
        status: 'Morno - Alta estabilidade',
        lastInteraction: '05/02/2024',
      ),
    ];

    return Column(
      children: leads.map((lead) => _buildLeadCard(lead)).toList(),
    );
  }

  Widget _buildLeadCard(LeadData lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          // Logo da empresa
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: lead.logoColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              lead.logoIcon,
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
                  lead.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lead.companyEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lead.contactName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  lead.contactPhone,
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
                  lead.status,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Última interação: ${lead.lastInteraction}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Ação futura para detalhes do cliente
                  },
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
              color: lead.rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${lead.rank}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeadData {
  final int rank;
  final Color rankColor;
  final String companyName;
  final String companyEmail;
  final String contactName;
  final String contactPhone;
  final Color logoColor;
  final IconData logoIcon;
  final String status;
  final String lastInteraction;

  LeadData({
    required this.rank,
    required this.rankColor,
    required this.companyName,
    required this.companyEmail,
    required this.contactName,
    required this.contactPhone,
    required this.logoColor,
    required this.logoIcon,
    required this.status,
    required this.lastInteraction,
  });
}
