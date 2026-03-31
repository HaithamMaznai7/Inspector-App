import 'package:fahis_inspector/common/widgets/app/logo.dart';

import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [FLocalization.localizeIcon(), FLocalization.themeMode()],
      ),
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
                  const Spacer(flex: 2),

                  // ── Icon ──
                  // const GradientIconCircle(icon: Iconsax.profile_2user),
                  const Logo(height: FSizes.logoHeightLg),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  // ── Title ──
                  Text(
                    AccessRequestPage.welcomeTitle.tr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : FColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FSizes.sm),

                  // ── Subtitle ──
                  Text(
                    AccessRequestPage.welcomeSubtitle.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? FColors.darkGrey : FColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 3),

                  // ── Already a member (primary gradient button) ──
                  SizedBox(
                    width: double.infinity,
                    height: FSizes.buttonHeightLg,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: FColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          FSizes.buttonRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: FColors.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed(RoutingUrl.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              FSizes.buttonRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          AccessRequestPage.alreadyMember.tr,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: FSizes.md),

                  // ── Request membership (outlined button) ──
                  SizedBox(
                    width: double.infinity,
                    height: FSizes.buttonHeightLg,
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed(RoutingUrl.requestAccess),
                      child: Text(
                        AccessRequestPage.requestMembership.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + FSizes.lg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
