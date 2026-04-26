import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/vehicle_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/plate_converter.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleDetailsController extends GetxController {
  String? slug;
  VehicleDetailsRepository? repository;
  Box? box;

  Box<List>? assets;
  AssetsRepository? assetsRepository;

  InspectionStepsController get mainController =>
      InspectionStepsBinding().instance;

  final Rxn<VehicleDetails> inspectionDetails = Rxn<VehicleDetails>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isSearchingVin = false.obs;

  final vinController = TextEditingController();
  final plateController = TextEditingController();
  final milageController = TextEditingController();
  final enginSizeController = TextEditingController();
  final colorController = TextEditingController();
  final seatColorController = TextEditingController();

  final Rx<VehicleDetails> editableDetails = VehicleDetails.empty().obs;

  final formErrors = RxMap<String, String>({});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Set to true at the very start of onClose(), before any TextEditingController
  // is disposed. Guards all async continuations that run after await gaps.
  bool _disposed = false;

  Worker? _reconnectWorker;
  StreamSubscription<VehicleDetails?>? _repoSub;
  StreamSubscription<VehicleConflict?>? _conflictSub;
  bool _repositoryReady = false;
  bool _conflictDialogOpen = false;

  @override
  void onInit() async {
    super.onInit();

    assets = await Hive.openBox('Assets');
    assetsRepository = AssetsRepository(assets!);

    update();

    inspectionDetails.listen((data) {
      // Suppress text controller updates while loading to prevent
      // race condition: user types in empty fields → API overwrites.
      if (!isLoading.value) {
        updateDetails();
      }
    });

    dd('inspection vehicle initialized');
  }

  @override
  void onReady() {
    super.onReady();

    _reconnectWorker = ever(
      ConnectionService.instance.onReconnect,
      (_) { if (_repositoryReady) repository!.flushPending(); },
    );

    // Initial load
    loadBySlug();
    // repository.listenToBroadcast().listen((data) {
    //   dd('data from broadcast');
    //   dd(data);
    // });
  }

  Future<void> loadBySlug() async {
    slug = InspectionDetailsBinding().instance.slug;

    isLoading.value = true;
    update();

    // RESET state
    repository = null;
    box = null;

    // Init cache + repo
    box = await Hive.openBox('Inspection_$slug');
    if (_disposed) return;
    repository = VehicleDetailsRepository(slug: slug!, box: box!);
    _repositoryReady = true;

    // Subscribe so post-flush server reconciliation reaches the editor.
    _repoSub?.cancel();
    _repoSub = repository!.stream.listen((data) {
      if (_disposed || isLoading.value || data == null) return;
      inspectionDetails.value = data;
      updateDetails();
      update();
    });

    // Subscribe to multi-inspector conflicts surfaced by flushPending().
    // When a conflict fires we prompt the user to either keep their edits
    // or accept the server copy. Guarded against showing multiple dialogs.
    _conflictSub?.cancel();
    _conflictSub = repository!.conflictStream.listen((conflict) {
      if (_disposed || conflict == null || _conflictDialogOpen) return;
      _showVehicleConflictDialog(conflict);
    });

    // Fast path (navigation with arguments)
    if (Get.arguments is VehicleDetails) {
      inspectionDetails.value = Get.arguments as VehicleDetails;
    }

    inspectionDetails.value ??= repository!.fetchFromCache();

    // Only fetch from API if online — cache was already loaded above.
    if (ConnectionService.instance.isConnectionGood.value) {
      try {
        inspectionDetails.value = await repository!.fetchFromApi();
      } on FNetworkException catch (e) {
        // Only a genuine "inspection is gone" (404) warrants bouncing home.
        // Transient network drops must keep the user on screen with cache.
        if (e.statusCode == 404 &&
            inspectionDetails.value == null &&
            !_disposed) {
          Future.microtask(() => Get.offAllNamed(RoutingUrl.home));
        }
      } catch (_) {
        // Timeout / cancelled / unknown — keep current state; reconnect retries.
      }
    }

    if (_disposed) return;

    // Populate text controllers once with final data
    updateDetails();
    isLoading.value = false;
    update();

    // Flush any vehicle details pending from a prior offline session.
    if (_repositoryReady) await repository!.flushPending();
  }

  @override
  void onClose() {
    _disposed = true;
    _reconnectWorker?.dispose();
    _repoSub?.cancel();
    _conflictSub?.cancel();
    super.onClose();
    vinController.dispose();
    plateController.dispose();
    milageController.dispose();
    enginSizeController.dispose();
    colorController.dispose();
    seatColorController.dispose();
    dd('inspection vehicle closed');
  }

  void updateDetails() {
    if (_disposed) return;
    vinController.text = inspectionDetails.value?.vin ?? '';

    // Normalize the plate from any format (Arabic, English, missing spaces)
    // into the canonical internal format "BRS 1234" before handing it to the
    // SaudiPlatePicker.  The picker listens to plateController so it will
    // refresh automatically.
    final rawPlate = inspectionDetails.value?.plate ?? '';
    plateController.text =
        rawPlate.isNotEmpty ? PlateConverter.normalize(rawPlate) : '';

    milageController.text = inspectionDetails.value?.milage ?? '';
    enginSizeController.text = inspectionDetails.value?.enginSize ?? '';
    colorController.text = inspectionDetails.value?.color ?? '';
    seatColorController.text = inspectionDetails.value?.seatColor ?? '';
  }

  bool validateForm() {
    inspectionDetails.value?.vin = vinController.text;
    inspectionDetails.value?.plate = plateController.text;
    inspectionDetails.value?.milage = milageController.text;
    inspectionDetails.value?.enginSize = enginSizeController.text;
    inspectionDetails.value?.color = colorController.text;
    inspectionDetails.value?.seatColor = seatColorController.text;
    formErrors.value = {};

    // Plate: must be exactly 3 valid Saudi letters + space + 4 digits.
    final plate = plateController.text.trim();
    if (!PlateConverter.isValid(plate)) {
      formErrors['plate'] = DetailsPage.plateNumberValidation.tr;
    }

    // Colors: validated here because they use a custom picker (not TextFormField).
    if (colorController.text.trim().isEmpty) {
      formErrors['color'] = 'fieldRequired'.tr;
    }
    if (seatColorController.text.trim().isEmpty) {
      formErrors['seats_color'] = 'fieldRequired'.tr;
    }

    final isValid = formKey.currentState?.validate() ?? false;

    dd('[validateForm] plate="${plateController.text}" '
        'plateValid=${PlateConverter.isValid(plate)} '
        'color="${colorController.text}" '
        'seatColor="${seatColorController.text}" '
        'formStateValid=$isValid '
        'formErrors=$formErrors');

    if (!isValid || formErrors.isNotEmpty) return false;

    formKey.currentState!.save();
    return true;
  }

  Future<void> searchByVin() async {
    final vin = vinController.text.trim();
    if (vin.length != 17) return;

    isSearchingVin.value = true;

    try {
      final n = Network(endpoint: EndPoints.vinSearch);
      n.setQuery = {'vin': vin};

      final CustomResponse r = await n.response(RoutingUrl.home);

      if (r.hasError || r.data == null || (r.data is Map && r.data.isEmpty)) {
        FLoader.infoSnackBar(
          title: DetailsPage.vinNotFound.tr,
          message: DetailsPage.vinNotFoundMsg.tr,
        );
        return;
      }

      final Map<String, dynamic> raw = Map<String, dynamic>.from(r.data);

      // Convert all values to String? so VehicleDetails.fromJson won't
      // throw a TypeError (the API returns ints/doubles for some fields).
      final Map<String, dynamic> stringified = {};
      for (final entry in raw.entries) {
        final v = entry.value;
        if (v == null || v == 'none' || v == '') {
          stringified[entry.key] = null;
        } else {
          stringified[entry.key] = v.toString();
        }
      }

      final searched = VehicleDetails.fromJson(stringified);

      // Normalize plate from API: may arrive as Arabic or without spaces.
      // PlateConverter.normalize() handles both and produces "BRS 1234".
      final rawPlate = searched.plate;
      final normalizedPlate =
          rawPlate != null ? PlateConverter.normalize(rawPlate) : null;

      // Merge: only overwrite fields that the search actually returned.
      final current = inspectionDetails.value ?? VehicleDetails.empty();
      inspectionDetails.value = current.copyWith(
        vin: searched.vin ?? current.vin,
        plate: (normalizedPlate != null && normalizedPlate.isNotEmpty)
            ? normalizedPlate
            : current.plate,
        bodyType: searched.bodyType ?? current.bodyType,
        fuelType: searched.fuelType ?? current.fuelType,
        gasolineType: searched.gasolineType ?? current.gasolineType,
        drivetrain: searched.drivetrain ?? current.drivetrain,
        gearbox: searched.gearbox ?? current.gearbox,
        milage: searched.milage ?? current.milage,
        cylindersNo: searched.cylindersNo ?? current.cylindersNo,
        seatsNo: searched.seatsNo ?? current.seatsNo,
        seatsType: searched.seatsType ?? current.seatsType,
        color: searched.color ?? current.color,
        seatColor: searched.seatColor ?? current.seatColor,
        yearModel: searched.yearModel ?? current.yearModel,
        enginSize: searched.enginSize ?? current.enginSize,
      );

      updateDetails();
      update();

      FLoader.successSnackBar(
        title: DetailsPage.vinFound.tr,
        message: DetailsPage.vinFoundMsg.tr,
      );
    } on FNetworkException catch (e) {
      if (e.statusCode == 404) {
        FLoader.infoSnackBar(
          title: DetailsPage.vinNotFound.tr,
          message: DetailsPage.vinNotFoundMsg.tr,
        );
      } else {
        FLoader.warningSnackBar(
          title: DetailsPage.vinSearchError.tr,
          message: DetailsPage.vinSearchErrorMsg.tr,
        );
      }
    } catch (_) {
      FLoader.warningSnackBar(
        title: DetailsPage.vinSearchError.tr,
        message: DetailsPage.vinSearchErrorMsg.tr,
      );
    } finally {
      isSearchingVin.value = false;
    }
  }

  /// Returns: -1 = failed, 0 = saved (no reset), 1 = saved + reset ran.
  Future<int> onSave() async {
    try {
      if (validateForm()) {
        await repository!.update(slug!, inspectionDetails.value!);
        _notifyInspectionDetailsAfterSave();
        // Only reset if user is RE-SAVING after already progressing
        // past the info step. On first save, child controllers already
        // have fresh data from their onInit — no reset needed.
        if (mainController.highestReachedIndex > 0) {
          await mainController.resetAfterVehicleInfoUpdate();
          return 1; // saved + reset
        }
        return 0; // saved, no reset
      }
      return -1;
    } on FNetworkException catch (e) {
      // Transport failures (statusCode -1) mean offline/timeout — the repo
      // has already queued the pending update. Treat as a local save so the
      // user gets consistent feedback ("saved locally") and can move on.
      // NOTE: hasPendingUpdate() is also true during real failures (422/500)
      // because the repo saves pending BEFORE the POST — must not be used
      // as a proxy for offline.
      if (e.statusCode == -1) {
        FLoader.infoSnackBar(
          title: 'saved_locally_title'.tr,
          message: 'saved_locally_message'.tr,
        );
        if (mainController.highestReachedIndex > 0) {
          await mainController.resetAfterVehicleInfoUpdate();
          return 1;
        }
        return 0;
      }
      if (e.statusCode == 422 && e.errors != null) {
        final errors = e.errors!;
        errors.forEach((key, val) {
          formErrors[key] = val[0];
        });
      }
      e.notify();
      return -1;
    } catch (e) {
      final f = FNetworkException('Failed to save data', statusCode: 404);
      f.notify();
      return -1;
    } finally {
      // Only rebuild on failure so 422 field errors show in the form.
      // Do NOT call update() on success — it rebuilds GetBuilder which
      // recreates all StreamBuilder asset streams (7 redundant API calls).
      if (formErrors.isNotEmpty) {
        update();
      }
    }
  }

  // Per-controller repositories mean the details screen's own Rxn never hears
  // our edits. Push the fresh vehicle to InspectionDetailsController explicitly
  // so its header + the home-list card refresh without a pull-to-refresh.
  void _notifyInspectionDetailsAfterSave() {
    final v = inspectionDetails.value;
    if (v == null) return;
    if (!Get.isRegistered<InspectionDetailsController>()) return;
    Get.find<InspectionDetailsController>().onVehicleSaved(v);
  }

  // ── Multi-inspector conflict dialog ─────────────────────────────────────
  //
  // Surfaced when the repo's pre-flush check detects the server moved between
  // save-time and flush-time. The user chooses between keeping their pending
  // edits (POST payload, last-writer-wins) or accepting the server version
  // (discard pending, refresh local cache with server state).
  Future<void> _showVehicleConflictDialog(VehicleConflict conflict) async {
    if (_disposed) return;
    _conflictDialogOpen = true;
    final ctx = Get.context;
    if (ctx == null) {
      _conflictDialogOpen = false;
      return;
    }
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final changes = _describeVehicleChanges(conflict.baseline, conflict.server);

    final keepMine = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: isDark ? FColors.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          'vehicle_conflict_title'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? FColors.light : FColors.dark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'vehicle_conflict_message'.tr,
              style: TextStyle(
                color: isDark ? FColors.grey : FColors.darkGrey,
                fontSize: FSizes.fontSizeSm,
              ),
            ),
            if (changes.isNotEmpty) ...[
              const SizedBox(height: FSizes.sm),
              ...changes.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(top: FSizes.xxs),
                  child: Text(
                    '• $line',
                    style: TextStyle(
                      color: isDark ? FColors.grey : FColors.darkGrey,
                      fontSize: FSizes.fontSizeSm,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('conflict_use_server'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'conflict_keep_mine'.tr,
              style: const TextStyle(
                color: FColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    _conflictDialogOpen = false;
    if (_disposed || repository == null) return;

    if (keepMine == true) {
      await repository!.resolveConflictKeepMine();
    } else {
      await repository!.resolveConflictUseServer();
      // Refresh the form with the newly-applied server copy.
      inspectionDetails.value = repository!.fetchFromCache();
      updateDetails();
      update();
    }
  }

  /// Produces a short human-readable diff between the baseline we captured at
  /// save-time and the server's current state, so the dialog can show which
  /// fields conflict (e.g. "VIN changed by another inspector").
  List<String> _describeVehicleChanges(
    VehicleDetails baseline,
    VehicleDetails server,
  ) {
    final lines = <String>[];
    void add(String label, String? a, String? b) {
      if ((a ?? '') != (b ?? '')) lines.add(label);
    }

    add(DetailsPage.vin.tr, baseline.vin, server.vin);
    add(DetailsPage.plateNumber.tr, baseline.plate, server.plate);
    add(DetailsPage.milage.tr, baseline.milage, server.milage);
    add(DetailsPage.yearModel.tr, baseline.yearModel, server.yearModel);
    add(DetailsPage.engineSize.tr, baseline.enginSize, server.enginSize);
    add(DetailsPage.bodyType.tr, baseline.bodyType, server.bodyType);
    add(DetailsPage.fuelType.tr, baseline.fuelType, server.fuelType);
    add(DetailsPage.exteriorColor.tr, baseline.color, server.color);
    add(DetailsPage.interiorColor.tr, baseline.seatColor, server.seatColor);
    return lines;
  }
}
