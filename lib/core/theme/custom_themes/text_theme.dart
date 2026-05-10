import 'package:flutter/material.dart';
import 'package:fahis_inspector/core/constants/app_sizes.dart';

class FTextTheme {
  FTextTheme._();

  static TextTheme lightTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeXxl, fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeXl, fontWeight: FontWeight.w600, color: Colors.black),
    headlineSmall: const TextStyle().copyWith(fontSize: FSizes.fontSizeLg, fontWeight: FontWeight.w600, color: Colors.black),

    titleLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w600, color: Colors.black),
    titleMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w500, color: Colors.black),
    titleSmall: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w400, color: Colors.black),

    bodyLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.w500, color: Colors.black),
    bodyMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.normal, color: Colors.black),
    bodySmall: TextStyle(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.w500, color: Colors.black.withValues(alpha: 0.5)),

    labelLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeXs, fontWeight: FontWeight.normal, color: Colors.black),
    labelMedium: TextStyle(fontSize: FSizes.fontSizeXs, fontWeight: FontWeight.normal, color: Colors.black.withValues(alpha: 0.5)),
  );

  static TextTheme darkTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeXxl, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeXl, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: const TextStyle().copyWith(fontSize: FSizes.fontSizeLg, fontWeight: FontWeight.w600, color: Colors.white),

    titleLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w600, color: Colors.white),
    titleMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w500, color: Colors.white),
    titleSmall: const TextStyle().copyWith(fontSize: FSizes.fontSizeMd, fontWeight: FontWeight.w400, color: Colors.white),

    bodyLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.w500, color: Colors.white),
    bodyMedium: const TextStyle().copyWith(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle(fontSize: FSizes.fontSizeSm, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5)),

    labelLarge: const TextStyle().copyWith(fontSize: FSizes.fontSizeXs, fontWeight: FontWeight.normal, color: Colors.white),
    labelMedium: TextStyle(fontSize: FSizes.fontSizeXs, fontWeight: FontWeight.normal, color: Colors.white.withValues(alpha: 0.5)),
  );
}
