import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/features/configuration/models/app_config.dart';
import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_details/models/inspection_details.dart';
import 'package:fahis_inspector/features/inspection_details/repository/details_repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionDetailsController extends GetxController {
  final String slug;
  late final InspectionDetailsRepository repository;
  late final Box box;

  static InspectionDetailsController get instance =>
      Get.find(tag: 'inspection-details');

  InspectionDetailsController(this.slug);

  InspectionController get mainController => Get.find(tag: 'inspection');

  final Rxn<InspectionDetails> inspectionDetails = Rxn<InspectionDetails>();

  final isLoading = false.obs;

  late TextEditingController vinController;
  late TextEditingController plateController;
  late TextEditingController milageController;
  late TextEditingController enginSizeController;
  late TextEditingController colorController;
  late TextEditingController seatColorController;

  final Rx<InspectionDetails> editableDetails = InspectionDetails.empty().obs;

  final formErrors = RxMap<String, String>({});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();

    vinController = TextEditingController(text: '');
    plateController = TextEditingController(text: '');
    milageController = TextEditingController(text: '');
    enginSizeController = TextEditingController(text: '');
    colorController = TextEditingController(text: '');
    seatColorController = TextEditingController(text: '');

    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    inspectionDetails.listen((data) {
      updateDetails();
    });

    box = await Hive.openBox(InspectionDetailsRepository.boxKey);

    repository = InspectionDetailsRepository(slug: slug, box: box);

    // 1. Show cached first
    inspectionDetails.value = repository.fetchFromCache();

    // 2. Then refresh from API
    isLoading.value = inspectionDetails.value == null;
    try {
      inspectionDetails.value = await repository.fetchFromApi();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();

    // repository.listenToBroadcast().listen((data) {
    //   print('data from broadcast');
    //   print(data);
    // });
  }

  @override
  void onClose() {
    super.onClose();

    // vinController.dispose();
    // plateController.dispose();
    // milageController.dispose();
    // enginSizeController.dispose();
    // colorController.dispose();
    // seatColorController.dispose();
  }

  updateDetails() async {
    vinController.text = inspectionDetails.value?.vin ?? '';
    plateController.text = inspectionDetails.value?.plate ?? '';
    milageController.text = inspectionDetails.value?.milage ?? '';
    enginSizeController.text = inspectionDetails.value?.enginSize ?? '';
    colorController.text = inspectionDetails.value?.color ?? '';
    seatColorController.text = inspectionDetails.value?.seatColor ?? '';
    mainController.updateInspection(details: inspectionDetails.value);
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

  onSave() async {
    isLoading.toggle();
    update();
    try {
      // Save to server
      if (validateForm()) {
        await InspectionDetailsRepository.update(
          slug,
          inspectionDetails.value!,
        );

      } else {}
    } on FNetworkException catch (e) {
      if (e.statusCode == 422 && e.errors != null) {
        // print(e.errors);
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
      isLoading.toggle();
      update();
    }
  }
}
