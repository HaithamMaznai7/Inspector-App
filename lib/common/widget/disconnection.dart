/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';

class Disconnection {
  Widget disconnection(){
    return Center();
  }
  Widget getDisconnection(String route, BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/No_Connect.png',height: 100,width: 100,),
            Text('It seems You are not connection to the Internet,'),
            Text('Please check from Your connection.'),
            ElevatedButton(onPressed: () {
              Get.toNamed(route);
            }, child: Container(
              width: 100,
              height: 40,
              color: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ))
          ],
        ),
      ),
    );
  }
}*/
