import 'dart:async';

import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_points/components/generate_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/resources/inspection_points_repository.dart';
import 'package:fahis_inspector/features/inspection_points/components/editing_screen.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/models/point_category.dart';
import 'package:fahis_inspector/models/review_point.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPointsController extends GetxController {
  late InspectionPointsRepository repository;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  Box<List>? get box => mainController.assetsBox;
  String? get slug => mainController.slug;

  Inspection? get inspection => mainController.inspection.value;
  Inspection? get canEdit => mainController.inspection.value;

  RxList<Point> allPoints = RxList<Point>([]);
  Stream<List<Point>> get stream => allPoints.stream;

  Rxn<PointCategory> category = Rxn<PointCategory>();
  Stream<PointCategory?> get categoryStream => category.stream;

  Rxn<ReviewPoint> review = Rxn<ReviewPoint>();
  Stream<ReviewPoint?> get reviewStream => review.stream;

  late StreamSubscription repositorySubscribtion;
  late StreamSubscription allPointsSubscribtion;

  final isLoading = false.obs;

  final isEditing = false.obs;

  Worker? _reconnectWorker;
  bool _repositoryReady = false;

  /// Whether [pointId] has a pending upload that hasn't synced to the server yet.
  bool hasPendingPoint(int pointId) =>
      _repositoryReady && repository.hasPendingPoint(pointId);

  @override
  void onInit() async {
    super.onInit();

    // Init cache + repo
    while (box == null || slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionPointsRepository(slug: slug!, box: box!);
    _repositoryReady = true;
    dd('inspection points initialized');
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    repositorySubscribtion.cancel();
    allPointsSubscribtion.cancel();
    super.onClose();
    dd('inspection points closed');
  }

  @override
  void onReady() {
    super.onReady();

    _reconnectWorker = ever(
      ConnectionService.instance.onReconnect,
      (_) { if (_repositoryReady) repository.flushPending(); },
    );

    repositorySubscribtion = repository.stream.listen((data) {
      allPoints.assignAll(data);
      update();
    });

    allPointsSubscribtion = allPoints.listen((data) {
      review.value = ReviewPoint.set(data);
      // review.refresh();
      category.value = category.value ?? review.value?.cats.firstOrNull;
      // category.refresh();
      // mainController.updateInspection(points: data);
      update();
    });

    // Initial load
    // Always load cached
    if (mainController.inspection.value?.hasPoints ?? false) {
      load();
    }
  }

  /// Loads points from cache first (instant UI), then fetches fresh
  /// data from the API. We only call repo methods here — the repo
  /// sets its internal `_data` RxList, which fires the repo stream,
  /// which the `repositorySubscribtion` listener picks up to update
  /// `allPoints` exactly once. We do NOT set `allPoints` directly
  /// here to avoid a circular listener loop (Stack Overflow).
  Future<void> load({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      update();
    } else {
      // Load from cache — triggers repo stream → allPoints listener
      repository.fetchFromCache();
      isLoading.value = allPoints.isEmpty;
      update();
    }

    // Fetch from API — triggers repo stream → allPoints listener
    await repository.fetchFromApi();

    isLoading.value = false;
    update();

    // Flush any points pending from a prior offline session.
    await repository.flushPending();
  }

  /// Opens the editing screen for a specific category.
  /// When the user presses "Done" or navigates back, we reload
  /// points from cache (instant UI) then fetch fresh data from API
  /// so the results page always shows up-to-date data.
  Future<void> onEdit({PointCategory? cat}) async {
    category.value = cat ?? review.value!.cats.first;
    await Get.to(() => const InspectionPointsScreen());
    // Reload points — repo stream → allPoints listener → review rebuilt
    await load();
  }

  void generate() async {
    if (await Get.dialog(GenerateDialog()) ?? false) {
      isLoading.value = true;
      update();
      await repository.generate();
      isLoading.value = false;
      update();
    }
  }

  Future<void> onRefresh() async {
    await load(isRefresh: true);
  }

  Future<void> onChangePoint(Point point, PointStatus status) async {
    // Trigger an immediate rebuild so the progress bar reflects the
    // local state change (point already mutated by PointCard) before
    // the API call returns.
    update();
    await repository.update(point, status);
  }

  // ── category navigation helpers ─────────────────────────────────────────────

  List<PointCategory> get categories => review.value?.cats ?? [];

  int get currentCategoryIndex => categories.indexWhere(
        (c) => c.category.id == category.value?.category.id,
      );

  bool get isOnFirstCategory => currentCategoryIndex <= 0;

  bool get isOnLastCategory =>
      currentCategoryIndex >= categories.length - 1;

  void setCategory(PointCategory cat) {
    category.value = cat;
    update();
  }

  void toNextCategory() {
    final idx = currentCategoryIndex;
    final cats = categories;
    if (idx < cats.length - 1) {
      category.value = cats[idx + 1];
      update();
    }
  }

  void toPreviousCategory() {
    final idx = currentCategoryIndex;
    if (idx > 0) {
      category.value = categories[idx - 1];
      update();
    }
  }
}
