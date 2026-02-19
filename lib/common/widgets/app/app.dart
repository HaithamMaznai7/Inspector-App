import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const Logo(height: 80)));
  }
}
