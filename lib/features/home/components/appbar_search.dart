import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarSearch extends StatefulWidget {
  final ValueChanged<bool>? onSearchStateChanged;
  
  const AppBarSearch({super.key, this.onSearchStateChanged});

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch> {
  bool expanded = false;
  final controller = TextEditingController();
  final focusNode = FocusNode();
  late InspectionsController inspectionsController;

  @override
  void initState() {
    super.initState();
    inspectionsController = InspectionsBinding().instance;
  }

  void _setExpanded(bool value) {
    setState(() => expanded = value);
    widget.onSearchStateChanged?.call(value);
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    focusNode.unfocus();
    inspectionsController.inspections.clear();
    inspectionsController.isLoading.value = true;
    inspectionsController.update();
    inspectionsController.load(
      query: trimmed,
      reset: true,
      cache: false,
    );
  }

  void _closeSearch() {
    controller.clear();
    focusNode.unfocus();
    _setExpanded(false);
    inspectionsController.inspections.clear();
    inspectionsController.isLoading.value = true;
    inspectionsController.update();
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
        _setExpanded(true);
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
          onSubmitted: _submitSearch,
        ),
      ),
    );
  }
}
