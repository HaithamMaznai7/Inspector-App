import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Standalone screen wrapper for editing a single inspection section.
/// Shows an AppBar with a gradient, the section title, and a "Done" button.
/// The child widget is the actual step editor (e.g., VehicleDetailsView).
class SectionEditScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionEditScreen({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: FColors.primaryGradient),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.apply(color: FColors.white),
        ),
        leading: BackPageButton(color: FColors.white),
        actions: [
          // "Done" button — pops back to the details screen
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              InspectionPage.doneBtn.tr,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.apply(color: FColors.white),
            ),
          ),
        ],
      ),
      body: child,
    );
  }
}
