import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors (from Chấm Công Trạm)
  static const Color primary = Color(0xFFCB2D2E);
  static const Color success = Color(0xFF1A6B5A);
  static const Color accent = Color(0xFFEB9B28);
  static const Color info = Color(0xFF1C4E6B);
  static const Color neutral = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFF8F4EE);
  static const Color background = Color(0xFFF8F4EE);
  static const Color white = Colors.white;

  static const Color danger = primary;

  // Point-specific Colors
  static const Color pointIncrease = success;
  static const Color pointDecrease = primary;
  static const Color pointNeutral = Color(0xFF888780);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFFAAAAAA);
  static const Color textOnPrimary = Colors.white;

  // Border & Divider
  static const Color border = Color(0xFFE0DAD4);
  static const Color divider = Color(0xFFECE8E2);

  // Card & Shadow
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000);

  // Status Colors
  static const Color statusActive = success;
  static const Color statusInactive = Color(0xFF888780);
  static const Color statusPending = accent;
  static const Color statusDanger = primary;

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8192F), Color(0xFFC8102E)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22876D), Color(0xFF1A6B5A)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC8102E), Color(0xFFF8F4EE)],
    stops: [0.0, 0.45],
  );
}
