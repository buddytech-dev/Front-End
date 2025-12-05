import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Modelo para representar uma ação concluída
class CompletedAction {
  final String id;
  final String companyName;
  final String companyEmail;
  final String contactName;
  final String contactPhone;
  final String actionType;
  final DateTime completedAt;
  final Color logoColor;
  final IconData logoIcon;

  CompletedAction({
    required this.id,
    required this.companyName,
    required this.companyEmail,
    required this.contactName,
    required this.contactPhone,
    required this.actionType,
    required this.completedAt,
    required this.logoColor,
    required this.logoIcon,
  });

  /// Factory para criar a partir de JSON (preparado para API)
  factory CompletedAction.fromJson(Map<String, dynamic> json) {
    return CompletedAction(
      id: json['id'] ?? '',
      companyName: json['company_name'] ?? '',
      companyEmail: json['company_email'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      actionType: json['action_type'] ?? '',
      completedAt: DateTime.tryParse(json['completed_at'] ?? '') ?? DateTime.now(),
      logoColor: Color(json['logo_color'] ?? 0xFF3B82F6),
      logoIcon: IconData(json['logo_icon'] ?? Icons.business.codePoint, fontFamily: 'MaterialIcons'),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<CompletedAction> _completedActions = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedActions();
  }

  Future<void> _loadCompletedActions() async {
    setState(() => _isLoading = true);

    // TODO: Buscar ações concluídas do Supabase
    // final response = await Supabase.instance.client
    //     .from('completed_actions')
    //     .select()
    //     .order('completed_at', ascending: false);

    // Dados mock para demonstração
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _completedActions = [
        CompletedAction(
          id: '1',
          companyName: 'Fronteira Soft',
          companyEmail: 'contato@fronteirasoft.com',
          contactName: 'Daniela Medeiros',
          contactPhone: '11 9 8000-0000',
          actionType: 'Reunião agendada',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          logoColor: const Color(0xFF3B82F6),
          logoIcon: Icons.business,
        ),
        CompletedAction(
          id: '2',
          companyName: 'Samba Bla Anca',
          companyEmail: 'contato@samba.com',
          contactName: 'João Santos',
          contactPhone: '11 9 8000-0001',
          actionType: 'E-mail enviado',
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
          logoColor: const Color(0xFFFFC107),
          logoIcon: Icons.music_note,
        ),
        CompletedAction(
          id: '3',
          companyName: 'Ambev Tech',
          companyEmail: 'contato@ambevtech.com',
          contactName: 'Paulo Carvalho',
          contactPhone: '11 9 8000-0002',
          actionType: 'Proposta enviada',
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
          logoColor: const Color(0xFFFF9800),
          logoIcon: Icons.local_drink,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context, mobile: 16, tablet: 24, desktop: 40),
        vertical: Responsive.value(context, mobile: 12, tablet: 16, desktop: 20),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            // Ícone de histórico
            Icon(
              Icons.history,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Histórico',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da seção
              Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações concluídas',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Histórico de ações concluídas',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de ações concluídas
              if (_completedActions.isEmpty)
                _buildEmptyState()
              else
                ..._completedActions.map((action) => _buildActionCard(action)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma ação concluída',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As ações que você concluir aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(CompletedAction action) {
    final isMobile = Responsive.isMobile(context);
    final logoSize = isMobile ? 50.0 : 60.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo da empresa
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: action.logoColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action.logoIcon,
              color: Colors.white,
              size: logoSize * 0.5,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.companyName,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.companyEmail,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 13),
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                // Linha do contato
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        action.contactName,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, base: 13),
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Linha do telefone
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      action.contactPhone,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 13),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge de ação concluída
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    action.actionType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
