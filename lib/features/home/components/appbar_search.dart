import 'dart:async';

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
  Timer? _debounce;

  late InspectionsController inspectionsController;

  @override
  void initState() {
    super.initState();
    inspectionsController = InspectionsBinding().instance;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      inspectionsController.load(reset: true);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      inspectionsController.load(
        query: query.trim(),
        reset: true,
        cache: false,
      );
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    controller.clear();
    focusNode.unfocus();
    setState(() => expanded = false);
    inspectionsController.load(reset: true);
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
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search by slug or plate...'.tr,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: FColors.primaryColor),
            suffixIcon: IconButton(
              icon: Icon(Icons.close, color: FColors.primaryColor),
              onPressed: _closeSearch,
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }
}
