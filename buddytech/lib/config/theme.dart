// ============================================================================
// theme.dart
// Configuração global de tema do aplicativo BuddyTech
// ============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ----------------------------
  // Tema claro
  // ----------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: "Inter",

      // ----------------------------
      // AppBar
      // ----------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ----------------------------
      // Tipografia
      // ----------------------------
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),

      // ----------------------------
      // Botões
      // ----------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),

      // ----------------------------
      // Inputs
      // ----------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      // ----------------------------
      // SnackBars
      // ----------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: Colors.white,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ----------------------------
      // ColorScheme
      // ----------------------------
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
      ),
    );
  }

  // ----------------------------
  // Builder para inputs customizados
  // ----------------------------
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(labelText: label);
  }
}
