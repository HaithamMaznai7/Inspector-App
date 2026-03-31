import 'package:fahis_inspector/common/widgets/components/gradient_icon_circle.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class RequestSuccessScreen extends StatelessWidget {
  const RequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 480 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 0 : FSizes.defaultSpace,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // ── Success icon ──
                    const GradientIconCircle(icon: Iconsax.tick_circle),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // ── Title ──
                    Text(
                      AccessRequestPage.requestSuccessTitle.tr,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : FColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FSizes.md),

                    // ── Subtitle ──
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: FSizes.sm),
                      child: Text(
                        AccessRequestPage.requestSuccessSubtitle.tr,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              isDark ? FColors.darkGrey : FColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ── Done button (gradient) ──
                    SizedBox(
                      width: double.infinity,
                      height: FSizes.buttonHeightLg,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: FColors.primaryGradient,
                          borderRadius:
                              BorderRadius.circular(FSizes.buttonRadius),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  FColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () =>
                              Get.offAllNamed(RoutingUrl.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(FSizes.buttonRadius),
                            ),
                          ),
                          child: Text(
                            AccessRequestPage.doneBtn.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom + FSizes.lg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
