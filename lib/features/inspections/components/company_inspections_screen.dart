import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen showing all inspection requests for a specific company.
/// Navigated to when user taps a CompanyCard.
class CompanyInspectionsScreen extends StatefulWidget {
  final String companyName;
  final List<Inspection> inspections;

  const CompanyInspectionsScreen({
    super.key,
    required this.companyName,
    required this.inspections,
  });

  @override
  State<CompanyInspectionsScreen> createState() =>
      _CompanyInspectionsScreenState();
}

class _CompanyInspectionsScreenState extends State<CompanyInspectionsScreen> {
  late List<Inspection> _inspections;

  @override
  void initState() {
    super.initState();
    _inspections = List.from(widget.inspections);
  }

  /// Re-fetches all inspections, then filters for this company
  Future<void> _refresh() async {
    dd('[CompanyInspections] Refreshing data for ${widget.companyName}');
    final controller = InspectionsBinding().instance;
    // Re-fetch from API
    await controller.load(reset: true, cache: false);
    // Re-filter for this company from the updated data
    final updated = controller.inspections
        .where((i) => i.customer?.name == widget.companyName)
        .toList();
    dd('[CompanyInspections] Refreshed: ${updated.length} inspections');
    setState(() => _inspections = updated);
  }

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
              widget.companyName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            // Request count subtitle
            Text(
              '${_inspections.length} ${'requests'.tr}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FColors.textSecondary,
                  ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: FColors.primaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          itemCount: _inspections.length,
          itemBuilder: (context, index) {
            final inspection = _inspections[index];
            return InspectionCard(
              slug: inspection.slug,
              customerName: inspection.customer?.name,
              vehicle: inspection.vehicle,
              stage: inspection.stage,
              rejectedNote: inspection.rejectedNote,
              onTap: () async {
                await Get.toNamed(
                  '${RoutingUrl.inspections}/${inspection.slug}',
                  arguments: inspection,
                );
                _refresh();
              },
            );
          },
        ),
      ),
    );
  }
}
