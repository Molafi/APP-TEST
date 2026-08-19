import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Builds light and dark themes that preserve the botanical identity while
/// meeting accessible contrast requirements.
class AppTheme {
  const AppTheme._();

  static ThemeData light({required bool isArabic}) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.leafGreenDark,
      primary: AppColors.leafGreenDark,
      secondary: AppColors.soilAmber,
      error: AppColors.errorRed,
      surface: AppColors.parchment,
    );
    return _base(
      scheme,
      isArabic: isArabic,
    ).copyWith(scaffoldBackgroundColor: AppColors.parchment);
  }

  static ThemeData dark({required bool isArabic}) {
    const ColorScheme scheme = ColorScheme.dark(
      primary: AppColors.leafGreen,
      secondary: AppColors.soilAmberLight,
      surface: AppColors.darkSurface,
      error: AppColors.errorRed,
    );
    return _base(
      scheme,
      isArabic: isArabic,
    ).copyWith(scaffoldBackgroundColor: AppColors.forestGreen);
  }

  static ThemeData _base(ColorScheme scheme, {required bool isArabic}) {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );
    return base.copyWith(
      textTheme: AppTextStyles.textTheme(base.textTheme, isArabic: isArabic),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Accessible min height WITHOUT forcing infinite width (Size.fromHeight
          // sets width to infinity, which crashes buttons placed inside a Row).
          // Full-width auth buttons still stretch via their parent Column.
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: AppColors.mossGray,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
