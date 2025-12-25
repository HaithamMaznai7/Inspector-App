import 'dart:async';
import 'package:fahis_inspector/features/inspection/models/book.dart';
import 'package:fahis_inspector/features/inspection/screens/overview_page.dart';
import 'package:fahis_inspector/features/inspection/screens/widgets/note_dialog.dart';
import 'package:fahis_inspector/features/inspection_body_notes/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_body_notes/models/inspection_body_notes.dart';
import 'package:fahis_inspector/features/inspection_body_notes/screens/view_section.dart';
import 'package:fahis_inspector/features/inspection_details/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_details/models/inspection_details.dart';
import 'package:fahis_inspector/features/inspection_details/screens/view_section.dart';
import 'package:fahis_inspector/features/inspection_obd/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_obd/models/obd_code.dart';
import 'package:fahis_inspector/features/inspection_obd/screens/view_section.dart';
import 'package:fahis_inspector/features/inspection_paint_body/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_paint_body/models/paint_body_part.dart';
import 'package:fahis_inspector/features/inspection_paint_body/screens/view_section.dart';
import 'package:fahis_inspector/features/inspection_photos/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/models/photo.dart';
import 'package:fahis_inspector/features/inspection_photos/screens/view_section.dart';
import 'package:fahis_inspector/features/inspection_points/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_points/models/point.dart';
import 'package:fahis_inspector/features/inspection_points/screens/view_section.dart';
import 'package:fahis_inspector/features/inspections/controllers/home_controller.dart';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/features/inspection/repository/repository.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectionController extends GetxController {
  static InspectionController get instance => Get.find(tag: 'inspection');

  final String slug;
  late final InspectionRepository repository;

  InspectionController(this.slug);

  // late TabController tabController;
  final Rxn<Inspection> inspection = Rxn<Inspection>();

  final isLoading = false.obs;

  RxList tabs = [].obs;

  Rx<Book?> inspectionBook = Rx<Book?>(null);

  var details = InspectionDetails.empty().obs;

  var photos = <Photo>[].obs;

  var points = Rx<ReviewPoint?>(null);

  var bodyNotes = <CarBody>[].obs;

  var obdCodes = <OBDCode>[].obs;

  @override
  void onInit() async {
    super.onInit();

    // tabController = TabController(length: tabs.length, vsync: this)

    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    repository = InspectionRepository(
      slug: slug,
      box: HomeController.instance.box,
    );

    inspection.listen((data) {
      updateInspection(inspection: data);
    });

    // 1. Show cached first
    inspection.value = repository.fetchFromCache();

    // 2. Then refresh from API
    isLoading.value = inspection.value == null;

    try {
      inspection.value = await repository.fetchFromApi();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() async {
    super.onReady();
    // await Future.delayed(Duration(seconds: 10));
    // repository.listenToBroadcast().listen((data) {
    //   inspection.value = data;
    //   update();
    // });
  }

  void initTabs(int id, {Map<String, dynamic>? data, bool add = true}) {
    // avoid duplication
    if (add && data == null) {
      data = {
        'id': id,
        'title': 'title',
        'icon': Iconsax.info_circle,
        'screen': SizedBox(),
      };
    }

    if (data != null) {
      data['id'] = id;

      if (!data.containsKey('title') || data['title'].runtimeType != String) {
        throw Exception('The Title not found or the type is not Widget');
      }

      if (!data.containsKey('icon') || data['icon'].runtimeType != IconData) {
        throw Exception('The Icon not found or the type is not Widget');
      }

      if (!data.containsKey('screen') || data['screen'].runtimeType != Widget) {
        // throw Exception('The Screen not found or the type is not Widget');
      }
    }

    final isExists = tabs.any((tab) => tab['id'] != null && tab['id'] == id);

    if (add && !isExists) {
      tabs.add(data);
    } else if (!add && isExists) {
      tabs.removeAt(id);
    }

    update();
  }

  void updateInspection({
    Inspection? inspection,
    InspectionDetails? details,
    List<Photo>? photos,
    List<Point>? points,
    List<CarBody>? bodySides,
    List<PaintBodyPart>? bodyPoints,
    List<OBDCode>? codes,
  }) {
    if (inspection != null) {
      initTabs(
        0,
        data: {
          'title': 'Overview',
          'icon': Icons.dashboard,
          'screen': OverView(),
        },
        add: true,
      );
      initializeTabs();
    }

    if ((this.inspection.value?.hasDetails ?? false) && details != null) {
      initTabs(
        1,
        data: {
          'title': 'Vehicle',
          'icon': Iconsax.car,
          'screen': VehicleReview(),
        },
        add: true,
      );
    }

    if ((this.inspection.value?.hasPoints ?? false) &&
        points != null &&
        points.isNotEmpty) {
      initTabs(
        2,
        data: {
          'title': 'Points',
          'icon': Iconsax.check,
          'screen': InspectionPointResults(),
        },
        add: true,
      );
    }

    if ((this.inspection.value?.hasPhotos ?? false) &&
        photos != null &&
        photos.isNotEmpty) {
      initTabs(
        3,
        data: {
          'title': 'Photos',
          'icon': Iconsax.image,
          'screen': AlbumPhotos(),
        },
        add: true,
      );
    }

    if ((this.inspection.value?.hasBody ?? false) &&
        bodySides != null &&
        bodySides.isNotEmpty) {
      initTabs(
        4,
        data: {
          'title': 'Body',
          'icon': Iconsax.check,
          'screen': InspectionBodyTypeResults(),
        },
        add: true,
      );
    }

    if ((this.inspection.value?.hasPaintBody ?? false) && bodyPoints != null) {
      initTabs(
        5,
        data: {
          'title': 'Paint Body',
          'icon': Iconsax.color_swatch,
          'screen': PaintBodyView(),
        },
        add: true,
      );
    }

    if ((this.inspection.value?.hasObd ?? false) && codes != null) {
      initTabs(
        6,
        data: {'title': 'OBD', 'icon': Iconsax.code, 'screen': OBDCodesView()},
        add: true,
      );
    }

    update();
  }

  initializeTabs() {
    if ((inspection.value?.hasDetails ?? false)) {
      if (Get.isRegistered<InspectionDetailsController>(
        tag: 'inspection-details',
      )) {
        Get.delete<InspectionDetailsController>(tag: 'inspection-details');
      }

      Get.put<InspectionDetailsController>(
        InspectionDetailsController(slug),
        tag: 'inspection-details',
      );
    }

    if ((inspection.value?.hasPoints ?? false)) {
      if (Get.isRegistered<InspectionPointsController>(
        tag: 'inspection-points',
      )) {
        Get.delete<InspectionPointsController>(tag: 'inspection-points');
      }

      Get.put<InspectionPointsController>(
        InspectionPointsController(slug),
        tag: 'inspection-points',
      );
    }

    if ((inspection.value?.hasPhotos ?? false)) {
      if (Get.isRegistered<InspectionPhotosController>(
        tag: 'inspection-album',
      )) {
        Get.delete<InspectionPhotosController>(tag: 'inspection-album');
      }

      Get.put<InspectionPhotosController>(
        InspectionPhotosController(slug),
        tag: 'inspection-album',
      );
    }

    if ((inspection.value?.hasBody ?? false)) {
      if (Get.isRegistered<InspectionBodyController>(tag: 'inspection-body')) {
        Get.delete<InspectionBodyController>(tag: 'inspection-body');
      }

      Get.put<InspectionBodyController>(
        InspectionBodyController(slug),
        tag: 'inspection-body',
      );
    }

    if ((inspection.value?.hasPaintBody ?? false)) {
      if (Get.isRegistered<InspectionPaintBodyController>(
        tag: 'inspection-paint-body',
      )) {
        Get.delete<InspectionPaintBodyController>(tag: 'inspection-paint-body');
      }

      Get.put<InspectionPaintBodyController>(
        InspectionPaintBodyController(slug),
        tag: 'inspection-paint-body',
      );
    }

    if ((inspection.value?.hasObd ?? false)) {
      if (Get.isRegistered<InspectionObdController>(tag: 'inspection-obd')) {
        Get.delete<InspectionObdController>(tag: 'inspection-obd');
      }

      Get.put<InspectionObdController>(
        InspectionObdController(slug),
        tag: 'inspection-obd',
      );
    }
  }

  getBook() async {
    inspectionBook.value = await repository.getBook();
  }

  Future<void> updateSelectedCenter(Book book) async {
    final updatedBook = await repository.setBook(book: book);

    // refresh full booking info (which includes updated inspectors)
    inspectionBook.value = updatedBook;
    inspectionBook.refresh();

    print(updatedBook?.branch);
    // update local inspection data
    inspection.value!.center = updatedBook?.branch != null
        ? InspectionCenter(
            center: updatedBook!.branch!,
            branch: updatedBook.branch,
            city: inspection.value!.customer?.city,
          )
        : null; // make sure this matches model
    inspection.refresh();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  Future<void> setSatge(InspectionStage stage) async {
    if (inspection.value == null || !Auth.can('update-inspection')) {
      return;
    }

    final oldValue = inspection.value!.stage;

    if (InspectionStage.accepted.value == stage.value) {
      inspection.value!.stage = stage;
    } else if (InspectionStage.finished.value == stage.value) {
      inspection.value!.note = await Get.dialog(
        NoteInputDialog(status: stage.toString(), note: inspection.value?.note),
      );
      print(inspection.value?.note);
      inspection.value!.stage = stage;
    } else if (InspectionStage.rejected.value == stage.value) {
      inspection.value!.rejectedNote = await Get.dialog(
        NoteInputDialog(status: stage.toString()),
      );
      inspection.value!.stage = stage;
    } else {
      inspection.value!.stage = stage;
    }

    try {
      inspection.value = await repository.update(inspection.value!);
    } on FNetworkException catch (e) {
      inspection.value?.stage = oldValue;
      e.notify();
    } catch (_) {
      print('error on update inspection');
    }
  }

  Future<void> callToVehicleOwner() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: inspection.value?.customer?.phone ?? '966',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch';
    }
  }
}
