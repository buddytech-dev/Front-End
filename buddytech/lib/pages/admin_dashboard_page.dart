import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../utils/responsive.dart';
import 'admin_users_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  AdminDashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      drawer: isMobile ? _buildDrawer() : null,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: _buildContent(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  Widget _buildHeader() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context),
        vertical: isMobile ? 12 : 16,
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
            if (isMobile)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            
            if (!isMobile) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
            ],

            Expanded(
              child: Text(
                'Painel\nAdministrativo',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: isMobile ? 18 : 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.left,
              ),
            ),

            // Indicador online
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Administração',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem('Dashboard', Icons.dashboard, 0),
            _buildDrawerItem('Usuários', Icons.people, 1),
            _buildDrawerItem('Relatórios', Icons.bar_chart, 2),
            _buildDrawerItem('Configurações', Icons.settings, 3),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.grey),
              title: const Text('Voltar ao App'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFF3B82F6).withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        _onNavTap(index);
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 0),
              _buildBottomNavItem(Icons.people, 1),
              _buildBottomNavItem(Icons.bar_chart, 2),
              _buildBottomNavItem(Icons.person, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUsersPage()),
      );
    } else {
      setState(() {
        _selectedNavIndex = index;
      });
    }
  }

  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            // Cards principais - Leads e Faturamento
            isMobile
                ? Row(
                    children: [
                      Expanded(child: _buildMainCard(
                        icon: Icons.people_alt_outlined,
                        value: _formatNumber(_stats?.totalLeads ?? 0),
                        label: 'Leads Totais',
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMainCard(
                        icon: Icons.receipt_long_outlined,
                        value: 'R\$${_formatCurrency(_stats?.totalRevenue ?? 0)}',
                        label: 'Faturamento',
                        growth: _stats?.revenueGrowth,
                      )),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildMainCard(
                        icon: Icons.people_alt_outlined,
                        value: _formatNumber(_stats?.totalLeads ?? 0),
                        label: 'Leads Totais',
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _buildMainCard(
                        icon: Icons.receipt_long_outlined,
                        value: 'R\$${_formatCurrency(_stats?.totalRevenue ?? 0)}',
                        label: 'Faturamento',
                        growth: _stats?.revenueGrowth,
                      )),
                    ],
                  ),

            SizedBox(height: isMobile ? 16 : 24),

            // Cards secundários - Novos Clientes e Clientes Recentes
            isMobile
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSecondaryCard(
                        title: 'Novos Clientes',
                        value: '${_stats?.newClients ?? 0}',
                        growth: _stats?.newClientsGrowth,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildRecentClientsCard()),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSecondaryCard(
                        title: 'Novos Clientes',
                        value: '${_stats?.newClients ?? 0}',
                        growth: _stats?.newClientsGrowth,
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _buildRecentClientsCard()),
                    ],
                  ),

            SizedBox(height: isMobile ? 16 : 24),

            // Taxa de conversão (apenas mobile - na esquerda)
            if (isMobile)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: _buildSecondaryCard(
                    title: 'Taxa de conversão',
                    value: '${_stats?.conversionRate ?? 0}%',
                    growth: _stats?.conversionRateGrowth,
                  ),
                ),
              ),

            if (!isMobile)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildSecondaryCard(
                      title: 'Taxa de conversão',
                      value: '${_stats?.conversionRate ?? 0}%',
                      growth: _stats?.conversionRateGrowth,
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),

            SizedBox(height: isMobile ? 16 : 24),

            // Gráfico de média de venda
            _buildChartCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required IconData icon,
    required String value,
    required String label,
    double? growth,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
              Icon(icon, size: isMobile ? 24 : 28, color: Colors.grey.shade600),
              Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: isMobile ? 24 : 28),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, base: 14),
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$growth%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard({
    required String title,
    required String value,
    double? growth,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 14),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: isMobile ? 28 : 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (growth != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$growth%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentClientsCard() {
    final isMobile = Responsive.isMobile(context);
    final clients = _stats?.recentClients ?? [];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
          Text(
            'Clientes recentes',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, base: 14),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ...clients.map((client) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  client,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    final isMobile = Responsive.isMobile(context);
    final monthlyData = _stats?.monthlyAverages ?? {};

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
              Text(
                'Média de venda',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_vert, size: 20, color: Colors.grey.shade400),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 150 : 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(monthlyData),
            ),
          ),
          const SizedBox(height: 8),
          // Labels dos meses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthlyData.keys.map((month) => Text(
              month,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}.000';
    }
    return number.toString();
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}

/// Custom painter para o gráfico de linha
class _ChartPainter extends CustomPainter {
  final Map<String, double> data;

  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final values = data.values.toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (values.length - 1);

    // Desenhar linhas de grade horizontais
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = size.height * (1 - i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      // Labels do eixo Y
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(minValue + range * i / 5).toInt()}k',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-30, y - 6));
    }

    // Desenhar linha do gráfico
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - (values[i] - minValue) / range);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Desenhar pontos
    final dotPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - (values[i] - minValue) / range);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
