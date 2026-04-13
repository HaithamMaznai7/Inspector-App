import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/authentication/views/profile_view.dart';
import 'package:fahis_inspector/features/authentication/views/team_selector_sheet.dart';
import 'package:fahis_inspector/features/authentication/components/user_avater.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
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
    final isDark = FHelper.isDarkMode(context);

    return GetBuilder<InspectionsController>(
      init: InspectionsBinding().instance,
      builder: (controller) {
        final selectedStage = controller.selectedStage.value;

        return SideMenu(
          controller: homeController.sideController,
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : FColors.light,
          mode: SideMenuMode.open,
          hasResizerToggle: isTablet,
          hasResizer: isTablet,
          minWidth: Get.width * .1,
          builder: (data) {
            return SideMenuData(
              defaultTileData: SideMenuItemTileDefaults(
                hoverColor: FColors.primaryColor.withValues(alpha: 0.06),
              ),
              animItems: SideMenuItemsAnimationData(),
              items: [
                // ── Stage filters ──────────────────────────────────
                ...InspectionStage.allStages.map((stage) {
                  final isSelected = selectedStage == stage;
                  final count =
                      controller.repository
                          ?.total['${stage.value ?? 'all'}_total'] ??
                      0;

                  return SideMenuItemDataTile(
                    hasSelectedLine: false,
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: FSizes.xs,
                      vertical: 1,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            gradient: FColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FColors.primaryColor.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                    selectedTitleStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: isDark ? FColors.light : FColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
                    tooltip: stage.getLabel,
                    // Icon inside a subtle circle
                    icon: _StageIcon(
                      icon: stage.icon,
                      color: stage.color,
                      isSelected: isSelected,
                    ),
                    badgeBuilder: count > 0
                        ? (widget) => Row(
                            children: [
                              Expanded(child: widget),
                              _CountBadge(
                                count: count,
                                isSelected: isSelected,
                                color: stage.color,
                              ),
                            ],
                          )
                        : null,
                  );
                }),

                // ── Divider ────────────────────────────────────────
                SideMenuItemDataDivider(
                  divider: Divider(
                    color: isDark
                        ? FColors.grey.withValues(alpha: 0.1)
                        : FColors.grey.withValues(alpha: 0.5),
                    thickness: 1,
                    height: FSizes.md,
                    indent: FSizes.sm,
                    endIndent: FSizes.sm,
                  ),
                ),

                // ── Settings & Support section label ───────────────
                SideMenuItemDataTitle(
                  title: 'Settings & Support'.tr,
                  textAlign: TextAlign.start,
                  titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FColors.darkGrey,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),

                // ── Switch Team ────────────────────────────────────
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  onTap: () => TeamSelectorSheet.show(),
                  title: 'Switch Team'.tr,
                  hoverColor: FColors.primaryColor.withValues(alpha: 0.06),
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: _ActionIcon(icon: Iconsax.people, color: FColors.info),
                ),

                // ── Language ───────────────────────────────────────
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  onTap: () => FLocalization.changeLocale(),
                  title: FLocalization.isArabic ? 'English' : 'عربي',
                  hoverColor: FColors.primaryColor.withValues(alpha: 0.06),
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: _ActionIcon(
                    icon: Iconsax.language_circle,
                    color: Colors.teal,
                  ),
                ),

                // ── Theme toggle ───────────────────────────────────
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  onTap: () => FLocalization.changeTheme(),
                  title: FLocalization.isLight
                      ? 'Dark Mode'.tr
                      : 'Light Mode'.tr,
                  hoverColor: FColors.primaryColor.withValues(alpha: 0.06),
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: _ActionIcon(
                    icon: FLocalization.isLight ? Iconsax.moon : Iconsax.sun_1,
                    color: FLocalization.isLight
                        ? Colors.indigo
                        : FColors.warning,
                  ),
                ),

                // ── Help & Support ─────────────────────────────────
                SideMenuItemDataTile(
                  isSelected: false,
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: FSizes.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  hoverColor: FColors.primaryColor.withValues(alpha: 0.06),
                  onTap: () async => await _callSupportTeam(),
                  title: 'Help & Support'.tr,
                  titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.light : FColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: _ActionIcon(
                    icon: Iconsax.headphone,
                    color: FColors.success,
                  ),
                ),
              ],

              // ── Header ──────────────────────────────────────────
              header: Obx(() {
                auth().profileRx.value; // reactive dependency
                if (!auth().isAuth) return const SizedBox.shrink();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 220) {
                      return _ExpandedHeader(context: context);
                    }
                    return _CollapsedHeader();
                  },
                );
              }),
            );
          },
        );
      },
    );
  }

  Future<void> _callSupportTeam() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '+966126818525');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch 966126818525';
    }
  }
}

// ── Stage icon: colored circle + icon ───────────────────────────────────────

class _StageIcon extends StatelessWidget {
  const _StageIcon({
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  final IconData icon;
  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FSizes.iconLg,
      height: FSizes.iconLg,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: FSizes.iconSm,
        color: isSelected ? Colors.white : color,
      ),
    );
  }
}

// ── Action item icon: orange-tinted circle ───────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FSizes.iconLg,
      height: FSizes.iconLg,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: FSizes.iconSm, color: color),
    );
  }
}

// ── Count badge ──────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.isSelected,
    required this.color,
  });

  final int count;
  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: FSizes.defaultSpace),
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.25)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: isSelected
            ? null
            : Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        count.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: FSizes.iconXs,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}

// ── Expanded header (side menu open / width ≥ 220) ───────────────────────────

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);
    final vPad = isTablet ? FSizes.lg : FSizes.md;

    return InkWell(
      onTap: () => Get.to(() => const ProfileView()),
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(FSizes.borderRadiusLg),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(FSizes.sm, FSizes.lg, FSizes.sm, FSizes.sm),
        padding: EdgeInsets.all(vPad - 4),
        decoration: BoxDecoration(
          gradient: FColors.primaryGradient,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: FColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Obx(() {
              auth().profileRx.value; // reactive dependency
              return FUserAvatar();
            }),
            const SizedBox(width: FSizes.sm),
            // Name + team
            Expanded(
              child: Obx(() {
                final profile = auth().profileRx.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile?.name ??
                          FirebaseAuth.instance.currentUser?.displayName ??
                          'User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: FSizes.xxs),
                    Text(
                      profile?.currentTeam?.name ??
                          FTexts.systemInspector.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                );
              }),
            ),
            // Logout
            GestureDetector(
              onTap: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: Text(FTexts.logoutConfirmTitle.tr),
                    content: Text(FTexts.logoutConfirmMessage.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(FTexts.cancelBtn.tr),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(FTexts.logoutBtn.tr),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) await auth().logOut();
              },
              child: Container(
                padding: const EdgeInsets.all(FSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.logout,
                  size: FSizes.iconSm,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collapsed header (side menu icon-only / width < 220) ─────────────────────

class _CollapsedHeader extends StatelessWidget {
  const _CollapsedHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: FSizes.lg, bottom: FSizes.sm),
      child: Center(
        child: InkWell(
          onTap: () => Get.to(() => const ProfileView()),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: Obx(() {
            auth().profileRx.value;
            return FUserAvatar();
          }),
        ),
      ),
    );
  }
}
