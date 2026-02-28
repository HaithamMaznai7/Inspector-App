import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const Logo(height: FSizes.logoHeightLg)));
  }
}
