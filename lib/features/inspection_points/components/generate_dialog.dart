import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenerateDialog extends StatelessWidget {

  const GenerateDialog({ super.key });

   @override
   Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(InspectionPage.generatDialogTitle.tr, style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
        color: FColors.black
      )),
      content: Center(
        child: Text(InspectionPage.generatDialogContent.tr, style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
          color: FColors.darkGrey
        )),
      ),
      actions: [
        TextButton(
          child: Text(InspectionPage.generatDialogConfirmBtn.tr, style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
            color: FColors.error
          )),
          onPressed: () => Get.back(result: true),
        ),
        TextButton(
          child: Text(InspectionPage.generatDialogCancel.tr, style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
            color: FColors.darkerGrey
          )),
          onPressed: () => Get.back(result: false),
        )
      ],
    );
  }
}