import 'package:flutter/material.dart';

/// Cores principais do aplicativo BuddyTech
class AppColors {
  AppColors._();

  // ========== CORES PRIMÁRIAS ==========
  static const Color primary = Color(0xFF0A66FF);
  static const Color primaryDark = Color(0xFF0044CC);
  static const Color primaryLight = Color(0xFF3B82F6);
  
  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // ========== CORES SECUNDÁRIAS ==========
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFF8B5CF6);

  // ========== CORES DE FUNDO ==========
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // ========== CORES DE TEXTO ==========
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========== CORES DE STATUS ==========
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ========== CORES DE BORDA ==========
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // ========== CORES DE NAVBAR ==========
  static const Color navbarBackground = Color(0xFF1E293B);
  static const Color navbarIcon = Color(0xFF94A3B8);
  static const Color navbarIconActive = Color(0xFFFFFFFF);

  // ========== CORES DE OVERLAY ==========
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x1A000000);
}
