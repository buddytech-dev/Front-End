import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

/// Modelo para o ranking de vendedores
class SellerRanking {
  final String id;
  final String name;
  final String? email;
  final String? photoUrl;
  final int totalPoints;
  final int leadsCount;
  final int leadsWon;
  final double conversionRate;
  final int rank;

  SellerRanking({
    required this.id,
    required this.name,
    this.email,
    this.photoUrl,
    required this.totalPoints,
    required this.leadsCount,
    required this.leadsWon,
    required this.conversionRate,
    required this.rank,
  });
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final ApiService _apiService = ApiService();
  List<SellerRanking> _rankings = [];
  bool _isLoading = true;
  String? _error;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Pega o ID do usuário atual
      _currentUserId = _apiService.currentSellerId ?? '';

      // Busca todos os vendedores
      final sellersResponse = await _apiService.getAllSellers();
      
      if (!sellersResponse.isSuccess) {
        setState(() {
          _error = sellersResponse.error;
          _isLoading = false;
        });
        return;
      }

      final sellers = sellersResponse.data ?? [];
      
      // Busca todos os leads para calcular estatísticas
      final leadsResponse = await _apiService.getAllLeads();
      final allLeads = leadsResponse.data ?? [];

      // Calcula estatísticas por vendedor
      final List<SellerRanking> rankings = [];
      
      for (final seller in sellers) {
        // Filtra leads deste vendedor
        final sellerLeads = allLeads.where((l) => l.sellerId == seller.id).toList();
        final leadsWon = sellerLeads.where((l) => 
          l.status?.toLowerCase() == 'won' || 
          l.status?.toLowerCase() == 'closed'
        ).length;
        
        final conversionRate = sellerLeads.isNotEmpty 
            ? (leadsWon / sellerLeads.length) * 100 
            : 0.0;

        rankings.add(SellerRanking(
          id: seller.id,
          name: seller.name ?? 'Vendedor',
          email: seller.email,
          photoUrl: seller.photoUrl,
          totalPoints: seller.currentPoints ?? 0,
          leadsCount: sellerLeads.length,
          leadsWon: leadsWon,
          conversionRate: conversionRate,
          rank: 0, // Será calculado depois
        ));
      }

      // Ordena por pontos (maior primeiro)
      rankings.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      
      // Atribui posições no ranking
      for (int i = 0; i < rankings.length; i++) {
        rankings[i] = SellerRanking(
          id: rankings[i].id,
          name: rankings[i].name,
          email: rankings[i].email,
          photoUrl: rankings[i].photoUrl,
          totalPoints: rankings[i].totalPoints,
          leadsCount: rankings[i].leadsCount,
          leadsWon: rankings[i].leadsWon,
          conversionRate: rankings[i].conversionRate,
          rank: i + 1,
        );
      }

      setState(() {
        _rankings = rankings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar ranking: $e';
        _isLoading = false;
      });
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
                : _error != null
                    ? _buildError()
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
        gradient: AppColors.primaryGradient,
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.leaderboard,
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
                    'Ranking de Vendedores',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Acompanhe o desempenho da equipe',
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
              onPressed: _loadRankings,
              tooltip: 'Atualizar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRankings,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_rankings.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            children: [
              // Top 3 em destaque
              if (_rankings.length >= 3) _buildTopThree(),
              
              SizedBox(height: Responsive.isMobile(context) ? 16 : 24),
              
              // Lista completa
              _buildRankingList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.leaderboard,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum vendedor encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O ranking aparecerá quando houver vendedores cadastrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    final isMobile = Responsive.isMobile(context);
    final top3 = _rankings.take(3).toList();

    if (isMobile) {
      // Layout vertical para mobile
      return Column(
        children: [
          if (top3.isNotEmpty) _buildPodiumItem(top3[0], 1, true),
          const SizedBox(height: 12),
          Row(
            children: [
              if (top3.length > 1)
                Expanded(child: _buildPodiumItem(top3[1], 2, false)),
              if (top3.length > 2) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildPodiumItem(top3[2], 3, false)),
              ],
            ],
          ),
        ],
      );
    }

    // Layout horizontal para desktop
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2º lugar
        if (top3.length > 1)
          SizedBox(
            width: 200,
            child: _buildPodiumItem(top3[1], 2, false),
          ),
        
        const SizedBox(width: 16),
        
        // 1º lugar (maior)
        if (top3.isNotEmpty)
          SizedBox(
            width: 240,
            child: _buildPodiumItem(top3[0], 1, true),
          ),
        
        const SizedBox(width: 16),
        
        // 3º lugar
        if (top3.length > 2)
          SizedBox(
            width: 200,
            child: _buildPodiumItem(top3[2], 3, false),
          ),
      ],
    );
  }

  Widget _buildPodiumItem(SellerRanking seller, int position, bool isFirst) {
    final isCurrentUser = seller.id == _currentUserId;
    
    Color medalColor;
    IconData medalIcon;
    double avatarSize;
    
    switch (position) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Ouro
        medalIcon = Icons.workspace_premium;
        avatarSize = isFirst ? 80 : 70;
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Prata
        medalIcon = Icons.workspace_premium;
        avatarSize = 60;
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronze
        medalIcon = Icons.workspace_premium;
        avatarSize = 60;
        break;
      default:
        medalColor = Colors.grey;
        medalIcon = Icons.emoji_events;
        avatarSize = 50;
    }

    return Container(
      padding: EdgeInsets.all(isFirst ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isFirst 
                ? medalColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isFirst ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Medalha
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // Avatar
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: medalColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: medalColor.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: seller.photoUrl != null
                      ? Image.network(
                          seller.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(seller.name),
                        )
                      : _buildDefaultAvatar(seller.name),
                ),
              ),
              // Medalha
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: medalColor.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontSize: isFirst ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: position == 1 ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isFirst ? 16 : 12),
          
          // Nome
          Text(
            seller.name,
            style: TextStyle(
              fontSize: isFirst ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (isCurrentUser)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Você',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Pontos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [medalColor.withOpacity(0.2), medalColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: medalColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${seller.totalPoints} pts',
                  style: TextStyle(
                    fontSize: isFirst ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Estatísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStat(Icons.people, '${seller.leadsCount}'),
              const SizedBox(width: 12),
              _buildMiniStat(Icons.check_circle, '${seller.leadsWon}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList() {
    // Pula os primeiros 3 (já mostrados no pódio)
    final restOfList = _rankings.length > 3 ? _rankings.skip(3).toList() : <SellerRanking>[];
    
    if (restOfList.isEmpty && _rankings.length <= 3) {
      // Mostra todos se tiver 3 ou menos
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classificação Geral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_rankings.length, (i) => _buildRankingItem(_rankings[i])),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Classificação Geral',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ...restOfList.map((seller) => _buildRankingItem(seller)),
      ],
    );
  }

  Widget _buildRankingItem(SellerRanking seller) {
    final isCurrentUser = seller.id == _currentUserId;
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(seller.rank).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${seller.rank}º',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(seller.rank),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser ? AppColors.primary : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: seller.photoUrl != null
                  ? Image.network(
                      seller.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(seller.name),
                    )
                  : _buildDefaultAvatar(seller.name),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      seller.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Você',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${seller.leadsCount} leads',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${seller.leadsWon} ganhos',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pontos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${seller.totalPoints}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Ouro
      case 2:
        return const Color(0xFFC0C0C0); // Prata
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.shade600;
    }
  }
}
