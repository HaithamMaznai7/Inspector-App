import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/localization/arabic.dart';
import 'package:fahis_inspector/util/localization/english.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': _Local.en,
    'ar': _Local.ar,
  };

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

  static Widget themeMode() {
    return IconButton(
      icon: Icon(
        (FLocalization.isLight ? Iconsax.moon : Iconsax.sun_1),
        color: FColors.primaryColor,
        size: 20,
      ),
      tooltip: 'change Language',
      onPressed: () => changeTheme(),
    );
  }

  static changeLocale() {
    Auth.local = isArabic ? 'en' : 'ar';
  }

  static changeTheme() {
    if (isLight) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  static bool get isArabic => Auth.local == 'ar';
  static bool get isLight => !Get.isDarkMode;
}

class _Local {
  static Map<String, String> en = English.en;
  static Map<String, String> ar = Arabic.ar;
}
