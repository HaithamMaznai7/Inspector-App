import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NotMoreInspections extends StatelessWidget {
  const NotMoreInspections({super.key});

  @override
  Widget build(BuildContext context) {
    InspectionsController controller = InspectionsBinding().instance;
    return Column(
      children: [
        Card(
          color: Colors.white24,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FSizes.md),
            child: Center(
              child: Text(
                HomePage.noMore.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        Center(
          child: IconButton(
            onPressed: () async => await controller.refreshPage(),
            icon: Icon(Iconsax.refresh, color: FColors.primaryColor),
          ),
        ),
      ],
    );
  }
}
