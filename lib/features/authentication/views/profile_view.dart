import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();

  Profile? _profile;
  List<City> _cities = [];
  City? _selectedCity;
  File? _pickedPhoto;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Show cached profile instantly — no waiting for network
    final cached = auth().profile;
    if (cached != null) {
      _profile = cached;
      _nameController.text = cached.name ?? '';
      _selectedCity = cached.city;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // Show cached cities instantly — no waiting for network
    final cachedCities = auth().cities;
    if (cachedCities.isNotEmpty) {
      if (mounted) {
        setState(() => _cities = List<City>.from(cachedCities));
      }
    }

    // Fetch profile + cities in parallel
    await Future.wait([
      ProfileRepository()
          .fetchProfile()
          .then((profile) {
            if (mounted) {
              setState(() {
                _profile = profile;
                _nameController.text = profile.name ?? '';
                _selectedCity = profile.city;
                auth().profile = profile;
              });
            }
          })
          .catchError((_) {}),

      Network(endpoint: 'assets/cities')
          .response(null)
          .then((response) {
            if (!response.hasError && response.data is List) {
              final cities = (response.data as List)
                  .map((e) => City.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
              auth().cities = cities;
              if (mounted) {
                setState(() => _cities = cities);
              }
            }
          })
          .catchError((_) {}),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _safeAvatarUrl(String? avatarUrl, String? name) {
    if (avatarUrl != null && !avatarUrl.contains('ui-avatars.com')) {
      return avatarUrl;
    }
    final initial = (name ?? 'U').isNotEmpty ? name![0] : 'U';
    return 'https://ui-avatars.com/api/?name=$initial&color=FF7D41&background=FFF0E8&format=png&size=128';
  }

  bool _hasRealAvatar(String? url) =>
      url != null && url.isNotEmpty && !url.contains('ui-avatars.com');

  /// Opens a full-screen dark overlay with the current profile picture.
  /// Tapping anywhere or the close button dismisses it.
  void _viewFullScreen() {
    final ImageProvider imageProvider;
    if (_pickedPhoto != null) {
      imageProvider = FileImage(_pickedPhoto!);
    } else if (_hasRealAvatar(_profile?.avatar)) {
      imageProvider = CachedNetworkImageProvider(_profile!.avatar!);
    } else {
      return; // nothing real to show
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Zoomable image centred on screen
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image(image: imageProvider, fit: BoxFit.contain),
                ),
              ),

              // Close button — top-right
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedPhoto = File(picked.path));
      }
    } catch (e) {
      dd('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FTexts.profileTitle.tr)),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: FColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.lg,
              ),
              child: Column(
                children: [
                  // Avatar with edit button
                  Center(
                    child: Stack(
                      children: [
                        // Tap avatar to view full screen
                        GestureDetector(
                          onTap: _viewFullScreen,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: FColors.grey.withValues(
                              alpha: 0.2,
                            ),
                            backgroundImage: _pickedPhoto != null
                                ? FileImage(_pickedPhoto!)
                                : CachedNetworkImageProvider(
                                    _safeAvatarUrl(
                                      _profile?.avatar,
                                      _profile?.name,
                                    ),
                                  ),
                            onBackgroundImageError: (_, __) {},
                          ),
                        ),
                        // Edit button — bottom-right of avatar
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: FColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Iconsax.camera,
                                size: 16,
                                color: FColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FSizes.lg),

                  // Name (editable)
                  _buildTextField(
                    label: FTexts.profileName.tr,
                    controller: _nameController,
                    hint: FTexts.profileNameHint.tr,
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: FSizes.md),

                  // Email (read-only)
                  _buildInfoTile(
                    icon: Iconsax.sms,
                    label: FTexts.profileEmail.tr,
                    value: _profile?.email ?? '-',
                  ),
                  const SizedBox(height: FSizes.sm),

                  // Phone (read-only)
                  _buildInfoTile(
                    icon: Iconsax.call,
                    label: FTexts.profilePhone.tr,
                    value: _profile?.mobile ?? '-',
                  ),
                  const SizedBox(height: FSizes.md),

                  // City dropdown
                  _buildCityDropdown(),
                  const SizedBox(height: FSizes.lg),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: _isUpdating ? null : _updateProfile,
                      child: _isUpdating
                          ? const SizedBox(
                              height: FSizes.iconInlineSm,
                              width: FSizes.iconInlineSm,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FColors.white,
                              ),
                            )
                          : Text(FTexts.profileUpdate.tr),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: FColors.primaryColor),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: FColors.primaryColor, size: 22),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
      ),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FTexts.profileCity.tr,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: FSizes.sm),
        GestureDetector(
          onTap: _showCitiesBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm + 4,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: FColors.darkGrey.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.buildings,
                  color: FColors.primaryColor,
                  size: FSizes.iconSm,
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Text(
                    _selectedCity?.name ?? FTexts.profileCity.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _selectedCity == null ? FColors.darkerGrey : null,
                    ),
                  ),
                ),
                const Icon(
                  Iconsax.arrow_down_1,
                  size: FSizes.iconSm,
                  color: FColors.darkerGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCitiesBottomSheet() {
    final searchController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final query = searchController.text.toLowerCase();
          final filteredCities = _cities
              .where((city) => city.name.toLowerCase().contains(query))
              .toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.only(top: FSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(FSizes.borderRadiusLg * 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: FSizes.sm),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.buildings,
                        color: FColors.primaryColor,
                        size: FSizes.iconSm,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        FTexts.profileCity.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) => setSheetState(() {}),
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search...'.tr,
                      prefixIcon: const Icon(
                        Iconsax.search_normal_1,
                        color: FColors.darkerGrey,
                        size: FSizes.iconSm,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                        borderSide: BorderSide(
                          color: FColors.darkGrey.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                        borderSide: BorderSide(
                          color: FColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                        borderSide: const BorderSide(
                          color: FColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Divider(color: FColors.grey.withValues(alpha: 0.1), height: 1),
                // Cities List
                Flexible(
                  child: filteredCities.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(FSizes.xl),
                          child: Text(
                            'No cities found'.tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.lg,
                            vertical: FSizes.md,
                          ),
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            final city = filteredCities[index];
                            final isSelected = _selectedCity?.id == city.id;

                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCity = city);
                                Get.back(); // close sheet
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(
                                  bottom: FSizes.sm,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: FSizes.sm,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? FColors.primaryColor.withValues(
                                          alpha: 0.12,
                                        )
                                      : Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusMd,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? FColors.primaryColor.withValues(
                                            alpha: 0.5,
                                          )
                                        : FColors.grey.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Leading Icon (Location Pin)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? FColors.primaryColor
                                            : FColors.grey.withValues(
                                                alpha: 0.1,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Iconsax.location,
                                        size: FSizes.iconXs + 2,
                                        color: isSelected
                                            ? FColors.white
                                            : FColors.darkerGrey,
                                      ),
                                    ),
                                    const SizedBox(width: FSizes.sm),
                                    // City Name
                                    Expanded(
                                      child: Text(
                                        city.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? FColors.primaryColor
                                                  : null,
                                            ),
                                      ),
                                    ),
                                    // Trailing Icon (Check mark)
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          right: FSizes.xs,
                                        ),
                                        child: Icon(
                                          Iconsax.tick_circle,
                                          color: FColors.primaryColor,
                                          size: 18,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 18 + FSizes.xs),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      FLoader.warningSnackBar(
        title: FTexts.profileName.tr,
        message: FTexts.profileNameHint.tr,
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final updatedProfile = await ProfileRepository().updateProfile(
        name: name,
        cityId: _selectedCity?.id,
        photo: _pickedPhoto,
      );
      auth().profile = updatedProfile;
      _profile = updatedProfile;
      _pickedPhoto = null; // Reset after successful upload
      FLoader.successSnackBar(title: FTexts.profileUpdate.tr);
      // Navigate back to home to refresh sidebar with updated profile
      Get.offAllNamed(RoutingUrl.home);
    } catch (e) {
      dd(e.toString());
      FLoader.errorSnackBar(
        title: FTexts.profileUpdate.tr,
        message: 'Failed to update profile. Please try again.'.tr,
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
