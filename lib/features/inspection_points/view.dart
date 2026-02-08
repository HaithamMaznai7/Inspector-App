import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointResults extends StatelessWidget {
  const InspectionPointResults({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPointsController>(
      init: InspectionPointsBinding().instance,
      builder: (controller) {
        final review = controller.review.value ?? ReviewPoint.set([]);
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(color: FColors.primaryColor),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView(
            children: [
              ListTile(
                leading: IconButton(
                  onPressed: () => controller.generate(),
                  icon: Icon(Iconsax.refresh),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points Review', style: TextStyle(fontSize: 18)),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Container(
                          color: FColors.darkGrey,
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Text(
                            '${review.none}',
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
                            '${review.note}',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: FColors.white),
                          ),
                        ),
                        SizedBox(width: FSizes.spaceBtwItems),
                        Container(
                          color: FColors.success,
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Text(
                            '${review.good}',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: FColors.white),
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
                    colorFilter: ColorFilter.mode(
                      FColors.black,
                      BlendMode.srcOut,
                    ),
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
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
          ),
        );
      },
    );
  }
}
