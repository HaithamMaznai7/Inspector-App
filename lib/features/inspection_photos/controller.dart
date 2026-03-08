import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/resources/inspection_photos_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ignore_for_file: avoid_print

/// Shorthand debug tag for photo controller logs.
void _log(String msg) {
  if (kDebugMode) print('[PHOTOS] $msg');
}

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

  /// Tracks photo IDs currently being uploaded — used to show shimmer.
  final RxList<int> uploadingIds = RxList<int>([]);

  /// Tracks photo IDs currently being deleted — used to suppress intermediate
  /// empty-list events from RxList.assignAll during the delete flow.
  final RxList<int> deletingIds = RxList<int>([]);

  /// True whenever any async mutation (upload or delete) is in flight.
  /// Used to skip the spurious empty-list event that RxList.assignAll emits
  /// during its internal clear() step.
  bool get _isMutating => uploadingIds.isNotEmpty || deletingIds.isNotEmpty;

  final isLoading = false.obs;
  final isResetting = false.obs;

  final isEditing = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _log('onInit — controller created');

    photos.listen((data) {
      // RxList.assignAll fires TWO events: first clear() → empty list, then
      // addAll() → full list. Skip the intermediate empty event during upload
      // so it never resets the user's active tab.
      if (data.isEmpty && _isMutating) {
        _log('photos.listen [onInit] fired — photos=0 during upload, SKIPPING');
        return;
      }

      _log('photos.listen [onInit] fired — '
          'photos=${data.length}, '
          'category.value=${category.value}');

      final newCats = data.map((p) => p.type).toSet().toList();
      categories.assignAll(newCats);
      categories.refresh();

      // Only auto-select a category on first load — never override the user's
      // active tab choice when photos update (e.g. after an upload).
      if (category.value == null && categories.isNotEmpty) {
        _log('photos.listen [onInit] → auto-selecting category: ${categories.first}');
        category.value = categories.first;
      } else if (categories.isEmpty) {
        _log('photos.listen [onInit] → categories empty, clearing category');
        category.value = null;
      } else {
        _log('photos.listen [onInit] → category kept at: ${category.value}');
      }

      update();
    });
  }

  @override
  void onReady() {
    super.onReady();
    _log('onReady — hasPhotos=${mainController.inspection.value?.hasPhotos}');

    if (mainController.inspection.value?.hasPhotos ?? false) {
      loadBySlug();
    }
  }

  Future<void> loadBySlug() async {
    _log('loadBySlug — start, resetting photos & category');
    isLoading.value = true;
    // RESET state
    photos.value = [];

    // Init cache + repo
    while (box == null && slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionPhotosRepository(box: box!, slug: slug!);

    repository.stream.listen((data) {
      _log('repository.stream → received ${data.length} photos, '
          'category.value=${category.value}');
      photos.assignAll(data);
      update();
    });

    category.listen((cat) {
      _log('category.listen → new value: $cat');
      filtered.assignAll(photos.where((photo) => photo.type == cat).toList());
      update();
    });

    photos.listen((data) {
      // Same guard as onInit listener: skip the intermediate empty-list event
      // that RxList.assignAll fires during its internal clear() step.
      if (data.isEmpty && _isMutating) {
        _log('photos.listen [loadBySlug] fired — photos=0 during upload, SKIPPING');
        return;
      }

      _log('photos.listen [loadBySlug] fired — '
          'photos=${data.length}, '
          'category.value=${category.value}');

      final newCats = data.map((p) => p.type).toSet().toList();
      categories.assignAll(newCats);
      categories.refresh();

      // Only auto-select a category on first load — never override the user's
      // active tab choice when photos update (e.g. after an upload).
      if (category.value == null && categories.isNotEmpty) {
        _log('photos.listen [loadBySlug] → auto-selecting: ${categories.first}');
        category.value = categories.first;
      } else if (categories.isEmpty) {
        _log('photos.listen [loadBySlug] → categories empty, clearing category');
        category.value = null;
      } else {
        _log('photos.listen [loadBySlug] → category kept at: ${category.value}');
      }

      update();
    });

    if (mainController.inspection.value?.hasPhotos ?? false) {
      fetchPhotos();
    }
  }

  Future<void> fetchPhotos() async {
    _log('fetchPhotos — loading from cache first');
    // 1. Show cached first
    photos.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = photos.isEmpty;
    update();

    try {
      _log('fetchPhotos — fetching from API');
      final fetched = await repository.fetchFromApi();
      _log('fetchPhotos — API returned ${fetched.length} photos');

      // 3. If the server returned no photos, auto-initialize them via POST,
      //    then re-fetch so the UI shows the newly created photo slots.
      if (fetched.isEmpty) {
        _log('fetchPhotos — generating initial slots via POST');
        await repository.generate();
        photos.assignAll(await repository.fetchFromApi());
      } else {
        photos.assignAll(fetched);
      }
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> picking(Photo photo) async {
    // Capture the user's active tab before any async gap so we can restore it
    // after the camera dialog and upload complete. The photos.listen callback
    // only auto-selects when category == null, but we keep this as a safety
    // net against any edge-case reset that might occur across async boundaries.
    final savedCategory = category.value;
    _log('picking — START | photo.id=${photo.id} | savedCategory=$savedCategory');

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cameras = await availableCameras();
      _log('picking — opening camera dialog');
      photo.file = await Get.dialog<File>(Camera(cameras: cameras));
      _log('picking — camera dialog closed | file=${photo.file != null ? "selected" : "cancelled"} | category.value=${category.value}');
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        photo.file = File(result.files.single.path!);
      }
      _log('picking — file picker closed | file=${photo.file != null ? "selected" : "cancelled"} | category.value=${category.value}');
    }

    // Only upload if file exists (user didn't cancel)
    if (photo.file != null) {
      _log('picking — upload START | category.value=${category.value}');
      uploadingIds.add(photo.id);
      update();
      try {
        await repository.update(photo);
        _log('picking — upload COMPLETE | category.value=${category.value}');
      } finally {
        uploadingIds.remove(photo.id);
        update();
      }
    }

    // Restore the user's active tab — guards against any reset that may have
    // happened across the camera dialog or upload async gaps.
    _log('picking — END | category.value=${category.value} | savedCategory=$savedCategory');
    if (savedCategory != null) {
      if (category.value != savedCategory) {
        _log('picking — RESTORING category from ${category.value} → $savedCategory');
      }
      category.value = savedCategory;
    }
    update();
  }

  Future<void> deleteAll() async {
    final savedCategory = category.value;
    _log('deleteAll — START | savedCategory=$savedCategory');
    isResetting.value = true;
    update();
    try {
      final reset = await repository.resetAll();
      _log('deleteAll — COMPLETE | photos=${reset.length}');
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      _log('deleteAll — ERROR: $e');
    } finally {
      isResetting.value = false;
      if (savedCategory != null) {
        category.value = savedCategory;
      }
      update();
    }
  }

  Future<void> delete(Photo photo) async {
    final savedCategory = category.value;
    _log('delete — photo.id=${photo.id} | savedCategory=$savedCategory');
    deletingIds.add(photo.id);
    try {
      await repository.delete(photo);
    } finally {
      deletingIds.remove(photo.id);
      if (savedCategory != null) {
        category.value = savedCategory;
      }
      update();
    }
  }
}
