import 'dart:async';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_body_notes/view.dart';
import 'package:fahis_inspector/features/inspection_obd/view.dart';
import 'package:fahis_inspector/features/paint_gauge/view.dart';
import 'package:fahis_inspector/features/inspection_photos/view_section.dart';
import 'package:fahis_inspector/features/inspection_points/view.dart';
import 'package:fahis_inspector/features/vehicle_details/view.dart';
import 'package:fahis_inspector/features/inspection_details/components/note_dialog.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

class InspectionStepsController extends GetxController {
  InspectionDetailsRepository? repository;
  Box? box;
  Box<List>? assetsBox;

  late Rx<Inspection> inspection;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  RxList<Map<String, dynamic>> tabs = RxList<Map<String, dynamic>>([]);

  /// MODE A (Sahrej): only Points + Photos, no Details/Body/OBD.
  bool get isSahrejMode =>
      inspection.value.hasPoints &&
      inspection.value.hasPhotos &&
      !inspection.value.hasDetails &&
      !inspection.value.hasBody &&
      !inspection.value.hasObd;

  Worker? _reconnectWorker;
  bool _repositoryReady = false;

  int currentIndex = 0;
  int index = 0;
  int highestReachedIndex = 0;

  Map<String, dynamic> _tab(
    int id,
    IconData icon,
    InspectionStage stage,
    Widget screen, {
    bool skippable = false,
    String? label,
  }) => {
    'id': id,
    'icon': icon,
    'stage': stage,
    'screen': screen,
    'skippable': skippable,
    'label': label ?? stage.getLabel,
  };

  /// Finds the list index of a tab by its stage.
  /// Returns -1 if no tab exists for that stage.
  int _tabIndexForStage(InspectionStage stage) {
    return tabs.indexWhere((tab) => tab['stage'] == stage);
  }

  void onInspectionChanged(Inspection? data) {
    isLoading.value = true;
    update();
    if (data == null) return;

    _buildTabsFromInspection(data);
    isLoading.value = false;
    update();
  }

  void _initializeIndex() {
    // IDs are already sequential from _buildTabsFromInspection
    tabs.sort((a, b) => a['id'].compareTo(b['id']));

    // Find the list index of the tab matching the inspection's current stage
    final stageIndex = _tabIndexForStage(inspection.value.stage);
    currentIndex = stageIndex >= 0 ? stageIndex : 0;
    index = currentIndex;
    highestReachedIndex = currentIndex;
  }

  @override
  void onInit() {
    super.onInit();

    inspection = Rx<Inspection>(Get.arguments as Inspection);

    load();

    onInspectionChanged(inspection.value);

    inspection.listen(onInspectionChanged);

    _reconnectWorker = ever(ConnectionService.instance.onReconnect, (_) {
      if (_repositoryReady) repository!.flushPendingStage();
    });
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
  }

  Future<void> load({bool refresh = false}) async {
    // RESET state
    repository = null;
    box = null;

    // Init cache + repo
    box = await Hive.openBox('Inspection_${inspection.value.slug}');
    assetsBox = await Hive.openBox<List>(inspection.value.slug);
    repository = InspectionDetailsRepository(
      slug: inspection.value.slug,
      box: box!,
    );
    _repositoryReady = true;
  }

  void goToTab(int index) {
    if (index >= 0 && index < tabs.length) {
      this.index = index;
      currentIndex = index;
      if (index > highestReachedIndex) {
        highestReachedIndex = index;
      }
    }
    update();
  }

