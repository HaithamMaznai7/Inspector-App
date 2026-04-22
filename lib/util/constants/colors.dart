import 'package:flutter/material.dart';

class FColors {
  FColors._();

  // App Basic Colors
  static const Color primaryColor = Color(0xFFFF7D41);
  static const Color primarySuccessColor = Color(0xFF27B951);
  static const Color secondaryColor = Color(0xFFFFE24B);
  static const Color primaryGradientColor = Color(0xFFF56969);
  static const Color primaryGradientColorSuccess = Color(0xFF27B951);
  static const Color secondaryGradientColor = Color(0xFF382723);
  static const Color accent = Color(0xFFB0C7FF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [primaryColor, primaryGradientColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient primaryGradientColorSuccesss = LinearGradient(
    colors: [primaryGradientColorSuccess, primarySuccessColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF091747);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background Colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF292929);
  static const Color primaryBackground = Color(0xFFF3F5FF);
  static const Color secondaryBackground = Color(0xFF003145);

  // Background Container Colors
  static const Color lightContainer = Color(0xFFF4F1eB);
  static Color darkContainer = FColors.white.withValues(alpha: 0.1);

  // Button Colors
  static const Color buttonPrimary = Color(0xFFF56969);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisable = Color(0xFFC4C4C4);

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and Validation Colors
  static const Color error = Color(0xFFCF2828);
  static const Color success = Color(0xFF27B951);
  static const Color warning = Color(0xFFFAB515);
  static const Color info = Color(0xFF1976D2);

  // Error and Validation Colors
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFF4F1EB);
}
