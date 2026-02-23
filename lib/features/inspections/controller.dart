import 'dart:async';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/models/order.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_repository.dart';
import 'package:fahis_inspector/resources/orders_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:fahis_inspector/util/constants/enums.dart';
import 'package:fahis_inspector/util/helpers/stage_mapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  InspectionsRepository? repository;
  OrdersRepository? ordersRepository;
  late final Box<Map> box;
  final ScrollController scrollController = ScrollController();
  RxList<Inspection> inspections = <Inspection>[].obs;
  RxList<Order> orders = <Order>[].obs;
  var isLoading = true.obs;

  // True when user has submitted a search query — bypasses segment/stage filters
  var isSearchActive = false.obs;

  // Pagination guard to prevent duplicate fetches
  bool _isFetchingNextPage = false;

  Stream<List<Inspection>> get stream => inspections.stream;

  RxList<InspectionStage> stages = RxList<InspectionStage>(
    InspectionStage.allStages,
  );

  var count = 0.obs;
  Rx<InspectionStage> selectedStage = Rx<InspectionStage>(InspectionStage.all);

  // 0 = Companies (شركات), 1 = Individuals (افراد)
  var selectedSegment = 1.obs; // Default to Individuals

  /// Inspections excluding reviewed/approved ones (no longer actionable).
  /// Used in the default All view. Explicit stage filter still shows them.
  List<Inspection> get _activeInspections =>
      inspections.where((i) => i.stage != InspectionStage.reviewed).toList();

  /// Groups inspections by customer name, returns only customers with 2+ requests
  Map<String, List<Inspection>> get companyGroups {
    final Map<String, List<Inspection>> grouped = {};
    for (final ins in _activeInspections) {
      final name = ins.customer?.name ?? '';
      grouped.putIfAbsent(name, () => []).add(ins);
    }
    // Only keep customers with multiple inspections
    grouped.removeWhere((_, list) => list.length < 2);
    dd('[Segments] companyGroups: ${grouped.length} companies');
    return grouped;
  }

  /// Returns inspections from b2c orders (converted from OrderItems)
  List<Inspection> get individualInspections {
    if (selectedStage.value != InspectionStage.all || isSearchActive.value) {
      // Filter/search mode: use old logic
      final Map<String, List<Inspection>> grouped = {};
      for (final ins in _activeInspections) {
        final name = ins.customer?.name ?? '';
        grouped.putIfAbsent(name, () => []).add(ins);
      }
      final singles = grouped.entries
          .where((e) => e.value.length == 1)
          .expand((e) => e.value)
          .toList();
      dd('[Segments] individualInspections (filter mode): ${singles.length} items');
      return singles;
    }

    // Orders mode: flatten order items for display
    final List<Inspection> converted = [];
    for (final order in orders) {
      for (final item in order.items) {
        converted.add(Inspection(
          id: item.id,
          slug: item.slug ?? '',
          customer: order.customer,
          vehicle: item.vehicle,
          stage: StageMapper.mapOrderItemStage(item.stage),
          uploadStatus: UploadStatus.live,
          createdDate: item.createdAt,
        ));
      }
    }
    dd('[Segments] individualInspections (orders mode): ${converted.length} items');
    return converted;
  }

  /// Switch between Companies and Individuals tabs
  void changeSegment(int index) {
    selectedSegment.value = index;
    update();
  }

  @override
  void onInit() async {
    super.onInit();

    box = await Hive.openBox<Map>("Inspections_User_${auth().user?.uid}");

    repository = InspectionsRepository(box: box, stage: selectedStage.value);
    ordersRepository = OrdersRepository(box: box, type: 'b2c');

    await loadOrders();
  }

  @override
  void onReady() {
    super.onReady();

    inspections.listen((_) => update());
    orders.listen((_) => update());

    scrollController.addListener(_onScroll);
  }

  /// Handles scroll-based pagination for both orders and inspections mode.
  void _onScroll() {
    if (_isFetchingNextPage) return;
    if (!scrollController.hasClients) return;

    final pos = scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;

    final isOrdersMode =
        selectedStage.value == InspectionStage.all && !isSearchActive.value;

    _isFetchingNextPage = true;

    if (isOrdersMode) {
      ordersRepository?.fetchNextPage().then((data) {
        orders.assignAll(data);
      }).whenComplete(() => _isFetchingNextPage = false);
    } else {
      repository?.fetchNextPage().then((data) {
        inspections.assignAll(data);
      }).whenComplete(() => _isFetchingNextPage = false);
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void changeStatus({InspectionStage newStage = InspectionStage.all}) async {
    selectedStage.value = newStage;

    if (newStage == InspectionStage.all) {
      // Reset to orders mode
      isSearchActive.value = false;
      inspections.clear();
      isLoading.value = true;
      update();
      await loadOrders(reset: true, cache: false);
    } else {
      // Switch to inspections filter mode
      inspections.clear();
      isLoading.value = true;
      update();
      await load(reset: true, stage: newStage, cache: false);
    }

    // Close drawer only on mobile (when drawer is open)
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  Future<void> load({
    String? query,
    InspectionStage? stage,
    bool reset = false,
    bool load = true,
    bool cache = true,
  }) async {
    // reload cached + api
    stage ??= selectedStage.value;

    // Guard: repository may not be initialized yet during async onInit
    if (repository == null) return;

    if (cache) {
      inspections.assignAll(repository!.fetchFromCache(stage: stage));
      update();
      if (load) {
        isLoading.value = inspections.isEmpty;
        update();
      }
    }

    try {
      while (auth().token == null) {
        await Future.delayed(Duration(seconds: 3));
      }

      inspections.assignAll(
        await repository!.fetchFromApi(query: query, stage: stage, reset: reset),
      );
    } finally {
      if (load) {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> loadOrders({
    String? query,
    String? status,
    bool reset = true,
    bool load = true,
    bool cache = true,
  }) async {
    if (ordersRepository == null) return;

    if (cache) {
      orders.assignAll(ordersRepository!.fetchFromCache(status: status));
      update();
      if (load) {
        isLoading.value = orders.isEmpty;
        update();
      }
    }

    try {
      while (auth().token == null) {
        await Future.delayed(Duration(seconds: 3));
      }

      orders.assignAll(
        await ordersRepository!.fetchFromApi(query: query, status: status, reset: reset),
      );
    } finally {
      if (load) {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> refreshPage() async {
    if (await FDeviceUtils.hasInternetConnection()) {
      if (selectedStage.value == InspectionStage.all && !isSearchActive.value) {
        // Orders mode
        orders.clear();
        isLoading.value = true;
        await loadOrders(reset: true, cache: false);
      } else {
        // Inspections mode
        inspections.clear();
        isLoading.value = true;
        await load(reset: true, cache: false);
      }
    }
  }

  Future<void> openInspection(Inspection inspection) async {
    try {
      await Get.toNamed(
        '${RoutingUrl.inspections}/${inspection.slug}',
        arguments: inspection,
      );
      // Refresh list when returning from details so stage labels are up to date
      if (selectedStage.value == InspectionStage.all && !isSearchActive.value) {
        loadOrders(reset: true);
      } else {
        load(reset: true);
      }
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    }
  }

  Future<void> openOrderItem(Order order, OrderItem item) async {
    try {
      String? slug = item.slug;

      // If slug is null, create the order item first
      if (slug == null) {
        isLoading.value = true;
        update();
        slug = await ordersRepository?.createOrderItem(item.id);
        isLoading.value = false;
        update();

        if (slug == null) {
          Get.snackbar(
            'Error'.tr,
            'Failed to create inspection'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Navigate to inspection details
      await Get.toNamed(
        '${RoutingUrl.inspections}/$slug',
      );

      // Refresh orders list
      loadOrders(reset: true);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    }
  }
}
