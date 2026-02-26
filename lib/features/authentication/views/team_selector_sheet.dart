import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/team.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Bottom sheet that shows the user's teams and allows switching.
class TeamSelectorSheet extends StatefulWidget {
  const TeamSelectorSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const TeamSelectorSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TeamSelectorSheet> createState() => _TeamSelectorSheetState();
}

class _TeamSelectorSheetState extends State<TeamSelectorSheet> {
  bool _isSwitching = false;

  List<Team> get _teams => auth().profile?.teams ?? [];
  Team? get _currentTeam => auth().profile?.currentTeam;

  Future<void> _switchTeam(Team team) async {
    if (team.id == _currentTeam?.id) return;
    if (team.id == null) return;

    setState(() => _isSwitching = true);

    try {
      final updatedProfile = await ProfileRepository().switchTeam(team.id!);
      auth().profile = updatedProfile;

      Get.back(); // close sheet

      // Refresh home data by reloading the page
      Get.offAllNamed(RoutingUrl.home);

      FLoader.successSnackBar(
        title: 'Team Switched'.tr,
        message: team.name ?? '',
      );
    } catch (e) {
      FLoader.errorSnackBar(
        title: 'Error'.tr,
        message: 'Failed to switch team'.tr,
      );
    } finally {
      if (mounted) setState(() => _isSwitching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.7),
      decoration: BoxDecoration(
        color: isDark ? FColors.dark : FColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(FSizes.borderRadiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: FColors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              children: [
                Icon(Iconsax.people, color: FColors.primaryColor),
                const SizedBox(width: FSizes.sm),
                Text(
                  'Teams'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Loading overlay
          if (_isSwitching)
            const LinearProgressIndicator(
              color: FColors.primaryColor,
              minHeight: 2,
            ),

          // Teams list
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
              children: [
                // Active teams section
                if (_teams.isNotEmpty) ...[
                  _sectionHeader(context, 'Teams'.tr),
                  ..._teams.map((team) => _buildTeamTile(context, team)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: FColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, Team team) {
    final isCurrent = team.id == _currentTeam?.id;

    return ListTile(
      onTap: _isSwitching ? null : () => _switchTeam(team),
      leading: _teamAvatar(team),
      title: Text(
        team.name ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        team.role ?? '',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: FColors.darkGrey),
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current'.tr,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: FColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(Iconsax.arrow_right_3, size: 18, color: FColors.darkGrey),
    );
  }

  Widget _teamAvatar(Team team) {
    final logo = team.ownerLogo;
    final name = team.name ?? '?';
    final initial = name.isNotEmpty ? name[0] : '?';

    if (team.isSystem) {
      return CircleAvatar(
        backgroundColor: FColors.primaryColor.withOpacity(0.1),
        child: Icon(Iconsax.shield_tick, color: FColors.primaryColor, size: 20),
      );
    }

    if (logo != null && !logo.contains('ui-avatars.com')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(logo),
        backgroundColor: FColors.grey.withOpacity(0.2),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      backgroundColor: FColors.primaryColor.withOpacity(0.1),
      child: Text(
        initial,
        style: const TextStyle(
          color: FColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
