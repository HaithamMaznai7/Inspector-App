import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/features/authentication/components/user_avater.dart';
import 'package:fahis_inspector/features/home/components/user_info.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
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

    return GetBuilder<InspectionsController>(
      init: InspectionsBinding().instance,
      builder: (controller) {
        final selectedStage = controller.selectedStage.value;

        final isDark = FHelper.isDarkMode(context);

        return SideMenu(
          controller: homeController.sideController,
          backgroundColor: isDark ? FColors.dark : FColors.white,
          mode: SideMenuMode.open,
          hasResizerToggle: isTablet,
          hasResizer: isTablet,
          minWidth: Get.width * .1,
          builder: (data) {
            return SideMenuData(
              defaultTileData: SideMenuItemTileDefaults(
                hoverColor: FColors.primaryColor.withValues(alpha: 0.08),
              ),
              animItems: SideMenuItemsAnimationData(),
              items: [
                ...InspectionStage.allStages.map((stage) {
                  final isSelected = selectedStage == stage;
                  final count =
                      controller
                          .repository
                          ?.total["${stage.value ?? 'all'}_total"] ??
                      0;

                  return SideMenuItemDataTile(
                    hasSelectedLine: false,
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: FSizes.xs,
                      vertical: 2,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: FColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FColors.primaryColor.withOpacity(.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusMd,
                            ),
                          ),
                    isSelected: isSelected,
                    onTap: () => controller.changeStatus(newStage: stage),
                    title: stage.getLabel,
                    selectedTitleStyle: Theme.of(context).textTheme.bodyMedium!
                        .copyWith(
                          color: FColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    badgeBuilder: count > 0
                        ? (widget) => Row(
                            children: [
                              Expanded(child: widget),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? FColors.white
                                      : stage.color.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: stage.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ],
                          )
                        : null,
                    titleStyle: Theme.of(context).textTheme.bodyMedium!
                        .copyWith(
                          color: isDark ? FColors.light : FColors.dark,
                          fontWeight: FontWeight.w500,
                        ),
                    tooltip: stage.getLabel,
                    icon: Icon(
                      stage.icon,
                      color: isSelected ? FColors.white : stage.color,
                      size: 20,
                    ),
                  );
                }),

                SideMenuItemDataDivider(
                  divider: Divider(
                    color: FColors.grey.withOpacity(.2),
                    thickness: 1,
                    height: FSizes.md,
                  ),
                ),
                SideMenuItemDataTitle(
                  title: 'Settings & Support'.tr,
                  textAlign: TextAlign.start,
                  titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: FColors.darkGrey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 2,
                  ),
                  onTap: () => FLocalization.changeLocale(),
                  title: FLocalization.isArabic ? 'English' : 'عربي',
                  hoverColor: FColors.primaryColor.withOpacity(.08),
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Iconsax.language_circle,
                    color: FColors.primaryColor,
                    size: 20,
                  ),
                ),
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 2,
                  ),
                  onTap: () => FLocalization.changeTheme(),
                  title: FLocalization.isLight ? 'Dark Mode'.tr : 'Light Mode'.tr,
                  hoverColor: FColors.primaryColor.withOpacity(.08),
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    FLocalization.isLight ? Iconsax.moon : Iconsax.sun_1,
                    color: FColors.primaryColor,
                    size: 20,
                  ),
                ),
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 2,
                  ),
                  hoverColor: FColors.primaryColor.withOpacity(.08),
                  onTap: () async => await _callSuportTeam(),
                  title: 'Help & Support'.tr,
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Iconsax.headphone,
                    color: FColors.primaryColor,
                    size: 20,
                  ),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.displayName ?? 'User Name',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: FColors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            FTexts.systemInspector.tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: FColors.white
                                                      .withOpacity(.8),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async =>
                                          await auth().logOut(),
                                      icon: Icon(
                                        Iconsax.logout,
                                        size: 20,
                                        color: FColors.white,
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
      },
    );
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
