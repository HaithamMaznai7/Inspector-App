import 'package:flutter/widgets.dart';
import 'package:fahis_inspector/core/theme/breakpoints.dart';

extension ResponsiveContext on BuildContext {
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= Breakpoints.tablet) return desktop ?? tablet ?? mobile;
    if (width >= Breakpoints.mobile) return tablet ?? mobile;
    return mobile;
  }
}
