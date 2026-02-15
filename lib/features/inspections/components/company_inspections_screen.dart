import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen showing all inspection requests for a specific company.
/// Navigated to when user taps a CompanyCard.
class CompanyInspectionsScreen extends StatelessWidget {
  final String companyName;
  final List<Inspection> inspections;

  const CompanyInspectionsScreen({
    super.key,
    required this.companyName,
    required this.inspections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FColors.softGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackPageButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company name
            Text(
              companyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            // Request count subtitle
            Text(
              '${inspections.length} ${'requests'.tr}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FColors.textSecondary,
                  ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        itemCount: inspections.length,
        itemBuilder: (context, index) {
          // Reuse existing InspectionCard for each request
          return InspectionCard(inspection: inspections[index]);
        },
      ),
    );
  }
}
