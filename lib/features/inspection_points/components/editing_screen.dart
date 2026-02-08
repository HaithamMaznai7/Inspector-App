import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspection_points/components/card.dart';
import 'package:fahis_inspector/features/inspection_points/controller.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionPointsScreen extends StatelessWidget {
  const InspectionPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder(
          init: InspectionPointsBinding().instance,
          builder: (controller) {
            final category = controller.category.value;
            return Text(
              category?.category.title ?? 'تفاصيل الفحص',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: FColors.white),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: FColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: BackPageButton( color: FColors.warning,),
      ),
      body: Column(
        children: [
          const SizedBox(height: FSizes.sm),
          // Horizontal Scrolling Choice Chips
          GetBuilder<InspectionPointsController>(
            init: InspectionPointsBinding().instance,
            builder: (controller) {
              final category = controller.category.value;
              final data = controller.review.value ?? ReviewPoint.set([]);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...data.cats.map((cat) {
                      final isSelected =
                          category?.category.id == cat.category.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.sm * .5,
                        ),
                        child: ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: isSelected
                                ? FColors.primaryColor
                                : FColors.white,
                            child: SvgPicture.network(
                              cat.category.icon,
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? FColors.white
                                    : FColors.primaryColor,
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) =>
                                  const CircularProgressIndicator(),
                            ),
                          ),
                          label: Text(
                            cat.category.title,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: isSelected
                                      ? FColors.white
                                      : FColors.primaryColor,
                                ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: FColors.primaryColor,
                          onSelected: (_) {
                            controller.onChangeCategory(cat: cat);
                            controller.update();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: FSizes.sm),

          // Vertical Scrolling Point Cards for Selected Category
          Flexible(
            child: GetBuilder<InspectionPointsController>(
              init: InspectionPointsBinding().instance,
              builder: (controller) {
                final category = controller.category.value;
                final canEditPoint =
                    controller.inspection?.stage.canEditPoint ?? false;

                if (category != null) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(FSizes.md),
                    itemCount: category.points.length,
                    itemBuilder: (context, index) {
                      final point = category.points[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: PointCard(
                          key: ValueKey(point.id),
                          point: point,
                          onChange: controller.onChangePoint,
                        ),
                      );
                    },
                  );
                }

                return Center(
                  child: CircularProgressIndicator(color: FColors.primaryColor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
