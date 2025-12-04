// ============================================================================
// login_page.dart
// Tela de Login da aplicação BuddyTech
// ============================================================================
//
// Responsável por:
//  • Autenticar o usuário via Supabase (email + senha)
//  • Validar campos antes de enviar
//  • Mostrar loader enquanto processa login
//  • Redirecionar para o MainShell (hub principal com navbar persistente)
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_colors.dart';
import '../config/theme.dart';
import '../routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores dos campos de email e senha
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  // ==========================================================================
  // Função de login
  // ==========================================================================
  Future<void> login() async {
    try {
      setState(() => loading = true);

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw "Preencha email e senha.";
      }

      // --- Autenticação Supabase ---
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // --- Redirecionamento ---
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.shell,
          (_) => false,
        );
      }
    } catch (e) {
      // Agora usa SnackBar com estilo global do Theme
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  // ==========================================================================
  // UI da tela de login
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------------- LOGO ----------------
                SizedBox(height: 160, child: Image.asset("assets/logo.png")),

                const SizedBox(height: 16),

                Text(
                  "BuddyTech",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // ---------------- CAMPO EMAIL ----------------
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.inputDecoration("Email"),
                ),

                const SizedBox(height: 16),

                // ---------------- CAMPO SENHA ----------------
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: AppTheme.inputDecoration("Senha"),
                ),

                const SizedBox(height: 32),

                // ---------------- BOTÃO LOGIN ----------------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Entrar"),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------------- ESQUECI SENHA ----------------
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.recoverPassword);
                  },
                  child: const Text(
                    "Esqueci minha senha",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
