import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/login_page.dart';
import '../widgets/menu_hamburger.dart';
import '../widgets/lead_card_widget.dart';

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
    final session = Supabase.instance.client.auth.currentSession;
    final userName = session?.user.userMetadata?['name'] ?? "Usuário";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ----------------------------
      // DRAWER
      // ----------------------------
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0D65F2)),
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () => logout(context),
              ),
            ],
          ),
        ),
      ),

      // ----------------------------
      // BODY (SafeArea azul corrigido)
      // ----------------------------
      body: Container(
        color: const Color(0xFF0D65F2), // 🔵 isso tira o branco acima da AppBar
        child: SafeArea(
          top: true,
          child: Container(
            color: const Color(0xFFF5F6FA), // fundo padrão do conteúdo
            child: Column(
              children: [
                // ----------------------------
                // APP BAR CUSTOMIZADA
                // ----------------------------
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D65F2),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 14,
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => MenuHamburger(
                          onTap: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),

                      const Expanded(
                        child: Center(
                          child: Text(
                            "Home",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => logout(context),
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            "assets/logo2.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ----------------------------
                // CONTEÚDO
                // ----------------------------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Olá $userName",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "confira seus principais clientes de hoje",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),

                        const SizedBox(height: 22),

                        const LeadCardWidget(
                          position: 1,
                          logoPath: "assets/logos/logo2.png",
                          companyName: "Premiere Soft",
                          email: "contato@premiere.com",
                          contactName: "Cleber Machado",
                          phone: "(47) 9 9999-9999",
                          status: "Alta probabilidade",
                          lastInteraction: "00/00/0000",
                        ),

                        const SizedBox(height: 16),

                        const LeadCardWidget(
                          position: 2,
                          logoPath: "assets/logos/logo2.png",
                          companyName: "Senior Sistemas",
                          email: "contato@senior.com",
                          contactName: "João Costa",
                          phone: "(11) 9 8888-8888",
                          status: "Média probabilidade",
                          lastInteraction: "02/08/2025",
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
