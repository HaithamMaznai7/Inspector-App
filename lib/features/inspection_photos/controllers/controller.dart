import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:fahis_inspector/common/controllers/camera_capture.dart';
import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/models/photo.dart';
import 'package:fahis_inspector/features/inspection_photos/repository/repository.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPhotosController extends GetxController {
  static InspectionPhotosController get instance =>
      Get.find(tag: 'inspection-album');

  final String slug;
  late final Box box;
  late final InspectionPhotosRepository repository;

  InspectionPhotosController(this.slug);

  InspectionController get mainController => Get.find(tag: 'inspection');

  final RxList<Photo> photos = RxList<Photo>([]);
  final RxList<Photo> filtered = RxList<Photo>([]);
  final RxList<String> categories = RxList<String>([]);
  final RxnString category = RxnString();

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

    box = await Hive.openBox(InspectionPhotosRepository.boxKey);

    repository = InspectionPhotosRepository(box: box, slug: slug);

    repository.stream.listen((data) {
      photos.assignAll(data);
      update();
    });

    category.listen((cat) {
      filtered.assignAll(photos.where((photo) => photo.type == cat).toList());
      update();
    });

    photos.listen((data) {
      categories.assignAll(data.map((p) => p.type).toSet().toList());
      categories.refresh();

      if (categories.isNotEmpty) {
        category.value = categories.first;
      } else {
        category.value = null; // nothing selected if no categories
      }

      mainController.updateInspection(photos: data);
      update();
    });

    if (![
      InspectionStage.pending,
      InspectionStage.accepted,
    ].contains(mainController.inspection.value?.stage)) {
      fetchPhotos();
    }
  }

  Future<void> fetchPhotos() async {
    // 1. Show cached first
    photos.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = photos.isEmpty;
    try {
      photos.assignAll(await repository.fetchFromApi());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> picking(Photo photo) async {
    final cat = category.value;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cameras = await availableCameras();
      photo.file = await Get.dialog<File>(CameraImagePicker(cameras: cameras));
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // or use FileType.image, FileType.custom, etc.
      );

      if (result != null && result.files.single.path != null) {
        photo.file = File(result.files.single.path!);
      }
    }

    await repository.update(photo);
    category.value = cat;
    update();
  }

  Future<void> delete(Photo photo) async {
    await repository.delete(photo);
  }
}
