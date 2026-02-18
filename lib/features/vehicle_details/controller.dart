import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
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

  Box<List>? assets;
  AssetsRepository? assetsRepository;

  InspectionStepsController get mainController =>
      InspectionStepsBinding().instance;

  final Rxn<VehicleDetails> inspectionDetails = Rxn<VehicleDetails>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final vinController = TextEditingController();
  final plateController = TextEditingController();
  final milageController = TextEditingController();
  final enginSizeController = TextEditingController();
  final colorController = TextEditingController();
  final seatColorController = TextEditingController();

  final Rx<VehicleDetails> editableDetails = VehicleDetails.empty().obs;

  final formErrors = RxMap<String, String>({});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

    isLoading.value = true;
    update();

    // RESET state
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

    // Populate text controllers once with final data
    updateDetails();
    isLoading.value = false;
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

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    formKey.currentState!.save();
    return true;
  }

  Future<bool> onSave() async {
    try {
      if (validateForm()) {
        await repository!.update(slug!, inspectionDetails.value!);
        // Only reset if user is RE-SAVING after already progressing
        // past the info step. On first save, child controllers already
        // have fresh data from their onInit — no reset needed.
        if (mainController.highestReachedIndex > 0) {
          await mainController.resetAfterVehicleInfoUpdate();
        }
        return true;
      }
      return false;
    } on FNetworkException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        final errors = e.errors!;
        errors.forEach((key, val) {
          formErrors[key] = val[0];
        });
      }
      e.notify();
      return false;
    } catch (e) {
      final f = FNetworkException('Failed to save data', statusCode: 404);
      f.notify();
      return false;
    } finally {
      // Only rebuild on failure so 422 field errors show in the form.
      // Do NOT call update() on success — it rebuilds GetBuilder which
      // recreates all StreamBuilder asset streams (7 redundant API calls).
      if (formErrors.isNotEmpty) {
        update();
      }
    }
  }
}
