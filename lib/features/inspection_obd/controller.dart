import 'dart:io';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/components/dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/resources/inspection_obd_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectionObdController extends GetxController {
  late InspectionObdRepository repository;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  Box<List>? get box => mainController.assetsBox;
  String? get slug => mainController.slug;

  RxList<OBDCode> codes = RxList<OBDCode>([]);
  RxnString report = RxnString();

  var isUpload = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

    codes.listen((data) {
      // mainController.updateInspection(codes: data);
    });
  }

  @override
  void onReady() async {
    super.onReady();

    if (mainController.inspection.value?.hasObd ?? false) {
      loadBySlug();
    }
  }

  Future<void> loadBySlug() async {
    isLoading.value = true;
    // RESET state
    codes.value = [];

    // Init cache + repo
    while (box == null && slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }

    repository = InspectionObdRepository(box: box!, slug: slug!);

    repository.stream.listen((data) {
      codes.assignAll(data);
      update();
    });

    repository.reportStream.listen((data) {
      report.value = data;
      update();
    });

    // codes.listen((data) {
    //   mainController.updateInspection(codes: data);
    // });

    if (mainController.inspection.value?.hasObd ?? false) {
      fetchCodes();
    }
  }

  Future<void> fetchCodes() async {
    try {
    // 1. Show cached first
      codes.assignAll(repository.fetchFromCache());
      update();

      // 2. Then refresh from API
      isLoading.value = codes.isEmpty;
      update();

      codes.assignAll(await repository.fetchFromApi());
    } on FNetworkException catch (_) {
      // e.notify();
    } catch (_) {

    } finally {
      isLoading.value = false;
      update();
    }
  }

  void openReport() async {
    final Uri uri = Uri.parse(report.value!);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // 👈 opens in browser
    )) {
      throw Exception("Could not launch ${report.value!}");
    }
  }

  Future<void> deleteReport() async {
    isUpload.value = true;
    update();
    try {
      report.value = await repository.removeReport();
    } finally {
      isUpload.value = false;
      update();
    }
  }

  Future<void> pickReport() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    final file = result != null && result.files.single.path != null
        ? File(result.files.single.path!)
        : null;

    try {
      if (file != null) {
        isUpload.value = true;
        update();
        report.value = await Future.microtask(() => repository.uploadReport(file));
      }
    } catch (e) {
      dd('error on upload ${e.toString()}');
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

  Future<void> onCreateEdit({OBDCode? code}) async {
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
