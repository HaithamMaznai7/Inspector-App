import 'dart:async';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/features/inspection_photos/view_section.dart';
import 'package:fahis_inspector/features/inspection_points/view.dart';
import 'package:fahis_inspector/features/vehicle_details/view.dart';
import 'package:fahis_inspector/features/inspection_details/components/note_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';

class InspectionStepsController extends GetxController
    with GetTickerProviderStateMixin {
  InspectionDetailsRepository? repository;
  Box? box;
  Box<List>? assetsBox;

  late Rx<Inspection> inspection;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  TabController? tabController;

  RxList<Map<String, dynamic>> tabs = RxList<Map<String, dynamic>>([]);

  int currentIndex = 0;
  int index = 0;

  Map<String, dynamic> _tab(
    int id,
    IconData icon,
    InspectionStage stage,
    Widget screen,
  ) => {'id': id, 'icon': icon, 'stage': stage, 'screen': screen};

  void onInspectionChanged(Inspection? data) {
    isLoading.value = true;
    update();
    if (data == null) return;

    _buildTabsFromInspection(data);
    isLoading.value = false;
    update();
  }

  void _recreateTabController() {
    tabs.sort((a, b) => a['id'].compareTo(b['id']));

    currentIndex =
        tabs
                .where((tab) => tab['stage'] == inspection.value.stage)
                .firstOrNull?['id']
            as int? ??
        0;
    index = currentIndex;

    try {
      tabController?.dispose();
    } catch (_) {}

    tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: index,
    );

    tabController?.addListener(() {
      currentIndex = tabController!.index;
    });
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
    if (index < tabs.length) {
      tabController?.animateTo(index);
    }

    update();
  }

  void _buildTabsFromInspection(Inspection inspection) {
    tabs.clear();

    if (inspection.hasDetails) {
      tabs.add(
        _tab(0, Iconsax.car, InspectionStage.info, const VehicleDetailsView()),
      );
    }

    if (inspection.hasPoints) {
      tabs.add(
        _tab(
          1,
          Iconsax.check,
          InspectionStage.points,
          const InspectionPointResults(),
        ),
      );
    }

    if (inspection.hasPhotos) {
      tabs.add(
        _tab(2, Iconsax.image4, InspectionStage.photos, const AlbumPhotos()),
      );
    }

    // if (inspection.hasBody) {
    //   tabs.add(
    //     _tab(
    //       3,
    //       Iconsax.note,
    //       InspectionStage.body,
    //       const InspectionBodyTypeResults(),
    //     ),
    //   );
    // }

    // if (inspection.hasObd) {
    //   tabs.add(
    //     _tab(4, Iconsax.code, InspectionStage.obd, const OBDCodesView()),
    //   );
    // }

    _recreateTabController();
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
    tabController?.dispose();
  }

  Future<void> setSatge(InspectionStage stage) async {
    isSubmitting.toggle();
    update();

    final oldValue = inspection.value.stage;

    switch (stage) {
      case InspectionStage.pending:
        inspection.value.stage = stage;
        goToTab(0);
        break;
      case InspectionStage.accepted:
        inspection.value.stage = stage;
        goToTab(0);
        break;
      case InspectionStage.info:
        inspection.value.stage = stage;
        goToTab(1);
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
          inspection.value.stage = stage;
          goToTab(3);
        }
        break;
      case InspectionStage.body:
        inspection.value.stage = stage;
        goToTab(4);
        break;
      case InspectionStage.obd:
        inspection.value.stage = stage;
        goToTab(5);
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
          goToTab(0);
        }
        break;
      case InspectionStage.reviewed:
        inspection.value.stage = stage;
        goToTab(0);
        break;
      case InspectionStage.rejected:
        final note = await Get.dialog(
          NoteInputDialog(status: stage.toString()),
        );
        if (note == null) {
          return;
        } else {
          inspection.value.rejectedNote = note;
          inspection.value.stage = stage;
          goToTab(0);
        }
        break;
      default:
        inspection.value.stage = oldValue;
        goToTab(0);
        break;
    }

    try {
      inspection.value = await repository!.update(inspection.value);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      inspection.value.stage = oldValue;
      load();
    } finally {
      isSubmitting.toggle();
      update();
      if (stage == InspectionStage.finished) {
        Get.back();
      }
    }
  }

  InspectionStage get next =>
      (tabs.value[index]['stage'] as InspectionStage).next ??
      InspectionStage.finished;

  InspectionStage get pervious =>
      (tabs.value[index]['stage'] as InspectionStage).cancel ??
      InspectionStage.accepted;

  void toNext() {
    dd((tabs.value[index]['stage'] as InspectionStage).getLabel);
    if (next == InspectionStage.finished) {
      Get.back();
    } else {
      goToTab(index + 1);
    }
  }

  void toPervious() {
    if (pervious == InspectionStage.pending ||
        pervious == InspectionStage.accepted) {
      Get.back();
    } else {
      goToTab(index - 1);
    }
  }
}
