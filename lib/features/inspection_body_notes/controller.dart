import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/features/inspection_body_notes/components/card.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/inspection_body_repository.dart';
import 'package:fahis_inspector/routes.dart';
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

      // 2. Then refresh from API
      isLoading.value = bodySides.isEmpty;
      update();

      bodySides.assignAll(await repository.fetchFromApi());
    } on FNetworkException catch (_) {
      // e.notify();
    } catch (_) {

    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> onCreateEdit(CarBody body, Marker marker) async {
    final result = await Get.dialog<Marker>(
      InspectionBodyNotesDialog(note: marker),
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
        await repository.store(body, result);
      } else {
        // Existing marker → update it
        await repository.update(marker);
      }
      FLoader.successSnackBar(
        title: FTexts.markerSavedSuccess.tr,
        message: FTexts.markerSavedSuccessMsg.tr,
      );
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
    } catch (_) {
      // Position drift is non-critical — silently ignore network errors
    }
  }

  Future<void> onRemove(Marker note) async {
    try {
      await repository.delete(note);
      FLoader.successSnackBar(
        title: FTexts.markerDeletedSuccess.tr,
        message: FTexts.markerDeletedSuccessMsg.tr,
      );
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
