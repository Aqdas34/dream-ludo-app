// ───────────────────────────────────────────────────────────────
// app_theme.dart  –  Colors & theme matching original Kotlin app
// Source: source_code_frontend/res/values/colors.xml
// ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Exact from Kotlin colors.xml ─────────────────────────────
  static const Color primary        = Color(0xFFFE2147); // colorPrimary
  static const Color primaryDark    = Color(0xFFE41D3F); // colorPrimaryDark
  static const Color primaryLight   = Color(0xFFFE4D6B); // colorAccent

  // ── App background (dark) ─────────────────────────────────────
  static const Color background     = Color(0xFF141414); // backgroundColor
  static const Color surface        = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  // ── Login screen (white) ──────────────────────────────────────
  static const Color loginBg        = Color(0xFFFFFFFF); // login_bk_color
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFFCECECE);
  static const Color textHint       = Color(0xFF888888); // colorGrey1
  static const Color textDark       = Color(0xFF070707); // light mode text

  // ── Supporting ────────────────────────────────────────────────
  static const Color success        = Color(0xFF32CD32);
  static const Color error          = Color(0xFFCC0000);
  static const Color warning        = Color(0xFFFFAE42);
  static const Color divider        = Color(0xFF2A2A2A);
  static const Color appBlue        = Color(0xFF435BD4);
  static const Color btnBlue        = Color(0xFF00B2F9);
  static const Color grey           = Color(0xFFCECECE);
  static const Color grey40         = Color(0xFF999999);
  static const Color grey60         = Color(0xFF666666);
  static const Color grey80         = Color(0xFF333333);
  static const Color grey10         = Color(0xFFE6E6E6);
  static const Color gold           = Color(0xFFFFD700);
  static const Color secondary      = Color(0xFFFF6584);

  // ── Settings Grid Colors ──────────────────────────────────────
  static const Color fabDeposit     = Color(0xFF8BC34A);
  static const Color fabWithdraw    = Color(0xFFFF8A65);
  static const Color fabBonus       = Color(0xFF42A5F5);
}

class AppTextStyles {
  AppTextStyles._();

  static const String? fontFamily = null; // Set to 'Poppins' when fonts added

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.white, letterSpacing: 0.5,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily, fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,   // Matches Kotlin colorPrimary toolbar
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Rounded like Kotlin loginButton
          ),
          textStyle: AppTextStyles.button,
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
    );
  }
}
