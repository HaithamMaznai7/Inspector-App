import 'dart:io';

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
    try {
      final profile = await ProfileRepository().fetchProfile();
      _profile = profile;
      auth().profile = profile;
      _nameController.text = profile.name ?? '';
      _selectedCity = profile.city;
    } catch (e) {
      _profile = auth().profile;
      _nameController.text = _profile?.name ?? '';
      _selectedCity = _profile?.city;
    }

    try {
      final net = Network(endpoint: 'assets/cities');
      final response = await net.response(null);
      if (!response.hasError && response.data is List) {
        _cities = (response.data as List)
            .map((e) => City.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  String _safeAvatarUrl(String? avatarUrl, String? name) {
    if (avatarUrl != null && !avatarUrl.contains('ui-avatars.com')) {
      return avatarUrl;
    }
    final initial = (name ?? 'U').isNotEmpty ? name![0] : 'U';
    return 'https://ui-avatars.com/api/?name=$initial&color=FF7D41&background=FFF0E8&format=png&size=128';
  }

  /// Shows a bottom sheet to pick photo from camera or gallery
  void _showPhotoPickerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(FSizes.borderRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: FSizes.iconCircleSm,
              height: FSizes.xs,
              margin: const EdgeInsets.only(bottom: FSizes.md),
              decoration: BoxDecoration(
                color: FColors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Change Photo'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: FSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _photoOption(
                  icon: Iconsax.camera,
                  label: 'Camera'.tr,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _photoOption(
                  icon: Iconsax.gallery,
                  label: 'Gallery'.tr,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
        decoration: BoxDecoration(
          color: FColors.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: FColors.primaryColor),
            const SizedBox(height: FSizes.sm),
            Text(
              label,
              style: TextStyle(
                color: FColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Get.back(); // close bottom sheet
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: FColors.grey.withValues(alpha: 0.2),
                          backgroundImage: _pickedPhoto != null
                              ? FileImage(_pickedPhoto!)
                              : NetworkImage(
                                      _safeAvatarUrl(
                                        _profile?.avatar,
                                        _profile?.name,
                                      ),
                                    )
                                    as ImageProvider,
                          onBackgroundImageError: (_, __) {},
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showPhotoPickerSheet,
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
        ).textTheme.labelSmall?.copyWith(color: FColors.grey),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FSizes.xs),
        DropdownButtonFormField<City>(
          initialValue: _selectedCity,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          hint: Text(FTexts.profileCity.tr),
          items: _cities
              .map(
                (city) =>
                    DropdownMenuItem<City>(value: city, child: Text(city.name)),
              )
              .toList(),
          onChanged: (city) => setState(() => _selectedCity = city),
        ),
      ],
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
      FLoader.errorSnackBar(
        title: FTexts.profileUpdate.tr,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
