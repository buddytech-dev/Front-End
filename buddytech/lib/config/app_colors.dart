// ============================================================================
// app_colors.dart
// Arquivo centralizado de cores da aplicação BuddyTech
// ============================================================================
//
// Aqui ficam todas as cores utilizadas no app, garantindo consistência visual.
// Sempre importar este arquivo no theme.dart e nas páginas.
// ============================================================================

import 'package:flutter/material.dart';

class AppColors {
  // ----------------------------
  // Cores principais da marca
  // ----------------------------
  static const Color primary = Color(0xFF0A66FF);
  static const Color primaryDark = Color(0xFF084FCC);
  static const Color accent = Color(0xFF00C2FF);

  // ----------------------------
  // Cores de fundo
  // ----------------------------
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);

  // ----------------------------
  // Cores de texto
  // ----------------------------
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);

  // ----------------------------
  // Cores de status
  // ----------------------------
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2C94C);
  static const Color error = Color(0xFFEB5757);
}
