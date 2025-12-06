import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';

/// Página de Gerenciamento de Contas (Administrativo).
/// Permite visualizar e gerenciar as contas de vendedores cadastradas no sistema.
class AdminAccountsPage extends StatefulWidget {
  const AdminAccountsPage({super.key});

  @override
  State<AdminAccountsPage> createState() => _AdminAccountsPageState();
}

class _AdminAccountsPageState extends State<AdminAccountsPage> {
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<SellerDto> _sellers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  /// Carrega a lista de vendedores da API.
  Future<void> _loadSellers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.getAllSellers();
      if (response.isSuccess) {
        setState(() {
          _sellers = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar vendedores: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isMobile ? 'Nova' : 'Nova Conta',
          style: const TextStyle(color: Colors.white),
        ),
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
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gerenciar Contas',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, base: isMobile ? 18 : 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadSellers,
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
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Erro desconhecido',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadSellers,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo principal (lista de contas).
  Widget _buildContent() {
    final padding = Responsive.padding(context);

    if (_sellers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conta cadastrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão + para criar uma nova conta',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
        child: ListView.builder(
          padding: EdgeInsets.all(padding),
          itemCount: _sellers.length,
          itemBuilder: (context, index) {
            final seller = _sellers[index];
            return _buildAccountCard(seller);
          },
        ),
      ),
    );
  }

  /// Constrói o card de conta (wrapper para mobile/desktop).
  Widget _buildAccountCard(SellerDto seller) {
    final isMobile = Responsive.isMobile(context);
    final roleText = _getRoleText(seller.role);
    final roleColor = _getRoleColor(seller.role);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAccountDialog(seller: seller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: isMobile 
              ? _buildMobileCardContent(seller, roleText, roleColor)
              : _buildDesktopCardContent(seller, roleText, roleColor),
        ),
      ),
    );
  }

  /// Constrói o conteúdo do card para mobile.
  Widget _buildMobileCardContent(SellerDto seller, String roleText, Color roleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com avatar, nome e ações
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: seller.photoUrl != null && seller.photoUrl!.isNotEmpty
                  ? NetworkImage(seller.photoUrl!)
                  : null,
              child: seller.photoUrl == null || seller.photoUrl!.isEmpty
                  ? Text(
                      (seller.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name ?? 'Sem nome',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    seller.email ?? 'Sem email',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Ações
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.grey.shade600,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showAccountDialog(seller: seller),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _confirmDelete(seller),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Badges e telefone
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                roleText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
            
            // Points badge
            if (seller.currentPoints != null && seller.currentPoints! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${seller.currentPoints}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              
            // Telefone
            if (seller.phoneNumber != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    seller.phoneNumber!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// Constrói o conteúdo do card para desktop.
  Widget _buildDesktopCardContent(SellerDto seller, String roleText, Color roleColor) {
    return Row(
      children: [
        // Avatar com foto ou inicial
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: seller.photoUrl != null && seller.photoUrl!.isNotEmpty
              ? NetworkImage(seller.photoUrl!)
              : null,
          child: seller.photoUrl == null || seller.photoUrl!.isEmpty
              ? Text(
                  (seller.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name ?? 'Sem nome',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                seller.email ?? 'Sem email',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (seller.phoneNumber != null) ...[
                const SizedBox(height: 2),
                Text(
                  seller.phoneNumber!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roleText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: roleColor,
            ),
          ),
        ),

        // Points badge
        if (seller.currentPoints != null && seller.currentPoints! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${seller.currentPoints}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Edit icon
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          color: Colors.grey.shade600,
          onPressed: () => _showAccountDialog(seller: seller),
        ),

        // Delete icon
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red.shade400,
          onPressed: () => _confirmDelete(seller),
        ),
      ],
    );
  }

  String _getRoleText(int? role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Vendedor';
      case 3:
        return 'Gerente';
      default:
        return 'Sem função';
    }
  }

  Color _getRoleColor(int? role) {
    switch (role) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAccountDialog({SellerDto? seller}) async {
    final isEditing = seller != null;
    final nameController = TextEditingController(text: seller?.name ?? '');
    final emailController = TextEditingController(text: seller?.email ?? '');
    final passwordController = TextEditingController(text: seller?.password ?? '');
    final phoneController = TextEditingController(text: seller?.phoneNumber ?? '');
    final photoUrlController = TextEditingController(text: seller?.photoUrl ?? '');
    int selectedRole = seller?.role ?? 2; // Default: Vendedor
    bool isLoading = false;
    bool showPassword = false;
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 40,
                vertical: 24,
              ),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.person_add,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Editar Conta' : 'Nova Conta',
                    style: TextStyle(fontSize: isMobile ? 18 : 20),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: isMobile ? screenWidth * 0.85 : 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar/Foto de perfil preview
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: photoUrlController.text.isNotEmpty
                                  ? NetworkImage(photoUrlController.text)
                                  : null,
                              child: photoUrlController.text.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Abre diálogo para inserir URL da foto
                                    _showPhotoUrlDialog(
                                      context,
                                      photoUrlController,
                                      setDialogState,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nome
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: isEditing ? 'Nova Senha (opcional)' : 'Senha *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Telefone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role dropdown
                      DropdownButtonFormField<int>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Função *',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Sem função')),
                          DropdownMenuItem(value: 1, child: Text('Administrador')),
                          DropdownMenuItem(value: 2, child: Text('Vendedor')),
                          DropdownMenuItem(value: 3, child: Text('Gerente')),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedRole = value ?? 2;
                          });
                        },
                      ),

                      if (isEditing && seller.currentPoints != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                'Pontos atuais: ${seller.currentPoints}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
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
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Validação
                          if (nameController.text.trim().isEmpty) {
                            _showSnackBar('Nome é obrigatório', isError: true);
                            return;
                          }
                          if (emailController.text.trim().isEmpty) {
                            _showSnackBar('Email é obrigatório', isError: true);
                            return;
                          }
                          if (!isEditing && passwordController.text.trim().isEmpty) {
                            _showSnackBar('Senha é obrigatória', isError: true);
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          try {
                            final sellerData = CreateSellerDto(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.isNotEmpty
                                  ? passwordController.text
                                  : null,
                              phoneNumber: phoneController.text.isNotEmpty
                                  ? phoneController.text.trim()
                                  : null,
                              role: selectedRole,
                              currentPoints: 0, // Pontos padrão = 0
                              photoUrl: photoUrlController.text.isNotEmpty
                                  ? photoUrlController.text.trim()
                                  : null,
                            );

                            ApiResponse response;
                            if (isEditing) {
                              response = await _apiService.updateSeller(
                                seller.id,
                                sellerData,
                              );
                            } else {
                              response = await _apiService.createSeller(sellerData);
                            }

                            if (response.isSuccess) {
                              Navigator.pop(context);
                              _loadSellers();
                              _showSnackBar(
                                isEditing
                                    ? 'Conta atualizada com sucesso!'
                                    : 'Conta criada com sucesso!',
                              );
                            } else {
                              _showSnackBar(
                                response.error ?? 'Erro ao salvar conta',
                                isError: true,
                              );
                            }
                          } catch (e) {
                            _showSnackBar('Erro: $e', isError: true);
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Salvar' : 'Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(SellerDto seller) async {
    final isMobile = Responsive.isMobile(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 40,
          vertical: 24,
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Confirmar exclusão',
                style: TextStyle(fontSize: isMobile ? 18 : 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja realmente excluir a conta de ${seller.name}?',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta ação não pode ser desfeita.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _apiService.deleteSeller(seller.id);
        if (response.isSuccess) {
          _loadSellers();
          _showSnackBar('Conta excluída com sucesso!');
        } else {
          _showSnackBar(response.error ?? 'Erro ao excluir conta', isError: true);
        }
      } catch (e) {
        _showSnackBar('Erro: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Diálogo para inserir URL da foto de perfil
  void _showPhotoUrlDialog(
    BuildContext context,
    TextEditingController photoUrlController,
    void Function(void Function()) setDialogState,
  ) {
    final tempController = TextEditingController(text: photoUrlController.text);
    final isMobile = Responsive.isMobile(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 40,
          vertical: 24,
        ),
        title: const Row(
          children: [
            Icon(Icons.image, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Foto de Perfil'),
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
                hintText: 'https://exemplo.com/foto.jpg',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Atualiza o preview
                (context as Element).markNeedsBuild();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Cole a URL de uma imagem hospedada na internet.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (tempController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                tempController.clear();
                photoUrlController.clear();
                setDialogState(() {});
                Navigator.pop(context);
              },
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () {
              photoUrlController.text = tempController.text;
              setDialogState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
