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
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
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
                          icon: const Icon(Iconsax.play, size: 20),
                          label: Text(InspectionPage.startInspection.tr),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      )
                    // ── State 2: Edit only (not on last step yet) ──
                    : state == 2
                        ? SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.openEditing,
                              icon: const Icon(Iconsax.edit_2, size: 18),
                              label: Text(FTexts.editBtn.tr),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: FColors.primaryColor,
                                side: const BorderSide(color: FColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          )
                        // ── State 3: Edit + Submit ──
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: controller.openEditing,
                                  icon: const Icon(Iconsax.edit_2, size: 18),
                                  label: Text(FTexts.editBtn.tr),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: FColors.primaryColor,
                                    side: const BorderSide(color: FColors.primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: FSizes.md),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.setSatge(InspectionStage.finished),
                                  icon: const Icon(Iconsax.send_1, size: 18),
                                  label: Text(FTexts.submitBtn.tr),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
          ),
        );
      },
    );
  }

}
