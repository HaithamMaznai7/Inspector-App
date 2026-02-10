import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/enums/body_part.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyTypeScreen extends StatelessWidget {
  final CarBody bodySide;

  const InspectionBodyTypeScreen({super.key, required this.bodySide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفحص'),
        centerTitle: true,
        backgroundColor: FColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: GetBuilder<InspectionBodyController>(
          init: InspectionBodyBinding().instance,
          autoRemove: false,
          builder: (controller) {
            final bodies = controller.bodySides;
            final body = bodies.where((b) => b.id == bodySide.id).first;

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
                          ...body.notes.map(
                            (Marker note) => Positioned(
                              left:
                                  imageWidth *
                                  (note.dx - 8) /
                                  100, // 70% of the image width
                              top:
                                  imageHeight *
                                  (note.dy - 8) /
                                  100, // 50% of the image height
                              child: IconButton(
                                icon: Icon(
                                  Iconsax.close_circle,
                                  color: FColors.primaryColor,
                                  size: 35,
                                ),
                                onPressed: () => InspectionBodyBinding()
                                    .instance
                                    .onCreateEdit(body, note),
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
