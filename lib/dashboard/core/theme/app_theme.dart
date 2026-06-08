import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────
// COLOR SYSTEM — Deep Blue + Electric Orange futuristic palette
// ─────────────────────────────────────────────────────────────────
abstract final class AppColors {
  // Brand blues
  static const navy       = Color(0xFF0D1A63);
  static const royalBlue  = Color(0xFF1A2CA3);
  static const cobalt     = Color(0xFF2845D6);
  static const cobaltSoft = Color(0xFF3454E8);

  // Brand orange
  static const orange     = Color(0xFFF68048);
  static const orangeGlow = Color(0xFFFF9A6C);
  static const orangeDim  = Color(0xFFC4612E);

  // Backgrounds (deep-space dark)
  static const bg         = Color(0xFF080D2E);
  static const bgSurface  = Color(0xFF0F1845);
  static const bgCard     = Color(0xFF131F54);
  static const bgCardHigh = Color(0xFF1A2A6B);
  static const border     = Color(0xFF1E3070);
  static const borderSoft = Color(0xFF243680);
  static const accent = Color(0xFFEA8C60);

  // Text
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8FA4D8);
  static const textMuted     = Color(0xFF4A608A);

  // Semantic
  static const success = Color(0xFF00E5A0);
  static const warning = Color(0xFFFFCA28);
  static const danger  = Color(0xFFFF4C6B);
  static const info    = Color(0xFF40C4FF);

  // Gradient definitions
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [orangeDim, orange, orangeGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [navy, royalBlue, cobalt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bg, bgSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [bgCard, bgCardHigh],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme aliases for consistency
  static const bgDark = bg;
  static const midnight = bgSurface;
  static const midnightLight = bgCardHigh;
  static const accentStart = orange;
  static const accentGradient = orangeGradient;
  static const statusGreen = success;
  static const statusRed = danger;
  static const statusAmber = warning;
  static const statusBlue = info;
  static const surface = bgCard;
}

// ─────────────────────────────────────────────────────────────────
// TEXT STYLES — Strict hierarchy using Barlow (professional, techy)
// ─────────────────────────────────────────────────────────────────
abstract final class AppTextStyles {
  // Display Large — screen headlines
  static const displayLarge = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Display Medium — section titles
  static const displayMedium = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Title Large — card headers
  static const titleLarge = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Title Medium — sub-headers, labels
  static const titleMedium = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Large — primary body text
  static const bodyLarge = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  // Body Medium — secondary descriptions, details
  static const bodyMedium = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label — uppercase metadata, badges
  static const label = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
    height: 1.2,
  );

  // Numeric — stats, counters
  static const numeric = TextStyle(
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w800,
    fontSize: 28,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    height: 1,
  );
}

// ─────────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.cobalt,
        surface: AppColors.bgCard,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Barlow',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Barlow',
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Barlow',
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: TextStyle(
          fontFamily: 'Barlow',
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCard,
        selectedColor: AppColors.orange.withOpacity(0.15),
        labelStyle: AppTextStyles.bodyMedium,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}