import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/history_page.dart';
import '../pages/client_details_page.dart';
import '../pages/seller_dashboard_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/admin_users_page.dart';
import '../pages/admin_accounts_page.dart';
import '../pages/admin_leads_page.dart';
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
  final String logoUrl;
  final String aiSummary;
  final List<String> recommendedActions;
  
  // Campos extras da Lead
  final String? title;
  final String? description;
  final String? leadSource;
  final String? priority;
  final int? currentScore;
  final double? probabilityOfClosing;
  final String? nextStepSuggestion;
  final String? suggestedContactType;
  final int? interactionsCount;
  
  // Dados da empresa
  final String? companyCNPJ;
  final String? companyLocation;
  final String? industry;

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
    this.logoUrl = '',
    required this.aiSummary,
    required this.recommendedActions,
    this.title,
    this.description,
    this.leadSource,
    this.priority,
    this.currentScore,
    this.probabilityOfClosing,
    this.nextStepSuggestion,
    this.suggestedContactType,
    this.interactionsCount,
    this.companyCNPJ,
    this.companyLocation,
    this.industry,
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
      logoUrl: client.logoUrl,
      aiSummary: client.aiSummary,
      recommendedActions: client.recommendedActions,
      title: client.title,
      description: client.description,
      leadSource: client.leadSource,
      priority: client.priority,
      currentScore: client.currentScore,
      probabilityOfClosing: client.probabilityOfClosing,
      nextStepSuggestion: client.nextStepSuggestion,
      suggestedContactType: client.suggestedContactType,
      interactionsCount: client.interactionsCount,
      companyCNPJ: client.companyCNPJ,
      companyLocation: client.companyLocation,
      industry: client.industry,
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
  static const String sellerDashboard = '/seller-dashboard';
  
  // Área administrativa
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminAccounts = '/admin/accounts';
  static const String adminLeads = '/admin/leads';
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
        
      case AppRoutes.sellerDashboard:
        return _buildRoute(const SellerDashboardPage(), settings);

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
            logoUrl: args.logoUrl,
            aiSummary: args.aiSummary,
            recommendedActions: args.recommendedActions,
            title: args.title,
            description: args.description,
            leadSource: args.leadSource,
            priority: args.priority,
            currentScore: args.currentScore,
            probabilityOfClosing: args.probabilityOfClosing,
            nextStepSuggestion: args.nextStepSuggestion,
            suggestedContactType: args.suggestedContactType,
            interactionsCount: args.interactionsCount,
            companyCNPJ: args.companyCNPJ,
            companyLocation: args.companyLocation,
            industry: args.industry,
          ),
          settings,
        );

      // ========== ÁREA ADMINISTRATIVA ==========
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboardPage(), settings);
        
      case AppRoutes.adminUsers:
        return _buildRoute(const AdminUsersPage(), settings);
        
      case AppRoutes.adminAccounts:
        return _buildRoute(const AdminAccountsPage(), settings);
        
      case AppRoutes.adminLeads:
        return _buildRoute(const AdminLeadsPage(), settings);

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
