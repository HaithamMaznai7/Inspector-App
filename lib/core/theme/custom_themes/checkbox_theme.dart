import 'package:flutter/material.dart';
import 'package:fahis_inspector/core/constants/app_colors.dart';

class FCheckBoxTheme {
  FCheckBoxTheme._();

  static CheckboxThemeData lightTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return Colors.black;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return FColors.primaryColor;
      return Colors.transparent;
    }),
  );

  static CheckboxThemeData darkTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return Colors.black;
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return FColors.primaryColor;
      return Colors.transparent;
    }),
  );
}
