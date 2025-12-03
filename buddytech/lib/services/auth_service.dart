import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

// Serviço simples para autenticação com Supabase
class AuthService {
  // retorna sessão atual
  static Session? currentSession() =>
      Supabase.instance.client.auth.currentSession;

  // logout
  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  // enviar email de recuperação (Supabase envia email)
  static Future<void> recoverPassword(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  // checa se usuario está autenticado
  static bool isAuthenticated() => currentSession() != null;
}
