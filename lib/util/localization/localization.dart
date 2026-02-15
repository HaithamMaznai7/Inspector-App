import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter/foundation.dart';

import '../constants/colors.dart';
import '../localization/arabic.dart';
import '../localization/english.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': _Local.en,
    'ar': _Local.ar,
  };

  // ── UI Widgets ──────────────────────────────────────────────────────

  /// Compact translate icon for app bars (login, reset password screens).
  static Widget localizeIcon() {
    return SizedBox(
      height: 40,
      width: 40,
      child: IconButton(
        icon: const Icon(
          Icons.translate,
          color: FColors.primaryColor,
          size: 20,
        ),
        onPressed: () => changeLocale(),
        tooltip: 'change Language',
      ),
    );
  }

  /// Theme toggle icon (light ↔ dark).
  static Widget themeMode() {
    return IconButton(
      icon: Icon(
        (FLocalization.isLight ? Iconsax.moon : Iconsax.sun_1),
        color: FColors.primaryColor,
        size: 20,
      ),
      tooltip: 'change Theme',
      onPressed: () => changeTheme(),
    );
  }

  // ── Locale Switching ────────────────────────────────────────────────

  static Future<void> changeLocale() async {
    final oldLang = Get.locale?.languageCode ?? 'ar';
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');

    // DEBUG: Log the language switch so we can trace issues.
    if (kDebugMode) {
      print('┌─── LANGUAGE SWITCH ───────────────────────');
      print('│ From: $oldLang → To: ${newLocale.languageCode}');
      print('│ Get.locale before: ${Get.locale}');
      print('└───────────────────────────────────────────');
    }

    // Update Firebase Auth language (for OTP SMS language).
    auth().firebase.setLanguageCode(newLocale.languageCode);

    // Update GetX locale — this triggers `.tr` string rebuilds across
    // the entire widget tree. All subsequent Network instances will
    // read the new locale from Get.locale for the Accept-Language header.
    await Get.updateLocale(newLocale);

    if (kDebugMode) {
      print('┌─── LANGUAGE SWITCH COMPLETE ──────────────');
      print('│ Get.locale after: ${Get.locale}');
      print(
        '│ Next API calls will send Accept-Language: ${newLocale.languageCode}',
      );
      print('└───────────────────────────────────────────');
    }
  }

  // ── Theme Switching ─────────────────────────────────────────────────

  static void changeTheme() {
    if (isLight) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────

  static bool get isArabic =>
      (Get.locale ?? Locale(auth().firebase.languageCode ?? 'ar'))
          .languageCode ==
      'ar';
  static bool get isLight => !Get.isDarkMode;
}

class _Local {
  static Map<String, String> en = English.en;
  static Map<String, String> ar = Arabic.ar;
}
