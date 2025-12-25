import 'package:fahis_inspector/features/inspection_points/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_points/models/point.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointResults extends StatelessWidget {
  const InspectionPointResults({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsController.instance,
      autoRemove: false,
      builder: (controller) {
      final review =
          controller.review.value ??
          ReviewPoint.set([]);
      final isLoading = controller.isLoading.value;
      if (isLoading) {
        return Center(child: CircularProgressIndicator(
          color: FColors.primaryColor,
        ));
      }

      return ListView(
        children: [
          ListTile(
            leading: IconButton(
              onPressed: controller.onEdit,
              icon: Icon(Iconsax.edit),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Points Review', style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    Container(
                      color: FColors.success,
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Text(
                        '${review.good}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(color: FColors.white),
                      ),
                    ),

                    SizedBox(width: FSizes.spaceBtwItems),
                    Container(
                      color: FColors.warning,
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Text(
                        '${review.note}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(color: FColors.white),
                      ),
                    ),
                    SizedBox(width: FSizes.spaceBtwItems),
                    Container(
                      color: FColors.darkGrey,
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Text(
                        '${review.none}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(color: FColors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...review.cats.map(
            (cat) => ListTile(
              leading: SvgPicture.network(
                cat.category.icon,
                width: 30,
                height: 30,
                alignment: Alignment.center,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(FColors.black, BlendMode.srcOut),
                placeholderBuilder: (context) => CircularProgressIndicator(),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat.category.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.fade,
                  ),
                  Row(
                    children: [
                      Container(
                        color: FColors.success,
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          '${cat.good}',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: FColors.white),
                        ),
                      ),

                      SizedBox(width: FSizes.spaceBtwItems),
                      Container(
                        color: FColors.warning,
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          '${cat.note}',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: FColors.white),
                        ),
                      ),
                      SizedBox(width: FSizes.spaceBtwItems),
                      Container(
                        color: FColors.darkGrey,
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          '${cat.none}',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: FColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => controller.onEdit(cat: cat),
            ),
          ),
        ],
      );
    });
  }
}
