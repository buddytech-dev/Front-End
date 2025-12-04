import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_colors.dart';
import '../config/theme.dart';
import '../routes.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final emailController = TextEditingController();
  bool loading = false;

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe um e-mail válido.")),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Se o e-mail existir, enviaremos o link de redefinição.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

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
                SizedBox(height: 150, child: Image.asset("assets/logo.png")),

                const SizedBox(height: 16),

                Text(
                  "BuddyTech",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                const SizedBox(height: 8),

                // ---------------- CAMPO DE EMAIL ----------------
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.inputDecoration("Insira seu e-mail"),
                ),

                const SizedBox(height: 32),

                // ---------------- BOTÃO ENVIAR LINK ----------------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : sendResetLink,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Enviar link de redefinição"),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------------- VOLTAR PARA LOGIN ----------------
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text(
                    "Voltar para login",
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
