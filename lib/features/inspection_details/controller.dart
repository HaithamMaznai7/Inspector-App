import 'dart:async';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/features/inspection_details/components/note_dialog.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_details_repository.dart';
import 'package:fahis_inspector/resources/inspection_points_repository.dart';
import 'package:fahis_inspector/resources/vehicle_details_repository.dart';
import 'package:fahis_inspector/resources/inspection_photos_repository.dart';
import 'package:fahis_inspector/resources/inspection_body_repository.dart';
import 'package:fahis_inspector/resources/inspection_obd_repository.dart';
import 'package:fahis_inspector/resources/paint_gauge_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

class InspectionDetailsController extends GetxController
    with GetTickerProviderStateMixin {
  String? slug;
  InspectionDetailsRepository? repository;
  Box? box;
  Box<List>? assetsBox;

  // late TabController tabController;

  final Rxn<Inspection> inspection = Rxn<Inspection>();
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  @override
  void onReady() {
    super.onReady();
    String? newSlug;
    var newInspection = Get.arguments as Inspection?;

    if (newInspection != null) {
      newSlug = newInspection.slug;
    } else {
      newSlug = Get.parameters['slug'];
    }

    if (newSlug == null) {
      Get.back();
    } else if (newSlug != slug) {
      load(newSlug);
    }
  }

  Future<void> load(String newSlug, {bool refresh = false}) async {
    slug = newSlug;

    isLoading.value = true;
    update();

    // RESET state
    repository = null;
    box = null;

    // Init cache + repo
    box = await Hive.openBox('Inspection_$slug');
    assetsBox = await Hive.openBox<List>(slug!);
    repository = InspectionDetailsRepository(slug: slug!, box: box!);

    // Fast path (navigation with arguments)
    if (refresh) {
      inspection.value = null;
      update();
    } else {
      // Re-read cache on every load so freshly-opened boxes surface data
      // even when a prior instance left `inspection.value` stale.
      inspection.value = repository!.fetchFromCache() ?? inspection.value;
      update();
    }

    bool apiFetchSucceeded = false;

    // Only call the API if online. When offline, cache was already loaded above.
    if (ConnectionService.instance.isConnectionGood.value) {
      try {
        inspection.value = await repository!.fetchFromApi();
        apiFetchSucceeded = true;
      } on FNetworkException catch (e) {
        // Only pop for genuine "inspection is gone" (404). Auth failures
        // (401/403) are handled globally by AuthMiddleware + sessionExpired().
        // Transient network drops must keep the user on the current screen.
        if (e.statusCode == 404) {
          Get.back();
          return;
        }
        e.notify();
      } catch (e) {
        dd(e);
      }
    }

    if (isLoading.value) {
      isLoading.value = false;
    }
    update();

    if (apiFetchSucceeded) {
      _loadSubResources();
    }
  }

  void _loadSubResources() {
    if (inspection.value?.hasDetails ?? false) {
      loadVehicleDetails();
    }
    if (inspection.value?.hasPoints ?? false) {
      loadInspectionPoints();
    }
    if (inspection.value?.hasPhotos ?? false) {
      loadInspectionPhotos();
    }
    if (inspection.value?.hasBody ?? false) {
      loadInspectionBodyNotes();
    }
    if (inspection.value?.hasObd ?? false) {
      loadInspectionOBD();
    }
    if (inspection.value?.hasPaintBody ?? false) {
      loadPaintPanels();
    }
  }

  Rxn<VehicleDetails> vehicleDetails = Rxn<VehicleDetails>(null);
  VehicleDetailsRepository? vehicleDetailsRepository;
  var vehicleDetailsLoading = true.obs;

  Future<void> loadVehicleDetails() async {
    vehicleDetailsRepository = VehicleDetailsRepository(slug: slug!, box: box!);

    // Show cached data instantly
    vehicleDetails.value ??= vehicleDetailsRepository!.fetchFromCache();
    vehicleDetailsLoading.value = vehicleDetails.value == null;
    update();

    if (ConnectionService.instance.isConnectionGood.value) {
      vehicleDetails.value = await vehicleDetailsRepository!.fetchFromApi();
    }

    vehicleDetailsLoading.value = false;
    update();
  }

  RxList<Point> inspectionPoints = RxList<Point>([]);
  InspectionPointsRepository? inspectionPointsRepository;
  var inspectionPointsLoading = true.obs;

  Future<void> loadInspectionPoints() async {
    inspectionPointsRepository = InspectionPointsRepository(
      slug: slug!,
      box: assetsBox!,
    );

    // Show cached data instantly
    final cached = inspectionPointsRepository!.fetchFromCache();
    if (cached.isNotEmpty) inspectionPoints.assignAll(cached);
    inspectionPointsLoading.value = inspectionPoints.isEmpty;
    update();

    if (ConnectionService.instance.isConnectionGood.value) {
      inspectionPoints.value = await inspectionPointsRepository!.fetchFromApi();
    }

    inspectionPointsLoading.value = false;
    update();
  }

  Future<void> loadInspectionPhotos() async {
    if (assetsBox == null || slug == null) return;
    try {
      final photosRepo = InspectionPhotosRepository(
        box: assetsBox!,
        slug: slug!,
      );
      if (ConnectionService.instance.isConnectionGood.value) {
        await photosRepo.fetchFromApi();
      }
      update();
    } catch (e) {
      dd('Error loading photos: $e');
    }
  }

  Future<void> loadInspectionBodyNotes() async {
    if (assetsBox == null || slug == null) return;
    try {
      final bodyRepo = InspectionBodyRepository(box: assetsBox!, slug: slug!);
      if (ConnectionService.instance.isConnectionGood.value) {
        await bodyRepo.fetchFromApi();
      }
      update();
    } catch (e) {
      dd('Error loading body notes: $e');
    }
  }

  Future<void> loadPaintPanels() async {
    if (slug == null) return;
    try {
      final paintBox = await Hive.openBox(PaintGaugeRepository.boxKey);
      final repo = PaintGaugeRepository(box: paintBox, slug: slug!);
      if (ConnectionService.instance.isConnectionGood.value) {
        await repo.fetchPanelsFromApi();
      }
      update();
    } catch (e) {
      dd('Error loading paint panels: $e');
    }
  }

  Future<void> loadInspectionOBD() async {
    if (assetsBox == null || slug == null) return;
    try {
      final obdRepo = InspectionObdRepository(box: assetsBox!, slug: slug!);
      if (ConnectionService.instance.isConnectionGood.value) {
        await obdRepo.fetchFromApi();
      }
      update();
    } catch (e) {
      dd('Error loading OBD: $e');
    }
  }

  Future<void> openEditing() async {
    if ([
      InspectionStage.finished,
      InspectionStage.reviewed,
    ].contains(inspection.value!.stage)) {
      return;
    }
    await Get.toNamed(RoutingUrl.inspectionSteps, arguments: inspection.value!);
    // Only refresh the main inspection (1 API call) to update the stage label.
    // Sub-resources are already up to date in cache from the steps screen.
    if (slug != null && ConnectionService.instance.isConnectionGood.value) {
      try {
        inspection.value = await repository!.fetchFromApi();
        update();
      } catch (_) {}
    }
  }

  Future<void> setSatge(InspectionStage stage) async {
    if (inspection.value == null) {
      return;
    }

    final oldValue = inspection.value!.stage;

    // For stages that show a dialog, collect input BEFORE showing loading
    switch (stage) {
      case InspectionStage.finished:
        final note = await Get.dialog<String>(
          NoteInputDialog(status: stage.value ?? 'finished'),
        );
        if (note == null) return; // user cancelled
        // Backend requires note when stage is finished; use '-' if empty
        inspection.value!.note = note.trim().isEmpty ? '-' : note.trim();
        inspection.value!.stage = stage;
        break;
      case InspectionStage.rejected:
        final note = await Get.dialog<String>(
          NoteInputDialog(status: stage.value ?? 'rejected'),
        );
        if (note == null) return; // user cancelled
        inspection.value!.rejectedNote = note.trim().isEmpty
            ? '-'
            : note.trim();
        inspection.value!.stage = stage;
        break;
      case InspectionStage.pending:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.accepted:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.info:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.points:
        if (VehicleDetailsBinding().isRegistered) {
          await VehicleDetailsBinding().instance.onSave();
        }
        break;
      case InspectionStage.photos:
        if (InspectionPointsBinding().isRegistered &&
            InspectionPointsBinding().instance.allPoints
                .where((point) => point.status != PointStatus.none)
                .toList()
                .isNotEmpty) {
          inspection.value!.stage = stage;
        }
        break;
      case InspectionStage.body:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.obd:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.reviewed:
        inspection.value!.stage = stage;
        break;
      default:
        inspection.value!.stage = oldValue;
        break;
    }

    // Now show loading indicator (after dialog confirmation)
    isSubmitting.toggle();
    update();

    bool success = false;
    try {
      inspection.value = await repository!.update(inspection.value!);
      success = true;

      // Propagate stage change to the list without refetching.
      if (InspectionsBinding().isRegistered && inspection.value != null) {
        InspectionsBinding().instance.applyInspectionUpdate(inspection.value!);
      }
    } on FNetworkException catch (e) {
      e.notify();
      inspection.value?.stage = oldValue;
    } catch (_) {
      inspection.value?.stage = oldValue;
      load(slug!);
    } finally {
      isSubmitting.toggle();
      update();
    }

    // Only show success and navigate AFTER confirming the API call succeeded
    if (success &&
        (stage == InspectionStage.finished ||
            stage == InspectionStage.reviewed)) {
      inspection.value?.note = '';
      inspection.value?.rejectedNote = null;
      box?.delete(slug);
      FLoader.successSnackBar(
        title: InspectionPage.submitSuccessTitle.tr,
        message: InspectionPage.submitSuccessMsg.tr,
      );
      Get.offAllNamed(RoutingUrl.home);
    }
  }

  void share() {
    try {
      SharePlus.instance
          .share(
            ShareParams(
              uri: Uri(
                host: EndPoints.domain,
                scheme: EndPoints.schema,
                path:
                    "/dashboard/operational-section/inspections-management/$slug",
              ),
              // files: file != null ? [file!] : null,
            ),
          )
          .then((result) {
            if (result.status == ShareResultStatus.success) {
              dd('sharing the inspection!');
              dd(result.raw);
            } else if (result.status == ShareResultStatus.dismissed) {
              FLoader.infoSnackBar(
                title: 'Inspection No. $slug',
                message: 'The Inspection\'s Url Copied Successfull',
              );
            }
          });
    } catch (e) {
      // dd(e.toString());
    }
  }
}
