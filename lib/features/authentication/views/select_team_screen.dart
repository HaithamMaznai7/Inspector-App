import 'package:cached_network_image/cached_network_image.dart';
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

/// Screen shown after login when no team has [current: true].
/// Only displays teams of type: system, center, centerBranch.
/// Has no back button — user must select a team to proceed.
class SelectTeamToContinueScreen extends StatefulWidget {
  const SelectTeamToContinueScreen({super.key});

  @override
  State<SelectTeamToContinueScreen> createState() =>
      _SelectTeamToContinueScreenState();
}

class _SelectTeamToContinueScreenState
    extends State<SelectTeamToContinueScreen> {
  bool _isSwitching = false;

  List<Team> get _selectableTeams =>
      (auth().profile?.teams ?? [])
          .where((t) => t.isSelectableTeam)
          .toList();

  Future<void> _selectTeam(Team team) async {
    if (team.id == null) return;

    setState(() => _isSwitching = true);

    try {
      final updatedProfile = await ProfileRepository().switchTeam(team.id!);
      auth().profile = updatedProfile;

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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: FSizes.lg),

              // Header icon
              CircleAvatar(
                radius: FSizes.xl,
                backgroundColor: FColors.primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Iconsax.people,
                  color: FColors.primaryColor,
                  size: FSizes.xl,
                ),
              ),
              const SizedBox(height: FSizes.md),

              // Title
              Text(
                'Select Team to Continue'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: FSizes.xs),

              // Subtitle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Text(
                  'Please select a team to continue using the app'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FColors.darkGrey,
                  ),
                ),
              ),

              const SizedBox(height: FSizes.lg),
              const Divider(height: 1),

              // Loading indicator
              if (_isSwitching)
                const LinearProgressIndicator(
                  color: FColors.primaryColor,
                  minHeight: 2,
                ),

              // Teams list
              Expanded(
                child: _selectableTeams.isEmpty
                    ? Center(
                        child: Text(
                          'No teams available'.tr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: FColors.darkGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: FSizes.md,
                          horizontal: FSizes.sm,
                        ),
                        itemCount: _selectableTeams.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: FSizes.dividerHeight, indent: 72),
                        itemBuilder: (context, index) {
                          final team = _selectableTeams[index];
                          return _buildTeamTile(context, team, isDark);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, Team team, bool isDark) {
    return ListTile(
      onTap: _isSwitching ? null : () => _selectTeam(team),
      leading: _teamAvatar(team),
      title: Text(
        team.name ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        team.role ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: FColors.darkGrey,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        size: FSizes.iconSm,
        color: FColors.darkGrey,
      ),
    );
  }

  Widget _teamAvatar(Team team) {
    final logo = team.ownerLogo;
    final name = team.name ?? '?';
    final initial = name.isNotEmpty ? name[0] : '?';

    if (team.isSystem) {
      return CircleAvatar(
        backgroundColor: FColors.primaryColor.withValues(alpha: 0.1),
        child: Icon(
          Iconsax.shield_tick,
          color: FColors.primaryColor,
          size: FSizes.iconInlineSm,
        ),
      );
    }

    if (logo != null && !logo.contains('ui-avatars.com')) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(logo),
        backgroundColor: FColors.grey.withValues(alpha: 0.2),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      backgroundColor: FColors.primaryColor.withValues(alpha: 0.1),
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
