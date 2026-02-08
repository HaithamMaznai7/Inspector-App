import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StageSelector extends StatelessWidget {
  const StageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (controller) {
        final isloading = controller.isLoading.value;

        if (isloading) {
          return SizedBox();
        }

        final canInspect = controller.inspection.value!.stage.canEdit;
        
        if(! canInspect){
          return SizedBox();
        }

        final isSubmitting = controller.isSubmitting.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: FDeviceUtils.getScreenWidth() * .9,
              child: isSubmitting 
                ? Container(
                    decoration: BoxDecoration(
                      color: FColors.primaryColor,
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusMd,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: FSizes.sm),
                    height: FDeviceUtils.getBottomNavigationBarHeight(),
                    width: FDeviceUtils.getScreenWidth() * .9,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: FColors.white,
                      ),
                    ),
                  )        
                : Expanded(
                    child: ElevatedButton(
                      onPressed: controller.openEditing,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: FSizes.md,
                        ),
                        child: Text('Inspect'),
                      ),
                    ),
                  )
            )
          ),
        );
      },
    );
  }
}
