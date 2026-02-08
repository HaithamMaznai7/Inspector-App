import '../../constants/colors.dart';
import 'package:flutter/material.dart';

class FCheckBoxTheme{
  FCheckBoxTheme._();

  static CheckboxThemeData lightTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if(states.contains(WidgetState.selected)){
        return Colors.white;
      }else{
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if(states.contains(WidgetState.selected)){
        return FColors.primaryColor;
      }else{
        return Colors.transparent;
      }
    }),
  );
  static CheckboxThemeData darkTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if(states.contains(WidgetState.selected)){
        return Colors.white;
      }else{
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if(states.contains(WidgetState.selected)){
        return FColors.primaryColor;
      }else{
        return Colors.transparent;
      }
    }),
  );
}