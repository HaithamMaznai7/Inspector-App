import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarSearch extends StatefulWidget {
  const AppBarSearch({super.key});

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch> {
  bool expanded = false;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool sheetOpened = false;

  late InspectionsController inspectionsController;
  @override
  void initState() {
    super.initState();
    inspectionsController = InspectionsBinding().instance;
    focusNode.addListener(() {
      if (focusNode.hasFocus && !sheetOpened) {
        sheetOpened = true;
      } else {
        sheetOpened = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: expanded ? _searchField() : _searchIcon(),
    );
  }

  Widget _searchIcon() {
    return IconButton(
      key: const ValueKey('icon'),
      icon: Icon(Icons.search, color: FColors.primaryColor),
      onPressed: () {
        setState(() => expanded = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          focusNode.requestFocus();
        });
        // FDeviceUtils.isKeyboardVisible().then((isShow) {
        //   if (!kIsWeb) {
        //     View.of(Get.context!).;
        //   }
        // });
      },
    );
  }

  Widget _searchField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: FSizes.md),
      width: FDeviceUtils.getScreenWidth() * .85,
      child: Center(
        child: TextField(
          key: const ValueKey('field'),
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search...'.tr,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: FColors.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: FColors.primaryColor),
              onPressed: () async {
                setState(() => expanded = false);
                inspectionsController.isLoading.toggle();
                await inspectionsController.load();
              },
            ),
          ),
          onChanged: (value) async =>
              await inspectionsController.load(query: value),
        ),
      ),
    );
  }
}
