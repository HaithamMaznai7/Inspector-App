import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepSelector extends StatelessWidget {
  const StepSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionStepsController>(
      init: InspectionStepsBinding().instance,
      builder: (controller) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: FDeviceUtils.getScreenWidth() * .9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: Theme.of(context)
                          .elevatedButtonTheme
                          .style!
                          .copyWith(
                            backgroundColor:
                                MaterialStateProperty.all(FColors.darkGrey),
                          ),
                      onPressed: () => controller.toPervious,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: FSizes.md,
                        ),
                        child: Text(controller.pervious.getLabel)
                      ),
                    )
                  ),

                  SizedBox(width: FSizes.spaceBtwItems),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.toNext,
                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: FSizes.md,
                        ),
                        child: Text(controller.next.getLabel)
                      ),
                    ),
                  )
                ],
              ),
            )
          ),
        );
      },
    );
  }
}
