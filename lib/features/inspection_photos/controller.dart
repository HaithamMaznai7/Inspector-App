import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/resources/inspection_photos_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPhotosController extends GetxController {
  late InspectionPhotosRepository repository;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  Box<List>? get box => mainController.assetsBox;
  String? get slug => mainController.slug;

  RxList<Photo> photos = RxList<Photo>([]);
  RxList<Photo> filtered = RxList<Photo>([]);
  RxList<String> categories = RxList<String>([]);
  RxnString category = RxnString();

  final isLoading = false.obs;

  final isEditing = false.obs;

  @override
  void onInit() async {
    super.onInit();

    photos.listen((data) {
      categories.assignAll(data.map((p) => p.type).toSet().toList());
      categories.refresh();

      if (categories.isNotEmpty) {
        category.value = data.firstOrNull?.type ?? categories.first;
      } else {
        category.value = null; // nothing selected if no categories
      }

      // mainController.updateInspection(photos: data);
      category.value = data.firstOrNull?.type ?? categories.firstOrNull;
      // mainController.updateInspection(photos: data);
      update();
    });
  }

  @override
  void onReady() {
    super.onReady();

    // Initial load
    // Always load cached
    if (mainController.inspection.value?.hasPhotos ?? false) {
      loadBySlug();
    }
    // repository.listenToBroadcast().listen((data) {
    //   dd('data from broadcast');
    //   dd(data);
    // });
  }

  Future<void> loadBySlug() async {
    isLoading.value = true;
    // RESET state
    photos.value = [];

    // Init cache + repo
    while (box == null && slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionPhotosRepository(box: box!, slug: slug!);

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
        category.value = data.firstOrNull?.type ?? categories.first;
      } else {
        category.value = null; // nothing selected if no categories
      }

      // mainController.updateInspection(photos: data);
      update();
    });

    if (mainController.inspection.value?.hasPhotos ?? false) {
      fetchPhotos();
    }
  }

  Future<void> fetchPhotos() async {
    // 1. Show cached first
    photos.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = photos.isEmpty;
    update();

    try {
      photos.assignAll(await repository.fetchFromApi());
    } on FNetworkException catch (_) {
      // e.notify();
    } catch (_) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> picking(Photo photo) async {
    final cat = category.value;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cameras = await availableCameras();
      photo.file = await Get.dialog<File>(Camera(cameras: cameras));
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
