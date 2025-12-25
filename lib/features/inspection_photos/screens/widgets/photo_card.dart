import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/features/inspection_photos/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/models/photo.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key, required this.photo});
  final Photo photo;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Card(
      color: isDark ? FColors.grey.withOpacity(.2) : FColors.grey,
      child: Padding(
        padding: const EdgeInsets.all(FSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => InspectionPhotosController.instance.picking(photo),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FSizes.sm),
                  color: isDark ? FColors.grey : Colors.white54,
                ),
                height: 100,
                width: 100,
                child: ClipRRect(
                        borderRadius: BorderRadius.circular(FSizes.sm),
                        child: photo.image == null && photo.file == null
                            ? Icon(Icons.camera_alt, size: 50)
                            : EasyImageView(
                                imageProvider:
                                    photo.file != null
                                    ? Image.file(
                                        photo.file!,
                                        fit: BoxFit.cover,
                                      ).image
                                    : Image.network(
                                        "${photo.image}",
                                        fit: BoxFit.cover,
                                      ).image,
                              ),
                      ),
              ),
            ),
            Expanded(
              child: Text(
                photo.title.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.visible,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: FColors.error),
              onPressed: () => InspectionPhotosController.instance.delete(photo),
            ),
          ],
        ),
      ),
    );
  }


}
