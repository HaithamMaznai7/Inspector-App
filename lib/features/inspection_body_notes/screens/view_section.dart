import 'package:fahis_inspector/features/inspection_body_notes/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/screens/editing_screen.dart';
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
      init: InspectionBodyController.instance,
      autoRemove: false,
      builder: (controller) {
        return ListView(
          children: controller.bodySides.map((body) {
            return ExpansionTile(
              leading: IconButton(
                onPressed: () => Get.to(InspectionBodyTypeScreen(
                  bodySide: body,
                )),
                icon: const Icon(Iconsax.add, color: FColors.primaryColor,),
              ),
              title: Text(
                body.part.name.toUpperCase(),
                style: const TextStyle(fontSize: 18),
              ),
              trailing: Badge(
                label: Text('${body.notes.length}'),
                child: const Icon(Iconsax.note, color: FColors.warning),
              ),
              childrenPadding: EdgeInsets.symmetric(horizontal: FSizes.lg),
              children: body.notes.map((note) {
                return ListTile(
                  title: Text(note.note ?? ''),
                  leading: IconButton(
                    icon: Icon(Iconsax.edit, color: FColors.warning),
                    onPressed: () => controller.onCreateEdit(body, note),
                  ),
                  trailing: IconButton(
                    icon: Icon(Iconsax.trash, color: FColors.error),
                    onPressed: () => controller.onRemove(note),
                  ),
                  onLongPress: () => controller.onCreateEdit(body, note),
                );
              }).toList(),
            );
          }).toList(),
        );

        // return Column(
        //   children: [
        //     // ...data.map(
        //     //   (bodyType) => ListTile(
        //     //     leading: Text("${bodyType.notes.length}"),
        //     //     title: Text(
        //     //       bodyType.part.label(),
        //     //       style: Theme.of(context).textTheme.titleMedium,
        //     //       overflow: TextOverflow.fade,
        //     //     ),
        //     //     onTap: () => Get.to(InspectionBodyTypeScreen(slug: controller.inspection.value.slug, data: data, category: bodyType.part,))
        //     //   )
        //     // )
        //   ],
        // );
      },
    );
  }
}
