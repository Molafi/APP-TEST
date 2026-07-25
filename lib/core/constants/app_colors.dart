import 'package:flutter/material.dart';

/// Botanical palette. Shades are tuned for accessible contrast in both light
/// and dark modes. State is never communicated by colour alone anywhere in the
/// UI — colours are always paired with an icon or text label.
class AppColors {
  const AppColors._();

  static const Color forestGreen = Color(0xFF1B3A2D);
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color leafGreenDark = Color(0xFF2E7D32);
  static const Color soilAmber = Color(0xFF8B6914);
  static const Color soilAmberLight = Color(0xFFB4922E);
  static const Color parchment = Color(0xFFF5F0E8);
  static const Color parchmentDark = Color(0xFFE7DEC9);
  static const Color mossGray = Color(0xFF6B7B6A);
  static const Color errorRed = Color(0xFFB00020);
  static const Color darkSurface = Color(0xFF243D2F);
  static const Color darkSurfaceAlt = Color(0xFF2C4A38);

  // Confidence / likelihood accents (always paired with a text label + icon).
  static const Color confidenceLow = Color(0xFFC0392B);
  static const Color confidenceMedium = Color(0xFFB4922E);
  static const Color confidenceHigh = Color(0xFF2E7D32);
}
