import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../services/client_service.dart';
import '../utils/responsive.dart';

class ClientDetailsPage extends StatefulWidget {
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
  bool _isLoadingEmail = false;
  bool _isLoadingScript = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Widget _buildContent(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final contentPadding = Responsive.padding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        padding: EdgeInsets.all(contentPadding),
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

  /// Card com métricas da lead (Score, Probabilidade, Prioridade, Fonte)
  Widget _buildLeadMetricsCard() {
    final isMobile = Responsive.isMobile(context);
    final cardPadding = isMobile ? 16.0 : 24.0;

    // Verifica se há métricas para exibir
    final hasMetrics =
        widget.currentScore != null ||
        widget.probabilityOfClosing != null ||
        widget.priority != null ||
        widget.leadSource != null;

    if (!hasMetrics) return const SizedBox.shrink();

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
          Text(
            'Métricas da Lead',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Score
              if (widget.currentScore != null)
                _buildMetricItem(
                  icon: Icons.score,
                  label: 'Score',
                  value: widget.currentScore.toString(),
                  color: Colors.blue,
                ),

              // Probabilidade
              if (widget.probabilityOfClosing != null)
                _buildMetricItem(
                  icon: Icons.trending_up,
                  label: 'Probabilidade',
                  value: '${(widget.probabilityOfClosing! * 100).toInt()}%',
                  color: _getProbabilityColor(widget.probabilityOfClosing!),
                ),

              // Prioridade
              if (widget.priority != null)
                _buildMetricItem(
                  icon: Icons.flag,
                  label: 'Prioridade',
                  value: widget.priority!,
                  color: _getPriorityColor(widget.priority!),
                ),

              // Fonte
              if (widget.leadSource != null && widget.leadSource!.isNotEmpty)
                _buildMetricItem(
                  icon: Icons.source,
                  label: 'Fonte',
                  value: widget.leadSource!,
                  color: Colors.purple,
                ),

              // Interações
              if (widget.interactionsCount != null)
                _buildMetricItem(
                  icon: Icons.chat,
                  label: 'Interações',
                  value: widget.interactionsCount.toString(),
                  color: Colors.teal,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card com dados da empresa (CNPJ, Localização, Setor)
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

  Color _getProbabilityColor(double probability) {
    if (probability >= 0.7) return Colors.green;
    if (probability >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgente':
      case 'urgent':
        return Colors.red;
      case 'alta':
      case 'high':
        return Colors.orange;
      case 'média':
      case 'medium':
        return Colors.amber;
      case 'baixa':
      case 'low':
      default:
        return Colors.green;
    }
  }

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
          Text(
            'Resumo de análise IA',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 16),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.aiSummary,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 14),
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActionsCard() {
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
          Text(
            'Ações recomendadas',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 16),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.recommendedActions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildActionItem(action),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 14),
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeAction(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Concluir Ação',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
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
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _completeAction(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Concluir Ação',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
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
