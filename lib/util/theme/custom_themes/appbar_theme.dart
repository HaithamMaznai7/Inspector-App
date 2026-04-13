import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import 'package:flutter/material.dart';

class FAppBarTheme{
  FAppBarTheme._();

  static const lightTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: FColors.white,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: FSizes.iconMd),
    actionsIconTheme: IconThemeData(color: Colors.black, size: FSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: FSizes.fontSizeLg,fontWeight: FontWeight.w600,color: Colors.black),
  );
  static const darkTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: FColors.dark,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: FSizes.iconMd),
    actionsIconTheme: IconThemeData(color: Colors.white, size: FSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: FSizes.fontSizeLg,fontWeight: FontWeight.w600,color: Colors.white),
  );
}