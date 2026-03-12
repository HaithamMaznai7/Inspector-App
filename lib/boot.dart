import 'routes.dart';
import 'util/localization/localization.dart';
import 'util/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Boot extends StatelessWidget {
  const Boot({super.key});

  /// Reads the cached locale from Hive, defaulting to Arabic.
  Future<Locale> _getCachedLocale() async {
    try {
      final box = await Hive.openBox('AppSettings');
      final lang = box.get('locale', defaultValue: 'ar') as String;
      return Locale(lang);
    } catch (_) {
      return const Locale('ar');
    }
  }

  /// Reads the cached theme mode from Hive, defaulting to system.
  Future<ThemeMode> _getCachedThemeMode() async {
    try {
      final box = await Hive.openBox('AppSettings');
      final themeString =
          box.get('themeMode', defaultValue: 'system') as String;
      switch (themeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (_) {
      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([_getCachedLocale(), _getCachedThemeMode()]).then(
        (results) => {
          'locale': results[0] as Locale,
          'themeMode': results[1] as ThemeMode,
        },
      ),
      builder: (context, snapshot) {
        final locale =
            snapshot.data?['locale'] as Locale? ?? const Locale('ar');
        final themeMode =
            snapshot.data?['themeMode'] as ThemeMode? ?? ThemeMode.system;
        return _buildApp(locale, themeMode);
      },
    );
  }

  Widget _buildApp(Locale locale, ThemeMode themeMode) {
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
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: child ?? const SizedBox(),
              ),
            ),
          ],
        );
      },
    );
  }
}
