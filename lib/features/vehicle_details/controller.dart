import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/vehicle_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleDetailsController extends GetxController {
  String? slug;
  VehicleDetailsRepository? repository;
  Box? box;

  late Box<List> assets;
  late AssetsRepository assetsRepository;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;

  final Rxn<VehicleDetails> inspectionDetails = Rxn<VehicleDetails>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  late TextEditingController vinController;
  late TextEditingController plateController;
  late TextEditingController milageController;
  late TextEditingController enginSizeController;
  late TextEditingController colorController;
  late TextEditingController seatColorController;

  final Rx<VehicleDetails> editableDetails = VehicleDetails.empty().obs;

  final formErrors = RxMap<String, String>({});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();

    assets = await Hive.openBox('Assets');
    assetsRepository = AssetsRepository(assets);

    update();

    vinController = TextEditingController(text: '');
    plateController = TextEditingController(text: '');
    milageController = TextEditingController(text: '');
    enginSizeController = TextEditingController(text: '');
    colorController = TextEditingController(text: '');
    seatColorController = TextEditingController(text: '');

    inspectionDetails.listen((data) {
      updateDetails();
    });

    dd('inspection vehicle initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Run on first load AND every URL change
    // ever(Get.routing.obs, (_) {
    //   final newSlug = Get.parameters['slug'];
    //   if (newSlug != null && newSlug != slug) {
    //     loadBySlug();
    //   }
    // });

    // Initial load
    loadBySlug();
    // repository.listenToBroadcast().listen((data) {
    //   dd('data from broadcast');
    //   dd(data);
    // });
  }

  Future<void> loadBySlug() async {
    slug = InspectionDetailsBinding().instance.slug;

    // RESET state
    inspectionDetails.value = null;
    repository = null;
    box = null;

    // Init cache + repo
    box = await Hive.openBox('Inspection_$slug');
    repository = VehicleDetailsRepository(slug: slug!, box: box!);

    // Fast path (navigation with arguments)
    if (Get.arguments is VehicleDetails) {
      inspectionDetails.value = Get.arguments as VehicleDetails;
    }

    inspectionDetails.value ??= repository!.fetchFromCache();

    try {
      inspectionDetails.value = await repository!.fetchFromApi();
    } catch (e) {
      if (inspectionDetails.value == null) {
        Future.microtask(() {
          Get.offAllNamed(RoutingUrl.home);
        });
      }
    }

    update();
  }

  @override
  void onClose() {
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
    vinController.text = inspectionDetails.value?.vin ?? '';
    plateController.text = inspectionDetails.value?.plate ?? '';
    milageController.text = inspectionDetails.value?.milage ?? '';
    enginSizeController.text = inspectionDetails.value?.enginSize ?? '';
    colorController.text = inspectionDetails.value?.color ?? '';
    seatColorController.text = inspectionDetails.value?.seatColor ?? '';
    // mainController.updateInspection(details: inspectionDetails.value);
  }

  bool validateForm() {
    inspectionDetails.value?.vin = vinController.text;
    inspectionDetails.value?.plate = plateController.text;
    inspectionDetails.value?.milage = milageController.text;
    inspectionDetails.value?.enginSize = enginSizeController.text;
    inspectionDetails.value?.color = colorController.text;
    inspectionDetails.value?.seatColor = seatColorController.text;
    formErrors.value = {};
    // final isValid = formKey.currentState!.validate();

    // if (isValid) {
    formKey.currentState!.save();
    // }

    return true;
  }

  Future<void> onSave() async {
    isSubmitting.toggle();
    update();
    try {
      // Save to server
      if (validateForm()) {
        await repository!.update(slug!, inspectionDetails.value!);

        mainController.load(slug!);
      }
    } on FNetworkException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        // dd(e.errors);
        final errors = e.errors!;
        errors.forEach((key, val) {
          formErrors[key] = val[0];
        });
      }
      e.notify();
    } catch (e) {
      final f = FNetworkException('Failed to save data', statusCode: 404);
      f.notify();
    } finally {
      isSubmitting.toggle();
      update();
      mainController.inspection.value!.stage = InspectionStage.points;
      mainController.update();
      // mainController.goToTab(2);
    }
  }
}
