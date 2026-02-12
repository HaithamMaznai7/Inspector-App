import 'package:fahis_inspector/features/inspection_photos/components/editing_screen.dart';
import 'package:fahis_inspector/features/inspection_photos/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Displays a compact photo summary section with:
/// - Header showing title + progress count
/// - Horizontal list of uploaded photo thumbnails
/// - A "+" card that opens a bottom sheet to pick a pending photo title,
///   then launches the camera to capture it
class AlbumPhotos extends StatelessWidget {
  const AlbumPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPhotosController>(
      init: InspectionPhotosBinding().instance,
      builder: (controller) {
        return Obx(() {
          final allPhotos = controller.photos;
          final isLoading = controller.isLoading.value;

          if (isLoading && allPhotos.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(FSizes.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final uploaded = allPhotos.where((p) => p.image != null).toList();
          final pending = allPhotos.where((p) => p.image == null).toList();
          final uploadedCount = uploaded.length;
          final totalCount = allPhotos.length;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: title + progress + manage button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
                  child: Row(
                    children: [
                      const Icon(Iconsax.camera, color: FColors.primaryColor, size: 22),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        InspectionPage.photosTitle.tr,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: FSizes.sm),
                      // Progress badge
                      if (totalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: uploadedCount == totalCount
                                ? FColors.success.withValues(alpha: 0.15)
                                : FColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Text(
                            '$uploadedCount / $totalCount',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: uploadedCount == totalCount
                                  ? FColors.success
                                  : FColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Manage all photos button
                      TextButton.icon(
                        onPressed: () => Get.to(() => InspectionPhotosScreen()),
                        icon: const Icon(Iconsax.setting_4, size: 18),
                        label: Text(InspectionPage.inspectionPhotos.tr),
                        style: TextButton.styleFrom(
                          foregroundColor: FColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FSizes.sm),

                // Horizontal photo strip: uploaded thumbnails + "add" card
                if (totalCount == 0)
                  Padding(
                    padding: const EdgeInsets.all(FSizes.md),
                    child: Center(
                      child: Text(
                        InspectionPage.noPhotosYet.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.apply(
                          color: FColors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
                      // uploaded thumbnails + 1 "add" card if there are pending photos
                      itemCount: uploaded.length + (pending.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Last item = "+" add card (only if pending photos exist)
                        if (index == uploaded.length) {
                          return _AddPhotoCard(
                            pendingCount: pending.length,
                            pendingPhotos: pending,
                            controller: controller,
                          );
                        }

                        // Uploaded photo thumbnail
                        final photo = uploaded[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: FSizes.sm),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                  child: Image.network(
                                    photo.image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: FColors.grey.withValues(alpha: 0.15),
                                      child: const Icon(Iconsax.image, color: FColors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                photo.title,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}

/// A "+" card shown at the end of the photo strip.
/// Tapping it opens a bottom sheet listing all pending (uncaptured) photo titles.
/// Selecting a title launches the camera to capture that specific photo.
class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({
    required this.pendingCount,
    required this.pendingPhotos,
    required this.controller,
  });

  final int pendingCount;
  final List<Photo> pendingPhotos;
  final InspectionPhotosController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPendingPicker(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: FSizes.sm),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: FColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  border: Border.all(
                    color: FColors.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.add_circle, color: FColors.primaryColor, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        '$pendingCount',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: FColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              InspectionPage.pendingPhotos.tr,
              style: Theme.of(context).textTheme.bodySmall?.apply(
                color: FColors.primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet listing all pending photo titles.
  /// User taps a title → camera opens → photo is captured for that title.
  void _showPendingPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: FSizes.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(FSizes.md),
              child: Text(
                InspectionPage.selectPhotoTitle.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            // Pending photo titles list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: pendingPhotos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final photo = pendingPhotos[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: FColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                      ),
                      child: const Icon(Iconsax.camera, color: FColors.primaryColor, size: 20),
                    ),
                    title: Text(
                      photo.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      photo.type,
                      style: Theme.of(context).textTheme.bodySmall?.apply(color: FColors.grey),
                    ),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: FColors.grey),
                    onTap: () {
                      Get.back(); // Close bottom sheet
                      controller.picking(photo); // Open camera
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + FSizes.md),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
