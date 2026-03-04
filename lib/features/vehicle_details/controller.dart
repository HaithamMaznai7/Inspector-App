import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_steps/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/vehicle_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
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

      // Merge: only overwrite fields that the search actually returned.
      final current = inspectionDetails.value ?? VehicleDetails.empty();
      inspectionDetails.value = current.copyWith(
        vin: searched.vin ?? current.vin,
        plate: searched.plate ?? current.plate,
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
}
