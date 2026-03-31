import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';

class GradientIconCircle extends StatelessWidget {
  const GradientIconCircle({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final circleSize = ResponsiveHelper.responsiveValue<double>(
      context,
      mobile: 140.0,
      tablet: 200.0,
    );
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FColors.primaryColor.withValues(alpha: 0.08),
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FColors.primaryColor.withValues(alpha: 0.12),
        ),
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: FColors.primaryColor.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: FSizes.iconCircleLg, color: Colors.white),
        ),
      ),
    );
  }
}
