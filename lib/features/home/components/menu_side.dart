import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/features/authentication/components/user_avater.dart';
import 'package:fahis_inspector/features/home/components/user_info.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenuWrapper extends StatelessWidget {
  final bool isTablet;
  const SideMenuWrapper({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final homeController = HomeBinding().instance;
    // return GetX<InspectionsController>(
      // init: InspectionsBinding().instance,
      // autoRemove: true,
      // builder: (controller) {
        // final selectedStage = controller.selectedStage.value.value;

        return SideMenu(
          controller: homeController.sideController,
          backgroundColor: FColors.white,
          mode: SideMenuMode.open,
          hasResizerToggle: isTablet,
          hasResizer: isTablet,
          minWidth: Get.width * .1,
          builder: (data) {
            return SideMenuData(
              defaultTileData: SideMenuItemTileDefaults(
                hoverColor: Colors.black,
              ),
              animItems: SideMenuItemsAnimationData(),
              items: [
                ...InspectionStage.allStages.map((stage) {
                  // final isSelected = selectedStage == stage.value;
                  final isSelected = null == stage.value;
                  int count = 0;
                  // if (! controller.isLoading.value) {
                    // count = controller.repository.total["${stage.value ?? 'all'}_total"] ?? 0;
                  // }
                  
                  return SideMenuItemDataTile(
                    hasSelectedLine: false,
                    decoration: isSelected
                      ? BoxDecoration(
                          gradient: FColors.primaryGradient,
                          borderRadius: BorderRadius.all(
                            Radius.circular(FSizes.sm),
                          )
                        )
                      : null,
                    isSelected: isSelected,
                    onTap: () => print('select'), // controller.changeStatus(newStage: stage),
                    title: stage.getLabel,
                    selectedTitleStyle: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: FColors.white),
                    badgeBuilder: (widget) => Badge.count(
                      count: count,
                      isLabelVisible: count > 0,
                      smallSize: FSizes.sm,
                      largeSize: FSizes.sm,
                      padding: EdgeInsetsGeometry.all(.5),
                      offset: Offset(FSizes.sm, - FSizes.sm),
                      alignment: FLocalization.isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      backgroundColor: isSelected
                          ? FColors.white
                          : FColors.error,
                      child: widget,
                    ),
                    titleStyle: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: FColors.dark),
                    tooltip: '$count',
                    icon: Icon(stage.icon, color: stage.color),
                    selectedIcon: Icon(stage.icon, color: FColors.white),
                  );
                }),

                // Add other menu items as needed (teams, settings, logout, etc.)
                SideMenuItemDataDivider(divider: Divider()),
                SideMenuItemDataTitle(
                  title: 'Settings & Support'.tr,
                  textAlign: TextAlign.start,
                  titleStyle: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.apply(color: FColors.primaryColor),
                ),
                SideMenuItemDataTile(
                  isSelected: false,
                  onTap: () => FLocalization.changeLocale(),
                  title: FLocalization.isArabic ? 'English' : 'عربي',
                  hoverColor: FColors.primaryColor.withOpacity(.3),
                  titleStyle: const TextStyle(color: FColors.black),
                  icon: Icon(
                    Iconsax.language_circle,
                    color: FColors.primaryColor,
                  ),
                  selectedIcon: const Icon(Icons.home),
                ),
                SideMenuItemDataTile(
                  isSelected: false,
                  hoverColor: FColors.primaryColor.withOpacity(.3),
                  onTap: () async => await _callSuportTeam(),
                  title: 'Help & Support'.tr,
                  icon: const Icon(Icons.car_crash),
                ),
              ],
              header: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && (snapshot.data != null)) {
                    final user = snapshot.data;
                    if (user != null) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 220) {
                            return InkWell(
                              onTap: () => Get.to(ProfileView()),
                              child: AnimatedContainer(
                                duration: Duration(seconds: 1),
                                width: constraints.maxWidth,
                                margin: const EdgeInsets.only(
                                  left: FSizes.sm,
                                  right: FSizes.sm,
                                  bottom: FSizes.sm,
                                  top: FSizes.lg,
                                ),
                                padding: const EdgeInsets.all(FSizes.sm),
                                decoration: const BoxDecoration(
                                  gradient: FColors.primaryGradient,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(FSizes.borderRadiusLg),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    UserWidget(),
                                    FUserAvatar(),
                                    const SizedBox(width: FSizes.sm),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName ?? 'User Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: FColors.white),
                                        ),
                                        Text(
                                          'Inspector',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () async =>
                                          await FirebaseAuth.instance.signOut(),
                                      icon: Icon(
                                        Iconsax.logout,
                                        size: 25,
                                        color: FColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return InkWell(
                            onTap: () => Get.to(ProfileView()),
                            child: FUserAvatar(),
                          );
                        },
                      );
                    }
                  }
                  return SizedBox();
                },
              ),
            );
          },
        );
      // },
    // );
  }

  Future<void> _callSuportTeam() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+966126818525');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch 966126818525';
    }
  }
}
