import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography: Playfair Display for display headings, Inter for body.
/// Google Fonts falls back gracefully; Arabic uses a system Arabic face so
/// legibility is preserved (Latin display fonts are not forced on Arabic).
class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme(TextTheme base, {required bool isArabic}) {
    // For Arabic, prefer a highly-legible sans face across the board rather
    // than a Latin serif display font that renders Arabic poorly.
    final TextTheme display = isArabic
        ? GoogleFonts.cairoTextTheme(base)
        : GoogleFonts.playfairDisplayTextTheme(base);
    final TextTheme body =
        isArabic ? GoogleFonts.cairoTextTheme(base) : GoogleFonts.interTextTheme(base);

    return base.copyWith(
      displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: display.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: body.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: body.bodyLarge,
      bodyMedium: body.bodyMedium,
      bodySmall: body.bodySmall,
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
