import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Displays inspection photos in the review page.
/// Uploaded photos are shown first with a green check badge,
/// followed by pending (not yet captured) photos with a grey camera icon.
/// A progress bar shows how many photos have been uploaded out of total.
class InspectionPhotosReview extends StatelessWidget {
  const InspectionPhotosReview({super.key});

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null) {
      return const AssetImage('assets/images/placeholder.png');
    }
    if (imageUrl.startsWith('//s3')) {
      return NetworkImage('https:$imageUrl');
    }
    return NetworkImage(imageUrl);
  }

  void _showFullImage(BuildContext context, Photo photo) {
    if (photo.image != null) {
      showImageViewer(
        context,
        _getImageProvider(photo.image),
        swipeDismissible: true,
        doubleTapZoomable: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsBinding().instance,
      builder: (c) {
        final isLoading = c.isLoading.value;
        final inspection = c.inspection.value;

        if (inspection == null || isLoading) {
          return const SizedBox();
        }

        // Get photos from controller's assetsBox
        final photos = c.assetsBox?.get('Photos') as List?;
        final photosList = photos != null
            ? photos.map((item) => Photo.fromJson(Map<String, dynamic>.from(item))).toList()
            : <Photo>[];

        // Sort: uploaded first, then pending
        final uploaded = photosList.where((p) => p.image != null).toList();
        final pending = photosList.where((p) => p.image == null).toList();
        final sorted = [...uploaded, ...pending];

        final uploadedCount = uploaded.length;
        final totalCount = photosList.length;
        final progress = totalCount > 0 ? uploadedCount / totalCount : 0.0;

        return InfoCard(
          title: Text(InspectionPage.inspectionPhotos.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.camera,
          // Show progress badge in the subtitle
          subtitle: totalCount > 0
              ? Text(
                  InspectionPage.photosProgress.trParams({
                    'uploaded': uploadedCount.toString(),
                    'total': totalCount.toString(),
                  }),
                  style: Theme.of(context).textTheme.bodySmall?.apply(
                    color: uploadedCount == totalCount ? FColors.success : FColors.warning,
                  ),
                )
              : null,
          children: [
            if (photosList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(FSizes.md),
                child: Text(
                  InspectionPage.noPhotosYet.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.apply(color: FColors.grey),
                ),
              )
            else ...[
              // Progress bar
              Padding(
                padding: const EdgeInsets.only(bottom: FSizes.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: FColors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      uploadedCount == totalCount ? FColors.success : FColors.primaryColor,
                    ),
                  ),
                ),
              ),
              // Photo grid — uploaded first, then pending
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final photo = sorted[index];
                    final hasImage = photo.image != null;
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: FSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo thumbnail or pending placeholder
                          Expanded(
                            child: GestureDetector(
                              onTap: hasImage ? () => _showFullImage(context, photo) : null,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                    child: hasImage
                                        ? Image.network(
                                            photo.image!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                _pendingPlaceholder(),
                                          )
                                        : _pendingPlaceholder(),
                                  ),
                                  // Status badge — top-right corner
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: hasImage
                                            ? FColors.success
                                            : FColors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        hasImage ? Icons.check : Iconsax.camera,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          // Photo title
                          Text(
                            photo.title,
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                              fontWeightDelta: 2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Photo type
                          Text(
                            photo.type,
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                              color: FColors.grey,
                            ),
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
          ],
        );
      },
    );
  }

  /// Grey placeholder shown for photos that haven't been captured yet
  Widget _pendingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: FColors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
      ),
      child: const Center(
        child: Icon(Iconsax.camera, color: FColors.grey, size: 36),
      ),
    );
  }
}
