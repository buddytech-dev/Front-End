import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../pages/login_page.dart';
import '../utils/responsive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
          _userName = user.userMetadata?['name'] ?? 
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
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Conteúdo principal
          Expanded(
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
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
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, base: 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Indicador online
            Container(
              width: isMobile ? 10 : 12,
              height: isMobile ? 10 : 12,
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

  Widget _buildContent() {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final imageSize = Responsive.value<double>(context, mobile: 120, tablet: 140, desktop: 150);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          children: [
            SizedBox(height: isMobile ? 12 : 20),

            // Foto de perfil
            _buildProfileImage(imageSize),

            SizedBox(height: isMobile ? 16 : 24),

            // Nome e cargo
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

            // Botões de ação - Grid em desktop, lista em mobile
            if (isDesktop)
              _buildDesktopActions()
            else
              _buildMobileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Estatísticas',
                Icons.bar_chart,
                onTap: () => _showComingSoon('Estatísticas'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Leads Atendidos',
                Icons.people_outline,
                onTap: () => _showComingSoon('Leads Atendidos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Taxa de conversão',
                Icons.trending_up,
                onTap: () => _showComingSoon('Taxa de conversão'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Configurações',
                Icons.settings_outlined,
                onTap: () => _showComingSoon('Configurações'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 300,
          child: _buildLogoutButton(),
        ),
      ],
    );
  }

  Widget _buildMobileActions() {
    return Column(
      children: [
        _buildActionButton(
          'Estatísticas',
          Icons.bar_chart,
          onTap: () => _showComingSoon('Estatísticas'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Leads Atendidos',
          Icons.people_outline,
          onTap: () => _showComingSoon('Leads Atendidos'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Taxa de conversão',
          Icons.trending_up,
          onTap: () => _showComingSoon('Taxa de conversão'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Configurações',
          Icons.settings_outlined,
          onTap: () => _showComingSoon('Configurações'),
        ),
        const SizedBox(height: 20),
        _buildLogoutButton(),
      ],
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
            border: Border.all(
              color: const Color(0xFF3B82F6),
              width: 3,
            ),
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
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
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

  Widget _buildActionButton(String text, IconData icon, {required VoidCallback onTap}) {
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
              Icon(icon, color: const Color(0xFF3B82F6), size: isMobile ? 20 : 22),
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
              Icon(Icons.logout, color: Colors.red.shade400, size: isMobile ? 20 : 22),
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        duration: const Duration(seconds: 2),
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
