import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/theme.dart';
import 'routes/routes.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_dashboard_page.dart';

/// Ponto de entrada da aplicação BuddyTech.
/// Inicializa o Flutter, carrega variáveis de ambiente e configura o Supabase.
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

/// Widget raiz da aplicação.
/// Configura o tema, rotas e define a página inicial baseada na autenticação.
class BuddyTechApp extends StatelessWidget {
  const BuddyTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BuddyTech",
      theme: AppTheme.light,
      home: const AuthGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// Widget responsável por verificar o estado de autenticação do usuário.
/// Redireciona para a página de Login ou para a Home/Admin dependendo do nível de acesso.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Widget? _targetPage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      setState(() {
        _targetPage = const LoginPage();
        _isLoading = false;
      });
      return;
    }

    // Usuário logado - verifica role
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _targetPage = const LoginPage();
          _isLoading = false;
        });
        return;
      }

      final seller = await Supabase.instance.client
          .from('Sellers')
          .select('Role')
          .eq('Id', user.id)
          .maybeSingle();

      final role = seller?['Role'] as int? ?? 0;

      setState(() {
        if (role == 1) {
          _targetPage = const AdminDashboardPage();
        } else if (role == 2) {
          _targetPage = const HomePage();
        } else {
          // Role 0 ou desconhecida - faz logout
          Supabase.instance.client.auth.signOut();
          _targetPage = const LoginPage();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _targetPage = const HomePage();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _targetPage ?? const LoginPage();
  }
}