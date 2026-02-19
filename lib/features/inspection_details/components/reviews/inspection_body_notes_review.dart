import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/features/inspection_details/components/reviews/info_card.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyNotesReview extends StatelessWidget {
  const InspectionBodyNotesReview({super.key});

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

  void _showFullImage(BuildContext context, String? imageUrl) {
    if (imageUrl != null) {
      showImageViewer(
        context,
        _getImageProvider(imageUrl),
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

        // WHAT: Read body notes from Hive cache and deserialize safely.
        // WHY: The original code used Map<String, dynamic>.from() which only
        //      shallow-casts the top-level map. Nested maps (markers inside
        //      'notes') remained as Map<dynamic, dynamic>, causing the crash
        //      when Marker.fromJson tried to access them.
        // HOW: We now rely on CarBody.fromJson's internal deep-casting (fixed
        //      in Phase 1) and wrap each parse in try/catch for resilience.
        // EDGE CASES:
        //   - bodyNotesData is null → empty list
        //   - One corrupted entry → skipped, others still load
        //   - Nested marker maps are Map<dynamic, dynamic> → handled by
        //     the updated _$CarBodyFromJson which deep-casts internally
        final bodyNotesData = c.assetsBox?.get('BodyNotes');
        final List<CarBody> bodyNotes = [];
        if (bodyNotesData != null) {
          for (final item in bodyNotesData) {
            try {
              bodyNotes.add(
                CarBody.fromJson(Map<String, dynamic>.from(item as Map)),
              );
            } catch (e) {
              // Skip corrupted entries silently
              debugPrint('Error parsing body note in review: $e');
            }
          }
        }

        return InfoCard(
          title: Text(InspectionPage.inspectionBodyNotes.tr),
          tilePadding: FSizes.md,
          icon: Iconsax.note,
          children: [
            if (bodyNotes.isEmpty)
              Padding(
                padding: EdgeInsets.all(FSizes.md),
                child: Text(
                  InspectionPage.notYet.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.apply(color: FColors.grey),
                ),
              )
            else
              ...bodyNotes.map((body) {
                return Padding(
                  padding: EdgeInsets.only(bottom: FSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Body Part Header
                      ListTile(
                        leading: Icon(
                          Iconsax.note_1,
                          color: FColors.primaryColor,
                        ),
                        title: Text(
                          body.part.label(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.apply(fontWeightDelta: 2),
                        ),
                        subtitle: Text(
                          InspectionPage.notesCount.trParams({
                            'count': '${body.notes.length}',
                          }),
                        ),
                      ),

                      // Markers/Notes List
                      if (body.notes.isNotEmpty)
                        ...body.notes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final marker = entry.value;
                          return Container(
                            margin: EdgeInsets.only(
                              left: FSizes.md,
                              right: FSizes.md,
                              top: FSizes.sm,
                            ),
                            padding: EdgeInsets.all(FSizes.sm),
                            decoration: BoxDecoration(
                              color: FColors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(
                                FSizes.borderRadiusSm,
                              ),
                              border: Border.all(
                                color: FColors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Note Header
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: FSizes.xs,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FColors.primaryColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        InspectionPage.noteLabel.trParams({
                                          'index': '${index + 1}',
                                        }),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.apply(
                                              color: FColors.primaryColor,
                                              fontWeightDelta: 2,
                                            ),
                                      ),
                                    ),
                                    if (marker.type != null &&
                                        marker.type!.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: FSizes.xs,
                                        ),
                                        child: Text(
                                          '• ${marker.type}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.apply(color: FColors.grey),
                                        ),
                                      ),
                                    Spacer(),
                                    Text(
                                      InspectionPage.positionLabel.trParams({
                                        'dx': marker.dx.toStringAsFixed(1),
                                        'dy': marker.dy.toStringAsFixed(1),
                                      }),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.apply(color: FColors.grey),
                                    ),
                                  ],
                                ),

                                // Note Text
                                if (marker.note != null &&
                                    marker.note!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: FSizes.xs),
                                    child: Text(
                                      marker.note!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),

                                // Marker Image
                                if (marker.image != null &&
                                    marker.image!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: FSizes.xs),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showFullImage(context, marker.image),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          FSizes.borderRadiusSm,
                                        ),
                                        child: Image.network(
                                          marker.image!,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 150,
                                                  height: 150,
                                                  color: FColors.grey
                                                      .withOpacity(0.1),
                                                  child: Icon(
                                                    Iconsax.image,
                                                    color: FColors.grey,
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                      // Divider after each body part
                      if (bodyNotes.last != body)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.sm,
                          ),
                          child: Divider(
                            color: FColors.grey.withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
