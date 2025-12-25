import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/models/inspection_body_notes.dart';
import 'package:fahis_inspector/features/inspection_body_notes/repository/repository.dart';
import 'package:fahis_inspector/features/inspection_body_notes/screens/widgets/card.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionBodyController extends GetxController {
  final String slug;
  late final Box box;
  late final InspectionBodyRepository repository;

  static InspectionBodyController get instance =>
      Get.find(tag: 'inspection-body');

  InspectionBodyController(this.slug);
  InspectionController get mainController => Get.find(tag: 'inspection');

  final RxList<CarBody> bodySides = RxList<CarBody>([]);
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    box = await Hive.openBox(InspectionBodyRepository.boxKey);

    repository = InspectionBodyRepository(box: box, slug: slug);

    repository.stream.listen((data) {
      bodySides.assignAll(data);
      update();
    });

    bodySides.listen((data) {
      mainController.updateInspection(bodySides: data);
    });

    if (! [InspectionStage.pending,InspectionStage.accepted].contains(mainController.inspection.value?.stage)) {
      fetchBodySides();
    }
  }

  Future<void> fetchBodySides() async {
    // 1. Show cached first
    bodySides.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = bodySides.isEmpty;
    try {
      bodySides.assignAll(await repository.fetchFromApi());
    } finally {
      isLoading.value = false;
      // update();
    }
  }

  @override
  void onReady() {
    super.onReady();

    // repository.listenToBroadcast().listen((data) {
    //   bodySides.assignAll(data); // update UI
    // });
  }

  onCreateEdit(CarBody body, Marker marker) async {
    final result = await Get.dialog<Marker>(
      InspectionBodyNotesDialog(note: marker),
    );

    if (result != null && result.id == 0) {
      await repository.store(body, result);
    } else if (result != null) {
      await repository.update(marker);
    }
  }

  Future<void> onRemove(Marker note) async {
    try {
      await repository.delete(note);
    } finally {
      update();
    }
  }
}
