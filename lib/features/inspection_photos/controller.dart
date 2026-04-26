import 'dart:io';

import 'package:fahis_inspector/common/widgets/camera/image_source_picker.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/resources/inspection_photos_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  Worker? _reconnectWorker;
  bool _repositoryReady = false;

  /// Whether a photo slot has an upload that hasn't yet synced to the server.
  bool hasPendingUpload(int photoId) =>
      _repositoryReady && repository.hasPendingUpload(photoId);

  final isLoading = false.obs;
  final isResetting = false.obs;

  final isEditing = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _log('onInit — controller created');
   
  }

  @override
  void onReady() {
    super.onReady();
    _log('onReady — hasPhotos=${mainController.inspection.value?.hasPhotos}');

    if (mainController.inspection.value?.hasPhotos ?? false) {
      loadBySlug();
    }

    _reconnectWorker = ever(
      ConnectionService.instance.onReconnect,
      (_) { if (_repositoryReady) repository.flushPending(); },
    );
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
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
    _repositoryReady = true;

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

    // 2. Then refresh from API only if online
    isLoading.value = photos.isEmpty;
    update();

    if (ConnectionService.instance.isConnectionGood.value) {
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
      }
    }

    isLoading.value = false;
    update();

    // Retry any uploads that were saved locally while offline.
    if (_repositoryReady && ConnectionService.instance.isConnectionGood.value) {
      await repository.flushPending();
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
      _log('picking — opening camera');
      photo.file = await ImageSourcePicker.pick();
      _log('picking — camera closed | file=${photo.file != null ? "selected" : "cancelled"} | category.value=${category.value}');
    }

    if (photo.file != null) {
      // Copy the captured file out of volatile tmp storage into app-private
      // storage. The OS can reclaim tmp between capture and reconnect — that
      // was a silent data-loss path for offline uploads. App-documents survive
      // until we explicitly delete after a successful sync.
      photo.file = await _persistCapture(photo.id, photo.file!);

      _log('picking — upload START | category.value=${category.value}');
      uploadingIds.add(photo.id);
      update();
      bool synced = false;
      try {
        synced = await repository.update(photo);
        _log('picking — upload COMPLETE synced=$synced | category.value=${category.value}');
      } finally {
        uploadingIds.remove(photo.id);
        update();
      }

      // Show a pending-sync snackbar when the upload was queued offline so the
      // inspector knows their capture is saved and will sync on reconnect.
      if (!synced) {
        FLoader.infoSnackBar(
          title: 'saved_locally_title'.tr,
          message: 'saved_locally_message'.tr,
          duration: 2,
        );
      }
    }

    _log('picking — END | category.value=${category.value} | savedCategory=$savedCategory');
    if (savedCategory != null) {
      if (category.value != savedCategory) {
        _log('picking — RESTORING category from ${category.value} → $savedCategory');
      }
      category.value = savedCategory;
    }
    update();
  }

  /// Copies a captured image from tmp/file_picker cache into app-documents so
  /// it survives OS tmp reclamation and app-kill while a pending upload waits
  /// for reconnect. Returns the destination file (falls back to the original
  /// on copy failure — the upload still tries the tmp path).
  Future<File> _persistCapture(int photoId, File src) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/inspector_photos/$slug');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final ext = src.path.split('.').isNotEmpty ? src.path.split('.').last : 'jpg';
      final dest = File('${dir.path}/photo_$photoId.$ext');
      await src.copy(dest.path);
      _log('persistCapture — copied to ${dest.path}');
      return dest;
    } catch (e) {
      _log('persistCapture — copy failed: $e, using tmp path');
      return src;
    }
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
    update();
    var synced = false;
    try {
      synced = await repository.delete(photo);
    } finally {
      deletingIds.remove(photo.id);
      if (savedCategory != null) {
        category.value = savedCategory;
      }
      update();
    }
    if (synced) {
      FLoader.successSnackBar(
        title: InspectionPage.deletePhoto.tr,
        message: InspectionPage.photoDeletedSuccess.tr,
        duration: 2,
      );
    } else {
      FLoader.infoSnackBar(
        title: 'queued_delete_title'.tr,
        message: 'queued_delete_message'.tr,
        duration: 2,
      );
    }
  }
}
