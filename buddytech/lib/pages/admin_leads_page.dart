import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

/// Página de Gerenciamento de Leads (Administrativo).
/// Permite visualizar todos os leads do sistema e atribuí-los a vendedores.
class AdminLeadsPage extends StatefulWidget {
  const AdminLeadsPage({super.key});

  @override
  State<AdminLeadsPage> createState() => _AdminLeadsPageState();
}

class _AdminLeadsPageState extends State<AdminLeadsPage> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  List<LeadDto> _leads = [];
  List<SellerDto> _sellers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carrega leads e vendedores da API em paralelo.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Carrega leads e sellers em paralelo
      final results = await Future.wait([
        _apiService.getAllLeads(),
        _apiService.getAllSellers(),
      ]);

      final leadsResponse = results[0] as ApiResponse<List<LeadDto>>;
      final sellersResponse = results[1] as ApiResponse<List<SellerDto>>;

      setState(() {
        if (leadsResponse.isSuccess) {
          _leads = leadsResponse.data ?? [];
        }
        if (sellersResponse.isSuccess) {
          _sellers = sellersResponse.data ?? [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'new': return Colors.grey;
      case 'contacted': return Colors.blue;
      case 'qualified': return Colors.orange;
      case 'proposal': return Colors.purple;
      case 'negotiation': return Colors.amber;
      case 'closed':
      case 'won': return Colors.green;
      case 'lost': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;
    switch (priority.toLowerCase()) {
      case 'low': return Colors.green;
      case 'medium': return Colors.blue;
      case 'high': return Colors.orange;
      case 'urgent': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : SingleChildScrollView(child: _buildContent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLeadDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Lead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  /// Constrói o cabeçalho da página.
  Widget _buildHeader() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context),
        vertical: isMobile ? 12 : 16,
      ),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: isMobile ? 24 : 28),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            Icon(Icons.leaderboard, color: Colors.white, size: isMobile ? 24 : 28),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Gerenciar Leads',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o estado de erro.
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo principal (estatísticas e lista de leads).
  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estatísticas
            _buildStatsCard(),
            SizedBox(height: isMobile ? 16 : 24),
            
            // Lista de leads
            if (_leads.isEmpty)
              _buildEmptyState()
            else
              ..._leads.map((lead) => _buildLeadCard(lead)),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// Constrói o card de estatísticas (resumo de leads).
  Widget _buildStatsCard() {
    final isMobile = Responsive.isMobile(context);
    final wonLeads = _leads.where((l) => l.status?.toLowerCase() == 'won' || l.status?.toLowerCase() == 'closed').length;
    final openLeads = _leads.where((l) => l.status?.toLowerCase() != 'won' && l.status?.toLowerCase() != 'closed' && l.status?.toLowerCase() != 'lost').length;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leads Cadastradas', style: TextStyle(fontSize: Responsive.fontSize(context, base: 18), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${_leads.length} leads no sistema', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          _buildStatBadge('$openLeads', 'Abertas', Colors.blue),
          const SizedBox(width: 12),
          _buildStatBadge('$wonLeads', 'Ganhas', Colors.green),
          const SizedBox(width: 12),
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh), tooltip: 'Atualizar'),
        ],
      ),
    );
  }

  /// Constrói um badge de estatística individual.
  Widget _buildStatBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  /// Constrói o estado vazio (sem leads).
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Nenhuma lead cadastrada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Clique no botão + para criar a primeira lead', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  /// Constrói o card de lead individual.
  Widget _buildLeadCard(LeadDto lead) {
    final isMobile = Responsive.isMobile(context);
    final statusColor = _getStatusColor(lead.status);
    final priorityColor = _getPriorityColor(lead.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar/Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: lead.logoUrl != null && lead.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(lead.logoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.business, color: statusColor)),
                      )
                    : Icon(Icons.business, color: statusColor),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (lead.companyName != null && lead.companyName != lead.title)
                      Text(lead.companyName!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Vendedor: ${lead.sellerName ?? 'Não atribuído'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(lead.statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              // Prioridade
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 12, color: priorityColor),
                    const SizedBox(width: 4),
                    Text(lead.priorityText, style: TextStyle(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Score/Pontuação
              if (lead.currentScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text('Score: ${lead.currentScore}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ),
              
              // Probabilidade
              if (lead.probabilityOfClosing != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('${(lead.probabilityOfClosing! * 100).toInt()}%', style: TextStyle(fontSize: 11, color: Colors.amber.shade700, fontWeight: FontWeight.w500)),
                ),
              ],
              
              const Spacer(),
              
              // Ações
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                onPressed: () => _showLeadDialog(lead: lead),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                onPressed: () => _confirmDelete(lead),
                tooltip: 'Excluir',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLeadDialog({LeadDto? lead}) {
    final isEditing = lead != null;
    final titleController = TextEditingController(text: lead?.title ?? '');
    final descriptionController = TextEditingController(text: lead?.description ?? '');
    final sourceController = TextEditingController(text: lead?.leadSource ?? '');
    final logoController = TextEditingController(text: lead?.logoUrl ?? '');
    
    // Campos da empresa (obrigatórios para criação)
    final companyNameController = TextEditingController(text: lead?.companyName ?? '');
    final companyCNPJController = TextEditingController();
    final companyEmailController = TextEditingController();
    final companyPhoneController = TextEditingController();
    final companyLocationController = TextEditingController();
    final industryController = TextEditingController();
    
    String? selectedSellerId = lead?.sellerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Lead' : 'Nova Lead'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Foto preview com botão de editar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            image: logoController.text.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(logoController.text),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {},
                                  )
                                : null,
                          ),
                          child: logoController.text.isEmpty
                              ? Icon(Icons.business, size: 36, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              onPressed: () => _showLogoUrlDialog(context, logoController, setDialogState),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // === DADOS DA LEAD ===
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dados da Lead', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título *',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: sourceController,
                          decoration: const InputDecoration(
                            labelText: 'Fonte (ex: Site, Indicação)',
                            prefixIcon: Icon(Icons.source),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // === DADOS DA EMPRESA ===
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.business, size: 18, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text('Dados da Empresa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade700)),
                            if (!isEditing) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Obrigatório', style: TextStyle(fontSize: 10, color: Colors.red.shade700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: companyNameController,
                          decoration: InputDecoration(
                            labelText: isEditing ? 'Nome da Empresa' : 'Nome da Empresa *',
                            prefixIcon: const Icon(Icons.business),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: companyCNPJController,
                          decoration: InputDecoration(
                            labelText: isEditing ? 'CNPJ' : 'CNPJ *',
                            prefixIcon: const Icon(Icons.numbers),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            hintText: '00.000.000/0000-00',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: companyEmailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: companyPhoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefone',
                                    prefixIcon: Icon(Icons.phone),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: companyLocationController,
                            decoration: const InputDecoration(
                              labelText: 'Localização',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: 'Cidade, Estado',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: industryController,
                            decoration: const InputDecoration(
                              labelText: 'Setor/Indústria',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: 'Ex: Tecnologia, Varejo, Saúde',
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // === VENDEDOR ===
                  DropdownButtonFormField<String?>(
                    value: selectedSellerId,
                    decoration: const InputDecoration(labelText: 'Vendedor Responsável', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Não atribuído')),
                      ..._sellers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name ?? s.email ?? 'Sem nome'))),
                    ],
                    onChanged: (v) => setDialogState(() => selectedSellerId = v),
                  ),
                  
                  // Nota sobre campos automáticos
                  if (isEditing && (lead.status != null || lead.priority != null)) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smart_toy, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Análise da IA',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (lead.status != null)
                            Text('Status: ${lead.statusText}', style: const TextStyle(fontSize: 13)),
                          if (lead.priority != null)
                            Text('Prioridade: ${lead.priorityText}', style: const TextStyle(fontSize: 13)),
                          if (lead.probabilityOfClosing != null)
                            Text('Probabilidade: ${(lead.probabilityOfClosing! * 100).toInt()}%', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Status, prioridade e probabilidade serão definidos automaticamente pela IA.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                // Validações
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Título é obrigatório'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                // Validações para criação (campos da empresa obrigatórios)
                if (!isEditing) {
                  if (companyNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome da empresa é obrigatório'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (companyCNPJController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CNPJ é obrigatório'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                }

                Navigator.pop(context);

                ApiResponse response;
                
                if (isEditing) {
                  // Para edição usamos UpdateLeadDto
                  final updateData = UpdateLeadDto(
                    id: lead.id,
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    leadSource: sourceController.text.isNotEmpty ? sourceController.text : null,
                    sellerId: selectedSellerId,
                  );
                  response = await _apiService.updateLead(lead.id, updateData);
                } else {
                  // Para criação usamos CreateLeadDto com campos da empresa
                  final createData = CreateLeadDto(
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    leadSource: sourceController.text.isNotEmpty ? sourceController.text : null,
                    companyLogo: logoController.text.isNotEmpty ? logoController.text : null,
                    sellerId: selectedSellerId,
                    // Campos obrigatórios da empresa
                    companyName: companyNameController.text,
                    companyCNPJ: companyCNPJController.text,
                    // Campos opcionais da empresa
                    companyEmail: companyEmailController.text.isNotEmpty ? companyEmailController.text : null,
                    companyPhone: companyPhoneController.text.isNotEmpty ? companyPhoneController.text : null,
                    companyLocation: companyLocationController.text.isNotEmpty ? companyLocationController.text : null,
                    industry: industryController.text.isNotEmpty ? industryController.text : null,
                  );
                  response = await _apiService.createLead(createData);
                }

                if (response.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing 
                                ? '✅ Lead "${titleController.text}" atualizada com sucesso!' 
                                : '✅ Lead "${titleController.text}" criada com sucesso!',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('❌ Erro: ${response.error ?? "Falha ao processar"}')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: Text(isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(LeadDto lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Lead'),
        content: Text('Tem certeza que deseja excluir "${lead.displayName}"?\n\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final leadName = lead.displayName;
              final response = await _apiService.deleteLead(lead.id);
              if (response.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text('🗑️ Lead "$leadName" excluída com sucesso!')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text('❌ Erro ao excluir: ${response.error ?? "Falha"}')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para inserir URL da logo/foto da lead
  void _showLogoUrlDialog(
    BuildContext context,
    TextEditingController logoController,
    void Function(void Function()) setDialogState,
  ) {
    final tempController = TextEditingController(text: logoController.text);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setUrlDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.image, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Logo/Foto da Lead'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview da imagem
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: tempController.text.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          tempController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('URL inválida', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Nenhuma imagem', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(
                  labelText: 'URL da imagem',
                  hintText: 'https://exemplo.com/logo.png',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setUrlDialogState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Cole a URL de uma imagem hospedada na internet (logo da empresa, foto do projeto, etc).',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            if (tempController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  tempController.clear();
                  logoController.clear();
                  setDialogState(() {});
                  Navigator.pop(ctx);
                },
                child: const Text('Remover', style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: () {
                logoController.text = tempController.text;
                setDialogState(() {});
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
