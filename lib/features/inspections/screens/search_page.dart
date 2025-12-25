import 'package:fahis_inspector/features/inspections/controllers/home_controller.dart';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/features/inspections/screens/widgets/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/screens/widgets/on_loading_home_page.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:iconsax/iconsax.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final controller = HomeController.instance;
  bool _searching = false;
  List<Inspection> inspections = [];
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(FSizes.md),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: HomePage.searchHint.tr,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _search,
                  ),
                  prefixIcon: IconButton(
                    onPressed: _back,
                    icon: Icon(
                      FLocalization.isArabic
                          ? Iconsax.arrow_right_3
                          : Iconsax.arrow_left_2,
                      color: FColors.primaryColor,
                    ),
                  ),
                ),
                autofocus: true,
                onChanged: (text) => _search(value: text),
                onSubmitted: (text) => _search(value: text),
              ),
              Divider(color: FColors.grey),
              if (inspections.isNotEmpty)
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: inspections
                        .map((item) => InspectionCard(inspection: item))
                        .toList(),
                  ),
                ),
              if (_searching) PlaceHolderRequestCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _back() => Get.back();

  _search({String? value}) async {
    setState(() {
      _searching = true;
    });
    value = value ?? _searchController.text;
    inspections = controller.inspections
        .where((inspection) => inspection.slug.contains(value!))
        .toList();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _searching = false;
    });
  }

  Future<void> fetch() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
