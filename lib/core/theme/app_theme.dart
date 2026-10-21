import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette: Green, Cream, White, and Gold
  static const Color primary = Color(0xFF135D38);
  static const Color primaryDark = Color(0xFF0D4126);
  static const Color primaryLight = Color(0xFF1E7B4C);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color greenTint = Color(0xFFEAF5EE);

  // Background and Surfaces (Light)
  static const Color creamBackground = Color(0xFFF9F9F4);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF3F4F0);

  // Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF0E1612);
  static const Color darkSurface = Color(0xFF17221C);
  static const Color darkSurfaceSoft = Color(0xFF1F2E26);
  static const Color darkBorder = Color(0xFF2A3D33);
  static const Color darkDivider = Color(0xFF22332A);
  static const Color darkGreenTint = Color(0xFF163324);

  // Gold Accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFFB45309);
  static const Color goldVibrant = Color(0xFFFBBF24);

  // Text Colors (Light)
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Text Colors (Dark)
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // Feature Card Badges / Icons (Light)
  static const Color wordsBadge = Color(0xFFE8F5E9);
  static const Color wordsColor = Color(0xFF2E7D32);

  static const Color sentencesBadge = Color(0xFFE0F2FE);
  static const Color sentencesColor = Color(0xFF0284C7);

  static const Color quizBadge = Color(0xFFF3E8FF);
  static const Color quizColor = Color(0xFF7C3AED);

  static const Color favouritesBadge = Color(0xFFFFF1F2);
  static const Color favouritesColor = Color(0xFFE11D48);

  static const Color searchBadge = Color(0xFFFEF3C7);
  static const Color searchColor = Color(0xFFD97706);

  // Status Colors
  static const Color correctGreen = Color(0xFF16A34A);
  static const Color correctBg = Color(0xFFDCFCE7);
  static const Color incorrectRed = Color(0xFFDC2626);
  static const Color incorrectBg = Color(0xFFFEE2E2);

  // Dark Status Bg
  static const Color darkCorrectBg = Color(0xFF143823);
  static const Color darkIncorrectBg = Color(0xFF3B1818);

  // UI Borders & Shadows
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // Theme-aware helper accessors
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : creamBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : surfaceWhite;

  static Color surfaceSoftColor(BuildContext context) =>
      isDark(context) ? darkSurfaceSoft : surfaceSoft;

  static Color borderSide(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color text(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color subtext(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color subtleTint(BuildContext context) =>
      isDark(context) ? darkGreenTint : greenTint;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surfaceWhite,
      ),
      fontFamily: 'NotoSansKannada',
      fontFamilyFallback: const ['NotoSansKannada', 'Roboto', 'sans-serif'],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansKannada',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: AppColors.greenTint,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.textSecondary,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.accentGreen,
        secondary: AppColors.goldVibrant,
        surface: AppColors.darkSurface,
      ),
      fontFamily: 'NotoSansKannada',
      fontFamilyFallback: const ['NotoSansKannada', 'Roboto', 'sans-serif'],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansKannada',
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkGreenTint,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.accentGreen,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColors.darkTextSecondary,
          );
        }),
      ),
    );
  }
}
