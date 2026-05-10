import 'package:hive_flutter/hive_flutter.dart';

/// Central access point for all Hive boxes.
///
/// Box names are defined as constants here so every feature uses the same
/// strings. Call the static helpers instead of raw [Hive.openBox] calls.
class HiveService {
  HiveService._();

  // ── Box name constants ────────────────────────────────────────────────────

  static const _kSettings = 'AppSettings';
  static const _kAuth = 'Auth';
  static const _kAssets = 'Assets';
  static const _kInspections = 'Inspections';
  static const _kNotifications = 'Notifications';

  // ── Standard boxes ────────────────────────────────────────────────────────

  static Future<Box> get settingsBox async =>
      Hive.isBoxOpen(_kSettings)
          ? Hive.box(_kSettings)
          : await Hive.openBox(_kSettings);

  static Future<Box<List>> get authBox async =>
      Hive.isBoxOpen(_kAuth)
          ? Hive.box<List>(_kAuth)
          : await Hive.openBox<List>(_kAuth);

  static Future<Box<List>> get assetsBox async =>
      Hive.isBoxOpen(_kAssets)
          ? Hive.box<List>(_kAssets)
          : await Hive.openBox<List>(_kAssets);

  static Future<Box<List>> get inspectionsBox async =>
      Hive.isBoxOpen(_kInspections)
          ? Hive.box<List>(_kInspections)
          : await Hive.openBox<List>(_kInspections);

  static Future<Box> get notificationsBox async =>
      Hive.isBoxOpen(_kNotifications)
          ? Hive.box(_kNotifications)
          : await Hive.openBox(_kNotifications);

  // ── Dynamic boxes ─────────────────────────────────────────────────────────

  /// Per-inspection data keyed by slug (e.g. 'Inspection_abc123').
  static Future<Box> inspectionBox(String slug) {
    final name = 'Inspection_$slug';
    return Hive.isBoxOpen(name) ? Future.value(Hive.box(name)) : Hive.openBox(name);
  }

  /// Per-slug asset cache (photo thumbnails, points, etc.).
  static Future<Box<List>> assetsCacheBox(String slug) {
    return Hive.isBoxOpen(slug)
        ? Future.value(Hive.box<List>(slug))
        : Hive.openBox<List>(slug);
  }

  /// Per-user inspection list (e.g. 'Inspections_User_uid123').
  static Future<Box<Map>> userInspectionsBox(String uid) {
    final name = 'Inspections_User_$uid';
    return Hive.isBoxOpen(name)
        ? Future.value(Hive.box<Map>(name))
        : Hive.openBox<Map>(name);
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  /// Clears all user-scoped boxes on logout. Keeps AppSettings intact.
  static Future<void> clearOnLogout() async {
    await Future.wait([
      (await authBox).clear(),
      (await assetsBox).clear(),
      (await inspectionsBox).clear(),
      (await notificationsBox).clear(),
    ]);
  }
}
