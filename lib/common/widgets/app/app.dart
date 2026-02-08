import 'package:fahis_inspector/boot/app_service_provider.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fahis'),
          ],
        ),
      ),
    );
  }
}
