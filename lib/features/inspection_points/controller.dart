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
import 'package:fahis_inspector/util/http/network_exception.dart';
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

  @override
  void onInit() async {
    super.onInit();

    // Init cache + repo
    while (box == null || slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionPointsRepository(slug: slug!, box: box!);
    dd('inspection points initialized');
  }

  @override
  void onClose() {
    super.onClose();

    repositorySubscribtion.cancel();
    allPointsSubscribtion.cancel();
    dd('inspection points closed');
  }

  @override
  void onReady() {
    super.onReady();
    // Run on first load AND every URL change

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

  Future<void> load({bool isRefresh = false}) async {
    // RESET state
    if (isRefresh) {
      allPoints.value = [];
      isLoading.value = true;
      update();
    } else {
      allPoints.value = repository.fetchFromCache();
      isLoading.value = allPoints.isEmpty;
      update();
    }

    allPoints.value = await repository.fetchFromApi();

    isLoading.value = false;
    update();
  }

  void onEdit({PointCategory? cat}) {
    category.value = cat ?? review.value!.cats.first;
    Get.to(InspectionPointsScreen());
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

  void onChangeCategory({PointCategory? cat}) {
    category.value = cat ?? review.value!.cats.first;
    Get.replace(InspectionPointsScreen());
  }

  Future<void> onChangePoint(Point point, PointStatus status) async {
    await repository.update(point, status);
  }
}
