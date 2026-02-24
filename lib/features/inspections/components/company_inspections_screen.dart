import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/order.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/stage_mapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen showing all order items (vehicles) for a specific B2B order.
/// Navigated to when user taps a CompanyCard.
class CompanyInspectionsScreen extends StatefulWidget {
  final String companyName;
  final Order order;

  const CompanyInspectionsScreen({
    super.key,
    required this.companyName,
    required this.order,
  });

  @override
  State<CompanyInspectionsScreen> createState() =>
      _CompanyInspectionsScreenState();
}

class _CompanyInspectionsScreenState extends State<CompanyInspectionsScreen> {
  late Order _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  /// Re-fetches B2B orders, then finds the updated version of this order
  Future<void> _refresh() async {
    dd('[CompanyInspections] Refreshing data for ${widget.companyName}');
    final controller = InspectionsBinding().instance;
    await controller.loadOrdersB2B(reset: true, cache: false);
    // Find the updated order by ID
    final updated = controller.ordersB2B
        .firstWhereOrNull((o) => o.id == widget.order.id);
    if (updated != null) {
      setState(() => _order = updated);
    }
    dd('[CompanyInspections] Refreshed: ${_order.items.length} items');
  }

  @override
  Widget build(BuildContext context) {
    final controller = InspectionsBinding().instance;

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
            // Vehicle count subtitle
            Text(
              '${_order.meta.total} ${'Vehicles'.tr}',
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
          itemCount: _order.items.length,
          itemBuilder: (context, index) {
            final item = _order.items[index];
            return InspectionCard(
              slug: item.slug,
              customerName: _order.customer.name,
              vehicle: item.vehicle,
              stage: StageMapper.mapOrderItemStage(item.stage),
              rejectedNote: null,
              onTap: () async {
                await controller.openB2BOrderItem(_order, item);
                _refresh();
              },
            );
          },
        ),
      ),
    );
  }
}
