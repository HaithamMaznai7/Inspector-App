import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// A card representing a single inspection photo slot.
/// Shows the photo title, upload status (uploaded or pending),
/// a thumbnail (or camera placeholder), and action buttons.
class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key, required this.photo});
  final Photo photo;

  bool get _hasImage => photo.image != null || photo.file != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: FColors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: InkWell(
        onTap: () => InspectionPhotosBinding().instance.picking(photo),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.sm),
          child: Row(
            children: [
              // Thumbnail or camera placeholder
              _buildThumbnail(),
              const SizedBox(width: FSizes.md),
              // Title + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Status chip
                    Row(
                      children: [
                        Icon(
                          _hasImage ? Iconsax.tick_circle : Iconsax.camera,
                          size: 14,
                          color: _hasImage ? FColors.success : FColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _hasImage
                              ? InspectionPage.photoUploaded.tr
                              : InspectionPage.addPhoto.tr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _hasImage ? FColors.success : FColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (_hasImage)
                IconButton(
                  onPressed: () => InspectionPhotosBinding().instance.delete(photo),
                  icon: const Icon(Iconsax.trash, size: 20),
                  color: FColors.error,
                  tooltip: InspectionPage.deletePhoto.tr,
                )
              else
                IconButton(
                  onPressed: () => InspectionPhotosBinding().instance.picking(photo),
                  icon: const Icon(Iconsax.camera, size: 20),
                  color: FColors.primaryColor,
                  tooltip: InspectionPage.takePhoto.tr,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the thumbnail: shows the photo if uploaded, or a camera placeholder
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
      child: SizedBox(
        width: 72,
        height: 72,
        child: _hasImage
            ? (photo.file != null
                ? Image.file(photo.file!, fit: BoxFit.cover)
                : Image.network(
                    photo.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  ))
            : _placeholder(),
      ),
    );
  }

  /// Grey placeholder with camera icon for pending photos
  Widget _placeholder() {
    return Container(
      color: FColors.grey.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Iconsax.camera, color: FColors.grey, size: 28),
      ),
    );
  }
}
