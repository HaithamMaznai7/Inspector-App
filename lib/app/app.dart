import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    
    // await Auth.auth.reinit();

    return GetMaterialApp(
      title: 'Fahis for inspectors',
      translations: FLocalization(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale(Auth.local),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      initialRoute: RoutingUrl.home,
      getPages: AppRoute.route,
    );
  }
}
