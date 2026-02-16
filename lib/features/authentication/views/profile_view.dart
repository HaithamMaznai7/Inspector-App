import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
      _nameController.text = profile.name ?? '';
      _selectedCity = profile.city;
    } catch (e) {
      // Fallback to cached auth profile
      _profile = auth().profile;
      _nameController.text = _profile?.name ?? '';
      _selectedCity = _profile?.city;
    }

    // Load cities (single call, not a stream)
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

  /// Builds a safe avatar URL. The default ui-avatars.com returns SVG
  /// which Flutter cannot decode — force PNG format.
  String _safeAvatarUrl(String? avatarUrl, String? name) {
    if (avatarUrl != null && !avatarUrl.contains('ui-avatars.com')) {
      return avatarUrl;
    }
    final initial = (name ?? 'U').isNotEmpty ? name![0] : 'U';
    return 'https://ui-avatars.com/api/?name=$initial&color=FF7D41&background=FFF0E8&format=png&size=128';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(FTexts.profileTitle.tr)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.lg,
              ),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: FColors.grey.withValues(alpha: 0.2),
                      backgroundImage: NetworkImage(
                        _safeAvatarUrl(_profile?.avatar, _profile?.name),
                      ),
                      onBackgroundImageError: (_, __) {},
                      child: _profile?.avatar == null
                          ? Icon(
                              Iconsax.user,
                              size: 50,
                              color: FColors.primaryColor,
                            )
                          : null,
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

                  // Email (read-only info)
                  _buildInfoTile(
                    icon: Iconsax.sms,
                    label: FTexts.profileEmail.tr,
                    value: _profile?.email ?? '-',
                  ),
                  const SizedBox(height: FSizes.sm),

                  // Phone (read-only info)
                  _buildInfoTile(
                    icon: Iconsax.call,
                    label: FTexts.profilePhone.tr,
                    value: _profile?.mobile ?? '-',
                  ),
                  const SizedBox(height: FSizes.md),

                  // City dropdown (loaded once)
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
                              height: 20,
                              width: 20,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
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
      await ProfileRepository().updateProfile(
        name: name,
        cityId: _selectedCity?.id,
      );
      FLoader.successSnackBar(title: FTexts.profileUpdate.tr);
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
