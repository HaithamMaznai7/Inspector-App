import 'package:fahis_inspector/Common/widget/logo.dart';
import 'package:fahis_inspector/features/authentication/screens/profile_view.dart';
import 'package:fahis_inspector/features/authentication/screens/widget/user_avater.dart';
import 'package:fahis_inspector/features/inspections/controllers/home_controller.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/features/inspections/screens/widgets/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/screens/widgets/not_more_items.dart';
import 'package:fahis_inspector/features/inspections/screens/widgets/on_loading_home_page.dart';
import 'package:fahis_inspector/features/notifications/controller/controller.dart';
import 'package:fahis_inspector/features/notifications/notifications_icon.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.instance;
    final screenWidth = MediaQuery.of(context).size.width;

    final isPhone = screenWidth < tabletBreakpoint;
    final isTablet =
        screenWidth >= tabletBreakpoint && screenWidth < desktopBreakpoint;

    // Use Drawer for phones
    if (isPhone) {
      final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Logo(height: 30),
          centerTitle: true,
          actions: [
            GetBuilder<NotificationsController>(
              tag: 'NotificationService',
              builder: (controller) => NotificationIcon(controller: controller),
            ),
            IconButton(
              onPressed: controller.openSearch,
              icon: Icon(Icons.search, color: FColors.primaryColor),
            ),
          ],
          leading: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Icon(Iconsax.menu_1, color: FColors.primaryColor),
          ),
        ),
        drawer: Drawer(
          width: Get.width * .8,
          child: SafeArea(
            child: SizedBox.expand(
              child: SideMenuWrapper(controller: controller),
            ),
          ),
        ),
        body: HomeContent(controller: controller),
      );
    }

    // Use Row layout for tablet & desktop
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: isTablet
                ? FDeviceUtils.getScreenWidth() * .45
                : FDeviceUtils.getScreenWidth() * .3,
            child: SideMenuWrapper(controller: controller),
          ),
          Expanded(child: HomeContent(controller: controller)),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final HomeController controller;

  const HomeContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        // vertical: FSizes.lg,
      ),
      child: Obx(() {
        final list = controller.inspections;
        final isLoad = controller.isLoading.value;

        if (isLoad) {
          return OnLoadingHomePage();
        }

        if (list.isEmpty) {
          return NotMoreItem();
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          semanticsLabel: 'hh',
          color: FColors.primaryColor,
          child: ListView(
            controller: controller.scrollController,
            children: [
              ...list.map((item) => InspectionCard(inspection: item)).toList(),
              Obx(() {
                final load = controller.repository.isFetchingMore.value;
                if (load) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return SizedBox();
                }
              }),
            ],
          ),
        );
      }),
    );
  }
}

class SideMenuWrapper extends StatelessWidget {
  final HomeController controller;

  const SideMenuWrapper({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      controller: controller.sideController,
      backgroundColor: FColors.white,
      mode: SideMenuMode.open,
      hasResizerToggle: false,
      hasResizer: false,
      builder: (data) {
        return SideMenuData(
          defaultTileData: SideMenuItemTileDefaults(hoverColor: Colors.black),
          animItems: SideMenuItemsAnimationData(),
          items: [
            ...InspectionStage.allStages.map((stage) {
              final isSelected =
                  controller.selectedStatus.value.value == stage.value;
              int count =
                  controller
                      .repository
                      .total["${stage.value ?? 'all'}_total"] ??
                  controller.inspections
                      .where((item) => item.stage.value == stage.value)
                      .toList()
                      .length;
              return SideMenuItemDataTile(
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: FColors.primaryGradient,
                        borderRadius: BorderRadius.all(
                          Radius.circular(FSizes.sm),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: FColors.darkGrey,
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      )
                    : null,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                hoverColor: FColors.primaryColor.withOpacity(.3),
                isSelected: isSelected,
                onTap: () => controller.changeStatus(newStatus: stage),
                title: stage.getLabel,
                // highlightSelectedColor: FColors.primaryColor,
                selectedTitleStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: FColors.white),
                badgeBuilder: (widget) => Badge(
                  label: Text('${count}'),
                  isLabelVisible: count > 0,
                  alignment: FLocalization.isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  // backgroundColor: isSelected ? FColors.white : FColors.error,
                  child: widget,
                ),
                titleStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: FColors.dark),
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
              icon: Icon(Iconsax.language_circle, color: FColors.primaryColor),
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
          header: Auth.user != null
              ? InkWell(
                  onTap: () => Get.to(ProfileView()),
                  child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        UserWidget(),
                        FUserAvatar(),
                        const SizedBox(width: FSizes.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Auth.user?.name ?? '',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: FColors.white),
                            ),
                            Text(
                              Auth.user!.currentTeam?.role ?? 'User',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: Auth.logout,
                          icon: Icon(
                            Iconsax.logout,
                            size: 25,
                            color: FColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
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

class UserWidget extends StatelessWidget {
  const UserWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final Offset position = button.localToGlobal(
          Offset.zero,
          ancestor: overlay,
        );

        await showMenu<PopupMenuEntry>(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx * .3,
            position.dy + 65, // ⬆️ Move upward (adjust as needed)
            position.dx,
            position.dy,
          ),
          items: [
            if (Auth.user != null)
              ...Auth.user!.teams.where((team) => team.isJoined).toList().map((
                team,
              ) {
                return PopupMenuItem(
                  enabled: Auth.user?.currentTeam?.id != team.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name ?? 'Team',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        team.role ?? 'User',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  onTap: () => HomeController.instance.changeTeam(team),
                );
              }),
            PopupMenuDivider(),
            PopupMenuItem(
              child: Text('Profile'),
              onTap: () => Get.to(ProfileView()),
            ),
            PopupMenuItem(child: Text('Logout'), onTap: () => Auth.logout()),
          ],
        );
      },
      icon: Icon(Iconsax.arrow_down_1, size: 25, color: FColors.white),
    );
  }
}
