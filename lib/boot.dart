import 'routes.dart';
import 'services/connection/offline_status_bar.dart';
import 'util/localization/localization.dart';
import 'util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Boot extends StatelessWidget {
  const Boot({super.key});

  @override
  Widget build(BuildContext context) {
    // AppSettings box is pre-opened in main() — read synchronously.
    final box = Hive.box('AppSettings');
    final lang = box.get('locale', defaultValue: 'ar') as String;
    final locale = Locale(lang);
    final themeString = box.get('themeMode', defaultValue: 'system') as String;
    final themeMode = switch (themeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return GetMaterialApp(
      title: 'Fahis for inspectors',
      translations: FLocalization(),
      locale: locale,
      fallbackLocale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: FAppTheme.lightTheme,
      darkTheme: FAppTheme.darkTheme,
      initialRoute: AppRoute.initial,
      getPages: AppRoute.route,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                const SafeArea(bottom: false, child: OfflineStatusBar()),
                Expanded(child: child ?? const SizedBox()),
              ],
            ),
          ),
        );
      },
    );
  }
}
