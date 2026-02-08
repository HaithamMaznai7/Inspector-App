import 'routes.dart';
import 'util/localization/localization.dart';
import 'util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Boot extends StatelessWidget {
  const Boot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fahis for inspectors',
      translations: FLocalization(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en'),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      initialRoute: AppRoute.INITIAL,
      getPages: AppRoute.route,
    );
  }
}
