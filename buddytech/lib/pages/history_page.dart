import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../models/interaction_history.dart';
import '../services/interaction_history_service.dart';
import '../utils/responsive.dart';

/// Página de Histórico de Interações.
/// Exibe todas as interações registradas com leads, permitindo filtragem e visualização de detalhes.
class HistoryPage extends StatefulWidget {
  final bool embedded;
  const HistoryPage({super.key, this.embedded = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final InteractionHistoryService _historyService = InteractionHistoryService();
  List<InteractionHistory> _history = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Carrega o histórico de interações e estatísticas do serviço local.
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = await _historyService.getHistory();
      final stats = await _historyService.getStatistics();

      setState(() {
        _history = history;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar histórico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Retorna a lista de interações filtrada pelo tipo selecionado.
  List<InteractionHistory> get _filteredHistory {
    if (_selectedFilter == 'all') return _history;
    return _history.where((e) => e.interactionType == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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

  /// Constrói o cabeçalho da página.
  Widget _buildHeader() {
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
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: isMobile ? 8 : 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.history,
                color: Colors.white,
                size: isMobile ? 22 : 26,
              ),
            ),
            SizedBox(width: isMobile ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Histórico de Interações',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Suas interações com leads e análises da IA',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 12),
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadHistory,
              tooltip: 'Atualizar',
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da página.
  ///
  /// Exibe estatísticas, filtros e a lista de histórico.
  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estatísticas - Responsivo
              if (isMobile)
                _buildStatisticsCardsMobile()
              else
                _buildStatisticsCards(),

              SizedBox(height: isMobile ? 20 : 24),

              // Filtros
              _buildFilters(),

              SizedBox(height: isMobile ? 16 : 16),

              // Lista de histórico
              _filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : isMobile
                  ? _buildHistoryListMobile()
                  : _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói os cards de estatísticas (Total, Semana, Mês).
  Widget _buildStatisticsCards() {
    final total = _statistics['total'] ?? 0;
    final thisWeek = _statistics['thisWeek'] ?? 0;
    final thisMonth = _statistics['thisMonth'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.format_list_numbered,
            label: 'Total',
            value: total.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            label: 'Esta semana',
            value: thisWeek.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.date_range,
            label: 'Este mês',
            value: thisMonth.toString(),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCardsMobile() {
    final total = _statistics['total'] ?? 0;
    final thisWeek = _statistics['thisWeek'] ?? 0;
    final thisMonth = _statistics['thisMonth'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.format_list_numbered,
                label: 'Total',
                value: total.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                label: 'Esta semana',
                value: thisWeek.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.date_range,
                label: 'Este mês',
                value: thisMonth.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(thisWeek / (total > 0 ? total : 1) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Esta semana',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de filtros por tipo de interação.
  Widget _buildFilters() {
    final isMobile = Responsive.isMobile(context);
    final filters = [
      {'value': 'all', 'label': 'Todos', 'icon': Icons.all_inclusive},
      {'value': 'call', 'label': 'Ligações', 'icon': Icons.phone},
      {'value': 'email', 'label': 'E-mails', 'icon': Icons.email},
      {'value': 'meeting', 'label': 'Reuniões', 'icon': Icons.event},
      {'value': 'proposal', 'label': 'Propostas', 'icon': Icons.description},
      {'value': 'negotiation', 'label': 'Negociações', 'icon': Icons.handshake},
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                selected: isSelected,
                avatar: Icon(
                  filter['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                label: Text(
                  filter['label'] as String,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                onSelected: (_) {
                  setState(() => _selectedFilter = filter['value'] as String);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade200,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              selected: isSelected,
              avatar: Icon(
                filter['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              label: Text(
                filter['label'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = filter['value'] as String);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Constrói o estado vazio (sem interações).
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 64, color: Colors.blue.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma interação registrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Registre interações nos detalhes dos leads\npara vê-las aqui e acompanhar seu progresso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Comece registrando uma interação',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de histórico agrupada por data.
  Widget _buildHistoryList() {
    final items = _filteredHistory;

    // Agrupa por data
    final grouped = <String, List<InteractionHistory>>{};
    for (final item in items) {
      final dateKey = _formatDateKey(item.date);
      grouped[dateKey] = [...(grouped[dateKey] ?? []), item];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Separador de data
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
            ),

            // Itens do dia
            ...entry.value.map(
              (item) => _buildHistoryItemMobileRefactored(item),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoryListMobile() {
    final items = _filteredHistory;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Agrupa por data
    final grouped = <String, List<InteractionHistory>>{};
    for (final item in items) {
      final dateKey = _formatDateKey(item.date);
      grouped[dateKey] = [...(grouped[dateKey] ?? []), item];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Separador de data
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Itens do dia
            ...entry.value.map(
              (item) => _buildHistoryItemMobileRefactored(item),
            ),

            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItemMobileRefactored(InteractionHistory item) {
    return GestureDetector(
      onTap: () => _showHistoryDetailsMobile(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Ícone + Info + Hora + Score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone com cor
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      item.interactionType,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.typeIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.leadName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(
                                item.interactionType,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(item.interactionType),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('HH:mm').format(item.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Score badge
                if (item.scoreAfter != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.scoreAfter}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Descrição
            Text(
              item.content,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // IA Sugestão (se houver)
            if (item.aiSuggestion != null && item.aiSuggestion!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade100, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.aiSuggestion!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple.shade700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHistoryDetailsMobile(InteractionHistory item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getTypeColor(
                            item.interactionType,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.typeIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.leadName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.typeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
                      // Info básica
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(item.date),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          if (item.scoreAfter != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Score',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '${item.scoreAfter}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Conteúdo
                      Text(
                        'Detalhes da Interação',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          item.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Sugestão da IA
                      if (item.aiSuggestion != null &&
                          item.aiSuggestion!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Sugestão da IA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade50,
                                Colors.blue.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.psychology,
                                  size: 16,
                                  color: Colors.purple.shade600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.aiSuggestion!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Probabilidade
                      if (item.probabilityAfter != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Probabilidade de Fechamento',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(item.probabilityAfter! * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return Colors.blue;
      case 'email':
        return Colors.orange;
      case 'meeting':
        return Colors.purple;
      case 'visit':
        return Colors.teal;
      case 'proposal':
        return Colors.indigo;
      case 'negotiation':
        return Colors.green;
      case 'follow_up':
        return Colors.amber.shade700;
      case 'demo':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoje';
    } else if (dateOnly == yesterday) {
      return 'Ontem';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE', 'pt_BR').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
