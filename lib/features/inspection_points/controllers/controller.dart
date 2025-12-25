import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_points/models/point.dart';
import 'package:fahis_inspector/features/inspection_points/repository/repository.dart';
import 'package:fahis_inspector/features/inspection_points/screens/editing_screen.dart';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPointsController extends GetxController {
  static InspectionPointsController get instance =>
      Get.find(tag: 'inspection-points');

  final String slug;
  late final Box box;
  late final InspectionPointsRepository repository;

  InspectionPointsController(this.slug);

  InspectionController get mainController => Get.find(tag: 'inspection');

  Inspection? get inspection => mainController.inspection.value;
  Inspection? get canEdit => mainController.inspection.value;
  
  RxList<Point> allPoints = RxList<Point>([]);
  Stream<List<Point>> get stream => allPoints.stream;

  Rxn<Category> category = Rxn<Category>();
  Stream<Category?> get categoryStream => category.stream;

  Rxn<ReviewPoint> review = Rxn<ReviewPoint>();
  Stream<ReviewPoint?> get reviewStream => review.stream;

  final isLoading = false.obs;

  final isEditing = false.obs;

  @override
  void onInit() async {
    super.onInit();
    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    box = await Hive.openBox(InspectionPointsRepository.boxKey);

    repository = InspectionPointsRepository(box: box, slug: slug);

    repository.stream.listen((data) {
      allPoints.assignAll(data);
      allPoints.refresh();
      update();
    });

    allPoints.listen((data) {
      review.value = ReviewPoint.set(data);
      review.refresh();
      category.value = category.value ?? review.value?.cats.firstOrNull;
      category.refresh();
      mainController.updateInspection(points: data);
      update();
    });

    // Always load cached
    if (! [InspectionStage.pending,InspectionStage.accepted].contains(mainController.inspection.value?.stage)) {
      fetchPoints();
    }
    print("init InspectionPoints");
  }

  void fetchPoints() async {
    // 1. Show cached first
    allPoints.assignAll(repository.fetchFromCache());
    // allPoints.refresh();

    // 2. Then refresh from API
    isLoading.value = allPoints.isEmpty;
    try {
      allPoints.assignAll(await repository.fetchFromApi());
      // allPoints.refresh();
    } finally {
      isLoading.value = false;
    }
  }

  void onEdit({Category? cat}) {
    category.value = cat ?? review.value!.cats.first;
    Get.to(InspectionPointsScreen());
  }

  void onChangeCategory({Category? cat}) {
    category.value = cat ?? review.value!.cats.first;
    Get.replace(InspectionPointsScreen());
  }

  void onChangeStatus(Point? point) {
    try {
      if (point != null) {
        repository.update(point);
      }
    } finally {
      update();
    }
  }
}
