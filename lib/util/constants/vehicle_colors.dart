import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A bilingual color option for vehicle exterior/interior pickers.
class VehicleColor {
  final String english;
  final String arabic;

  const VehicleColor({required this.english, required this.arabic});

  /// Returns the name in the app's current locale (Arabic or English).
  String get localizedName =>
      Get.locale?.languageCode == 'ar' ? arabic : english;
}

/// Static color lists and helpers for the vehicle color pickers.
abstract class VehicleColors {
  // ── Exterior colors ───────────────────────────────────────────────────────

  static const List<VehicleColor> exterior = [
    VehicleColor(english: 'White', arabic: 'أبيض'),
    VehicleColor(english: 'Pearl White', arabic: 'أبيض لؤلؤي'),
    VehicleColor(english: 'Black', arabic: 'أسود'),
    VehicleColor(english: 'Silver', arabic: 'فضي'),
    VehicleColor(english: 'Gray', arabic: 'رمادي'),
    VehicleColor(english: 'Dark Gray', arabic: 'رمادي داكن'),
    VehicleColor(english: 'Red', arabic: 'أحمر'),
    VehicleColor(english: 'Blue', arabic: 'أزرق'),
    VehicleColor(english: 'Navy Blue', arabic: 'أزرق داكن'),
    VehicleColor(english: 'Green', arabic: 'أخضر'),
    VehicleColor(english: 'Brown', arabic: 'بني'),
    VehicleColor(english: 'Beige', arabic: 'بيج'),
    VehicleColor(english: 'Gold', arabic: 'ذهبي'),
    VehicleColor(english: 'Yellow', arabic: 'أصفر'),
    VehicleColor(english: 'Orange', arabic: 'برتقالي'),
  ];

  // ── Interior colors ───────────────────────────────────────────────────────

  static const List<VehicleColor> interior = [
    VehicleColor(english: 'Black', arabic: 'أسود'),
    VehicleColor(english: 'Gray', arabic: 'رمادي'),
    VehicleColor(english: 'Light Gray', arabic: 'رمادي فاتح'),
    VehicleColor(english: 'Beige', arabic: 'بيج'),
    VehicleColor(english: 'Brown', arabic: 'بني'),
    VehicleColor(english: 'Cream', arabic: 'كريمي'),
    VehicleColor(english: 'Red', arabic: 'أحمر'),
    VehicleColor(english: 'White', arabic: 'أبيض'),
    VehicleColor(english: 'Black / Beige', arabic: 'أسود / بيج'),
    VehicleColor(english: 'Black / Red', arabic: 'أسود / أحمر'),
    VehicleColor(english: 'Camel', arabic: 'جملي'),
  ];

  // ── Approximate visual swatches ───────────────────────────────────────────

  static const Map<String, Color> swatches = {
    'White': Color(0xFFF2F2F2),
    'Pearl White': Color(0xFFEEE9E2),
    'Black': Color(0xFF1C1C1C),
    'Silver': Color(0xFFBDBDBD),
    'Gray': Color(0xFF757575),
    'Dark Gray': Color(0xFF424242),
    'Red': Color(0xFFCC2222),
    'Blue': Color(0xFF1565C0),
    'Navy Blue': Color(0xFF0A2070),
    'Green': Color(0xFF2E7D32),
    'Brown': Color(0xFF795548),
    'Beige': Color(0xFFF5F0DC),
    'Gold': Color(0xFFFFD700),
    'Yellow': Color(0xFFFFCC00),
    'Orange': Color(0xFFFF7D41),
    'Camel': Color(0xFFC19A6B),
    'Light Gray': Color(0xFFBDBDBD),
    'Cream': Color(0xFFFFF8E7),
    'Black / Beige': Color(0xFF1C1C1C),
    'Black / Red': Color(0xFF1C1C1C),
  };

  // ── Lookup helper ─────────────────────────────────────────────────────────

  /// Finds a [VehicleColor] from [list] by English name or Arabic name.
  /// Returns null when the stored value doesn't match any known color.
  static VehicleColor? find(List<VehicleColor> list, String value) {
    final t = value.trim();
    if (t.isEmpty) return null;
    try {
      return list.firstWhere(
        (c) => c.english.toLowerCase() == t.toLowerCase() || c.arabic == t,
      );
    } catch (_) {
      return null;
    }
  }
}
