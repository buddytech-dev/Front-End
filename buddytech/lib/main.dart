// ============================================================================
// main.dart
// Arquivo principal da aplicação BuddyTech
// ============================================================================
//
// Responsável por:
//
//  • Inicializar o Flutter e carregar variáveis de ambiente (.env)
//  • Configurar a conexão com o Supabase (backend e autenticação)
//  • Iniciar o MaterialApp com tema global e rotas nomeadas
//  • Direcionar o usuário para a tela correta via Auth Gateway
//
// Estrutura principal:
//
//  1. main()
//     → Carrega .env
//     → Inicializa Supabase
//     → Executa BuddyTechApp()
//
//  2. BuddyTechApp
//     → Define tema, rotas, navegação e tela inicial
//
//  3. Auth Gateway (via rota "/")
//     → Verifica sessão ativa do usuário
//     → Se logado → HomePage
//     → Se não logado → LoginPage
//
// Observação:
// Toda a navegação do app deve ser feita usando rotas nomeadas
// centralizadas no arquivo routes.dart.
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- CONFIG / TEMA ----
import 'config/theme.dart';
import 'routes.dart';

// ---- PÁGINAS ----
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/recover_password.dart';
import 'pages/client_details_page.dart';
import 'pages/suggested_emails_page.dart';
import 'pages/meeting_script_page.dart';
import 'pages/ranking_page.dart';
import 'pages/profile_page.dart';
import 'pages/completed_actions_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis do .env
  await dotenv.load(fileName: "assets/.env");

  // Inicializa Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const BuddyTechApp());
}

class BuddyTechApp extends StatelessWidget {
  const BuddyTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BuddyTech",
      debugShowCheckedModeBanner: false,

      // ---- Aplicando o tema global ----
      theme: AppTheme.lightTheme,

      // ---- Início da navegação ----
      initialRoute: AppRoutes.root,

      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ==================================================================
          // GATEWAY ROOT — Verifica se usuário está autenticado
          // ==================================================================
          case AppRoutes.root:
            final session = Supabase.instance.client.auth.currentSession;

            if (session != null) {
              return MaterialPageRoute(builder: (_) => const HomePage());
            } else {
              return MaterialPageRoute(builder: (_) => const LoginPage());
            }

          // ==================================================================
          // ROTAS NORMAIS
          // ==================================================================
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomePage());

          case AppRoutes.recoverPassword:
            return MaterialPageRoute(
              builder: (_) => const RecoverPasswordPage(),
            );

          case AppRoutes.clientDetails:
            return MaterialPageRoute(builder: (_) => const ClientDetailsPage());

          case AppRoutes.suggestedEmails:
            return MaterialPageRoute(
              builder: (_) => const SuggestedEmailsPage(),
            );

          case AppRoutes.meetingScript:
            return MaterialPageRoute(builder: (_) => const MeetingScriptPage());

          case AppRoutes.ranking:
            return MaterialPageRoute(builder: (_) => const RankingPage());

          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfilePage());

          case AppRoutes.completedActions:
            return MaterialPageRoute(
              builder: (_) => const CompletedActionsPage(),
            );

          // ==================================================================
          // ROTA NÃO ENCONTRADA
          // ==================================================================
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text(
                    "Rota não encontrada",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
        }
      },
    );
  }
}
