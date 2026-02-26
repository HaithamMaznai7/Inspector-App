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
  OrdersRepository? ordersRepositoryB2B;
  late final Box<Map> box;
  final ScrollController scrollController = ScrollController();
  RxList<Inspection> inspections = <Inspection>[].obs;
  RxList<Order> orders = <Order>[].obs;
  RxList<Order> ordersB2B = <Order>[].obs;
  var isLoading = true.obs;
  var isLoadingB2B = false.obs;

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

  /// B2B orders filtered to exclude b2c (backend may return mixed types)
  List<Order> get b2bOrders =>
      ordersB2B.where((o) => o.businessType != 'b2c').toList();

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
    // Lazy-load b2b data on first switch to Companies tab
    if (index == 0 && ordersB2B.isEmpty && !isLoadingB2B.value) {
      isLoadingB2B.value = true;
      loadOrdersB2B(cache: false);
    }
    update();
  }

  @override
  void onInit() async {
    super.onInit();

    box = await Hive.openBox<Map>("Inspections_User_${auth().user?.uid}");

    repository = InspectionsRepository(box: box, stage: selectedStage.value);
    ordersRepository = OrdersRepository(box: box, type: 'b2c');
    ordersRepositoryB2B = OrdersRepository(box: box, type: 'b2b');

    // Skip cache on init — cache is keyed by user UID only, not by team,
    // so after a team switch it would briefly show the previous team's orders.
    await loadOrders(cache: false);
  }

  @override
  void onReady() {
    super.onReady();

    inspections.listen((_) => update());
    orders.listen((_) => update());
    ordersB2B.listen((_) => update());

    scrollController.addListener(_onScroll);
  }

  /// Handles scroll-based pagination for orders, b2b, and inspections mode.
  void _onScroll() {
    if (_isFetchingNextPage) return;
    if (!scrollController.hasClients) return;

    final pos = scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;

    final isDefaultMode =
        selectedStage.value == InspectionStage.all && !isSearchActive.value;

    _isFetchingNextPage = true;

    if (isDefaultMode && selectedSegment.value == 0) {
      // Companies tab (b2b)
      ordersRepositoryB2B?.fetchNextPage().then((data) {
        ordersB2B.assignAll(data);
      }).whenComplete(() => _isFetchingNextPage = false);
    } else if (isDefaultMode) {
      // Individuals tab (b2c)
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

  /// After data loads, checks if the list content fills the viewport.
  /// If not and more pages exist, auto-fetches the next page.
  /// This handles the case where cards are too few to enable scrolling.
  void _autoLoadMoreIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      if (_isFetchingNextPage) return;

      final pos = scrollController.position;
      // If content doesn't overflow (can't scroll), load more
      if (pos.maxScrollExtent <= 0) {
        final isDefaultMode =
            selectedStage.value == InspectionStage.all && !isSearchActive.value;

        if (isDefaultMode && selectedSegment.value == 0) {
          _fetchNextB2BPage();
        } else if (isDefaultMode) {
          _fetchNextB2CPage();
        }
      }
    });
  }

  void _fetchNextB2BPage() {
    if (_isFetchingNextPage) return;
    _isFetchingNextPage = true;
    ordersRepositoryB2B?.fetchNextPage().then((data) {
      ordersB2B.assignAll(data);
      // Check again after this page loads
      _autoLoadMoreIfNeeded();
    }).whenComplete(() => _isFetchingNextPage = false);
  }

  void _fetchNextB2CPage() {
    if (_isFetchingNextPage) return;
    _isFetchingNextPage = true;
    ordersRepository?.fetchNextPage().then((data) {
      orders.assignAll(data);
      _autoLoadMoreIfNeeded();
    }).whenComplete(() => _isFetchingNextPage = false);
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
      _autoLoadMoreIfNeeded();
    } finally {
      if (load) {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> refreshPage() async {
    if (await FDeviceUtils.hasInternetConnection()) {
      final isDefaultMode =
          selectedStage.value == InspectionStage.all && !isSearchActive.value;

      if (isDefaultMode && selectedSegment.value == 0) {
        // Companies tab (b2b)
        ordersB2B.clear();
        isLoadingB2B.value = true;
        await loadOrdersB2B(reset: true, cache: false);
      } else if (isDefaultMode) {
        // Individuals tab (b2c)
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

  /// Open an order item from a B2B order (Companies tab).
  /// Same null-slug logic as b2c, but refreshes b2b data on return.
  Future<void> openB2BOrderItem(Order order, OrderItem item) async {
    try {
      String? slug = item.slug;

      if (slug == null) {
        isLoadingB2B.value = true;
        update();
        slug = await ordersRepositoryB2B?.createOrderItem(item.id);
        isLoadingB2B.value = false;
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

      await Get.toNamed(
        '${RoutingUrl.inspections}/$slug',
      );

      // Refresh b2b orders list
      loadOrdersB2B(reset: true);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    }
  }

  /// Load B2B orders from API
  Future<void> loadOrdersB2B({
    String? query,
    String? status,
    bool reset = true,
    bool load = true,
    bool cache = true,
  }) async {
    if (ordersRepositoryB2B == null) return;

    if (cache) {
      ordersB2B.assignAll(ordersRepositoryB2B!.fetchFromCache(status: status));
      update();
      if (load) {
        isLoadingB2B.value = ordersB2B.isEmpty;
        update();
      }
    }

    try {
      while (auth().token == null) {
        await Future.delayed(Duration(seconds: 3));
      }

      ordersB2B.assignAll(
        await ordersRepositoryB2B!.fetchFromApi(query: query, status: status, reset: reset),
      );
      _autoLoadMoreIfNeeded();
    } finally {
      if (load) {
        isLoadingB2B.value = false;
        update();
      }
    }
  }
}
