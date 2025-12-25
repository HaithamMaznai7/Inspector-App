import 'package:fahis_inspector/common/widget/inputs/dropdown_field.dart';
import 'package:fahis_inspector/features/configuration/repository/config_repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/authentication/models/city.dart';
import 'package:fahis_inspector/services/authentication/models/user.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  User? user = Auth.user;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  List<City> cities = [];

  var isUpdate = false;
  @override
  void initState() {
    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    phoneController.text = user?.mobile ?? '';
    cities = [];

    _loadCities();
    super.initState();
  }

  _loadCities() async {
    final allCities = await ConfigRepository.getCities();
    setState(() {
      cities = allCities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: FSizes.lg,
            vertical: FSizes.md,
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                // user?.avatar != null
                //     ? Image.network(user!.avatar!)
                //     : CircleAvatar(
                //         radius: 50,
                //         backgroundColor: FColors.grey,
                //         child: Icon(
                //           Icons.person,
                //           size: 50.0,
                //           color: FColors.primaryColor,
                //         ),
                //       ),
                SizedBox(height: 16.0),
                buildEditableField(
                  label: 'Name',
                  value: user?.name ?? '',
                  controller: nameController,
                  prefixIcon: Icon(Iconsax.user, color: FColors.primaryColor),
                ),
                SizedBox(height: 16.0),
                buildEditableField(
                  label: 'Email',
                  value: user?.email ?? '',
                  controller: emailController,
                  prefixIcon: Icon(Icons.email, color: FColors.primaryColor),
                  suffixIcon: (user?.emailVerification != null)
                      ? Icon(Iconsax.verify, color: FColors.success)
                      : Icon(
                          Icons.vertical_distribute_sharp,
                          color: FColors.error,
                        ),
                ),
                SizedBox(height: 16.0),
                buildEditableField(
                  label: 'Phone Number',
                  value: user?.mobile ?? '',
                  controller: phoneController,
                  prefixIcon: Icon(Iconsax.mobile, color: FColors.primaryColor),
                  suffixIcon: (user?.mobileVerification != null)
                      ? Icon(Iconsax.verify, color: FColors.success)
                      : Icon(
                          Icons.vertical_distribute_sharp,
                          color: FColors.error,
                        ),
                ),
                SizedBox(height: 16.0),
                FDropdownField<City>(
                  label: 'Select City',
                  items: cities,
                  onChanged: (value) => setState(() {
                    user?.city = value;
                  }),
                  value: user?.city,
                ),

                isUpdate
                    ? Container(
                        decoration: BoxDecoration(
                          color: FColors.primaryColor,
                          borderRadius: BorderRadius.circular(
                            FSizes.borderRadiusMd,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: FSizes.sm),
                        width: double.infinity,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: FColors.white,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: Theme.of(context).elevatedButtonTheme.style,
                          onPressed: () => _updateProfile(),
                          child: Text('Update'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required String value,
    required TextEditingController controller,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    controller.text = value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: const OutlineInputBorder(),
              hintText: "Enter $label",
            ),
          ),
        ],
      ),
    );
  }

  _updateProfile() async {
    FFullScreenLoader.openLoadingDialog(page: Center(
      child: CircularProgressIndicator(color: FColors.primaryColor)
    ));

    final isValid = user != null && formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    try {
      user!.name = nameController.text;
      user!.email = emailController.text.trim();
      user!.city = user?.city;

      await Auth.userRepo?.updateProfile(user!);
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      // isUpdate = !isUpdate;
      FFullScreenLoader.stopLoading();
    }
  }
}
