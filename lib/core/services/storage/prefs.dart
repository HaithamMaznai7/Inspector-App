import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Prefs._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Keys ──────────────────────────────────────────────────────────────────

  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kLocaleCode = 'locale_code';
  static const _kThemeMode = 'theme_mode';
  static const _kLastUserId = 'last_user_id';
  static const _kHiveMigrated = 'hive_migrated';
  static const _kHasLaunchedBefore = 'has_launched_before';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  static Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  // ── Locale ────────────────────────────────────────────────────────────────

  static String get localeCode => _prefs.getString(_kLocaleCode) ?? 'ar';
  static Future<void> setLocaleCode(String value) =>
      _prefs.setString(_kLocaleCode, value);

  // ── Theme ─────────────────────────────────────────────────────────────────

  /// Stored as 'light', 'dark', or 'system'.
  static String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  static Future<void> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  // ── Last User ─────────────────────────────────────────────────────────────

  static String? get lastUserId => _prefs.getString(_kLastUserId);
  static Future<void> setLastUserId(String value) =>
      _prefs.setString(_kLastUserId, value);
  static Future<void> clearLastUserId() => _prefs.remove(_kLastUserId);

  // ── First launch (iOS Keychain stale-token guard) ─────────────────────────

  static bool get hasLaunchedBefore =>
      _prefs.getBool(_kHasLaunchedBefore) ?? false;
  static Future<void> setHasLaunchedBefore() =>
      _prefs.setBool(_kHasLaunchedBefore, true);

  // ── Migration ─────────────────────────────────────────────────────────────

  /// One-time copy of locale and themeMode from old Hive 'AppSettings' box.
  /// Safe to call on every startup — skips silently after first run.
  static Future<void> migrateFromHive() async {
    if (_prefs.getBool(_kHiveMigrated) == true) return;
    try {
      final Box box = Hive.isBoxOpen('AppSettings')
          ? Hive.box('AppSettings')
          : await Hive.openBox('AppSettings');

      final locale = box.get('locale') as String?;
      final theme = box.get('themeMode') as String?;

      if (locale != null) await setLocaleCode(locale);
      if (theme != null) await setThemeMode(theme);
    } catch (_) {
      // Old box absent on fresh install — no action needed.
    }
    await _prefs.setBool(_kHiveMigrated, true);
  }
}
