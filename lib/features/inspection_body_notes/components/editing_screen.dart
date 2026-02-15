import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/enums/body_part.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyTypeScreen extends StatelessWidget {
  final CarBody bodySide;

  const InspectionBodyTypeScreen({super.key, required this.bodySide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FTexts.bodyInspectionDetails.tr,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.apply(color: FColors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: FColors.white),
      ),
      body: SingleChildScrollView(
        child: GetBuilder<InspectionBodyController>(
          init: InspectionBodyBinding().instance,
          autoRemove: false,
          builder: (controller) {
            final bodies = controller.bodySides;
            final match = bodies.where((b) => b.id == bodySide.id);
            if (match.isEmpty) return const SizedBox();
            final body = match.first;

            double imageWidth =
                body.part == BodyPart.right || body.part == BodyPart.left
                ? 600
                : body.part == BodyPart.interior
                ? 320
                : 300;
            double imageHeight = body.part == BodyPart.interior
                ? 450
                : body.part == BodyPart.right || body.part == BodyPart.left
                ? 125
                : 250;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: FSizes.md),
                  // Tappable body image with positioned markers
                  GestureDetector(
                    onTapDown: (TapDownDetails v) => controller.onCreateEdit(
                      body,
                      Marker(
                        id: 0,
                        dx: v.localPosition.dx / imageWidth * 100,
                        dy: v.localPosition.dy / imageHeight * 100,
                      ),
                    ),
                    child: SizedBox(
                      height: imageHeight,
                      width: imageWidth,
                      child: Stack(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              imageWidth = constraints.maxWidth;
                              imageHeight = constraints.maxHeight;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(FSizes.sm),
                                child: EasyImageView(
                                  imageProvider: Image.network(
                                    body.image,
                                    fit: BoxFit.cover,
                                  ).image,
                                ),
                              );
                            },
                          ),
                          // Render each marker as a tappable icon
                          ...body.notes.map(
                            (Marker note) => Positioned(
                              left: imageWidth * (note.dx - 8) / 100,
                              top: imageHeight * (note.dy - 8) / 100,
                              child: GestureDetector(
                                onTap: () => controller.onCreateEdit(body, note),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: FColors.primaryColor.withOpacity(.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Iconsax.warning_2,
                                    color: FColors.primaryColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
