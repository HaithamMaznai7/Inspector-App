import 'dart:async';
import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/components/dialog.dart';
import 'package:fahis_inspector/features/inspection_obd/components/pdf_viewer_screen.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/obd_ble/protocol/errors.dart';
import 'package:fahis_inspector/obd_ble/services/dtc_description_service.dart';
import 'package:fahis_inspector/obd_ble/services/elm327_command_service.dart';
import 'package:fahis_inspector/obd_ble/services/obd_ble_connection_service.dart';
import 'package:fahis_inspector/obd_ble/ui/obd_device_scan_page.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/resources/inspection_obd_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/cached_image_key.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_filex/open_filex.dart';

/// Max upload file size: 1 MB
const int _kMaxFileSizeBytes = 1 * 1024 * 1024;

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

  /// Whether the OBD report upload is queued offline and hasn't synced yet.
  bool get hasPendingReport =>
      _repositoryReady && repository.hasPendingReport();

  /// True when any OBD code is missing a description or hasn't synced to
  /// the server. Blocks inspection finalisation — those rows would be lost
  /// (device-fetched 422 case) or could replay on reconnect (manual-offline
  /// case) after the inspection is already marked finished.
  bool get hasIncompleteCodes => codes.any(
        (c) => c.isPending || c.description.trim().isEmpty,
      );

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

  // ── BLE device (Veepeak / ELM327) ────────────────────────────────────────
  final Rx<ObdBleConnectionState> bleState =
      Rx<ObdBleConnectionState>(ObdBleConnectionState.disconnected);
  final RxnString connectedDeviceName = RxnString();
  final RxBool isReadingFromDevice = false.obs;

  ObdBleConnectionService? _ble;
  Elm327CommandService? _elm;
  StreamSubscription<ObdBleConnectionState>? _bleStateSub;

  /// In-session marker of codes that came from the BLE adapter. Used to
  /// render a small bluetooth badge on the code card so the inspector can
  /// tell at a glance which codes the device produced. Not persisted — after
  /// the inspector leaves the screen the marker is gone (the server has no
  /// concept of source).
  final RxSet<String> _bleSourcedCodes = <String>{}.obs;
  bool isBleSourced(String code) => _bleSourcedCodes.contains(code);

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    // Cancel the state-change subscription synchronously — no Rx writes needed
    // at shutdown, so skip disconnectDevice() to avoid async Rx access after
    // the controller is removed from Get's registry.
    _bleStateSub?.cancel();
    _bleStateSub = null;
    _ble?.disconnect().catchError((_) {});
    _ble?.dispose();
    _ble = null;
    _elm = null;
    super.onClose();
  }

  /// Opens the device picker as a **bottom sheet** (matches paint gauge UX)
  /// and connects to the device the inspector selects.
  ///
  /// The picker auto-selects its UI per platform: bonded-device list on
  /// Android (Classic SPP requires bonding before connect) and a live BLE
  /// scan filtered by the ELM327 service UUID on iOS.
  Future<void> pickAndConnectDevice() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final device = await showModalBottomSheet<BleObdDevice>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        height: MediaQuery.of(sheetCtx).size.height * 0.65,
        decoration: BoxDecoration(
          color: Theme.of(sheetCtx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(FSizes.borderRadiusLg),
          ),
        ),
        child: const ObdDeviceScanPage(),
      ),
    );
    if (device == null) return;
    await connectToDevice(device.mac, device.name);
  }

  /// Instantiates the BLE + ELM327 services, connects, and runs the init
  /// sequence. Any failure shows a snackbar and resets to disconnected.
  Future<void> connectToDevice(String mac, String name) async {
    _log('connectToDevice – mac: $mac, name: $name');

    await disconnectDevice();

    final ble = ObdBleConnectionService();
    _ble = ble;
    _elm = Elm327CommandService(
      writeBytes: ble.write,
      notifications: ble.notifications,
    );

    _bleStateSub = ble.connectionState.listen((state) {
      bleState.value = state;
      if (state == ObdBleConnectionState.lostConnection) {
        FLoader.warningSnackBar(title: InspectionPage.obdDeviceDisconnected.tr);
      }
    });

    try {
      connectedDeviceName.value = name;
      bleState.value = ObdBleConnectionState.connecting;

      await ble.connect(mac);
      await _elm!.initialize();

      bleState.value = ObdBleConnectionState.connected;
      _log('connectToDevice – ready');

      // Connecting an OBD reader is itself the user's request to read codes —
      // skip the extra "Read from device" tap and fetch immediately.
      await readCodesFromDevice();
    } catch (e) {
      _log('connectToDevice – failed: $e');
      // ECU comms failures (UNABLE TO CONNECT, BUS INIT, etc.) get a distinct
      // message — the BLE/SPP link is fine, the issue is between the adapter
      // and the car. Anything else stays on the generic "connection failed".
      final title = e is ElmEcuConnectionException
          ? InspectionPage.obdEcuConnectFailed.tr
          : InspectionPage.obdConnectionFailed.tr;
      FLoader.errorSnackBar(title: title);
      await disconnectDevice();
    }
  }

  /// Disconnects the BLE link and nulls out the services.
  Future<void> disconnectDevice() async {
    _log('disconnectDevice');
    await _bleStateSub?.cancel();
    _bleStateSub = null;

    try {
      await _ble?.disconnect();
    } catch (_) {}
    _ble?.dispose();
    _ble = null;
    _elm = null;

    bleState.value = ObdBleConnectionState.disconnected;
    connectedDeviceName.value = null;
  }

  /// Reads stored DTCs from the adapter and ingests any new ones through the
  /// same `repository.store()` path as manually added codes. The command
  /// service handles the protocol details.
  Future<void> readCodesFromDevice() async {
    if (bleState.value != ObdBleConnectionState.connected) return;
    _log('readCodesFromDevice – start');

    isReadingFromDevice.value = true;
    try {
      final dtcs = await _elm!.readDtcs();
      _log('readCodesFromDevice – parsed ${dtcs.length} DTCs');

      if (dtcs.isEmpty) {
        FLoader.infoSnackBar(title: InspectionPage.obdNoCodesFromDevice.tr);
        return;
      }

      // Filter to genuinely new codes so we don't waste an AI call on a code
      // we'll skip anyway as a duplicate.
      final newDtcs = dtcs
          .where((dtc) =>
              !codes.any((c) => c.code == dtc) && !hasPendingCode(dtc))
          .toList();

      // Fetch AI descriptions for all new codes in parallel — vehicle context
      // is identical for every code on this inspection, so resolve it once.
      final vehicle = mainController.inspection.value?.vehicle;
      final lang = Get.locale?.languageCode == 'ar' ? 'ar' : 'en';

      final results = newDtcs.isEmpty
          ? <DtcResult?>[]
          : await Future.wait(
              newDtcs.map(
                (dtc) => DtcDescriptionService.describe(
                  dtc: dtc,
                  vehicle: vehicle,
                  lang: lang,
                ),
              ),
            );

      int addedCount = 0;
      for (var i = 0; i < newDtcs.length; i++) {
        final added = await _ingestDeviceCode(
          newDtcs[i],
          results[i]?.description ?? '',
        );
        if (added) addedCount++;
      }

      if (addedCount == 0) {
        FLoader.infoSnackBar(title: InspectionPage.obdNoNewCodes.tr);
      } else {
        FLoader.successSnackBar(
          title: InspectionPage.obdCodesAdded.trParams({
            'count': addedCount.toString(),
          }),
        );
      }
    } catch (e) {
      _log('readCodesFromDevice – error: $e');
      // Surface ECU comms failures specifically — same rationale as
      // connectToDevice's catch: link is fine, car-side is the problem.
      final title = e is ElmEcuConnectionException
          ? InspectionPage.obdEcuConnectFailed.tr
          : InspectionPage.obdActionError.tr;
      FLoader.errorSnackBar(title: title);
    } finally {
      isReadingFromDevice.value = false;
    }
  }

  /// Returns `true` if the code was ingested, `false` if it was a duplicate.
  Future<bool> _ingestDeviceCode(String dtc, [String description = '']) async {
    final isDuplicate =
        codes.any((c) => c.code == dtc) || hasPendingCode(dtc);
    if (isDuplicate) {
      _log('_ingestDeviceCode – skip duplicate: $dtc');
      return false;
    }
    _log('_ingestDeviceCode – storing: $dtc desc=${description.length}c');
    _bleSourcedCodes.add(dtc);
    await repository.store(
      OBDCode(id: 0, code: dtc, description: description),
    );
    return true;
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

  /// Opens the OBD report inside the app. Single code path for online +
  /// offline + pending — pick the first file we can get:
  ///
  ///  1. `pending://<path>` sentinel → the user's queued local file.
  ///  2. Cached file from [DefaultCacheManager] (warm after prior online view).
  ///  3. Download via `getSingleFile` (online only, best effort).
  ///
  /// Routes to a viewer based on the file extension parsed from the URL —
  /// PDF → in-app `PdfViewerScreen`, image → `easy_image_viewer`, otherwise
  /// hand off to the platform via `OpenFilex`. New uploads are PDF-only, but
  /// legacy server-side reports may still be JPG/PNG and must remain viewable.
  Future<void> openReport() async {
    final url = report.value;
    if (url == null || url.isEmpty) return;
    _log('openReport – url: $url');

    // 1. Pending local file (offline upload not yet synced)
    if (url.startsWith('pending://')) {
      final path = url.substring('pending://'.length);
      final file = File(path);
      if (file.existsSync()) {
        _log('openReport – opening pending local file: $path');
        await _routeToViewer(file, url);
        return;
      }
      _log('openReport – pending local file missing: $path');
    }

    // 2/3. Real URL → cache first, fall back to network. SAS query params
    // rotate per response, so we key the cache by the path-only form.
    try {
      final key = stableCacheKey(url);
      final cached = await DefaultCacheManager().getFileFromCache(key);
      if (cached != null) {
        _log('openReport – opening cached file: ${cached.file.path}');
        await _routeToViewer(cached.file, url);
        return;
      }

      if (!ConnectionService.instance.isConnectionGood.value) {
        _log('openReport – offline and no cached file');
        FLoader.warningSnackBar(
          title: 'report_not_cached_title'.tr,
          message: 'report_not_cached_message'.tr,
        );
        return;
      }

      final downloaded = await DefaultCacheManager().getSingleFile(
        url,
        key: key,
      );
      _log('openReport – downloaded file: ${downloaded.path}');
      await _routeToViewer(downloaded, url);
    } catch (e) {
      _log('openReport – error: $e');
      FLoader.errorSnackBar(title: InspectionPage.obdActionError.tr);
    }
  }

  /// Picks the right viewer based on the URL's path extension. The query
  /// string never lies (SAS tokens don't change file type), so we read it
  /// from `Uri.path` to be robust against `?se=…&sig=…`.
  Future<void> _routeToViewer(File file, String url) async {
    final ext = _extensionOf(url);
    if (ext == 'pdf') {
      await Get.to(() => PdfViewerScreen(file: file));
      return;
    }
    if (const {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'}.contains(ext)) {
      final ctx = Get.context;
      if (ctx == null) {
        await OpenFilex.open(file.path);
        return;
      }
      showImageViewer(
        ctx,
        FileImage(file),
        swipeDismissible: true,
        doubleTapZoomable: true,
        useSafeArea: true,
      );
      return;
    }
    // Unknown extension — hand off to the platform viewer.
    await OpenFilex.open(file.path);
  }

  String _extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toLowerCase();
  }

  Future<void> deleteReport() async {
    _log('deleteReport – start');
    isUpload.value = true;
    update();
    try {
      final synced = await repository.removeReport();
      _log('deleteReport – done (synced=$synced)');
      if (synced) {
        FLoader.successSnackBar(title: InspectionPage.obdDeleteSuccess.tr);
      } else {
        FLoader.infoSnackBar(
          title: 'queued_delete_title'.tr,
          message: 'queued_delete_message'.tr,
        );
      }
    } catch (e) {
      _log('deleteReport – error: $e');
    } finally {
      isUpload.value = false;
      update();
    }
  }

  Future<void> pickReport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    final file = result != null && result.files.single.path != null
        ? File(result.files.single.path!)
        : null;

    if (file == null) {
      _log('pickReport – no file selected');
      return;
    }

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
      final result = await repository.uploadReport(file);
      report.value = result;

      if (result == null) {
        _log('pickReport – upload returned null');
        FLoader.errorSnackBar(title: InspectionPage.obdUploadFailed.tr);
      } else if (result.startsWith('pending://')) {
        _log('pickReport – queued for reconnect, local path: $result');
        FLoader.infoSnackBar(
          title: 'saved_locally_title'.tr,
          message: 'saved_locally_message'.tr,
        );
      } else {
        _log('pickReport – upload success, report URL: $result');
        FLoader.successSnackBar(title: InspectionPage.obdUploadSuccess.tr);
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
      final synced = await repository.delete(code);
      _log('delete code – done (synced=$synced)');
      if (synced) {
        FLoader.successSnackBar(
          title: InspectionPage.obdCodeDeletedSuccess.tr,
          message: InspectionPage.obdCodeDeletedSuccessMsg.tr,
        );
      } else {
        FLoader.infoSnackBar(
          title: 'queued_delete_title'.tr,
          message: 'queued_delete_message'.tr,
        );
      }
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
      if (result != null && result.id <= 0) {
        _log('onCreateEdit – storing code (id=${result.id}): ${result.code}');
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
