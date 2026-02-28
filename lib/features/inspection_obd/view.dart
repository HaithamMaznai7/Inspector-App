import 'package:fahis_inspector/features/inspection_obd/controller.dart';
import 'package:fahis_inspector/common/widgets/skeletons/skeleton.dart';
import 'package:fahis_inspector/features/inspection_obd/components/card.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OBDCodesView extends StatelessWidget {
  const OBDCodesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.lg,
        ),
        child: Column(
          children: [
            Card(
              color: isDark ? FColors.darkGrey : FColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: GetBuilder<InspectionObdController>(
                init: InspectionObdBinding().instance,
                autoRemove: false,
                builder: (controller) {
                  String? file = controller.report.value;
                  bool isUpload = controller.isUpload.value;
                  final isBusy = isUpload || controller.isLoading.value;

                  final isReport = controller.report.value != null;

                  return AbsorbPointer(
                    absorbing: isBusy,
                    child: Opacity(
                      opacity: isBusy ? 0.6 : 1.0,
                      child: Container(
                        padding: EdgeInsets.all(FSizes.sm),
                        decoration: BoxDecoration(
                          color: FColors.primaryColor.withOpacity(
                            isReport ? 1 : .4,
                          ),
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                        child: Row(
                          children: [
                            isUpload
                                ? CircularProgressIndicator(color: FColors.white)
                                : CircleAvatar(
                                    backgroundColor: FColors.white,
                                    child: IconButton(
                                      onPressed: controller.pickReport,
                                      icon: Icon(
                                        Iconsax.attach_square,
                                        color: FColors.primaryColor,
                                      ),
                                    ),
                                  ),
                            SizedBox(width: FSizes.md),
                            if (file != null)
                              CircleAvatar(
                                backgroundColor: FColors.white,
                                child: IconButton(
                                  onPressed: () => controller.openReport(),
                                  icon: Icon(
                                    Iconsax.eye,
                                    color: FColors.primaryColor,
                                  ),
                                ),
                              ),
                            SizedBox(width: FSizes.md),
                            Expanded(
                              child: Text(
                                isReport ? InspectionPage.obdFileName.tr : InspectionPage.uploadObdReport.tr,
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (file != null)
                              CircleAvatar(
                                backgroundColor: FColors.white,
                                child: IconButton(
                                  onPressed: () => controller.deleteReport(),
                                  icon: Icon(Iconsax.trash, color: FColors.error),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: FSizes.spaceBtwItems),

            Card(
              color: isDark ? FColors.darkGrey : FColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              child: Padding(
                padding: EdgeInsets.all(FSizes.sm),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: FColors.primaryColor,
                        borderRadius: BorderRadius.circular(
                          FSizes.cardRadiusMd,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: FSizes.sm,
                          vertical: FSizes.sm,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: FColors.white,
                              child: IconButton(
                                onPressed: () => InspectionObdBinding().instance.onCreateEdit(),
                                icon: Icon(
                                  Iconsax.add,
                                  color: FColors.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: FSizes.md),
                            Text(
                              InspectionPage.obdCodesTitle.tr,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GetBuilder<InspectionObdController>(
                      init: InspectionObdBinding().instance,
                      autoRemove: false,
                      builder: (controller) {
                        List<OBDCode> codes = controller.codes.value;
                        final isLoading = controller.isLoading.value;
 
                        if (isLoading) {
                          return ListTile(
                            leading: Skeleton(
                              color: FColors.primaryGradientColor,
                              height: FSizes.iconInlineSm,
                              width: FSizes.iconInlineSm,
                            ),
                            title: Skeleton(
                              color: FColors.primaryGradientColor,
                              height: 20,
                            ),
                          );
                        }

                        if (codes.isNotEmpty) {
                          return Column(
                            children: [
                              SizedBox(height: FSizes.sm),
                              ...codes.map((code) => OBDCodeCard(code: code)),
                            ],
                          );
                        }
                        

                        return ListTile(
                          title: Text(
                            'No data found',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: FColors.primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
