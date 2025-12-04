import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'routes.dart';

import 'pages/login_page.dart';
import 'pages/recover_password.dart';
import 'pages/client_details_page.dart';
import 'pages/suggested_emails_page.dart';
import 'pages/meeting_script_page.dart';
import 'pages/ranking_page.dart';
import 'pages/profile_page.dart';
import 'pages/completed_actions_page.dart';
import 'pages/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

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
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.root,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ================================================================
          // ROOT — Gateway de autenticação
          // ================================================================
          case AppRoutes.root:
            final session = Supabase.instance.client.auth.currentSession;

            if (session != null) {
              return MaterialPageRoute(builder: (_) => const MainShell());
            } else {
              return MaterialPageRoute(builder: (_) => const LoginPage());
            }

          // ================================================================
          // SHELL PRINCIPAL (NAVBAR PERMANENTE)
          // ================================================================
          case AppRoutes.shell:
            return MaterialPageRoute(builder: (_) => const MainShell());

          // ================================================================
          // ROTAS COMUNS
          // ================================================================
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginPage());

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

          // ================================================================
          // ROTA NÃO ENCONTRADA
          // ================================================================
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Rota não encontrada")),
              ),
            );
        }
      },
    );
  }
}
