import 'package:flutter/material.dart';
import 'package:fahis_inspector/core/constants/app_colors.dart';

class FBottomSheetTheme {
  FBottomSheetTheme._();

  static BottomSheetThemeData lightTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: FColors.white,
    modalBackgroundColor: FColors.white,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static BottomSheetThemeData darkTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: FColors.dark,
    modalBackgroundColor: Colors.black,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}
