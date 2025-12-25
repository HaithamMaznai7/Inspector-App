import 'package:fahis_inspector/common/widget/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VehicleInfo extends StatelessWidget {
  const VehicleInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
      color: FColors.grey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.lg,
        ),
        child: GetBuilder<InspectionController>(
          init: Get.find<InspectionController>(),
          builder: (c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.user),
                    const SizedBox(width: FSizes.sm),
                    SizedBox(
                      width: FDeviceUtils.getScreenWidth() * .4,
                      child: Text(
                        '${c.inspection.value?.customer?.name}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      color: FColors.success,
                      icon: Icon(Iconsax.call),
                      onPressed: () async => await c.callToVehicleOwner(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Iconsax.call),
                    SizedBox(width: FSizes.sm),
                    TextButton(
                      child: Text(
                        '${c.inspection.value?.customer?.phone}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: c.inspection.value?.customer?.phone ?? ''));
                        FLoader.infoSnackBar(
                          title: 'Copied to Clipboard',
                          message: '${c.inspection.value?.customer?.phone} copied to clipboard!',
                          duration: 3,
                        );
                      },
                    ),
                    SizedBox(width: FSizes.sm),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.location),
                    const SizedBox(width: FSizes.sm),
                    SizedBox(
                      width: FDeviceUtils.getScreenWidth() * .4,
                      child: Text(
                        '${c.inspection.value?.customer?.city?.label}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
