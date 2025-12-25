import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class FHelper {
  FHelper._();

  static Color? getColor(String value){
    /// Define your product specific colors here and it will match the attribute colors and show specific \u001b[32mThis is green\u001b[0m
    if(value == 'green'){
      return Colors.green;
    }else if(value == 'yellow'){
      return Colors.amberAccent;
    }else if(value == 'grey'){
      return Colors.grey;
    }else if(value == 'black'){
      return Colors.black26;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else if(value == 'Green'){
      return Colors.green;
    }else{
      return Colors.black;
    }
  }
  
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static getSnackBar({required String message,required Color color,IconData? icon, int duration = 15 }){
    Get.rawSnackbar(
      messageText: Text(
          message,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal'
          )
      ),
      duration: Duration(seconds: duration),
      backgroundColor: color,
      icon: Icon(icon,color: Colors.white,size: 35,),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static getSnackBarWithBtn({required String message,required Color color,IconData? icon,required String btnTitle,required Callback callback}){
    Get.rawSnackbar(
      messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          )
      ),
      duration: const Duration(days: 1),
      backgroundColor: color,
      icon: Icon(icon,color: Colors.white,size: 35,),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
      mainButton: Container(
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(onPressed: () => callback, child: Text(btnTitle)),
      ),
    );
  }
  
  static void showAlert(String title, String message){
    showDialog(
        context: Get.context!,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
              )
            ],
          );
        }
    );
  }
  
  static void navigateToScreen(BuildContext context, Widget screen){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
    );
  }
  
  static String truncateText(String text,int maxLength){
    if(text.length <= maxLength){
      return text;
    }else{
      return '${text.substring(0, maxLength)}...';
    }
  }
  
  static isDarkMode(BuildContext? context){
    return Theme.of(context ?? Get.context!).brightness == Brightness.dark;
  }
  
  static Size screenSize(){
    return MediaQuery.of(Get.context!).size ;
  }

  static double screenHeight(){
    return MediaQuery.of(Get.context!).size.height ;
  }

  static double screenWidth(){
    return MediaQuery.of(Get.context!).size.width ;
  }

  static List<T> removeDuplicates<T>(List<T> list){
    return list.toSet().toList();
  }
  
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize){
    final wrappedList = <Widget>[];
    for(var i = 0; i < widgets.length; i+= rowSize){
      final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }

  static String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        '1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)]).join();

    return randomString;
  }
}