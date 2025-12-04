// ============================================================================
// routes.dart
// Sistema centralizado de rotas nomeadas da aplicação BuddyTech
// ============================================================================
//
// Este arquivo reúne todos os nomes de rotas usados no aplicativo, permitindo:
//
//  • Organização e padronização das telas
//  • Navegação clara usando rotas nomeadas
//  • Evitar erros por strings repetidas ou digitadas errado
//  • Facilitar manutenção de novas telas no futuro
//
// ============================================================================

class AppRoutes {
  // ----------------------------
  // Rota inicial (Gateway de autenticação)
  // ----------------------------
  static const String root = '/';

  // ----------------------------
  // SHELL PRINCIPAL (Navegação com Navbar fixa)
  // ----------------------------
  static const String shell = '/shell';

  // ----------------------------
  // TELAS PRINCIPAIS
  // ----------------------------
  static const String login = '/login';
  static const String home = '/home';

  // ----------------------------
  // RECUPERAÇÃO DE SENHA
  // ----------------------------
  static const String recoverPassword = '/recover-password';

  // ----------------------------
  // DETALHES / CLIENTES
  // ----------------------------
  static const String clientDetails = '/client-details';

  // ----------------------------
  // IA • SUGESTÃO DE E-MAILS
  // ----------------------------
  static const String suggestedEmails = '/suggested-emails';

  // ----------------------------
  // ROTEIRO DE REUNIÃO
  // ----------------------------
  static const String meetingScript = '/meeting-script';

  // ----------------------------
  // RANKING DE PERFORMANCE
  // ----------------------------
  static const String ranking = '/ranking';

  // ----------------------------
  // PERFIL DO USUÁRIO
  // ----------------------------
  static const String profile = '/profile';

  // ----------------------------
  // AÇÕES CONCLUÍDAS (Histórico)
  // ----------------------------
  static const String completedActions = '/completed-actions';

  // ----------------------------
  // (Opcional) Tela de erro 404 personalizada
  // ----------------------------
  static const String notFound = '/not-found';
}
