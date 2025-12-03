import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          //  NAVBAR 
          _buildNavbar(context),

          //  CONTEÚDO PRINCIPAL 
          Expanded(
            child: SingleChildScrollView(
              child: _buildHeroSection(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo + Nome
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 32,
                width: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                'BuddyTech',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Menu de navegação
          Row(
            children: [
              _navItem('Home', isActive: true),
              const SizedBox(width: 32),
              _navItem('Lead Score'),
              const SizedBox(width: 32),
              _navItem('Ações Sugeridas'),
              const SizedBox(width: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black54),
                onPressed: () => logout(context),
                tooltip: 'Sair',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String text, {bool isActive = false}) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: isActive ? const Color(0xFF0A66FF) : Colors.black54,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
 
    const double maxContentWidth = 1200;
    
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 1200 ? 40 : 80,
          vertical: 100,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lado esquerdo - Texto e botões
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  const Text(
                    'Label goes here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0A66FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título principal
                  const Text(
                    'Bem-vindo ao AI\nSales Buddy',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A66FF),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtítulo
                  Text(
                    'Seu painel de priorização de oportunidades',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botões
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Simular E-mails',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Simular Reuniões',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 60),

            // Lado direito - Placeholder de imagem
            Expanded(
              flex: 1,
              child: Container(
                height: 350,
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
