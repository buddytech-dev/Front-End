import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/history_page.dart';
import '../pages/client_details_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/admin_users_page.dart';
import '../models/client_model.dart';

/// Argumentos para navegação à página de detalhes do cliente
class ClientDetailsArgs {
  final String companyName;
  final String companyEmail;
  final String contactName;
  final String contactPhone;
  final String status;
  final String lastInteraction;
  final int rank;
  final Color logoColor;
  final IconData logoIcon;
  final String aiSummary;
  final List<String> recommendedActions;

  ClientDetailsArgs({
    required this.companyName,
    required this.companyEmail,
    required this.contactName,
    required this.contactPhone,
    required this.status,
    required this.lastInteraction,
    required this.rank,
    required this.logoColor,
    required this.logoIcon,
    required this.aiSummary,
    required this.recommendedActions,
  });

  /// Cria a partir de um ClientModel
  factory ClientDetailsArgs.fromClientModel(ClientModel client) {
    return ClientDetailsArgs(
      companyName: client.companyName,
      companyEmail: client.companyEmail,
      contactName: client.contactName,
      contactPhone: client.contactPhone,
      status: client.status,
      lastInteraction: client.lastInteraction,
      rank: client.rank,
      logoColor: client.logoColor,
      logoIcon: client.logoIcon,
      aiSummary: client.aiSummary,
      recommendedActions: client.recommendedActions,
    );
  }
}

/// Nomes das rotas do aplicativo
class AppRoutes {
  AppRoutes._();

  // Autenticação
  static const String login = '/login';
  
  // Área do vendedor
  static const String home = '/home';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String clientDetails = '/client-details';
  
  // Área administrativa
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
}

/// Gerador de rotas do aplicativo
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ========== AUTENTICAÇÃO ==========
      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);

      // ========== ÁREA DO VENDEDOR ==========
      case AppRoutes.home:
        return _buildRoute(const HomePage(), settings);
        
      case AppRoutes.profile:
        return _buildRoute(const ProfilePage(), settings);
        
      case AppRoutes.history:
        return _buildRoute(const HistoryPage(), settings);
        
      case AppRoutes.clientDetails:
        final args = settings.arguments as ClientDetailsArgs;
        return _buildRoute(
          ClientDetailsPage(
            companyName: args.companyName,
            companyEmail: args.companyEmail,
            contactName: args.contactName,
            contactPhone: args.contactPhone,
            status: args.status,
            lastInteraction: args.lastInteraction,
            rank: args.rank,
            logoColor: args.logoColor,
            logoIcon: args.logoIcon,
            aiSummary: args.aiSummary,
            recommendedActions: args.recommendedActions,
          ),
          settings,
        );

      // ========== ÁREA ADMINISTRATIVA ==========
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboardPage(), settings);
        
      case AppRoutes.adminUsers:
        return _buildRoute(const AdminUsersPage(), settings);

      // ========== ROTA NÃO ENCONTRADA ==========
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Cria uma rota com animação padrão
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