  void _buildTabsFromInspection(Inspection inspection) {
    tabs.clear();

    // Sequential counter so tab IDs always match their list index
    int counter = 0;

    if (inspection.hasDetails) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.car,
          InspectionStage.info,
          const VehicleDetailsView(),
        ),
      );
    }

    if (inspection.hasPoints) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.check,
          InspectionStage.points,
          const InspectionPointResults(),
        ),
      );
    }

    if (inspection.hasPhotos) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.image4,
          InspectionStage.photos,
          const AlbumPhotos(),
        ),
      );
    }

    if (inspection.hasBody) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.note,
          InspectionStage.body,
          const InspectionBodyTypeResults(),
        ),
      );
    }

    if (inspection.hasPaintBody) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.brush_1,
          InspectionStage.body,
          const PaintGaugeStepView(),
          skippable: true,
          label: PaintGaugePage.stepTitle.tr,
        ),
      );
    }

    if (inspection.hasObd) {
      tabs.add(
        _tab(
          counter++,
          Iconsax.code,
          InspectionStage.obd,
          const OBDCodesView(),
        ),
      );
    }

    _initializeIndex();
  }

  void initializeTabs() {
    if (inspection.value.hasDetails) {
      VehicleDetailsBinding().dependencies();
    }

    if (!(['pending', 'accepted'].contains(inspection.value.stage.value) &&
            inspection.value.hasDetails) &&
        inspection.value.hasPoints) {
      InspectionPointsBinding().dependencies();
    }

    if (!(['pending', 'accepted'].contains(inspection.value.stage.value) &&
            inspection.value.hasDetails) &&
        inspection.value.hasPhotos) {
      InspectionPhotosBinding().dependencies();
    }

    if (!(['pending', 'accepted'].contains(inspection.value.stage.value) &&
            inspection.value.hasDetails) &&
        inspection.value.hasBody) {
      InspectionBodyBinding().dependencies();
    }

    if (!(['pending', 'accepted'].contains(inspection.value.stage.value) &&
            inspection.value.hasDetails) &&
        inspection.value.hasObd) {
      InspectionObdBinding().dependencies();
    }

    if (!(['pending', 'accepted'].contains(inspection.value.stage.value) &&
            inspection.value.hasDetails) &&
        inspection.value.hasPaintBody) {
      PaintGaugeBinding().dependencies();
    }
  }

  /// Safe reset after vehicle info is updated.
  /// Clears all cached data, resets step progress, notes, points,
  /// and controller state so it behaves like first-time inspection entry.
  Future<void> resetAfterVehicleInfoUpdate() async {
    _log('resetAfterVehicleInfoUpdate – start');

    // 1. Clear Hive cache for this inspection (NOT assets – they're global)
    if (box != null && box!.isOpen) {
      await box!.clear();
      _log('resetAfterVehicleInfoUpdate – inspection box cleared');
    }

    // 2. Reset step progress to first tab
    currentIndex = 0;
    index = 0;
    highestReachedIndex = 0;

    // 3. Reset & reload child controllers in PARALLEL to minimize wait
    final futures = <Future>[];

    if (InspectionPointsBinding().isRegistered) {
      final pointsCtrl = InspectionPointsBinding().instance;
      pointsCtrl.allPoints.clear();
      pointsCtrl.category.value = null;
      pointsCtrl.review.value = null;
      futures.add(
        pointsCtrl.load().then(
          (_) => _log('resetAfterVehicleInfoUpdate – points reloaded'),
        ),
      );
    }

    if (InspectionPhotosBinding().isRegistered) {
      final photosCtrl = InspectionPhotosBinding().instance;
      photosCtrl.photos.clear();
      photosCtrl.filtered.clear();
      photosCtrl.categories.clear();
      photosCtrl.category.value = null;
      futures.add(
        photosCtrl.fetchPhotos().then(
          (_) => _log('resetAfterVehicleInfoUpdate – photos reloaded'),
        ),
      );
    }

    if (InspectionBodyBinding().isRegistered) {
      final bodyCtrl = InspectionBodyBinding().instance;
      bodyCtrl.bodySides.clear();
      futures.add(
        bodyCtrl.fetchBodySides().then(
          (_) => _log('resetAfterVehicleInfoUpdate – body reloaded'),
        ),
      );
    }

    if (InspectionObdBinding().isRegistered) {
      final obdCtrl = InspectionObdBinding().instance;
      obdCtrl.codes.clear();
      obdCtrl.report.value = null;
      futures.add(
        obdCtrl.loadBySlug().then(
          (_) => _log('resetAfterVehicleInfoUpdate – OBD reloaded'),
        ),
      );
    }

    if (PaintGaugeBinding().isRegistered) {
      PaintGaugeBinding().instance.resetMeasurements();
      _log('resetAfterVehicleInfoUpdate – paint gauge reset');
    }

    // Also reload main inspection data in parallel
    futures.add(load(refresh: true));

    await Future.wait(futures);

    _log('resetAfterVehicleInfoUpdate – done');
    update();
  }

  /// Returns a progression index for comparing stage order.
  /// Higher index = further along in the inspection flow.
  static int _stageProgressIndex(InspectionStage stage) {
    const order = [
      InspectionStage.info, // 0
      InspectionStage.points, // 1
      InspectionStage.photos, // 2
      InspectionStage.body, // 3
      InspectionStage.obd, // 4
      InspectionStage.finished, // 5
    ];
    final i = order.indexOf(stage);
    return i >= 0 ? i : -1;
  }

  Future<void> setSatge(InspectionStage stage) async {
    isSubmitting.toggle();
    update();

    final oldValue = inspection.value.stage;

    // Stores the result of vehicle-info save so we can use it after the API call.
    // -1 = failed, 0 = saved (no reset), 1 = saved + reset
    int vehicleSaveResult = 0;

    // ── Step 1: Pre-flight validation & data collection ──────────────────
    switch (stage) {
      case InspectionStage.info:
        break;
      case InspectionStage.points:
        // Save & validate vehicle details before advancing from Info
        if (VehicleDetailsBinding().isRegistered) {
          vehicleSaveResult = await VehicleDetailsBinding().instance.onSave();
          if (vehicleSaveResult < 0) {
            _log('setSatge(points) – vehicle save/validation failed');
            isSubmitting.toggle();
            update();
            return;
          }
        }
        break;
      case InspectionStage.photos:
        // Validate points before advancing to photos
        if (!_validatePoints()) {
          isSubmitting.toggle();
          update();
          return;
        }
        break;
      case InspectionStage.body:
        // Validate photos before advancing to body
        if (!_validatePhotos()) {
          isSubmitting.toggle();
          update();
          return;
        }
        break;
      case InspectionStage.obd:
        break;
      case InspectionStage.finished:
        // Validate photos if this inspection has photos (for Sahrej finish)
        if (inspection.value.hasPhotos && !_validatePhotos()) {
          isSubmitting.toggle();
          update();
          return;
        }

        final note = await Get.dialog<String>(
          NoteInputDialog(
            status: stage.toString(),
            note: inspection.value.note,
          ),
        );
        // null = dialog dismissed/cancelled
        if (note == null) {
          isSubmitting.toggle();
          update();
          return;
        }
        // Backend requires note when stage is finished; use '-' if empty
        inspection.value.note = note.trim().isEmpty ? '-' : note.trim();
        break;
      default:
        break;
    }

    // ── Step 2: Determine if we need to update the backend stage ─────────
    // Only call the API when advancing BEYOND the current backend stage.
    // When re-visiting a previous tab, just validate (Step 1) and navigate
    // (Step 3) — never regress the backend stage.
    final isAdvancing =
        _stageProgressIndex(stage) > _stageProgressIndex(oldValue);

    if (isAdvancing) {
      inspection.value.stage = stage;
      if (kDebugMode) {
        print('┌─── setSatge: API REQUEST ─────────────────');
        print('│ Old stage : $oldValue (${oldValue.value})');
        print(
          '│ New stage : ${inspection.value.stage} (${inspection.value.stage.value})',
        );
        print('│ Note      : "${inspection.value.note}"');
        print('│ Slug      : ${inspection.value.slug}');
        print('└────────────────────────────────────────────');
      }
      try {
        inspection.value = await repository!.update(inspection.value);

        // Propagate stage change to the home listing without refetching.
        if (InspectionsBinding().isRegistered) {
          InspectionsBinding().instance.applyInspectionUpdate(inspection.value);
        }

        // Patch the details controller's inspection so the stage label
        // updates immediately when navigating back (avoids relying on a
        // potentially delayed API GET response).
        if (InspectionDetailsBinding().isRegistered) {
          final detailsCtrl = InspectionDetailsBinding().instance;
          detailsCtrl.inspection.value = inspection.value;
          detailsCtrl.update();
        }
      } on FNetworkException catch (e) {
        if (kDebugMode) {
          print('┌─── setSatge: API ERROR ───────────────────');
          print('│ Status  : ${e.statusCode}');
          print('│ Message : ${e.message}');
          print('│ Title   : ${e.title}');
          print('│ Errors  : ${e.errors}');
          print('└────────────────────────────────────────────');
        }
        e.notify();
        inspection.value.stage = oldValue;
        isSubmitting.toggle();
        update();
        return;
      } catch (_) {
        inspection.value.stage = oldValue;
        isSubmitting.toggle();
        update();
        return;
      }
    } else {
      _log('setSatge($stage) – not advancing (backend=$oldValue), skip API');
    }

    isSubmitting.toggle();
    update();

    // ── Step 3: Navigate & post-navigation setup ──────────────────────────
    if (stage == InspectionStage.finished) {
      Get.back();
      return;
    }

    goToTab(_tabIndexForStage(stage));

    // After advancing to the points tab, trigger a load/regenerate so the
    // points list reflects the (possibly updated) vehicle info.
    if (stage == InspectionStage.points &&
        InspectionPointsBinding().isRegistered) {
      final pointsCtrl = InspectionPointsBinding().instance;
      if (vehicleSaveResult == 1) {
        // Vehicle info was reset — regenerate points if the backend cleared them.
        // Call repository.generate() directly — controller.generate()
        // shows a confirmation dialog which we don't want here.
        if (pointsCtrl.allPoints.isEmpty) {
          _log('setSatge(points) – points empty after reset, regenerating');
          pointsCtrl.isLoading.value = true;
          pointsCtrl.update();
          await pointsCtrl.repository.generate();
          pointsCtrl.isLoading.value = false;
          pointsCtrl.update();
        }
      } else if (isAdvancing) {
        // First save — refresh points (initial load may have been empty
        // because vehicle details weren't saved yet).
        pointsCtrl.load(isRefresh: true);
      }
    }
  }

  bool get isOnFirstTab => index == 0;
  bool get isOnLastTab => index == tabs.length - 1;
  bool get allTabsReached => highestReachedIndex >= tabs.length - 1;

  InspectionStage get next =>
      (tabs[index]['stage'] as InspectionStage).next ??
      InspectionStage.finished;

  InspectionStage get pervious =>
      (tabs[index]['stage'] as InspectionStage).cancel ??
      InspectionStage.accepted;

  void toNext() {
    if (isOnLastTab) {
      setSatge(InspectionStage.finished);
      return;
    }

    final currentStage = tabs[index]['stage'] as InspectionStage;
    final nextTabIndex = index + 1;
    final nextStage = tabs[nextTabIndex]['stage'] as InspectionStage;

    // If consecutive tabs share the same stage (e.g. body notes → paint gauge),
    // just navigate to the next tab without a backend stage update.
    if (nextStage == currentStage) {
      goToTab(nextTabIndex);
      return;
    }

    final nextApiStage = currentStage.next;
    if (nextApiStage != null) {
      setSatge(nextApiStage);
    } else {
      Get.back();
    }
  }

  void toPervious() {
    if (index != 0) {
      goToTab(index - 1);
    } else {
      Get.back();
    }
  }

  /// Whether the current step passes validation so the Next button
  /// can be enabled. This is called by the StepSelector widget.
  bool get canAdvanceFromCurrentStep {
    if (tabs.isEmpty || index >= tabs.length) return false;

    // Skippable tabs (e.g. paint gauge) are always advanceable
    if (tabs[index]['skippable'] == true) return true;

    final stage = tabs[index]['stage'] as InspectionStage;

    switch (stage) {
      case InspectionStage.info:
        return _isVehicleInfoComplete();
      case InspectionStage.points:
        return _arePointsValid();
      case InspectionStage.photos:
        return _arePhotosValid();
      case InspectionStage.obd:
        return true;
      default:
        return true;
    }
  }

  /// Called when the user taps "Review" on the last step.
  /// Saves the current stage, then pops back to inspection details.
  /// The caller (openEditing) already refreshes data after this returns.
  Future<void> finishAndReview() async {
    _log('finishAndReview – start');

    // Prevent double submission
    if (isSubmitting.value) {
      _log('finishAndReview – already submitting, ignoring');
      return;
    }

    // Validate current step before finishing
    if (!canAdvanceFromCurrentStep) {
      _showValidationForCurrentStep();
      _log('finishAndReview – current step validation failed');
      return;
    }

    isSubmitting.value = true;
    update();

    bool success = false;
    try {
      // Save current stage to API
      if (repository != null) {
        _log('finishAndReview – saving to API...');
        inspection.value = await repository!.update(inspection.value);
        _log('finishAndReview – saved successfully');
        success = true;
      }
    } on FNetworkException catch (e) {
      _log('finishAndReview – FNetworkException: ${e.statusCode}');
      e.notify();
    } catch (e) {
      _log('finishAndReview – error: $e');
    } finally {
      isSubmitting.value = false;
      update();
    }

    // Only pop back on successful submission
    if (success) {
      Get.back();
    }
  }

  // ─── Validation helpers (return bool, no UI) ───

  bool _isVehicleInfoComplete() {
    if (!VehicleDetailsBinding().isRegistered) return true;
    final ctrl = VehicleDetailsBinding().instance;
    final vin = ctrl.vinController.text.trim();
    final plate = ctrl.plateController.text.trim();
    final milage = ctrl.milageController.text.trim();
    final cc = ctrl.enginSizeController.text.trim();
    final color = ctrl.colorController.text.trim();
    final seatColor = ctrl.seatColorController.text.trim();
    return vin.length == 17 &&
        plate.isNotEmpty &&
        milage.isNotEmpty &&
        cc.isNotEmpty &&
        RegExp(r'^\d+(\.\d+)?$').hasMatch(cc) &&
        color.isNotEmpty &&
        seatColor.isNotEmpty;
  }

  bool _arePointsValid() {
    if (!InspectionPointsBinding().isRegistered) return true;
    final points = InspectionPointsBinding().instance.allPoints;
    if (points.isEmpty) return false;
    if (isSahrejMode) {
      // MODE A: ALL points must be filled
      return points.every((p) => p.status != PointStatus.none);
    } else {
      // MODE B: at least one point filled
      return points.any((p) => p.status != PointStatus.none);
    }
  }

  bool _arePhotosValid() {
    if (!InspectionPhotosBinding().isRegistered) {
      // Controller not registered — if the inspection actually requires
      // photos we must NOT silently pass. Accessing .instance will
      // lazy-init the controller, but photos won't be loaded yet.
      if (inspection.value.hasPhotos) {
        _log(
          '_arePhotosValid – controller not registered but hasPhotos=true → false',
        );
        return false;
      }
      return true;
    }
    final photos = InspectionPhotosBinding().instance.photos;
    final result = photos.isEmpty
        ? false
        : isSahrejMode
        ? photos.every((p) => p.image != null)
        : photos.any((p) => p.image != null);
    _log(
      '_arePhotosValid – total=${photos.length}, '
      'withImage=${photos.where((p) => p.image != null).length}, '
      'sahrej=$isSahrejMode → $result',
    );
    return result;
  }

  // ─── Validation with UI feedback ───

  bool _validateVehicleInfo() {
    if (!VehicleDetailsBinding().isRegistered) return true;
    final ctrl = VehicleDetailsBinding().instance;
    final formValid = ctrl.formKey.currentState?.validate() ?? false;
    if (!formValid) {
      _log('_validateVehicleInfo – form validation failed');
      FLoader.warningSnackBar(
        title: InspectionPage.vehicleInfoRequired.tr,
        message: InspectionPage.vehicleInfoRequiredMsg.tr,
      );
      return false;
    }
    return true;
  }

  bool _validatePoints() {
    if (_arePointsValid()) return true;
    _log('_validatePoints – failed (sahrej=$isSahrejMode)');
    if (isSahrejMode) {
      FLoader.warningSnackBar(
        title: InspectionPage.allPointsRequired.tr,
        message: InspectionPage.allPointsRequiredMsg.tr,
      );
    } else {
      FLoader.warningSnackBar(
        title: InspectionPage.pointsRequired.tr,
        message: InspectionPage.pointsRequiredMsg.tr,
      );
    }
    return false;
  }

  bool _validatePhotos() {
    if (_arePhotosValid()) return true;
    _log('_validatePhotos – failed (sahrej=$isSahrejMode)');
    if (isSahrejMode) {
      FLoader.warningSnackBar(
        title: InspectionPage.allPhotosRequired.tr,
        message: InspectionPage.allPhotosRequiredMsg.tr,
      );
    } else {
      FLoader.warningSnackBar(
        title: InspectionPage.photosRequired.tr,
        message: InspectionPage.photosRequiredMsg.tr,
      );
    }
    return false;
  }

  /// Shows a validation snackbar for the current step (used by finishAndReview).
  void _showValidationForCurrentStep() {
    if (tabs.isEmpty || index >= tabs.length) return;
    final stage = tabs[index]['stage'] as InspectionStage;
    switch (stage) {
      case InspectionStage.info:
        _validateVehicleInfo();
        break;
      case InspectionStage.points:
        _validatePoints();
        break;
      case InspectionStage.photos:
        _validatePhotos();
        break;
      case InspectionStage.obd:
        break;
      default:
        break;
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[Steps Controller] $message');
    }
  }
}
