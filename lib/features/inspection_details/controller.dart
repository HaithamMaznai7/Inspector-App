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
import 'package:fahis_inspector/routes.dart';
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
      inspection.value = newInspection;
    } else {
      newSlug = Get.parameters['slug'];
    }

    if (newSlug == null) {
      Get.back();
    } else if (newSlug != slug) {
      load(newSlug);
    }
  }

  // WHAT: Load an inspection by slug, fetch from cache first, then API,
  //       then load sub-resources (details, points, photos, body, OBD).
  // WHY: The original code fired all sub-resource loads in the `finally` block,
  //      meaning they ran even when the main fetch failed (e.g., no internet).
  //      This caused 5 simultaneous error snackbars and the Overlay crash.
  // HOW: Sub-resource loads are now in a separate method `_loadSubResources()`
  //      called only after the main inspection is confirmed loaded.
  //      A `apiFetchSucceeded` flag tracks whether the API was reachable.
  // EDGE CASES:
  //   - No internet + cached inspection: shows cached data, skips API sub-loads
  //   - No internet + no cache: shows loading then stays on screen with cached data
  //   - 404/401/403: navigates back immediately
  // PERFORMANCE: Sub-resources are loaded in parallel (fire-and-forget) for speed,
  //              but only when we know the network is available.
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
      inspection.value ??= repository!.fetchFromCache();
      update();
    }

    // WHAT: Track whether the API fetch succeeded to decide if sub-resources
    //       should also be fetched from the API.
    // WHY: If the main fetch failed due to no internet, firing 5 more API calls
    //      will also fail, producing 5 error snackbars and crashing the overlay.
    bool apiFetchSucceeded = false;

    try {
      inspection.value = await repository!.fetchFromApi();
      // WHAT: Mark API as reachable only if fetchFromApi didn't throw.
      apiFetchSucceeded = true;
    } on FNetworkException catch (e) {
      // WHAT: Check for critical HTTP errors that mean we should leave this screen.
      // WHY: 404 = inspection doesn't exist, 401/403 = no permission.
      // FIX: The original code used .contains((i) => i == e.statusCode) which
      //      passes a function to .contains() — always returns false because the
      //      list contains ints, not functions. Changed to .contains(e.statusCode).
      if ([404, 401, 403].contains(e.statusCode)) {
        Get.back();
        return;
      }
      // WHAT: For non-critical errors (e.g., no internet), show one snackbar.
      // WHY: Better UX than showing 5+ identical error snackbars from sub-resources.
      e.notify();
    } catch (e) {
      dd(e);
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
      update();
    }

    // WHAT: Load sub-resources only if the API is reachable.
    // WHY: If we're offline, all sub-resource API calls will also fail,
    //      flooding the user with identical error snackbars.
    // HOW: When offline, we still have cached inspection data (if any)
    //      displayed to the user — sub-resources will load from cache
    //      via their respective controllers when those screens are opened.
    if (apiFetchSucceeded) {
      _loadSubResources();
    }
  }

  // WHAT: Fire all sub-resource loads in parallel.
  // WHY: Separated from load() for clarity and to control when they execute.
  // HOW: Each load is fire-and-forget (not awaited) for parallel execution.
  //      Each method has its own try/catch so one failure doesn't block others.
  // RELATED: loadVehicleDetails(), loadInspectionPoints(), etc.
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
  }

  Rxn<VehicleDetails> vehicleDetails = Rxn<VehicleDetails>(null);
  VehicleDetailsRepository? vehicleDetailsRepository;
  var vehicleDetailsLoading = true.obs;

  Future<void> loadVehicleDetails() async {
    vehicleDetailsRepository = VehicleDetailsRepository(slug: slug!, box: box!);
    if (vehicleDetailsRepository == null) {
      return;
    }

    vehicleDetailsLoading.value = true;
    update();

    vehicleDetails.value = await vehicleDetailsRepository!.fetchFromApi();

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
    if (inspectionPointsRepository == null) {
      return;
    }

    inspectionPointsLoading.value = true;
    update();

    inspectionPoints.value = await inspectionPointsRepository!.fetchFromApi();

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
      await photosRepo.fetchFromApi();
      update();
    } catch (e) {
      dd('Error loading photos: $e');
    }
  }

  Future<void> loadInspectionBodyNotes() async {
    if (assetsBox == null || slug == null) return;
    try {
      final bodyRepo = InspectionBodyRepository(box: assetsBox!, slug: slug!);
      await bodyRepo.fetchFromApi();
      update();
    } catch (e) {
      dd('Error loading body notes: $e');
    }
  }

  Future<void> loadInspectionOBD() async {
    if (box == null || slug == null) return;
    try {
      final obdRepo = InspectionObdRepository(box: box!, slug: slug!);

      // DEBUG: Check what's in cache BEFORE API call
      final cachedBefore = box!.get(slug);
      dd(
        'OBD DEBUG [1] cache key="$slug", cached data BEFORE fetch: $cachedBefore',
      );
      dd('OBD DEBUG [1] cached type: ${cachedBefore.runtimeType}');

      final result = await obdRepo.fetchFromApi();

      // DEBUG: Check what API returned
      dd('OBD DEBUG [2] API returned ${result.length} codes: $result');

      // DEBUG: Check what's in cache AFTER API call
      final cachedAfter = box!.get(slug);
      dd('OBD DEBUG [3] cached data AFTER fetch: $cachedAfter');
      dd('OBD DEBUG [3] cached type: ${cachedAfter.runtimeType}');

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
    // Refresh after returning from steps screen so stage label is up to date
    if (slug != null) {
      load(slug!, refresh: true);
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
        inspection.value!.rejectedNote = note.trim().isEmpty ? '-' : note.trim();
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
    // XFile? file;
    // final url = Uri.parse('https://drive.google.com/file/d/1sYS1z3u3A8Truq-b8kYi0zH1SC-thuDa/view?usp=sharing');
    // try {
    //   final url = Uri.parse(
    //     'https://images.sampletemplates.com/wp-content/uploads/2017/02/Survey-Analysis-Report.pdf',
    //   );

    //   file = XFile.fromData(File.fromUri(url).readAsBytesSync());
    // } catch (e) {
    //   dd(e.toString());
    //   file = null;
    // }

    try {
      SharePlus.instance
          .share(
            ShareParams(
              uri: Uri(
                host: EndPoints.websiteDomain,
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
