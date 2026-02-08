import '../constants/colors.dart';
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/bottom_sheet_theme.dart';
import 'custom_themes/checkbox_theme.dart';
import 'custom_themes/chip_theme.dart';
import 'custom_themes/elevated_button_theme.dart';
import 'custom_themes/outlined_button_theme.dart';
import 'custom_themes/text_field_theme.dart';
import 'custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class FAppTheme{
  FAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Tajawal',
    brightness: Brightness.light,
    primaryColor: FColors.primaryColor,
    textTheme: FTextTheme.lightTheme ,
    chipTheme: FChipTheme.lightTheme,
    scaffoldBackgroundColor: FColors.white,
    appBarTheme: FAppBarTheme.lightTheme,
    checkboxTheme: FCheckBoxTheme.lightTheme,
    bottomSheetTheme: FBottomSheetTheme.lightTheme,
    elevatedButtonTheme: FElevatedButtonTheme.lightTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.lightTheme,
    inputDecorationTheme: FTextFormFieldTheme.lightTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Tajawal',
    brightness: Brightness.dark,
    primaryColor: FColors.primaryColor,
    textTheme: FTextTheme.darkTheme ,
    chipTheme: FChipTheme.darkTheme,
    scaffoldBackgroundColor: FColors.dark,
    appBarTheme: FAppBarTheme.darkTheme,
    checkboxTheme: FCheckBoxTheme.darkTheme,
    bottomSheetTheme: FBottomSheetTheme.darkTheme,
    elevatedButtonTheme: FElevatedButtonTheme.darkTheme,
    outlinedButtonTheme: FOutlinedButtonTheme.darkTheme,
    inputDecorationTheme: FTextFormFieldTheme.darkTheme,
  );
}