import 'package:flutter/material.dart';

/// Design tokens centralizados para manter consistência visual
class DesignTokens {
  DesignTokens._(); // Private constructor para tornar a classe não instanciável

  // CORES
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color surfaceWhite = Color(0xFFFFFFFE);
  static const Color backgroundLight = Color(0xFFFBFCFD);
  static const Color borderLight = Color(0xFFF1F5F9);
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Cores de status
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // ESPAÇAMENTOS
  static const double space2xs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;

  // RAIOS DE BORDA
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // TAMANHOS DE ÍCONES
  static const double iconXs = 16.0;
  static const double iconSm = 18.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ELEVAÇÕES/SOMBRAS
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // TIPOGRAFIA
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: textMuted,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: textMuted,
  );

  // DURAÇÃO DE ANIMAÇÕES
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // CURVAS DE ANIMAÇÃO
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.easeOut;

  // HELPER METHODS
  
  /// Retorna decoração padrão para containers
  static BoxDecoration containerDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? backgroundLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLg),
      border: borderColor != null 
          ? Border.all(color: borderColor, width: 1.5)
          : null,
      boxShadow: shadow ?? shadowSm,
    );
  }

  /// Retorna decoração para cards
  static BoxDecoration cardDecoration({
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: surfaceWhite,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(color: borderLight, width: 1.5),
      boxShadow: elevated ? shadowMd : shadowSm,
    );
  }

  /// Retorna decoração para botões
  static BoxDecoration buttonDecoration({
    Color? backgroundColor,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? primaryBlue,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: isPressed ? shadowSm : shadowMd,
    );
  }

  /// Retorna padding padrão
  static EdgeInsets get paddingStandard => const EdgeInsets.all(spaceMd);
  
  /// Retorna padding para páginas
  static EdgeInsets get paddingPage => const EdgeInsets.fromLTRB(spaceLg, spaceMd, spaceLg, spaceMd);
  
  /// Retorna padding para cards
  static EdgeInsets get paddingCard => const EdgeInsets.all(spaceLg);

  // BREAKPOINTS RESPONSIVOS
  static const double breakpointMobile = 768;
  static const double breakpointTablet = 1024;
  static const double breakpointDesktop = 1440;

  /// Verifica se é dispositivo móvel
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointTablet;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
}