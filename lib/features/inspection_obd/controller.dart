import 'dart:io';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/components/dialog.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/resources/inspection_obd_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Max upload file size: 10 MB
const int _kMaxFileSizeBytes = 10 * 1024 * 1024;

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

  Worker? _reconnectWorker;
  bool _repositoryReady = false;

  /// Whether OBD data is ready (has report OR at least one code).
  bool get hasData => report.value != null && codes.isNotEmpty;

  /// Whether [code] has a pending upload that hasn't synced to the server yet.
  bool hasPendingCode(String code) =>
      _repositoryReady && repository.hasPendingCode(code);

  /// Whether all async data has been loaded (not in a loading state).
  bool get isDataReady => !isLoading.value && !isUpload.value;

  @override
  void onInit() async {
    super.onInit();
    _log('onInit');

    codes.listen((data) {
      // mainController.updateInspection(codes: data);
    });
  }

  @override
  void onReady() async {
    super.onReady();
    _log('onReady – hasObd: ${mainController.inspection.value?.hasObd}');

    if (mainController.inspection.value?.hasObd ?? false) {
      loadBySlug();
    }

    _reconnectWorker = ever(ConnectionService.instance.onReconnect, (_) {
      if (_repositoryReady) repository.flushPending();
    });
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
  }

  Future<void> loadBySlug() async {
    _log('loadBySlug – waiting for box/slug...');
    isLoading.value = true;
    // RESET state
    codes.value = [];

    // Init cache + repo
    while (box == null && slug == null) {
      await Future.delayed(Duration(seconds: 1));
    }
    _log('loadBySlug – box/slug ready, slug=$slug');

    repository = InspectionObdRepository(box: box!, slug: slug!);
    _repositoryReady = true;

    repository.stream.listen((data) {
      _log('stream → ${data.length} codes');
      codes.assignAll(data);
      update();
    });

    repository.reportStream.listen((data) {
      _log('reportStream → report=${data != null ? "present" : "null"}');
      report.value = data;
      update();
    });

    if (mainController.inspection.value?.hasObd ?? false) {
      fetchCodes();
    }
  }

  Future<void> fetchCodes() async {
    _log('fetchCodes – start');
    try {
      // 1. Show cached first
      codes.assignAll(repository.fetchFromCache());
      _log('fetchCodes – cached: ${codes.length} codes');
      update();

      // 2. Then refresh from API only if online
      isLoading.value = codes.isEmpty;
      update();

      if (ConnectionService.instance.isConnectionGood.value) {
        final apiCodes = await repository.fetchFromApi();
        _log('fetchCodes – API returned: ${apiCodes.length} codes');
        codes.assignAll(apiCodes);
      }
    } on FNetworkException catch (e) {
      _log('fetchCodes – FNetworkException: ${e.statusCode}');
    } catch (e) {
      _log('fetchCodes – error: $e');
    } finally {
      isLoading.value = false;
      update();
      _log(
        'fetchCodes – done. codes=${codes.length}, report=${report.value != null}',
      );
    }
    // Flush any codes pending from a prior offline session.
    if (ConnectionService.instance.isConnectionGood.value) {
      await repository.flushPending();
    }
  }

  void openReport() async {
    _log('openReport – url: ${report.value}');
    final Uri uri = Uri.parse(report.value!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch ${report.value!}");
    }
  }

  Future<void> deleteReport() async {
    _log('deleteReport – start');
    isUpload.value = true;
    update();
    try {
      report.value = await repository.removeReport();
      _log('deleteReport – success');
      FLoader.successSnackBar(title: InspectionPage.obdDeleteSuccess.tr);
    } catch (e) {
      _log('deleteReport – error: $e');
    } finally {
      isUpload.value = false;
      update();
    }
  }

  Future<void> pickReport() async {
    final result = await FilePicker.pickFiles(type: FileType.any);

    final file = result != null && result.files.single.path != null
        ? File(result.files.single.path!)
        : null;

    if (file == null) {
      _log('pickReport – no file selected');
      return;
    }

    // File size check
    final fileSize = await file.length();
    _log(
      'pickReport – selected file: ${file.path}, size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
    );

    if (fileSize > _kMaxFileSizeBytes) {
      _log(
        'pickReport – REJECTED: file too large ($fileSize bytes > $_kMaxFileSizeBytes)',
      );
      FLoader.warningSnackBar(
        title: InspectionPage.obdFileTooLarge.tr,
        message: InspectionPage.obdFileTooLargeMsg.tr,
      );
      return;
    }

    try {
      isUpload.value = true;
      update();

      _log('pickReport – uploading...');
      report.value = await repository.uploadReport(file);

      if (report.value != null) {
        _log('pickReport – upload success, report URL: ${report.value}');
        FLoader.successSnackBar(title: InspectionPage.obdUploadSuccess.tr);
      } else {
        _log('pickReport – upload returned null');
        FLoader.errorSnackBar(title: InspectionPage.obdUploadFailed.tr);
      }
    } catch (e) {
      _log('pickReport – error: $e');
      FLoader.errorSnackBar(
        title: InspectionPage.obdUploadFailed.tr,
        message: e.toString(),
      );
    } finally {
      isUpload.value = false;
      update();
    }
  }

  Future<void> delete(OBDCode code) async {
    _log('delete code – id: ${code.id}, code: ${code.code}');
    isLoading.value = true;
    update();

    try {
      await repository.delete(code);
      _log('delete code – success');
      FLoader.successSnackBar(
        title: InspectionPage.obdCodeDeletedSuccess.tr,
        message: InspectionPage.obdCodeDeletedSuccessMsg.tr,
      );
    } catch (e) {
      _log('delete code – error: $e');
      FLoader.errorSnackBar(title: InspectionPage.obdActionError.tr);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> onCreateEdit({OBDCode? code}) async {
    _log('onCreateEdit – existing code: ${code?.code}');
    isLoading.value = true;
    update();

    OBDCode? result = await Get.bottomSheet<OBDCode>(
      AddingObdCode(code: code),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      ignoreSafeArea: false,
    );

    try {
      if (result != null && result.id == 0) {
        _log('onCreateEdit – storing new code: ${result.code}');
        final synced = await repository.store(result);
        _log('onCreateEdit – stored (synced=$synced)');
        if (synced) {
          FLoader.successSnackBar(
            title: InspectionPage.obdCodeAddSuccess.tr,
            message: InspectionPage.obdCodeAddSuccessMsg.tr,
          );
        } else {
          FLoader.infoSnackBar(
            title: 'saved_locally_title'.tr,
            message: 'saved_locally_message'.tr,
          );
        }
      }

      if (result != null && result.id > 0) {
        _log('onCreateEdit – updating code id=${result.id}: ${result.code}');
        await repository.update(result);
        _log('onCreateEdit – updated successfully');
        FLoader.successSnackBar(
          title: InspectionPage.obdCodeEditSuccess.tr,
          message: InspectionPage.obdCodeEditSuccessMsg.tr,
        );
      }

      if (result == null) {
        _log('onCreateEdit – dialog cancelled');
      }
    } catch (e) {
      _log('onCreateEdit – error: $e');
      FLoader.errorSnackBar(title: InspectionPage.obdActionError.tr);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[OBD Controller] $message');
    }
  }
}
