import 'package:fahis_inspector/features/inspection_photos/components/editing_screen.dart';
import 'package:fahis_inspector/features/inspection_photos/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Photo section displayed inside the inspection steps screen.
///
/// Layout:
/// - Header: title + count badge + manage button
/// - Uploaded photos shown as a 3-column grid with thumbnails
/// - "Add Photo" button opens a bottom sheet with available photo slots
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
            return const Center(child: CircularProgressIndicator());
          }

          final uploaded = allPhotos.where((p) => p.image != null).toList();
          final available = allPhotos.where((p) => p.image == null).toList();
          final uploadedCount = uploaded.length;
          final totalCount = allPhotos.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(FSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
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
                    if (totalCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$uploadedCount / $totalCount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: FColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Get.to(() => InspectionPhotosScreen()),
                      icon: const Icon(Iconsax.setting_4, size: 16),
                      label: Text(InspectionPage.inspectionPhotos.tr),
                      style: TextButton.styleFrom(
                        foregroundColor: FColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // ── Uploaded photos grid ──
                if (uploaded.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: uploaded.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: FSizes.sm,
                      crossAxisSpacing: FSizes.sm,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final photo = uploaded[index];
                      return _UploadedPhotoTile(
                        photo: photo,
                        onTap: () => _showFullImage(context, photo),
                      );
                    },
                  ),
                  const SizedBox(height: FSizes.md),
                ],

                // ── Empty state ──
                if (uploaded.isEmpty && available.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: FSizes.xl),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Iconsax.camera, size: 48, color: FColors.grey.withValues(alpha: 0.35)),
                          const SizedBox(height: FSizes.sm),
                          Text(
                            InspectionPage.noPhotosYet.tr,
                            style: Theme.of(context).textTheme.bodyMedium?.apply(color: FColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── "Add Photo" button ──
                if (available.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAvailablePhotos(context, available, controller),
                      icon: const Icon(Iconsax.add_circle, size: 20),
                      label: Text(InspectionPage.addPhoto.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FColors.primaryColor,
                        side: BorderSide(color: FColors.primaryColor.withValues(alpha: 0.35)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  /// Opens a full-screen image viewer for the given photo.
  static void _showFullImage(BuildContext context, Photo photo) {
    final imageUrl = photo.image!;
    final imageProvider = NetworkImage(
      imageUrl.startsWith('//') ? 'https:$imageUrl' : imageUrl,
    );
    showImageViewer(context, imageProvider, useSafeArea: true, swipeDismissible: true);
  }

  /// Bottom sheet listing available photo slots the user can capture.
  static void _showAvailablePhotos(
    BuildContext context,
    List<Photo> photos,
    InspectionPhotosController controller,
  ) {
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
                color: FColors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: FColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                      ),
                      child: const Icon(Iconsax.camera, color: FColors.primaryColor, size: 20),
                    ),
                    title: Text(photo.title, style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Text(
                      photo.type,
                      style: Theme.of(context).textTheme.bodySmall?.apply(color: FColors.grey),
                    ),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: FColors.grey),
                    onTap: () {
                      Get.back();
                      controller.picking(photo);
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

/// A single uploaded photo tile in the grid.
/// Shows the thumbnail with a subtle green check badge and the title below.
class _UploadedPhotoTile extends StatelessWidget {
  const _UploadedPhotoTile({required this.photo, required this.onTap});

  final Photo photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  child: Image.network(
                    photo.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: FColors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: const Icon(Iconsax.image, color: FColors.grey, size: 28),
                    ),
                  ),
                ),
                // Green check badge
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: FColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            photo.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
