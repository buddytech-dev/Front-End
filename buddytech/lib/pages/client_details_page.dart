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
  final String aiSummary;
  final List<String> recommendedActions;

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
    required this.aiSummary,
    required this.recommendedActions,
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
          Expanded(
            child: SingleChildScrollView(
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context, mobile: 16, tablet: 24, desktop: 40),
        vertical: Responsive.value(context, mobile: 12, tablet: 16, desktop: 20),
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
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
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        padding: EdgeInsets.all(contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de informações do cliente
            _buildClientInfoCard(),

            SizedBox(height: isMobile ? 20 : 32),

            // Card de contato
            _buildContactCard(context),

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
    final logoSize = Responsive.value<double>(context, mobile: 60, tablet: 70, desktop: 80);
    final badgeSize = Responsive.value<double>(context, mobile: 48, tablet: 56, desktop: 64);
    
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
                    // Logo da empresa
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: widget.logoColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
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
                // Logo da empresa
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: widget.logoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
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
          // Status
          Row(
            children: [
              Text(
                'Estado - ',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  color: Colors.black54,
                ),
              ),
              Expanded(
                child: Text(
                  widget.status,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 16 : 24),
          const Divider(),
          SizedBox(height: isMobile ? 12 : 16),

          // Email
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-mail do contato',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.companyEmail,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.companyEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-mail copiado!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copiar e-mail'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-mail do contato',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.companyEmail,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.companyEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-mail copiado!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'Copiar e-mail',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

          SizedBox(height: isMobile ? 12 : 16),
          const Divider(),
          SizedBox(height: isMobile ? 12 : 16),

          // Telefone
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome do contato',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.contactName,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Telefone - ${widget.contactPhone}',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade em desenvolvimento'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Enviar mensagem'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nome do contato',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.contactName,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Telefone - ${widget.contactPhone}',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 14),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade em desenvolvimento'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        'enviar\nmensagem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
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
                  .map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildActionItem(action),
                      ))
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
                  onPressed: _isLoadingEmail ? null : () => _showSuggestedEmail(context),
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
                  onPressed: _isLoadingScript ? null : () => _showMeetingScript(context),
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
            onPressed: _isLoadingEmail ? null : () => _showSuggestedEmail(context),
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
            onPressed: _isLoadingScript ? null : () => _showMeetingScript(context),
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
      final email = await _clientService.generateSuggestedEmail('1'); // TODO: passar ID real
      
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
      final script = await _clientService.generateMeetingScript('1'); // TODO: passar ID real
      
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
    await _clientService.markActionAsCompleted('1', 'Ação concluída'); // TODO: passar ID real
    
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
