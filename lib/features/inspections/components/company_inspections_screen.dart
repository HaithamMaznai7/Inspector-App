import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/features/inspections/components/inspection_card.dart';
import 'package:fahis_inspector/features/inspections/controller.dart';
import 'package:fahis_inspector/models/order.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
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
  late final InspectionsController _controller;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _controller = InspectionsBinding().instance;

    // Log what the CompanyCard passed in — this is the data driving the card chips
    AppLogger.info(
      'CompanyInspectionsScreen',
      'Opened — ${widget.companyName} (order #${_order.id})',
      {
        'order_slug': _order.slug,
        'order_status': _order.status,
        'business_type': _order.businessType,
        // OrderMeta fields — these are the source for CompanyCard status chips
        'meta.total (total vehicles label)': _order.meta.total,
        'meta.finishedCount → Completed chip': _order.meta.finishedCount,
        'meta.processedCount → In Progress chip': _order.meta.processedCount,
        'meta.rejectedCount → Rejected chip': _order.meta.rejectedCount,
        // Actual items in the payload (may differ from meta if paginated)
        'items_in_payload': _order.items.length,
      },
    );

    // Log each item's stage for tracing individual inspection states
    for (var i = 0; i < _order.items.length; i++) {
      final item = _order.items[i];
      AppLogger.trace(
        'CompanyInspectionsScreen',
        'Item[$i] id=${item.id} stage=${item.stage}',
        {
          'slug': item.slug ?? '(null — not started)',
          'vehicle': '${item.vehicle.make?.label} ${item.vehicle.model?.label} ${item.vehicle.year}',
          'inspection_type': item.inspectionType?.title ?? '(none)',
          'enable': item.enable,
          'report': item.report ?? '(none)',
        },
      );
    }
  }

  /// Re-fetches B2B orders, then finds the updated version of this order
  Future<void> _refresh() async {
    AppLogger.trace(
      'CompanyInspectionsScreen',
      'Refreshing — ${widget.companyName} (order #${widget.order.id})',
    );
    await _controller.loadOrdersB2B(reset: true, cache: false);
    // Find the updated order by ID
    final updated = _controller.ordersB2B
        .firstWhereOrNull((o) => o.id == widget.order.id);
    if (updated != null && mounted) {
      setState(() => _order = updated);
      AppLogger.info(
        'CompanyInspectionsScreen',
        'Refresh complete — ${_order.items.length} items',
        {
          'meta.total': _order.meta.total,
          'meta.finishedCount': _order.meta.finishedCount,
          'meta.processedCount': _order.meta.processedCount,
          'meta.rejectedCount': _order.meta.rejectedCount,
        },
      );
    } else {
      AppLogger.warn(
        'CompanyInspectionsScreen',
        'Order #${widget.order.id} not found in refreshed B2B list',
      );
    }
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
              inspectionTypeTitle: item.inspectionType?.title,
              onTap: () async {
                await _controller.openB2BOrderItem(_order, item);
                if (mounted) _refresh();
              },
            );
          },
        ),
      ),
    );
  }
}
