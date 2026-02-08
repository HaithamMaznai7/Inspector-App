import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/common/styles/spacing_style.dart';
import 'package:fahis_inspector/common/widgets/materials/inputs/dropdown_field.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/profile_repository.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Profile? profile = auth().profile;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  List<City> cities = [];

  var isUpdate = false;
  @override
  void initState() {
    nameController.text = auth().profile?.name ?? '';
    emailController.text = auth().profile?.email ?? '';
    phoneController.text = auth().profile?.mobile ?? '';
    cities = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: FSpacingStyle.paddingWithAppBarHeight,
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: FSizes.lg,
                          vertical: FSizes.md,
                        ),
                        child: StreamBuilder<Profile?>(
                          stream: ProfileRepository().getUser(profile: profile),
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            return Center(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: Get.width * .3,
                                    width: Get.width * .3,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: CircleAvatar(
                                            radius: Get.width * .3,
                                            backgroundColor: FColors.grey,
                                            child: user?.avatar != null
                                                ? EasyImageView(
                                                    imageProvider: NetworkImage(
                                                      user!.avatar!.startsWith(
                                                            EndPoints
                                                                .websiteUrl,
                                                          )
                                                          ? user.avatar!.replaceAll(
                                                              EndPoints
                                                                  .websiteUrl,
                                                              '${EndPoints.schema}://${EndPoints.domain}',
                                                            )
                                                          : user.avatar!,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    size: Get.width * .3,
                                                    color: FColors.primaryColor,
                                                  ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: IconButton(
                                            onPressed: () => _pickProfile(),
                                            icon: Icon(
                                              Iconsax.camera,
                                              color: FColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  buildEditableField(
                                    label: 'Name',
                                    value: user?.name ?? '',
                                    controller: nameController,
                                    prefixIcon: Icon(
                                      Iconsax.user,
                                      color: FColors.primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  buildEditableField(
                                    label: 'Email',
                                    value: user?.email ?? '',
                                    controller: emailController,
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: FColors.primaryColor,
                                    ),
                                    suffixIcon:
                                        (user?.emailVerification ?? false)
                                        ? Icon(
                                            Iconsax.verify,
                                            color: FColors.success,
                                          )
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
                                    prefixIcon: Icon(
                                      Iconsax.mobile,
                                      color: FColors.primaryColor,
                                    ),
                                    suffixIcon:
                                        (user?.mobileVerification ?? false)
                                        ? Icon(
                                            Iconsax.verify,
                                            color: FColors.success,
                                          )
                                        : Icon(
                                            Icons.vertical_distribute_sharp,
                                            color: FColors.error,
                                          ),
                                  ),
                                  SizedBox(height: 16.0),
                                  StreamBuilder<List<City>>(
                                    stream: AssetsRepository.getCities(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null &&
                                          snapshot.data!.isNotEmpty) {
                                        return FDropdownField<City>(
                                          label: 'Select City',
                                          items: snapshot.data!,
                                          onChanged: (value) => setState(() {
                                            profile!.city = value;
                                          }),
                                          value: profile?.city,
                                        );
                                      }

                                      return FDropdownField<City>(
                                        label: 'Select City',
                                        items: cities,
                                        onChanged: (value) => setState(() {
                                          user?.city = value;
                                        }),
                                        value: user?.city,
                                      );
                                    },
                                  ),

                                  isUpdate
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: FColors.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              FSizes.borderRadiusMd,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: FSizes.sm,
                                          ),
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
                                            style: Theme.of(
                                              context,
                                            ).elevatedButtonTheme.style,
                                            onPressed: () => user != null
                                                ? _updateProfile(user)
                                                : dd('No User'),
                                            child: Text('Update'),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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

  Future<void> _pickProfile() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await availableCameras();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // or use FileType.image, FileType.custom, etc.
      );

      if (result != null && result.files.single.path != null) {
        setState(() {});
      }
    }

    // Prpfile

    // auth().firebase.currentUser?.updatePhotoURL(photoURL)
  }

  Future<void> _updateProfile(Profile profile) async {
    setState(() {
      isUpdate = true;
    });

    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    formKey.currentState!.save();

    try {
      await ProfileRepository().updateProfile(profile);
    } catch (e) {
      rethrow;
    } finally {
      // isUpdate = !isUpdate;
      FFullScreenLoader.stopLoading();
    }
  }
}
