import 'package:flutter/material.dart';

/// Classe utilitária para layouts responsivos
class Responsive {
  /// Verifica se a tela é mobile (< 650px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  /// Verifica se a tela é tablet (650px - 1100px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  /// Verifica se a tela é desktop (>= 1100px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Retorna a largura da tela
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Retorna a altura da tela
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Retorna valores diferentes baseado no tamanho da tela
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  /// Padding responsivo (retorna double)
  static double padding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 40;
  }

  /// EdgeInsets responsivo
  static EdgeInsets paddingInsets(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
  }

  /// Largura máxima do conteúdo
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 900;
    return 1200;
  }

  /// Tamanho de fonte responsivo com base
  /// O parâmetro base é o tamanho para desktop, mobile será reduzido proporcionalmente
  static double fontSize(BuildContext context, {required double base}) {
    if (isMobile(context)) return base * 0.85;
    if (isTablet(context)) return base * 0.92;
    return base;
  }
}

/// Widget wrapper para layouts responsivos
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? desktop;
    }
    return mobile;
  }
}
