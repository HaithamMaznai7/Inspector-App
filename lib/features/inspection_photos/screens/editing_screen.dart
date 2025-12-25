import 'package:fahis_inspector/features/inspection_photos/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/screens/widgets/photo_card.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPhotosScreen extends StatelessWidget {
  InspectionPhotosScreen({super.key});
  final InspectionPhotosController controller = InspectionPhotosController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.category.value ?? 'الصور',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: FColors.white),
        ),
        centerTitle: true,
        backgroundColor: FColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            FLocalization.isArabic
                ? Iconsax.arrow_right_3
                : Iconsax.arrow_left_2,
            color: FColors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(FSizes.md),
        children: [
          // Horizontal Scrolling Choice Chips
          
          Obx(() {
              final category = controller.category.value;
              final categories = controller.categories.value;
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...categories.map((cat) {
                      final isSelected = category == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.sm * .5,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: isSelected
                                      ? FColors.white
                                      : FColors.primaryColor,
                                ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: FColors.primaryColor,
                          onSelected: (bool selected) {
                            controller.category.value = cat;
                            controller.update();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );

            }
          ),
          const SizedBox(height: FSizes.lg),

          // Vertical Scrolling Point Cards for Selected Category
          Obx(() {
              final all = controller.photos.value;
              final category = controller.category.value;

              final photos = all.where((p) => p.type == category).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: PhotoCard(photo: photo),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
