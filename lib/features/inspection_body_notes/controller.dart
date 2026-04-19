import 'package:flutter/material.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/features/inspection_body_notes/components/card.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/inspection_body_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionBodyController extends GetxController {
  late InspectionBodyRepository repository;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  Box<List>? get box => mainController.assetsBox;
  String? get slug => mainController.slug;

  late Box<List> assets;
  late AssetsRepository assetsRepository;

  final RxList<CarBody> bodySides = RxList<CarBody>([]);
  var isLoading = false.obs;

  Worker?
  _reconnectWorker; // Used to trigger a flush of pending markers when connectivity is restored.
  bool _repositoryReady =
      false; // To prevent trying to flush pending markers before the repository is initialized.

  @override
  void onInit() async {
    super.onInit();

    assets = await Hive.openBox('Assets');
    assetsRepository = AssetsRepository(assets);

    bodySides.listen((data) {
      // mainController.updateInspection(bodySides: data);
    });
  }

  @override
  void onReady() async {
    super.onReady();

    if (mainController.inspection.value?.hasBody ?? false) {
      loadBySlug();
    }

    _reconnectWorker = ever(
      // Listen to connectivity changes and attempt to flush pending markers when a connection is re-established.
      ConnectionService.instance.onReconnect,
      (_) => _flushPendingIfRepositoryReady(),
    );
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
  }

  Future<void> loadBySlug() async {
    isLoading.value = true;
    // RESET state
    bodySides.value = [];

    // Init cache + repo
    while (box == null && slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionBodyRepository(box: box!, slug: slug!);
    _repositoryReady = true;

    repository.stream.listen((data) {
      bodySides.assignAll(data);
      update();
    });

    if (mainController.inspection.value?.hasBody ?? false) {
      fetchBodySides();
    }
  }

  Future<void> fetchBodySides() async {
    // 1. Show cached first
    try {
      bodySides.assignAll(repository.fetchFromCache());
      update();

      // 2. Then refresh from API only if online
      isLoading.value = bodySides.isEmpty;
      update();

      if (ConnectionService.instance.isConnectionGood.value) {
        bodySides.assignAll(await repository.fetchFromApi());
      }
    } on FNetworkException catch (_) {
    } catch (_) {
    } finally {
      isLoading.value = false;
      update();
    }
    // Flush any markers that were saved locally during a prior offline session.
    if (ConnectionService.instance.isConnectionGood.value) {
      await _flushPendingIfRepositoryReady();
    }
  }

  Future<void> _flushPendingIfRepositoryReady() async {
    if (!_repositoryReady) return;
    await repository.flushPendingMarkers();
  }

  Future<void> onCreateEdit(CarBody body, Marker marker) async {
    final result = await Get.bottomSheet<Marker>(
      InspectionBodyNotesDialog(note: marker),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      ignoreSafeArea: false,
    );

    if (result == null) return;

    // Delete signal from the dialog (id == -1)
    if (result.id == -1 && marker.id > 0) {
      await onRemove(marker);
      return;
    }

    try {
      // New marker (id == 0) → store it
      if (result.id == 0) {
        final synced = await repository.store(body, result);
        if (synced) {
          FLoader.successSnackBar(
            title: FTexts.markerSavedSuccess.tr,
            message: FTexts.markerSavedSuccessMsg.tr,
          );
        } else {
          // Saved locally — will POST when connectivity returns.
          // FLoader.warningSnackBar(
          //   title: FTexts.markerSavedSuccess.tr,
          //   message: 'saved_locally_will_sync'.tr,
          // );
          //TODO: decide if we want this snackbar or not.
        }
      } else {
        // Existing marker → update it
        await repository.update(marker);
        FLoader.successSnackBar(
          title: FTexts.markerSavedSuccess.tr,
          message: FTexts.markerSavedSuccessMsg.tr,
        );
      }
    } on FNetworkException {
      // no second snackbar needed.
    } catch (_) {
      FLoader.errorSnackBar(
        title: FTexts.markerErrorTitle.tr,
        message: FTexts.markerErrorMsg.tr,
      );
    }
  }

  /// Called after drag ends to persist the new dx/dy without opening the dialog.
  /// Only fires for existing markers (id > 0) — new markers have no backend record yet.
  Future<void> onMoved(Marker marker) async {
    if (marker.id <= 0) return;
    try {
      await repository.update(marker);
      FLoader.successSnackBar(
        title: FTexts.markerMovedSuccess.tr,
        message: FTexts.markerMovedSuccessMsg.tr,
      );
    } on FNetworkException {
      // Repository already called e.notify() — no second snackbar needed.
    } catch (_) {
      FLoader.errorSnackBar(
        title: FTexts.markerErrorTitle.tr,
        message: FTexts.markerErrorMsg.tr,
      );
    }
  }

  Future<void> onRemove(Marker note) async {
    try {
      await repository.delete(note);
      FLoader.successSnackBar(
        title: FTexts.markerDeletedSuccess.tr,
        message: FTexts.markerDeletedSuccessMsg.tr,
      );
    } on FNetworkException {
      // Repository already called e.notify() — no second snackbar needed.
    } catch (_) {
      FLoader.errorSnackBar(
        title: FTexts.markerErrorTitle.tr,
        message: FTexts.markerErrorMsg.tr,
      );
    } finally {
      update();
    }
  }
}
