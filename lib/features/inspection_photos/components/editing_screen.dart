import 'package:fahis_inspector/features/inspection_photos/components/photo_card.dart';
import 'package:fahis_inspector/features/inspection_photos/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:get/get.dart';

/// Full-screen editing view for inspection photos.
/// Shows category chips at the top to filter by photo type,
/// and a list of photo cards for the selected category.
/// Each card shows the photo title, upload status, and action buttons.
class InspectionPhotosScreen extends StatelessWidget {
  InspectionPhotosScreen({super.key});
  final InspectionPhotosController controller = InspectionPhotosBinding().instance;

  /// Localizes photo category names from backend
  String _localizeCategory(String? category) {
    if (category == null) return InspectionPage.photosTitle.tr;
    switch (category.toLowerCase()) {
      case 'exterior':
        return InspectionPage.photoCategoryExterior.tr;
      case 'interior':
        return InspectionPage.photoCategoryInterior.tr;
      default:
        return category; // fallback to original if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show the selected category name in the AppBar
        title: Obx(() => Text(
          _localizeCategory(controller.category.value),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: FColors.white,
          ),
        )),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        // "Done" button — pops back to the previous page
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: FSizes.sm),
            child: TextButton(
              onPressed: () => Get.back(),
              child: Text(
                InspectionPage.doneBtn.tr,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips with upload count badges
          Obx(() {
            final category = controller.category.value;
            final categories = controller.categories;
            final allPhotos = controller.photos;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: FColors.grey.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = category == cat;
                    // Count uploaded vs total for this category
                    final catPhotos = allPhotos.where((p) => p.type == cat).toList();
                    final catUploaded = catPhotos.where((p) => p.image != null).length;
                    final catTotal = catPhotos.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: FSizes.xs / 2),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_localizeCategory(cat)),
                            const SizedBox(width: FSizes.xs),
                            // Upload count badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : FColors.primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$catUploaded/$catTotal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : FColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : FColors.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: FColors.primaryColor,
                        backgroundColor: FColors.primaryColor.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: isSelected
                              ? FColors.primaryColor
                              : FColors.primaryColor.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                        onSelected: (_) {
                          controller.category.value = cat;
                          controller.update();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          // Photo cards list for the selected category
          // Sorted: uploaded first, then pending
          Expanded(
            child: Obx(() {
              final allPhotos = controller.photos;
              final category = controller.category.value;

              final catPhotos = allPhotos.where((p) => p.type == category).toList();
              // Sort: uploaded first, pending last
              final uploaded = catPhotos.where((p) => p.image != null).toList();
              final pending = catPhotos.where((p) => p.image == null).toList();
              final sorted = [...uploaded, ...pending];

              if (sorted.isEmpty) {
                return Center(
                  child: Text(
                    InspectionPage.noPhotosYet.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.apply(
                      color: FColors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(FSizes.md),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final photo = sorted[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: FSizes.sm),
                    child: PhotoCard(photo: photo),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
