import 'package:fahis_inspector/features/inspection_body_notes/controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/components/editing_screen.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyTypeResults extends StatelessWidget {
  const InspectionBodyTypeResults({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionBodyController>(
      init: InspectionBodyBinding().instance,
      autoRemove: false,
      builder: (controller) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          itemCount: controller.bodySides.length,
          separatorBuilder: (_, __) => const SizedBox(height: FSizes.xs),
          itemBuilder: (context, index) {
            final body = controller.bodySides[index];
            final noteCount = body.notes.length;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                side: BorderSide(color: FColors.grey.withOpacity(.3)),
              ),
              child: ExpansionTile(
                // Navigate to the body image editing screen
                leading: GestureDetector(
                  onTap: () =>
                      Get.to(InspectionBodyTypeScreen(bodySide: body)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: FColors.primaryColor.withOpacity(.08),
                      borderRadius: BorderRadius.circular(FSizes.sm),
                    ),
                    child: const Icon(
                      Iconsax.add,
                      color: FColors.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                // Localized body part label
                title: Text(
                  body.part.label(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                // Notes count badge
                trailing: Badge(
                  label: Text(
                    '$noteCount',
                    style: const TextStyle(color: FColors.white, fontSize: 11),
                  ),
                  backgroundColor:
                      noteCount > 0 ? FColors.primaryColor : FColors.grey,
                  child: const Icon(Iconsax.note_1, color: FColors.warning),
                ),
                childrenPadding: const EdgeInsets.only(
                  left: FSizes.md,
                  right: FSizes.md,
                  bottom: FSizes.sm,
                ),
                children: body.notes.map((note) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: FSizes.xs),
                    decoration: BoxDecoration(
                      color: FColors.grey.withOpacity(.1),
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        note.note ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Edit icon
                      leading: GestureDetector(
                        onTap: () => controller.onCreateEdit(body, note),
                        child: const Icon(
                          Iconsax.edit_2,
                          color: FColors.warning,
                          size: 20,
                        ),
                      ),
                      // Delete icon
                      trailing: GestureDetector(
                        onTap: () => controller.onRemove(note),
                        child: const Icon(
                          Iconsax.trash,
                          color: FColors.error,
                          size: 20,
                        ),
                      ),
                      onTap: () => controller.onCreateEdit(body, note),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
