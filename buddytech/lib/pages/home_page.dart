import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart';
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Título
            Text(
              "Olá $userName",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text(
              "Confira seus principais clientes de hoje",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            /// --- APENAS UM CARD -> modelo real de componente ---
            const LeadCardWidget(
              logoPath: "assets/logos/premiere.png",
              companyName: "Premiere Soft",
              email: "contato@premiere.com",
              contactName: "Cleber Machado",
              phone: "(47) 9 9999-9999",
              status: "Alta probabilidade",
              lastInteraction: "00/00/0000",
              position: 1,
            ),

            const SizedBox(height: 16),

            /// Você pode duplicar depois quando vier os dados reais
            /// Ex.: ListView.builder() ou List.generate()
          ],
        ),
      ),
    );
  }
}
