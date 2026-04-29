import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StageSelector extends StatelessWidget {
  const StageSelector({super.key});

  /// Determine which UI state to show:
  /// 1 = not started (pending/accepted) → "Start Inspection"
  /// 2 = in progress but hasn't reached last step → Edit only
  /// 3 = reached last step → Edit + Submit
  static int _resolveState(InspectionDetailsController controller) {
    final stage = controller.inspection.value!.stage;
    final inspection = controller.inspection.value!;

    if ([InspectionStage.pending, InspectionStage.accepted].contains(stage)) {
      return 1;
    }

    // Two scenarios:
    // Regular (has OBD) → last step is obd
    // Sahrej (no OBD)   → last step is photos
    final lastStep = inspection.hasObd
        ? InspectionStage.obd
        : InspectionStage.photos;

    if (stage == lastStep) {
      return 3;
    }

    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (controller) {
        final isLoading = controller.isLoading.value;

        if (isLoading || controller.inspection.value == null) {
          return const SizedBox();
        }

        final canInspect = controller.inspection.value!.stage.canEdit;

        if (!canInspect) {
          return const SizedBox();
        }

        final isSubmitting = controller.isSubmitting.value;
        final state = _resolveState(controller);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            child: isSubmitting
                ? Container(
                    decoration: BoxDecoration(
                      gradient: FColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusMd,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                    height: FDeviceUtils.getBottomNavigationBarHeight(),
                    width: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(color: FColors.white),
                    ),
                  )
                : state == 1
                // ── State 1: Start Inspection ──
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.openEditing,

                      label: Text(InspectionPage.startInspection.tr),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                    ),
                  )
                // ── State 2: Edit only (not on last step yet) ──
                : state == 2
                ? SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.openEditing,
                      icon: const Icon(Iconsax.edit_2, size: FSizes.iconSm),
                      label: Text(FTexts.editBtn.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FColors.primaryColor,
                        side: const BorderSide(color: FColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            FSizes.borderRadiusMd,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                    ),
                  )
                // ── State 3: Edit + Submit ──
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.openEditing,
                          icon: const Icon(Iconsax.edit_2, size: FSizes.iconSm),
                          label: Text(FTexts.editBtn.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FColors.primaryColor,
                            side: const BorderSide(color: FColors.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                FSizes.borderRadiusMd,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                          ),
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      Expanded(
                        // Reactive on connectivity + OBD code state so the
                        // button greys out the moment the device goes offline
                        // or any code becomes incomplete.
                        child: Obx(() {
                          final canFinish = controller.canFinish;
                          return ElevatedButton.icon(
                            onPressed: canFinish
                                ? () => controller.setSatge(
                                    InspectionStage.finished,
                                  )
                                : null,
                            icon: const Icon(
                              Iconsax.tick_circle,
                              size: FSizes.iconSm,
                            ),
                            label: Text(FTexts.submitBtn.tr),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: FSizes.md,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
