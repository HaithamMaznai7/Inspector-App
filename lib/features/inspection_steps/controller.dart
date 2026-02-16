import 'dart:async';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_body_notes/view.dart';
import 'package:fahis_inspector/features/inspection_obd/view.dart';
import 'package:fahis_inspector/features/inspection_photos/view_section.dart';
import 'package:fahis_inspector/features/inspection_points/view.dart';
import 'package:fahis_inspector/features/vehicle_details/view.dart';
import 'package:fahis_inspector/features/inspection_details/components/note_dialog.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
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

  int currentIndex = 0;
  int index = 0;
  int highestReachedIndex = 0;

  Map<String, dynamic> _tab(
    int id,
    IconData icon,
    InspectionStage stage,
    Widget screen,
  ) => {'id': id, 'icon': icon, 'stage': stage, 'screen': screen};

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

    // isLoading.value = false;
    // update();
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
        _tab(counter++, Iconsax.car, InspectionStage.info, const VehicleDetailsView()),
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
        _tab(counter++, Iconsax.image4, InspectionStage.photos, const AlbumPhotos()),
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

    if (inspection.hasObd) {
      tabs.add(
        _tab(counter++, Iconsax.code, InspectionStage.obd, const OBDCodesView()),
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
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> setSatge(InspectionStage stage) async {
    isSubmitting.toggle();
    update();

    final oldValue = inspection.value.stage;

    // Use stage-based lookup so navigation works for partial orders
    switch (stage) {
      case InspectionStage.info:
        inspection.value.stage = stage;
        goToTab(_tabIndexForStage(stage));
        break;
      case InspectionStage.points:
        // Save vehicle details before advancing from Info to Points
        if (VehicleDetailsBinding().isRegistered) {
          final saved = await VehicleDetailsBinding().instance.onSave();
          if (!saved) {
            isSubmitting.toggle();
            update();
            return;
          }
        }
        inspection.value.stage = stage;
        goToTab(_tabIndexForStage(stage));
        break;
      case InspectionStage.photos:
        if (InspectionPointsBinding().isRegistered &&
            InspectionPointsBinding().instance.allPoints
                .where((point) => point.status != PointStatus.none)
                .toList()
                .isNotEmpty) {
          inspection.value.stage = stage;
          goToTab(_tabIndexForStage(stage));
        } else {
          FLoader.warningSnackBar(
            title: 'Validtion Failed',
            message: 'One Or More Points Required',
          );
        }
        break;
      case InspectionStage.body:
        inspection.value.stage = stage;
        goToTab(_tabIndexForStage(stage));
        break;
      case InspectionStage.obd:
        inspection.value.stage = stage;
        goToTab(_tabIndexForStage(stage));
        break;
      case InspectionStage.finished:
        final note = await Get.dialog(
          NoteInputDialog(
            status: stage.toString(),
            note: inspection.value.note,
          ),
        );
        if (note == null) {
          return;
        } else {
          inspection.value.note = note;
          inspection.value.stage = stage;
          Get.back();
        }
        break;
      default:
        break;
    }

    // Skip API call if stage didn't actually change
    if (inspection.value.stage == oldValue) {
      isSubmitting.toggle();
      update();
      return;
    }

    try {
      inspection.value = await repository!.update(inspection.value);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      inspection.value.stage = oldValue;
      // load();
    } finally {
      isSubmitting.toggle();
      update();
      if (stage == InspectionStage.finished) {
        Get.back();
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
    // Use the current tab's stage to find the next stage
    // instead of fromIndex(index) which assumes hardcoded ordering
    final currentStage = tabs[index]['stage'] as InspectionStage;
    final nextStage = currentStage.next;
    if (nextStage != null) {
      setSatge(nextStage);
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

  /// Called when the user taps "Review" on the last step.
  /// Saves the current stage, then pops back to inspection details.
  /// The caller (openEditing) already refreshes data after this returns.
  Future<void> finishAndReview() async {
    isSubmitting.value = true;
    update();

    try {
      // Save current stage to API
      if (repository != null) {
        inspection.value = await repository!.update(inspection.value);
      }
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      // Silently handle — still navigate back to review
    } finally {
      isSubmitting.value = false;
      update();
    }

    // Pop back to the existing inspection details screen
    Get.back();
  }
}
