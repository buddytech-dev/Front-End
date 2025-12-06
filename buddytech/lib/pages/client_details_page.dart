import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../models/interaction_history.dart';
import '../services/client_service.dart';
import '../services/api_service.dart';
import '../services/interaction_history_service.dart';
import '../utils/responsive.dart';

/// Página de detalhes de um cliente (Lead).
/// Exibe informações detalhadas, histórico de interações e permite realizar ações como enviar email, gerar script e registrar interações.
class ClientDetailsPage extends StatefulWidget {
  final String leadId;
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
  final String? companyCNPJ;
  final String? companyLocation;
  final String? industry;

  const ClientDetailsPage({
    super.key,
    required this.leadId,
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

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  final ClientService _clientService = ClientService();
  final ApiService _apiService = ApiService();
  final InteractionHistoryService _historyService = InteractionHistoryService();
  bool _isLoadingEmail = false;
  bool _isLoadingScript = false;
  bool _isLoadingInteraction = false;
  bool _isRefreshing = false;
  bool _interactionInProgress =
      false; // Flag extra para prevenir chamadas duplicadas

  // Estados mutáveis para dados da IA (podem ser atualizados após interação)
  late int? _currentScore;
  late double? _probabilityOfClosing;
  late String? _priority;
  late String? _nextStepSuggestion;
  late String? _suggestedContactType;
  late int? _interactionsCount;
  late String _aiSummary;

  @override
  void initState() {
    super.initState();
    // Inicializa com os valores passados pelo widget
    _currentScore = widget.currentScore;
    _probabilityOfClosing = widget.probabilityOfClosing;
    _priority = widget.priority;
    _nextStepSuggestion = widget.nextStepSuggestion;
    _suggestedContactType = widget.suggestedContactType;
    _interactionsCount = widget.interactionsCount;
    _aiSummary = widget.aiSummary;
  }

  /// Atualiza os dados da lead buscando da API
  Future<void> _refreshLeadData() async {
    print('🔄 Iniciando _refreshLeadData...');
    setState(() => _isRefreshing = true);

    try {
      final response = await _apiService.getLeadById(widget.leadId);

      print('📡 Response isSuccess: ${response.isSuccess}');
      print('📡 Response data: ${response.data}');

      if (response.isSuccess && response.data != null) {
        final lead = response.data!;
        print('📊 Antes do setState:');
        print('   _currentScore: $_currentScore');
        print('   _interactionsCount: $_interactionsCount');

        setState(() {
          _currentScore = lead.currentScore;
          _probabilityOfClosing = lead.probabilityOfClosing;
          _priority = lead.priorityText;
          _nextStepSuggestion = lead.nextStepSuggestion;
          _suggestedContactType = lead.suggestedContactType;
          _interactionsCount = lead.interactionsCount;
          _aiSummary =
              lead.nextStepSuggestion ?? lead.description ?? widget.aiSummary;
        });

        print('📊 Depois do setState:');
        print('   _currentScore: $_currentScore');
        print('   _interactionsCount: $_interactionsCount');
        print('✅ setState executado com sucesso!');
      } else {
        print('❌ Response falhou ou data é null');
      }
    } catch (e) {
      print('❌ Erro ao atualizar dados: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ BUILD: score=$_currentScore, interações=$_interactionsCount');

    return Scaffold(
      key: ValueKey(
        'details_${_currentScore}_${_interactionsCount}_${_probabilityOfClosing}',
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header azul
          _buildHeader(context),

          // Conteúdo principal
          Expanded(child: SingleChildScrollView(child: _buildContent(context))),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho da página.
  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context,
          mobile: 16,
          tablet: 24,
          desktop: 40,
        ),
        vertical: Responsive.value(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Botão voltar
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            Expanded(
              child: Text(
                'Detalhes do Cliente',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da página de detalhes.
  /// Organiza os cards de informação em uma coluna centralizada.
  Widget _buildContent(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final contentPadding = Responsive.padding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        padding: EdgeInsets.only(
          left: contentPadding,
          right: contentPadding,
          top: contentPadding,
          bottom: isMobile
              ? 120
              : contentPadding, // Extra padding on mobile for nav bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de informações do cliente
            _buildClientInfoCard(),

            SizedBox(height: isMobile ? 20 : 32),

            // Card de métricas da lead (Score, Probabilidade, etc.)
            _buildLeadMetricsCard(),

            SizedBox(height: isMobile ? 20 : 32),

            // Card de dados da empresa
            _buildCompanyDataCard(),

            SizedBox(height: isMobile ? 20 : 32),

            // Card de resumo de análise IA
            _buildAIAnalysisCard(),

            SizedBox(height: isMobile ? 20 : 32),

            // Card de ações recomendadas
            _buildRecommendedActionsCard(),

            SizedBox(height: isMobile ? 24 : 40),

            // Botões de ação
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Constrói o card com informações básicas do cliente (Logo, Nome, Contato).
  /// Adapta o layout para mobile (coluna) ou desktop (linha).
  Widget _buildClientInfoCard() {
    final isMobile = Responsive.isMobile(context);
    final logoSize = Responsive.value<double>(
      context,
      mobile: 60,
      tablet: 70,
      desktop: 80,
    );
    final badgeSize = Responsive.value<double>(
      context,
      mobile: 48,
      tablet: 56,
      desktop: 64,
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    // Logo da empresa (com suporte a imagem)
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: widget.logoColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  widget.logoIcon,
                                  color: Colors.white,
                                  size: logoSize * 0.5,
                                ),
                              ),
                            )
                          : Icon(
                              widget.logoIcon,
                              color: Colors.white,
                              size: logoSize * 0.5,
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Informações da empresa
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 20),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Última: ${widget.lastInteraction}',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 13),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge de ranking
                    Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${widget.rank}',
                          style: TextStyle(
                            fontSize: badgeSize * 0.35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Logo da empresa (com suporte a imagem)
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: widget.logoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              widget.logoIcon,
                              color: Colors.white,
                              size: logoSize * 0.5,
                            ),
                          ),
                        )
                      : Icon(
                          widget.logoIcon,
                          color: Colors.white,
                          size: logoSize * 0.5,
                        ),
                ),

                const SizedBox(width: 24),

                // Informações da empresa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.companyName,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Última interação: ${widget.lastInteraction}',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 14),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge de ranking
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${widget.rank}',
                      style: TextStyle(
                        fontSize: badgeSize * 0.35,
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

  /// Constrói o card de métricas do lead (Score, Probabilidade, Prioridade).
  /// Exibe indicadores visuais coloridos para facilitar a análise rápida.
  Widget _buildLeadMetricsCard() {
    print(
      '🎨 Rebuild _buildLeadMetricsCard: score=$_currentScore, interações=$_interactionsCount',
    );

    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    // Verifica se há métricas para exibir (usa variáveis de estado)
    final hasMetrics =
        _currentScore != null ||
        _probabilityOfClosing != null ||
        _priority != null ||
        widget.leadSource != null;

    if (!hasMetrics) return const SizedBox.shrink();

    return Container(
      key: ValueKey('metrics_${_currentScore}_${_interactionsCount}'),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Métricas da Lead',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_isRefreshing) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final metricsItems = <Widget>[];

              if (_currentScore != null)
                metricsItems.add(
                  _buildMetricItem(
                    icon: Icons.score,
                    label: 'Score',
                    value: _currentScore.toString(),
                    color: Colors.blue,
                  ),
                );

              if (_probabilityOfClosing != null)
                metricsItems.add(
                  _buildMetricItem(
                    icon: Icons.trending_up,
                    label: 'Probabilidade',
                    value: '${(_probabilityOfClosing! * 100).toInt()}%',
                    color: _getProbabilityColor(_probabilityOfClosing!),
                  ),
                );

              if (_priority != null)
                metricsItems.add(
                  _buildMetricItem(
                    icon: Icons.flag,
                    label: 'Prioridade',
                    value: _priority!,
                    color: _getPriorityColor(_priority!),
                  ),
                );

              if (widget.leadSource != null && widget.leadSource!.isNotEmpty)
                metricsItems.add(
                  _buildMetricItem(
                    icon: Icons.source,
                    label: 'Fonte',
                    value: widget.leadSource!,
                    color: Colors.purple,
                  ),
                );

              if (_interactionsCount != null)
                metricsItems.add(
                  _buildMetricItem(
                    icon: Icons.chat,
                    label: 'Interações',
                    value: _interactionsCount.toString(),
                    color: Colors.teal,
                  ),
                );

              // Número de colunas baseado na largura disponível
              final itemWidth = isMobile ? 140 : 160;
              final spacing = 16.0;
              final availableWidth = constraints.maxWidth;
              final colsCount =
                  ((availableWidth + spacing) / (itemWidth + spacing))
                      .floor()
                      .clamp(1, 5);

              return GridView.count(
                crossAxisCount: colsCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: (itemWidth) / (isMobile ? 80 : 90),
                children: metricsItems,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Constrói um item individual de métrica (ícone + rótulo + valor).
  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? 80 : 90,
        minWidth: isMobile ? 140 : 160,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Constrói o card com dados detalhados da empresa (CNPJ, Localização, Setor).
  Widget _buildCompanyDataCard() {
    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    // Sempre mostra o card com os dados disponíveis
    final items = _buildCompanyInfoItems();

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                color: const Color(0xFF3B82F6),
                size: isMobile ? 22 : 26,
              ),
              const SizedBox(width: 12),
              Text(
                'Dados da Empresa',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Grid de informações ou mensagem de sem dados
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dados da empresa não disponíveis',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            isMobile
                ? Column(children: items)
                : Wrap(spacing: 32, runSpacing: 16, children: items),
        ],
      ),
    );
  }

  /// Gera a lista de widgets com informações da empresa para o card.
  List<Widget> _buildCompanyInfoItems() {
    final items = <Widget>[];

    // Nome da Empresa
    if (widget.companyName.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.apartment,
          label: 'Nome da Empresa',
          value: widget.companyName,
        ),
      );
    }

    // CNPJ
    if (widget.companyCNPJ != null && widget.companyCNPJ!.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.badge_outlined,
          label: 'CNPJ',
          value: widget.companyCNPJ!,
          copyable: true,
        ),
      );
    }

    // E-mail
    if (widget.companyEmail.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.email_outlined,
          label: 'E-mail',
          value: widget.companyEmail,
          copyable: true,
        ),
      );
    }

    // Telefone
    if (widget.contactPhone.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.phone_outlined,
          label: 'Telefone',
          value: widget.contactPhone,
          copyable: true,
        ),
      );
    }

