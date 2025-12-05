import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/mission_service.dart';
import '../utils/responsive.dart';

class SellerDashboardPage extends StatefulWidget {
  final bool embedded;
  const SellerDashboardPage({super.key, this.embedded = false});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final ApiService _apiService = ApiService();
  final MissionService _missionService = MissionService();
  bool _isLoading = true;
  List<LeadDto> _myLeads = [];
  List<LeadDto> _allLeads = [];
  SellerDto? _currentSeller;
  int _totalMissionPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getLeadsBySeller(),
        _apiService.getAllLeads(),
        _apiService.getCurrentSeller(),
        _missionService.getTotalPoints(),
      ]);

      setState(() {
        final myLeadsResponse = results[0] as ApiResponse<List<LeadDto>>;
        if (myLeadsResponse.isSuccess) {
          _myLeads = myLeadsResponse.data ?? [];
        }

        final allLeadsResponse = results[1] as ApiResponse<List<LeadDto>>;
        if (allLeadsResponse.isSuccess) {
          _allLeads = allLeadsResponse.data ?? [];
        }

        final sellerResponse = results[2] as ApiResponse<SellerDto>;
        if (sellerResponse.isSuccess) {
          _currentSeller = sellerResponse.data;
        }

        final pointsResponse = results[3] as int;
        _totalMissionPoints = pointsResponse;

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(
        color: const Color(0xFFF8FAFC),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com informações do vendedor
                      _buildSellerHeader(),

                      const SizedBox(height: 24),

                      // Cards de métricas
                      _buildMetricsSection(),

                      const SizedBox(height: 24),

                      // Missões e Pontos
                      _buildMissionsPointsCard(),

                      const SizedBox(height: 24),

                      // Minhas Leads
                      _buildMyLeadsSection(),

                      const SizedBox(height: 24),

                      // Oportunidades de Parceria
                      _buildPartnershipOpportunitiesSection(),

                      const SizedBox(height: 24),

                      // Todas as Empresas
                      _buildAllCompaniesSection(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meu Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com informações do vendedor
                    _buildSellerHeader(),

                    const SizedBox(height: 24),

                    // Cards de métricas
                    _buildMetricsSection(),

                    const SizedBox(height: 24),

                    // Minhas Leads
                    _buildMyLeadsSection(),

                    const SizedBox(height: 24),

                    // Oportunidades de Parceria
                    _buildPartnershipOpportunitiesSection(),

                    const SizedBox(height: 24),

                    // Todas as Empresas
                    _buildAllCompaniesSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSellerHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _currentSeller?.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _currentSeller!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentSeller?.name ?? 'Vendedor',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentSeller?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentSeller?.currentPoints ?? 0} pontos',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    final isMobile = Responsive.isMobile(context);

    // Calcula métricas
    final totalLeads = _myLeads.length;
    final wonLeads = _myLeads
        .where(
          (l) =>
              l.status?.toLowerCase() == 'won' ||
              l.status?.toLowerCase() == 'ganho',
        )
        .length;
    final inProgressLeads = _myLeads
        .where(
          (l) =>
              l.status?.toLowerCase() == 'negotiation' ||
              l.status?.toLowerCase() == 'negociação' ||
              l.status?.toLowerCase() == 'proposal' ||
              l.status?.toLowerCase() == 'proposta',
        )
        .length;
    final conversionRate = totalLeads > 0
        ? (wonLeads / totalLeads * 100).round()
        : 0;

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _buildMetricCard(
              title: 'Minhas Leads',
              value: '$totalLeads',
              icon: Icons.people_alt,
              color: const Color(0xFF3B82F6),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _buildMetricCard(
              title: 'Leads Ganhas',
              value: '$wonLeads',
              icon: Icons.emoji_events,
              color: const Color(0xFF10B981),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _buildMetricCard(
              title: 'Em Andamento',
              value: '$inProgressLeads',
              icon: Icons.pending_actions,
              color: const Color(0xFFF59E0B),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: _buildMetricCard(
              title: 'Conversão',
              value: '$conversionRate%',
              icon: Icons.trending_up,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Minhas Leads',
            value: '$totalLeads',
            icon: Icons.people_alt,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Leads Ganhas',
            value: '$wonLeads',
            icon: Icons.emoji_events,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Em Andamento',
            value: '$inProgressLeads',
            icon: Icons.pending_actions,
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: 'Conversão',
            value: '$conversionRate%',
            icon: Icons.trending_up,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLeadsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Minhas Leads',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ver Todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_myLeads.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Você ainda não tem leads',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_myLeads
                .take(5)
                .map((lead) => _buildLeadItem(lead, isMyLead: true))),
        ],
      ),
    );
  }

  Widget _buildPartnershipOpportunitiesSection() {
    // Leads de outros vendedores que podem ser parcerias
    final partnershipLeads = _allLeads.where((lead) {
      final isNotMine = lead.sellerId != _apiService.currentSellerId;
      final isOpen =
          lead.status?.toLowerCase() != 'won' &&
          lead.status?.toLowerCase() != 'ganho' &&
          lead.status?.toLowerCase() != 'lost' &&
          lead.status?.toLowerCase() != 'perdido';
      return isNotMine && isOpen;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.handshake,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Oportunidades de Parceria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Leads de outros vendedores que você pode ajudar',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (partnershipLeads.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma oportunidade no momento',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...partnershipLeads
                .take(5)
                .map((lead) => _buildLeadItem(lead, isPartnership: true)),
        ],
      ),
    );
  }

  Widget _buildAllCompaniesSection() {
    // Agrupa leads por empresa
    final companiesMap = <String, List<LeadDto>>{};
    for (final lead in _allLeads) {
      final companyName =
          lead.companyName ?? lead.title ?? 'Empresa Desconhecida';
      companiesMap.putIfAbsent(companyName, () => []).add(lead);
    }

    final companies = companiesMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Todas as Empresas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Empresas cadastradas no sistema',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (companies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.business_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma empresa cadastrada',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...companies
                .take(10)
                .map((entry) => _buildCompanyItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildLeadItem(
    LeadDto lead, {
    bool isMyLead = false,
    bool isPartnership = false,
  }) {
    final statusColor = _getStatusColor(lead.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar/Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: lead.logoUrl != null && lead.logoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      lead.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          (lead.displayName.isNotEmpty
                                  ? lead.displayName[0]
                                  : 'L')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      (lead.displayName.isNotEmpty ? lead.displayName[0] : 'L')
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (lead.currentScore != null) ...[
                      Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Score: ${lead.currentScore}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (lead.probabilityOfClosing != null) ...[
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(lead.probabilityOfClosing! * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isPartnership && lead.sellerName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Vendedor: ${lead.sellerName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lead.statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyItem(String companyName, List<LeadDto> leads) {
    final totalLeads = leads.length;
    final wonLeads = leads
        .where(
          (l) =>
              l.status?.toLowerCase() == 'won' ||
              l.status?.toLowerCase() == 'ganho',
        )
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                companyName.isNotEmpty ? companyName[0].toUpperCase() : 'E',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalLeads lead${totalLeads != 1 ? 's' : ''} • $wonLeads ganho${wonLeads != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Ícone
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'won':
      case 'ganho':
        return Colors.green;
      case 'lost':
      case 'perdido':
        return Colors.red;
      case 'negotiation':
      case 'negociação':
        return Colors.orange;
      case 'qualified':
      case 'qualificado':
        return Colors.blue;
      case 'proposal':
      case 'proposta':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMissionsPointsCard() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 15,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pontos de Missões',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, base: 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Complete missões para ganhar pontos extras',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_totalMissionPoints',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'pontos',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navega para a página de missões
                Navigator.pushNamed(context, '/missions');
              },
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text(
                'Ver Missões',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
