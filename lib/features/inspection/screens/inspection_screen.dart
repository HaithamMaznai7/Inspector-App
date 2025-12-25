import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InspectionScreen extends StatelessWidget {
  final controller = InspectionController.instance;

  InspectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionController>(
      init: InspectionController.instance,
      builder: (controller) {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: FColors.primaryColor),
          );
        }

        return DefaultTabController(
          length: controller.tabs.length,
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: FColors.primaryGradient,
                ),
              ),
              title: Text(
                DetailsPage.pageTitle.trParams({'inspection': controller.slug}),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.apply(color: FColors.white),
              ),
              // centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async =>
                      await ConnectionService.instance.reload(),
                  icon: Icon(Iconsax.share, color: FColors.white),
                ),
              ],
              leading: IconButton(
                icon: Icon(
                  FLocalization.isArabic
                      ? Iconsax.arrow_right_3
                      : Iconsax.arrow_left_2,
                  color: FColors.white,
                ),
                onPressed: () {
                  if (Get.previousRoute.isNotEmpty) {
                    Get.back();
                  } else {
                    Get.offAllNamed(
                      RoutingUrl.home,
                    ); // or your app's default page
                  }
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Obx(
                  () => TabBar(
                    tabs: controller.tabs
                        .map(
                          (tab) => Tab(
                            icon: Icon(
                              tab['icon'] as IconData,
                              color: FColors.white,
                            ),
                            // child: Text(
                            //   tab['title'],
                            //   style: Theme.of(context).textTheme.labelMedium!
                            //       .copyWith(color: FColors.white),
                            // ),
                          ),
                        )
                        .toList(),
                    indicatorColor: FColors.white,
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: controller.tabs
                  .map((tab) => tab['screen'] as Widget)
                  .toList(),
            ),
          ),
        );
        
      },
    );
  }
}
