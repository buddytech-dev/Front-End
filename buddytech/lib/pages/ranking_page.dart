import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/mission_service.dart';
import '../utils/responsive.dart';

/// Modelo para o ranking de vendedores.
/// Armazena estatísticas de desempenho de cada vendedor.
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

/// Página de Ranking de Vendedores.
/// Exibe a classificação dos vendedores baseada em pontos e desempenho.
class RankingPage extends StatefulWidget {
  final bool embedded;
  const RankingPage({super.key, this.embedded = false});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final ApiService _apiService = ApiService();
  final MissionService _missionService = MissionService();
  List<SellerRanking> _rankings = [];
  bool _isLoading = true;
  String? _error;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  /// Carrega os dados de ranking da API.
  /// Busca vendedores e leads, calcula estatísticas e ordena por pontuação.
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

      // Obtém pontos de missões do usuário atual
      final missionPoints = await _missionService.getTotalPoints();

      // Calcula estatísticas por vendedor
      final List<SellerRanking> rankings = [];

      for (final seller in sellers) {
        // Filtra leads deste vendedor
        final sellerLeads = allLeads
            .where((l) => l.sellerId == seller.id)
            .toList();
        final leadsWon = sellerLeads
            .where(
              (l) =>
                  l.status?.toLowerCase() == 'won' ||
                  l.status?.toLowerCase() == 'closed',
            )
            .length;

        final conversionRate = sellerLeads.isNotEmpty
            ? (leadsWon / sellerLeads.length) * 100
            : 0.0;

        // Se é o vendedor atual, adiciona os pontos das missões
        int totalPoints = seller.currentPoints ?? 0;
        if (seller.id == _currentUserId) {
          totalPoints += missionPoints;
        }

        rankings.add(
          SellerRanking(
            id: seller.id,
            name: seller.name ?? 'Vendedor',
            email: seller.email,
            photoUrl: seller.photoUrl,
            totalPoints: totalPoints,
            leadsCount: sellerLeads.length,
            leadsWon: leadsWon,
            conversionRate: conversionRate,
            rank: 0, // Será calculado depois
          ),
        );
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
    if (widget.embedded) {
      return Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
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

  /// Constrói a tela de erro.
  ///
  /// Exibe uma mensagem de erro e um botão para tentar recarregar os dados.
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

  /// Constrói o conteúdo principal da página.
  ///
  /// Exibe o pódio (top 3) e a lista completa de vendedores.
  Widget _buildContent() {
    if (_rankings.isEmpty) {
      return _buildEmptyState();
    }

    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            children: [
              // Resumo rápido (apenas mobile)
              if (isMobile && _rankings.isNotEmpty) ...[
                _buildQuickStats(),
                SizedBox(height: isMobile ? 20 : 24),
              ],

              // Top 3 em destaque
              if (_rankings.length >= 3) _buildTopThree(),

              SizedBox(height: isMobile ? 24 : 32),

              // Lista completa
              _buildRankingList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_rankings.isEmpty) return const SizedBox.shrink();

    final currentUserRank = _rankings.cast<SellerRanking?>().firstWhere(
      (r) => r?.id == _currentUserId,
      orElse: () => null,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total de Vendedores',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_rankings.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sua Posição',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUserRank != null ? '${currentUserRank.rank}º' : '-',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seus Pontos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUserRank != null
                    ? '${currentUserRank.totalPoints}'
                    : '-',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de destaque para os 3 primeiros colocados.
  ///
  /// Adapta o layout para mobile (vertical) ou desktop (pódio horizontal).
  Widget _buildTopThree() {
    final isMobile = Responsive.isMobile(context);
    final top3 = _rankings.take(3).toList();

    if (isMobile) {
      // Pódio estilo atletismo para mobile
      return _buildPodiumAtletismo(top3);
    }

    // Layout horizontal para desktop
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2º lugar
        if (top3.length > 1)
          SizedBox(width: 200, child: _buildPodiumItem(top3[1], 2, false)),

        const SizedBox(width: 16),

        // 1º lugar (maior)
        if (top3.isNotEmpty)
          SizedBox(width: 240, child: _buildPodiumItem(top3[0], 1, true)),

        const SizedBox(width: 16),

        // 3º lugar
        if (top3.length > 2)
          SizedBox(width: 200, child: _buildPodiumItem(top3[2], 3, false)),
      ],
    );
  }

  Widget _buildPodiumAtletismo(List<SellerRanking> top3) {
    // Usa MediaQuery para responsividade
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcula alturas responsivas
    final podiumHeight = screenHeight * 0.30; // 30% da altura da tela
    final column1Height = podiumHeight * 0.6; // 1º lugar
    final column2Height = podiumHeight * 0.45; // 2º lugar
    final column3Height = podiumHeight * 0.3; // 3º lugar

    final avatarSize = screenWidth < 350 ? 32.0 : 40.0;
    final emojiSize = screenWidth < 350 ? 14.0 : 18.0;
    final numberSize = screenWidth < 350 ? 18.0 : 22.0;
    final nameSize = screenWidth < 350 ? 10.0 : 11.0;
    final pointsSize = screenWidth < 350 ? 9.0 : 10.0;

    return Column(
      children: [
        // Nomes dos vendedores no topo - com padding responsivo
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 350 ? 4.0 : 8.0,
            vertical: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2º lugar (esquerda)
              if (top3.length > 1)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        top3[1].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${top3[1].totalPoints} pts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: pointsSize,
                          color: const Color(0xFFC0C0C0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: screenWidth < 350 ? 4 : 8),
              // 1º lugar (centro)
              if (top3.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        top3[0].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameSize + 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${top3[0].totalPoints} pts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: pointsSize + 1,
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: screenWidth < 350 ? 4 : 8),
              // 3º lugar (direita)
              if (top3.length > 2)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        top3[2].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${top3[2].totalPoints} pts',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: pointsSize,
                          color: const Color(0xFFCD7F32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
        SizedBox(height: screenWidth < 350 ? 6 : 8),
        // Pódio com 3 alturas diferentes - Responsivo
        SizedBox(
          height: podiumHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2º lugar
              if (top3.length > 1)
                Expanded(
                  child: _buildPodiumColumnResponsive(
                    seller: top3[1],
                    position: 2,
                    height: column2Height,
                    avatarSize: avatarSize,
                    emojiSize: emojiSize,
                    numberSize: numberSize,
                    podiumColor: const Color(0xFF3B82F6),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: screenWidth < 350 ? 4 : 8),
              // 1º lugar
              if (top3.isNotEmpty)
                Expanded(
                  child: _buildPodiumColumnResponsive(
                    seller: top3[0],
                    position: 1,
                    height: column1Height,
                    avatarSize: avatarSize,
                    emojiSize: emojiSize,
                    numberSize: numberSize,
                    podiumColor: const Color(0xFF3B82F6),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              SizedBox(width: screenWidth < 350 ? 4 : 8),
              // 3º lugar
              if (top3.length > 2)
                Expanded(
                  child: _buildPodiumColumnResponsive(
                    seller: top3[2],
                    position: 3,
                    height: column3Height,
                    avatarSize: avatarSize,
                    emojiSize: emojiSize,
                    numberSize: numberSize,
                    podiumColor: const Color(0xFF3B82F6),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumColumn({
    required SellerRanking seller,
    required int position,
    required double height,
    required Color podiumColor,
  }) {
    return Column(
      children: [
        // Avatar acima da coluna - reduzido
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                podiumColor.withOpacity(0.4),
                podiumColor.withOpacity(0.2),
              ],
            ),
            border: Border.all(color: podiumColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: seller.photoUrl != null
                ? Image.network(
                    seller.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(seller.name),
                  )
                : _buildDefaultAvatar(seller.name),
          ),
        ),
        // Coluna do pódio
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [podiumColor, podiumColor.withOpacity(0.8)],
            ),
            border: Border.all(color: podiumColor, width: 2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                position == 1
                    ? '🏆'
                    : position == 2
                    ? '🥈'
                    : '🥉',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                '$position',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumColumnResponsive({
    required SellerRanking seller,
    required int position,
    required double height,
    required double avatarSize,
    required double emojiSize,
    required double numberSize,
    required Color podiumColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar acima da coluna - responsivo
        Container(
          width: avatarSize,
          height: avatarSize,
          margin: EdgeInsets.only(bottom: avatarSize * 0.1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                podiumColor.withOpacity(0.4),
                podiumColor.withOpacity(0.2),
              ],
            ),
            border: Border.all(color: podiumColor, width: avatarSize * 0.05),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: seller.photoUrl != null
                ? Image.network(
                    seller.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildDefaultAvatar(seller.name),
                  )
                : _buildDefaultAvatar(seller.name),
          ),
        ),
        // Coluna do pódio - responsiva
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [podiumColor, podiumColor.withOpacity(0.8)],
            ),
            border: Border.all(color: podiumColor, width: height * 0.03),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(height * 0.1),
              topRight: Radius.circular(height * 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                position == 1
                    ? '🏆'
                    : position == 2
                    ? '🥈'
                    : '🥉',
                style: TextStyle(fontSize: emojiSize),
              ),
              SizedBox(height: height * 0.08),
              Text(
                '$position',
                style: TextStyle(
                  fontSize: numberSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói um item individual do pódio (1º, 2º ou 3º lugar).
  Widget _buildPodiumItem(SellerRanking seller, int position, bool isFirst) {
    final isCurrentUser = seller.id == _currentUserId;

    Color medalColor;
    double avatarSize;
    Color cardGradientStart;
    Color cardGradientEnd;

    switch (position) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Ouro
        avatarSize = isFirst ? 90 : 70;
        cardGradientStart = const Color(0xFFFFF8E1);
        cardGradientEnd = const Color(0xFFFFE082);
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Prata
        avatarSize = 65;
        cardGradientStart = Colors.white;
        cardGradientEnd = const Color(0xFFF5F5F5);
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronze
        avatarSize = 65;
        cardGradientStart = const Color(0xFFFFF3E0);
        cardGradientEnd = const Color(0xFFFFE0B2);
        break;
      default:
        medalColor = Colors.grey;
        avatarSize = 50;
        cardGradientStart = Colors.white;
        cardGradientEnd = Colors.grey.shade50;
    }

    return Container(
      padding: EdgeInsets.all(isFirst ? 24 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardGradientStart, cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: medalColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: medalColor.withOpacity(0.4),
            blurRadius: isFirst ? 25 : 15,
            offset: const Offset(0, 8),
          ),
          if (isFirst)
            BoxShadow(
              color: medalColor.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
        ],
      ),
      child: Column(
        children: [
          // Medalha com efeito
          Stack(
            alignment: Alignment.topCenter,
            children: [
              // Avatar com brilho
              Container(
                margin: const EdgeInsets.only(top: 24),
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [medalColor, medalColor.withOpacity(0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: medalColor.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: seller.photoUrl != null
                        ? Image.network(
                            seller.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildDefaultAvatar(seller.name),
                          )
                        : _buildDefaultAvatar(seller.name),
                  ),
                ),
              ),
              // Medalha com ícone
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: medalColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: medalColor.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  position == 1
                      ? '🏆'
                      : position == 2
                      ? '🥈'
                      : '🥉',
                  style: TextStyle(fontSize: isFirst ? 24 : 20),
                ),
              ),
            ],
          ),

          SizedBox(height: isFirst ? 20 : 16),

          // Nome
          Text(
            seller.name,
            style: TextStyle(
              fontSize: isFirst ? 20 : 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (isCurrentUser)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Você',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Pontos com destaque
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  medalColor.withOpacity(0.3),
                  medalColor.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${seller.totalPoints}',
                  style: TextStyle(
                    fontSize: isFirst ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Taxa de conversão
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${seller.conversionRate.toStringAsFixed(1)}% conversão',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Estatísticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopThreeMiniStat(
                '${seller.leadsCount}',
                'Leads',
                Icons.people,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withOpacity(0.2),
              ),
              _buildTopThreeMiniStat(
                '${seller.leadsWon}',
                'Ganhos',
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeMiniStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Constrói a lista de classificação (abaixo do pódio).
  Widget _buildRankingList() {
    // Pula os primeiros 3 (já mostrados no pódio)
    final restOfList = _rankings.length > 3
        ? _rankings.skip(3).toList()
        : <SellerRanking>[];

    if (restOfList.isEmpty && _rankings.length <= 3) {
      // Mostra todos se tiver 3 ou menos
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Classificação Geral',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _rankings.length,
            (i) => _buildRankingItem(_rankings[i]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Classificação Geral',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...restOfList.map((seller) => _buildRankingItem(seller)),
      ],
    );
  }

  /// Constrói um item da lista de classificação.
  Widget _buildRankingItem(SellerRanking seller) {
    final isCurrentUser = seller.id == _currentUserId;
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Posição com ícone visual
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRankColor(seller.rank).withOpacity(0.2),
                      _getRankColor(seller.rank).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${seller.rank}º',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getRankColor(seller.rank),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Avatar melhorado
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getRankColor(seller.rank).withOpacity(0.3),
                      _getRankColor(seller.rank).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: isCurrentUser
                        ? AppColors.primary
                        : _getRankColor(seller.rank).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: seller.photoUrl != null
                      ? Image.network(
                          seller.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatar(seller.name),
                        )
                      : _buildDefaultAvatar(seller.name),
                ),
              ),

              const SizedBox(width: 12),

              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            seller.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Você',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${seller.conversionRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${seller.leadsCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${seller.leadsWon}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pontos em destaque
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRankColor(seller.rank).withOpacity(0.9),
                      _getRankColor(seller.rank).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${seller.totalPoints}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'pts',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um avatar padrão com a inicial do nome.
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
