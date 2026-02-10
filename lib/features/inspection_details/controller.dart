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
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> load(String newSlug, {bool refresh = false}) async {
    slug = newSlug;

    if (inspection.value == null) {
      isLoading.value = true;
      update();
    }

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

    if (inspection.value == null) {
      isLoading.value = true;
      update();
    }

    try {
      inspection.value = await repository!.fetchFromApi();
    } on FNetworkException catch (e) {
      if ([404, 401, 403].contains((i) => i == e.statusCode)) {
        Get.back();
      }
    } catch (e) {
      dd(e);
      Get.back();
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
      update();
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
      final photosRepo = InspectionPhotosRepository(box: assetsBox!, slug: slug!);
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
      await obdRepo.fetchFromApi();
      update();
    } catch (e) {
      dd('Error loading OBD: $e');
    }
  }

  void openEditing() {
    if ([
      InspectionStage.finished,
      InspectionStage.reviewed,
    ].contains(inspection.value!.stage)) {
      return;
    }
    Get.toNamed(RoutingUrl.inspectionSteps, arguments: inspection.value!);
  }

  Future<void> setSatge(InspectionStage stage) async {
    if (inspection.value == null) {
      return;
    }
    isSubmitting.toggle();
    update();

    final oldValue = inspection.value!.stage;

    switch (stage) {
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
      case InspectionStage.finished:
        final note = await Get.dialog(
          NoteInputDialog(
            status: stage.toString(),
            note: inspection.value?.note,
          ),
        );
        if (note == null) {
          return;
        } else {
          inspection.value!.note = note;
          inspection.value!.stage = stage;
        }
        break;
      case InspectionStage.reviewed:
        inspection.value!.stage = stage;
        break;
      case InspectionStage.rejected:
        final note = await Get.dialog(
          NoteInputDialog(status: stage.toString()),
        );
        if (note == null) {
          return;
        } else {
          inspection.value!.rejectedNote = note;
          inspection.value!.stage = stage;
        }
        break;
      default:
        inspection.value!.stage = oldValue;
        break;
    }

    try {
      inspection.value = await repository!.update(inspection.value!);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      inspection.value?.stage = oldValue;
      load(slug!);
    } finally {
      isSubmitting.toggle();
      update();
      if (stage == InspectionStage.finished ||
          stage == InspectionStage.reviewed) {
        Get.back();
      }
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
