import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../config/app_colors.dart';
import '../routes/routes.dart';
import '../utils/responsive.dart';

/// Página de Perfil do Usuário.
/// Permite visualizar e editar informações pessoais, como foto e nome.
class ProfilePage extends StatefulWidget {
  final bool embedded;
  const ProfilePage({super.key, this.embedded = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _userName = 'Nome do Usuário';
  String _userRole = 'Vendedor';
  String? _profileImageUrl;
  Uint8List? _profileImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Carrega os dados do perfil do usuário atual do Supabase.
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // TODO: Carregar dados do perfil do Supabase
        // final response = await _supabase
        //     .from('profiles')
        //     .select()
        //     .eq('id', user.id)
        //     .single();
        //
        // setState(() {
        //   _userName = response['name'] ?? 'Nome do Usuário';
        //   _userRole = response['role'] ?? 'Vendedor';
        //   _profileImageUrl = response['avatar_url'];
        // });

        // Por enquanto usa dados do auth
        setState(() {
          _userName =
              user.userMetadata?['name'] ??
              user.email?.split('@').first ??
              'Nome do Usuário';
          _userRole = user.userMetadata?['role'] ?? 'Vendedor';
          _profileImageUrl = user.userMetadata?['avatar_url'];
        });
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _profileImageBytes = result.files.single.bytes;
          _isLoading = true;
        });

        // TODO: Upload para Supabase Storage
        // final user = _supabase.auth.currentUser;
        // if (user != null) {
        //   final fileName = '${user.id}/avatar.png';
        //   await _supabase.storage
        //       .from('avatars')
        //       .uploadBinary(fileName, _profileImageBytes!);
        //
        //   final imageUrl = _supabase.storage
        //       .from('avatars')
        //       .getPublicUrl(fileName);
        //
        //   await _supabase
        //       .from('profiles')
        //       .update({'avatar_url': imageUrl})
        //       .eq('id', user.id);
        //
        //   setState(() => _profileImageUrl = imageUrl);
        // }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erro ao fazer upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: _buildContent())),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Conteúdo principal
          Expanded(child: SingleChildScrollView(child: _buildContent())),
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
            // Logo - apenas desktop
            if (!isMobile)
              Image.asset(
                'assets/logo.png',
                height: 32,
                width: 32,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.business, color: Colors.white, size: 32),
              ),
            SizedBox(width: isMobile ? 8 : 16),
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // nav.png - mobile, Foto de perfil - desktop
            if (isMobile)
              Image.asset(
                'assets/nav.png',
                height: 32,
                width: 32,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.business, color: Colors.white, size: 32),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: _profileImageBytes != null
                      ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
                      : _profileImageUrl != null
                      ? Image.network(
                          _profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatarWhite(),
                        )
                      : _buildDefaultAvatarWhite(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final imageSize = Responsive.value<double>(
      context,
      mobile: 120,
      tablet: 140,
      desktop: 150,
    );

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: isDesktop
            ? Row(
                children: [
                  // Coluna esquerda - Foto e info
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isMobile ? 12 : 20),
                        _buildProfileImage(imageSize),
                        SizedBox(height: isMobile ? 16 : 24),
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 28),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userRole,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, base: 16),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  // Coluna direita - Ações
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          'Estatísticas',
                          Icons.bar_chart,
                          onTap: _showStatistics,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Leads Atendidos',
                          Icons.people,
                          onTap: _showAttendedLeads,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Taxa de conversão',
                          Icons.trending_up,
                          onTap: _showConversionRate,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          'Configurações',
                          Icons.settings,
                          onTap: _showSettings,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(child: _buildLogoutButton()),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(height: isMobile ? 12 : 20),
                  _buildProfileImage(imageSize),
                  SizedBox(height: isMobile ? 16 : 24),
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userRole,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, base: 16),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildMobileActions(),
                ],
              ),
      ),
    );
  }

  Widget _buildMobileActions() {
    return Column(
      children: [
        _buildStatCard(
          'Total de Vendas',
          'R\$ 12.500,00',
          Colors.green,
          Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _buildStatCard('Taxa de Conversão', '45%', Colors.blue, Icons.percent),
        const SizedBox(height: 12),
        _buildStatCard('Leads Atendidos', '89', Colors.orange, Icons.people),
        const SizedBox(height: 12),
        _buildStatCard(
          'Ticket Médio',
          'R\$ 278,00',
          Colors.purple,
          Icons.attach_money,
        ),
        const SizedBox(height: 20),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(double size) {
    final buttonSize = size * 0.3;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3B82F6), width: 3),
          ),
          child: ClipOval(
            child: _profileImageBytes != null
                ? Image.memory(
                    _profileImageBytes!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  )
                : _profileImageUrl != null
                ? Image.network(
                    _profileImageUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(size),
                  )
                : _buildDefaultAvatar(size),
          ),
        ),
        // Botão de editar foto
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndUploadImage,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: buttonSize * 0.5,
              ),
            ),
          ),
        ),
        // Loading overlay
        if (_isLoading)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.person_outline,
        size: size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildDefaultAvatarWhite() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.person_outline, size: 20, color: Colors.white),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF3B82F6),
                size: isMobile ? 20 : 22,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final isMobile = Responsive.isMobile(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showLogoutConfirmation,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: Colors.red.shade400,
                size: isMobile ? 20 : 22,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Sair',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: 16),
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatistics() {
    _showModalSheet(
      title: 'Estatísticas',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Total de vendas',
                'R\$ 12.500,00',
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 16),
              _buildStatCard('Conversões', '45%', Colors.blue, Icons.percent),
              const SizedBox(height: 16),
              _buildStatCard(
                'Ticket médio',
                'R\$ 278,00',
                Colors.orange,
                Icons.attach_money,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Clientes ativos',
                '89',
                Colors.purple,
                Icons.people,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendedLeads() {
    _showModalSheet(
      title: 'Leads Atendidos',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildLeadItem(
                'João Silva',
                'Contato realizado em 15/12/2024',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildLeadItem(
                'Maria Santos',
                'Aguardando resposta',
                Icons.schedule,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildLeadItem(
                'Pedro Costa',
                'Contactado em 14/12/2024',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildLeadItem(
                'Ana Lima',
                'Novo lead',
                Icons.fiber_new,
                Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConversionRate() {
    _showModalSheet(
      title: 'Taxa de Conversão',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConversionStat('Este mês', '45%', Colors.green),
              const SizedBox(height: 16),
              _buildConversionStat('Mês anterior', '38%', Colors.blue),
              const SizedBox(height: 16),
              _buildConversionStat('Média geral', '42%', Colors.grey),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você está 7% acima da média!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
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
    );
  }

  void _showSettings() {
    _showModalSheet(
      title: 'Configurações',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingItem('Notificações', Icons.notifications_outlined),
              const Divider(height: 24),
              _buildSettingItem('Privacidade', Icons.lock_outlined),
              const Divider(height: 24),
              _buildSettingItem(
                'Preferências de exibição',
                Icons.display_settings,
              ),
              const Divider(height: 24),
              _buildSettingItem('Segurança da conta', Icons.security),
              const Divider(height: 24),
              _buildSettingItem('Sobre', Icons.info_outlined),
            ],
          ),
        ),
      ),
    );
  }

  void _showModalSheet({required String title, required Widget child}) {
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      // Pop-up dialog centralizado para desktop
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      );
    } else {
      // Bottom sheet para mobile/tablet
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
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLeadItem(
    String name,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionStat(String period, String rate, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rate,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
