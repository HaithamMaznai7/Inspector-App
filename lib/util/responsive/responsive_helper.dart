import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// Returns a value based on the current screen size breakpoint.
  /// Falls back: desktop → tablet → mobile.
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return desktop ?? tablet ?? mobile;
    if (width >= 600) return tablet ?? mobile;
    return mobile;
  }

  /// Returns a fraction of the screen width.
  static double scaledWidth(BuildContext context, double fraction) =>
      MediaQuery.sizeOf(context).width * fraction;

  /// Returns a fraction of the screen height.
  static double scaledHeight(BuildContext context, double fraction) =>
      MediaQuery.sizeOf(context).height * fraction;
}
