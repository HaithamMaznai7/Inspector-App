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

class InspectionPhotosReview extends StatelessWidget {
  const InspectionPhotosReview({super.key});

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null) {
      return const AssetImage('assets/images/placeholder.png');
    }

    if (imageUrl.startsWith('https://') || imageUrl.startsWith('http://')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('//s3')) {
      return NetworkImage('https:$imageUrl');
    } else {
      return NetworkImage(imageUrl);
    }
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
          return SizedBox();
        }

        // Get photos from controller's assetsBox
        final photos = c.assetsBox?.get('Photos') as List?;
        final photosList = photos != null
            ? photos.map((item) => Photo.fromJson(Map<String, dynamic>.from(item))).toList()
            : <Photo>[];

        return InfoCard(
          title: Text(InspectionPage.inspectionPhotos.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.camera,
          children: [
            if (photosList.isEmpty)
              Padding(
                padding: EdgeInsets.all(FSizes.md),
                child: Text(
                  InspectionPage.notYet.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.apply(color: FColors.grey),
                ),
              )
            else
              Container(
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.sm),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photosList.length,
                  itemBuilder: (context, index) {
                    final photo = photosList[index];
                    return Container(
                      width: 160,
                      margin: EdgeInsets.only(right: FSizes.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showFullImage(context, photo),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                child: photo.image != null
                                    ? Image.network(
                                        photo.image!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: FColors.grey.withOpacity(0.2),
                                            child: Icon(
                                              Iconsax.image,
                                              color: FColors.grey,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: FColors.grey.withOpacity(0.2),
                                        child: Icon(
                                          Iconsax.image,
                                          color: FColors.grey,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: FSizes.xs),
                          Text(
                            photo.title,
                            style: Theme.of(context).textTheme.bodySmall?.apply(
                              fontWeightDelta: 2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
        );
      },
    );
  }
}