    // Localização
    if (widget.companyLocation != null && widget.companyLocation!.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.location_on_outlined,
          label: 'Localização',
          value: widget.companyLocation!,
        ),
      );
    }

    // Setor/Indústria
    if (widget.industry != null && widget.industry!.isNotEmpty) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.category_outlined,
          label: 'Setor',
          value: widget.industry!,
        ),
      );
    }

    // Nome do Contato
    if (widget.contactName.isNotEmpty &&
        widget.contactName != widget.companyName) {
      items.add(
        _buildCompanyInfoRow(
          icon: Icons.person_outline,
          label: 'Nome do Contato',
          value: widget.contactName,
        ),
      );
    }

    return items;
  }

  /// Constrói uma linha de informação da empresa (ícone + rótulo + valor).
  ///
  /// Exibe um ícone, um rótulo descritivo e o valor correspondente.
  /// Se [copyable] for true, exibe um botão para copiar o valor.
  Widget _buildCompanyInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
      constraints: BoxConstraints(minWidth: isMobile ? double.infinity : 280),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 12),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 14),
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (copyable)
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        color: Colors.grey.shade500,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Copiar',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$label copiado!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna a cor associada à probabilidade de fechamento.
  ///
  /// * Verde: Alta probabilidade (>= 0.7)
  /// * Laranja: Média probabilidade (>= 0.4)
  /// * Vermelho: Baixa probabilidade (< 0.4)
  Color _getProbabilityColor(double probability) {
    if (probability >= 0.7) return Colors.green;
    if (probability >= 0.4) return Colors.orange;
    return Colors.red;
  }

  /// Retorna a cor associada à prioridade do lead.
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'urgente':
        return Colors.red;
      case 'high':
      case 'alta':
        return Colors.orange;
      case 'medium':
      case 'média':
        return Colors.blue;
      case 'low':
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Constrói o cartão de informações de contato.
  ///
  /// Exibe detalhes como telefone, email e endereço, permitindo ações rápidas.
  Widget _buildContactCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do card
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF3B82F6),
                size: isMobile ? 22 : 26,
              ),
              const SizedBox(width: 12),
              Text(
                'Status e Próximos Passos',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(widget.status).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(widget.status),
                  color: _getStatusColor(widget.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Atual',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 12),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.status,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 16),
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(widget.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Próximo passo sugerido
          if (widget.nextStepSuggestion != null &&
              widget.nextStepSuggestion!.isNotEmpty) ...[
            SizedBox(height: isMobile ? 16 : 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo Passo Sugerido',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 12),
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.nextStepSuggestion!,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Tipo de contato sugerido
          if (widget.suggestedContactType != null &&
              widget.suggestedContactType!.isNotEmpty) ...[
            SizedBox(height: isMobile ? 16 : 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _getContactTypeIcon(widget.suggestedContactType!),
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Contato Sugerido',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 12),
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.suggestedContactType!,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Retorna a cor associada ao status do lead.
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ganho':
      case 'fechado':
      case 'convertido':
        return Colors.green;
      case 'perdido':
      case 'cancelado':
        return Colors.red;
      case 'negociação':
      case 'proposta':
        return Colors.orange;
      case 'qualificado':
        return Colors.blue;
      case 'novo':
      case 'aberto':
      default:
        return Colors.blueGrey;
    }
  }

  /// Retorna o ícone associado ao status do lead.
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ganho':
      case 'fechado':
      case 'convertido':
        return Icons.check_circle;
      case 'perdido':
      case 'cancelado':
        return Icons.cancel;
      case 'negociação':
      case 'proposta':
        return Icons.handshake;
      case 'qualificado':
        return Icons.verified;
      case 'novo':
      case 'aberto':
      default:
        return Icons.radio_button_unchecked;
    }
  }

  /// Retorna o ícone associado ao tipo de contato.
  IconData _getContactTypeIcon(String contactType) {
    switch (contactType.toLowerCase()) {
      case 'email':
      case 'e-mail':
        return Icons.email;
      case 'telefone':
      case 'ligação':
      case 'call':
        return Icons.phone;
      case 'whatsapp':
        return Icons.chat;
      case 'reunião':
      case 'meeting':
        return Icons.event;
      case 'visita':
        return Icons.location_on;
      default:
        return Icons.contact_mail;
    }
  }

  /// Constrói o cartão de análise de Inteligência Artificial.
  ///
  /// Exibe insights gerados por IA, incluindo score de probabilidade e resumo.
  Widget _buildAIAnalysisCard() {
    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone de IA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Análise de Inteligência Artificial',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Score e Probabilidade em destaque
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
              ),
            ),
            child: Stack(
              children: [
                // Indicador de atualização
                if (_isRefreshing)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    // Score
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_currentScore ?? 0}',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 32),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Score da Lead',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                    // Probabilidade
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${((_probabilityOfClosing ?? 0) * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 32),
                              fontWeight: FontWeight.bold,
                              color: _getProbabilityColor(
                                _probabilityOfClosing ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prob. Fechamento',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                    // Prioridade
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(_priority ?? 'Normal'),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _priority ?? 'Normal',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(
                                  context,
                                  base: 12,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prioridade',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, base: 12),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Próximo Passo Sugerido pela IA
          if (_nextStepSuggestion != null &&
              _nextStepSuggestion!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sugestão da IA',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 14),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nextStepSuggestion!,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 14),
                      color: Colors.amber.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Se não tiver sugestão, mostra o aiSummary
          if ((_nextStepSuggestion == null || _nextStepSuggestion!.isEmpty) &&
              _aiSummary.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _aiSummary,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 14),
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói o cartão de ações recomendadas.
  ///
  /// Lista ações sugeridas para avançar com o lead, como enviar email ou agendar reunião.
  Widget _buildRecommendedActionsCard() {
    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    // Lista de ações baseadas nos dados da IA
    final List<Map<String, dynamic>> actions = [];

    // Adiciona ação baseada na sugestão de tipo de contato
    if (_suggestedContactType != null &&
        _suggestedContactType!.isNotEmpty &&
        _suggestedContactType != 'N/A') {
      actions.add({
        'icon': Icons.contact_phone,
        'title': 'Tipo de Contato Sugerido',
        'description': _suggestedContactType!,
        'color': Colors.green,
      });
    }

    // Adiciona ação baseada na prioridade
    if (_priority != null) {
      final priorityLower = _priority!.toLowerCase();
      if (priorityLower == 'high' ||
          priorityLower == 'urgent' ||
          priorityLower == 'alta' ||
          priorityLower == 'urgente') {
        actions.add({
          'icon': Icons.priority_high,
          'title': 'Prioridade Alta',
          'description':
              'Este lead requer atenção imediata. Faça contato hoje.',
          'color': Colors.red,
        });
      }
    }

    // Adiciona ação baseada na probabilidade
    if (_probabilityOfClosing != null) {
      if (_probabilityOfClosing! >= 0.5) {
        actions.add({
          'icon': Icons.trending_up,
          'title': 'Alta Chance de Conversão',
          'description': 'Lead quente! Agende uma reunião de fechamento.',
          'color': Colors.green,
        });
      } else if (_probabilityOfClosing! >= 0.3) {
        actions.add({
          'icon': Icons.email,
          'title': 'Nutrir Lead',
          'description': 'Envie conteúdo relevante para aumentar o interesse.',
          'color': Colors.blue,
        });
      } else {
        actions.add({
          'icon': Icons.refresh,
          'title': 'Reengajar Lead',
          'description': 'Lead frio. Tente uma abordagem diferente.',
          'color': Colors.orange,
        });
      }
    }

    // Adiciona ações padrão se não houver nenhuma
    if (actions.isEmpty) {
      actions.add({
        'icon': Icons.phone,
        'title': 'Fazer Primeiro Contato',
        'description':
            'Entre em contato para entender as necessidades do cliente.',
        'color': Colors.blue,
      });
      actions.add({
        'icon': Icons.calendar_today,
        'title': 'Agendar Reunião',
        'description': 'Agende uma apresentação do produto/serviço.',
        'color': Colors.purple,
      });
    }

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.task_alt,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ações Recomendadas',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...actions
              .map(
                (action) => _buildActionCard(
                  icon: action['icon'],
                  title: action['title'],
                  description: action['description'],
                  color: action['color'],
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  /// Constrói um card individual de ação recomendada.
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 14),
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 13),
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os botões de ação principais (Registrar Interação, Editar, etc.).
  ///
  /// Adapta o layout para mobile (coluna) ou desktop (linha).
  Widget _buildActionButtons(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          // Botão de Registrar Interação (destaque)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingInteraction
                  ? null
                  : () => _showInteractionDialog(context),
              icon: _isLoadingInteraction
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_circle_outline),
              label: const Text('Registrar Interação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoadingEmail
                      ? null
                      : () => _showSuggestedEmail(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoadingEmail
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Ver e-mail\nsugerido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoadingScript
                      ? null
                      : () => _showMeetingScript(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoadingScript
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Gerar roteiro\nda reunião',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Botão de Registrar Interação
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoadingInteraction
                ? null
                : () => _showInteractionDialog(context),
            icon: _isLoadingInteraction
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_circle_outline),
            label: Text(
              'Registrar Interação',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 14),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoadingEmail
                ? null
                : () => _showSuggestedEmail(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoadingEmail
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Ver e-mail\nsugerido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoadingScript
                ? null
                : () => _showMeetingScript(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isLoadingScript
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Gerar roteiro da\nreunião',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Exibe o diálogo para registrar uma interação
  void _showInteractionDialog(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      _showInteractionBottomSheet(context);
    } else {
      _showInteractionDialogDesktop(context);
    }
  }

  void _showInteractionBottomSheet(BuildContext context) {
    String selectedType = 'call';
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final interactionTypes = [
      {'value': 'call', 'label': 'Ligação', 'icon': Icons.phone},
      {'value': 'email', 'label': 'E-mail', 'icon': Icons.email},
      {'value': 'meeting', 'label': 'Reunião', 'icon': Icons.event},
      {'value': 'visit', 'label': 'Visita', 'icon': Icons.location_on},
      {'value': 'proposal', 'label': 'Proposta', 'icon': Icons.description},
      {'value': 'negotiation', 'label': 'Negociação', 'icon': Icons.handshake},
      {'value': 'follow_up', 'label': 'Follow-up', 'icon': Icons.update},
      {'value': 'demo', 'label': 'Demonstração', 'icon': Icons.play_circle},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setDialogState) => SafeArea(
          bottom: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_task,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Registrar Interação',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Conteúdo
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Interação',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: interactionTypes.map((type) {
                              final isSelected = selectedType == type['value'];
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedType = type['value'] as String;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        type['icon'] as IconData,
                                        size: 16,
                                        color: isSelected
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        type['label'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.green.shade700
                                              : Colors.grey.shade700,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                'Descrição da Interação',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Descreva o que foi conversado, resultado da interação...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Ao registrar uma interação, a IA irá recalcular o score e as sugestões para este lead.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botões
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 64 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(sheetContext),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    if (notesController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Por favor, descreva a interação',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    if (isSubmitting) return;
                                    setDialogState(() => isSubmitting = true);

                                    final typeToSend = selectedType;
                                    final notesToSend = notesController.text;

                                    Navigator.pop(sheetContext);

                                    _registerInteraction(
                                      typeToSend,
                                      notesToSend,
                                    );
                                  },
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              isSubmitting ? 'Enviando...' : 'Registrar',
                              style: const TextStyle(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInteractionDialogDesktop(BuildContext context) {
    String selectedType = 'call';
    final notesController = TextEditingController();
    bool isSubmitting = false;

    final interactionTypes = [
      {'value': 'call', 'label': 'Ligação', 'icon': Icons.phone},
      {'value': 'email', 'label': 'E-mail', 'icon': Icons.email},
      {'value': 'meeting', 'label': 'Reunião', 'icon': Icons.event},
      {'value': 'visit', 'label': 'Visita', 'icon': Icons.location_on},
      {'value': 'proposal', 'label': 'Proposta', 'icon': Icons.description},
      {'value': 'negotiation', 'label': 'Negociação', 'icon': Icons.handshake},
      {'value': 'follow_up', 'label': 'Follow-up', 'icon': Icons.update},
      {'value': 'demo', 'label': 'Demonstração', 'icon': Icons.play_circle},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_task, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              const Text('Registrar Interação'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de Interação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interactionTypes.map((type) {
                    final isSelected = selectedType == type['value'];
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedType = type['value'] as String;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Descrição da Interação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Descreva o que foi conversado, resultado da interação...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ao registrar uma interação, a IA irá recalcular o score e as sugestões para esta lead.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (notesController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, descreva a interação'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (isSubmitting) return;
                      setDialogState(() => isSubmitting = true);

                      final typeToSend = selectedType;
                      final notesToSend = notesController.text;

                      Navigator.pop(dialogContext);

                      _registerInteraction(typeToSend, notesToSend);
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(isSubmitting ? 'Enviando...' : 'Registrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Registra a interação na API
  Future<void> _registerInteraction(String type, String notes) async {
    // Previne chamadas duplicadas com dupla verificação
    if (_isLoadingInteraction || _interactionInProgress) {
      print(
        '⚠️ _registerInteraction já está em execução, ignorando chamada duplicada',
      );
      print(
        '   _isLoadingInteraction=$_isLoadingInteraction, _interactionInProgress=$_interactionInProgress',
      );
      return;
    }

    // Marca como em progresso IMEDIATAMENTE (antes do setState)
    _interactionInProgress = true;

    print('🚀 _registerInteraction chamado: type=$type');
    setState(() => _isLoadingInteraction = true);

    // Salva valores anteriores para o histórico
    final scoreBefore = _currentScore;
    final probabilityBefore = _probabilityOfClosing;

    try {
      final interaction = InteractionDto(
        type: type,
        notes: notes.isNotEmpty ? notes : null,
        date: DateTime.now(),
      );

      print('📤 Enviando interação para API...');
      final response = await _apiService.addInteraction(
        widget.leadId,
        interaction,
      );
      print('📥 Resposta recebida: isSuccess=${response.isSuccess}');

      if (!mounted) return;

      if (response.isSuccess) {
        // Se a API retornou o lead atualizado, usa diretamente
        if (response.data != null) {
          final lead = response.data!;
          print('✅ API retornou lead atualizado!');
          print('   Score: ${lead.currentScore}');
          print('   Probabilidade: ${lead.probabilityOfClosing}');
          print('   Interações: ${lead.interactionsCount}');

          setState(() {
            _currentScore = lead.currentScore;
            _probabilityOfClosing = lead.probabilityOfClosing;
            _priority = lead.priorityText;
            _nextStepSuggestion = lead.nextStepSuggestion;
            _suggestedContactType = lead.suggestedContactType;
            _interactionsCount = lead.interactionsCount;
            if (lead.nextStepSuggestion != null) {
              _aiSummary = lead.nextStepSuggestion!;
            }
          });

          // Salva no histórico local
          await _saveToHistory(
            type: type,
            content: notes,
            scoreBefore: scoreBefore,
            scoreAfter: lead.currentScore,
            probabilityBefore: probabilityBefore,
            probabilityAfter: lead.probabilityOfClosing,
            aiSuggestion: lead.nextStepSuggestion,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Interação registrada! Score: ${lead.currentScore} | Prob: ${((lead.probabilityOfClosing ?? 0) * 100).toInt()}%',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Salva no histórico mesmo sem resposta da IA
          await _saveToHistory(
            type: type,
            content: notes,
            scoreBefore: scoreBefore,
            scoreAfter: _currentScore,
            probabilityBefore: probabilityBefore,
            probabilityAfter: _probabilityOfClosing,
            aiSuggestion: null,
          );

          // Se não retornou, busca os dados atualizados
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Interação registrada! Buscando dados atualizados...',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          // Aguarda um pouco e depois atualiza os dados
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            await _refreshLeadData();
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${response.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar interação: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Reseta ambas as flags
      _interactionInProgress = false;
      if (mounted) {
        setState(() => _isLoadingInteraction = false);
      }
    }
  }

  /// Salva a interação no histórico local
  Future<void> _saveToHistory({
    required String type,
    required String content,
    int? scoreBefore,
    int? scoreAfter,
    double? probabilityBefore,
    double? probabilityAfter,
    String? aiSuggestion,
  }) async {
    try {
      final historyItem = InteractionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: widget.leadId,
        leadName: widget.companyName,
        interactionType: type,
        content: content,
        date: DateTime.now(),
        scoreBefore: scoreBefore,
        scoreAfter: scoreAfter,
        probabilityBefore: probabilityBefore,
        probabilityAfter: probabilityAfter,
        aiSuggestion: aiSuggestion,
      );

      await _historyService.saveInteraction(historyItem);
      print('💾 Interação salva no histórico!');
    } catch (e) {
      print('❌ Erro ao salvar no histórico: $e');
    }
  }

  /// Exibe o e-mail sugerido pela IA
  Future<void> _showSuggestedEmail(BuildContext context) async {
    setState(() => _isLoadingEmail = true);

    try {
      final email = await _clientService.generateSuggestedEmail(
        '1',
      ); // TODO: passar ID real

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('E-mail Sugerido'),
          content: SingleChildScrollView(
            child: SelectableText(
              email,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: email));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('E-mail copiado!')),
                );
              },
              child: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  /// Exibe o roteiro de reunião gerado pela IA
  Future<void> _showMeetingScript(BuildContext context) async {
    setState(() => _isLoadingScript = true);

    try {
      final script = await _clientService.generateMeetingScript(
        '1',
      ); // TODO: passar ID real

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Roteiro de Reunião'),
          content: SingleChildScrollView(
            child: SelectableText(
              script,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: script));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Roteiro copiado!')),
                );
              },
              child: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingScript = false);
    }
  }

  /// Marca a ação como concluída e volta para a home
  Future<void> _completeAction(BuildContext context) async {
    await _clientService.markActionAsCompleted(
      '1',
      'Ação concluída',
    ); // TODO: passar ID real

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ação concluída com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
