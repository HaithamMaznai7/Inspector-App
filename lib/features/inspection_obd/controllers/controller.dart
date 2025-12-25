import 'dart:io';
import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/repository/repository.dart';
import 'package:fahis_inspector/features/inspection_obd/models/obd_code.dart';
import 'package:fahis_inspector/features/inspection_obd/repository/repository.dart';
import 'package:fahis_inspector/features/inspection_obd/screens/widgets/dialog.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectionObdController extends GetxController {
  static InspectionObdController get instance =>
      Get.find(tag: 'inspection-obd');

  final String slug;
  late final Box box;
  late final InspectionObdRepository repository;

  InspectionObdController(this.slug);
  InspectionController get mainController => Get.find(tag: 'inspection');

  RxList<OBDCode> codes = RxList<OBDCode>([]);
  RxnString report = RxnString();

  var isUpload = false.obs;
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

    repository = InspectionObdRepository(box: box, slug: slug);

    repository.stream.listen((data) {
      codes.assignAll(data);
      update();
    });

    repository.reportStream.listen((data) {
      report.value = data;
      update();
    });

    codes.listen((data) {
      mainController.updateInspection(codes: data);
    });

    if (! [InspectionStage.pending,InspectionStage.accepted].contains(mainController.inspection.value?.stage)) {
      fetchCodes();
    }
  }

  Future<void> fetchCodes() async {
    // 1. Show cached first
    codes.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = codes.isEmpty;
    update();

    try {
      codes.assignAll(await repository.fetchFromApi());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // @override
  // void onReady() {
  //   super.onReady();

  //   // repository.listenToBroadcast().listen((data) {
  //   //   codes.assignAll(data);
  //   // });
  // }

  openReport() async {
    final Uri uri = Uri.parse(report.value!);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // 👈 opens in browser
    )) {
      throw Exception("Could not launch ${report.value!}");
    }
  }

  deleteReport() async {
    isUpload.value = true;
    update();
    try {
      report.value = await repository.upload(null);
    }finally {
      isUpload.value = false;
      update();
    }
  }

  pickReport() async {
    isUpload.value = true;
    update();

    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    final file = result != null && result.files.single.path != null
        ? File(result.files.single.path!)
        : null;

    try {
      report.value = await repository.upload(file);
    } catch (e) {
      print('error on upload ${e.toString()}');
    } finally {
      isUpload.value = false;
      update();
    }
  }

  Future<void> delete(OBDCode code) async {
    isLoading.value = true;
    update();

    try {
      await repository.delete(code);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  onCreateEdit({OBDCode? code}) async {
    isLoading.value = true;
    update();

    OBDCode? result = await Get.dialog<OBDCode>(AddingObdCode(code: code));

    try {
      if (result != null && result.id == 0) {
        await repository.store(result);
      }

      if (result != null && result.id > 0) {
        await repository.update(result);
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
