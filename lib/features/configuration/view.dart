import 'package:fahis_inspector/features/configuration/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingBinding().instance;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.xs,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Obx(() => AnimatedOpacity(
                      opacity: controller.isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: TextButton(
                        onPressed:
                            controller.isLastPage ? null : controller.skipPage,
                        style: TextButton.styleFrom(
                          foregroundColor: FColors.textSecondary,
                        ),
                        child: Text(
                          FTexts.skip.tr,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: FColors.textSecondary,
                                  ),
                        ),
                      ),
                    )),
              ),
            ),

            // ── Page content ──
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
                  _OnBoardingContent(
                    icon: Iconsax.task_square,
                    title: OnBoardingTexts.onBoardingTitle1,
                    subTitle: OnBoardingTexts.onBoardingSubTitle1,
                  ),
                  _OnBoardingContent(
                    icon: Iconsax.scan,
                    title: OnBoardingTexts.onBoardingTitle2,
                    subTitle: OnBoardingTexts.onBoardingSubTitle2,
                  ),
                  _OnBoardingContent(
                    icon: Iconsax.notification,
                    title: OnBoardingTexts.onBoardingTitle3,
                    subTitle: OnBoardingTexts.onBoardingSubTitle3,
                  ),
                ],
              ),
            ),

            // ── Bottom controls ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                FSizes.defaultSpace,
                0,
                FSizes.defaultSpace,
                MediaQuery.of(context).padding.bottom + FSizes.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotIndicators(controller: controller),
                  const SizedBox(height: FSizes.xl),
                  _NextButton(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Per-page content ────────────────────────────────────────────────────────

class _OnBoardingContent extends StatelessWidget {
  const _OnBoardingContent({
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  final IconData icon;
  final String title, subTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Decorative icon ──
          _GradientIconCircle(icon: icon),

          const SizedBox(height: 48),

          // ── Title ──
          Text(
            title.tr,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : FColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: FSizes.md),

          // ── Subtitle ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
            child: Text(
              subTitle.tr,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? FColors.darkGrey : FColors.textSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─── Gradient icon with decorative rings ─────────────────────────────────────

class _GradientIconCircle extends StatelessWidget {
  const _GradientIconCircle({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FColors.primaryColor.withOpacity(0.08),
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: FColors.primaryColor.withOpacity(0.12),
        ),
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: FColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: FColors.primaryColor.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 52, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Animated dot indicators ─────────────────────────────────────────────────

class _DotIndicators extends StatelessWidget {
  const _DotIndicators({required this.controller});
  final OnBoardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            OnBoardingController.totalPages,
            (i) {
              final isActive = controller.currentPageIndex.value == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? FColors.primaryColor
                      : FColors.primaryColor.withOpacity(0.2),
                ),
              );
            },
          ),
        ));
  }
}

// ─── Full-width gradient button ──────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({required this.controller});
  final OnBoardingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLast = controller.isLastPage;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: FColors.primaryGradient,
            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: FColors.primaryColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.buttonRadius),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Row(
                key: ValueKey(isLast),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'getStarted'.tr : FTexts.nextBtn.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 8),
                    Icon(
                      FLocalization.isArabic
                          ? Iconsax.arrow_left_2
                          : Iconsax.arrow_right_3,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
