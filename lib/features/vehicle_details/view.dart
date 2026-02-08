import 'package:fahis_inspector/common/widgets/components/custom_selector.dart';
import 'package:fahis_inspector/features/vehicle_details/controller.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VehicleDetailsView extends StatelessWidget {
  const VehicleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VehicleDetailsBinding().instance;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FSizes.lg,
          vertical: FSizes.md,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    controller
                                .mainController
                                .inspection
                                .value
                                ?.vehicle
                                ?.make
                                ?.avatar ==
                            null
                        ? const Icon(Iconsax.car, size: 30)
                        : Image.network(
                            controller
                                .mainController
                                .inspection
                                .value!
                                .vehicle!
                                .make!
                                .avatar!,
                            fit: BoxFit.contain,
                            width: 30,
                            height: 30,
                          ),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      '${controller.mainController.inspection.value?.vehicle?.make?.label}',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Iconsax.car),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      '${controller.mainController.inspection.value?.vehicle?.model?.label}',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Iconsax.calendar),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      '${controller.mainController.inspection.value?.vehicle?.year}',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            GetBuilder<VehicleDetailsController>(
              init: VehicleDetailsBinding().instance,
              autoRemove: false,
              builder: (controller) {
                final details = controller.editableDetails.value;

                return Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DetailsPage.vehicleInfoTile,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),
                      buildEditableField(
                        DetailsPage.vin.tr,
                        'vin',
                        details.vin ?? '',
                        controller.vinController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      buildEditableField(
                        DetailsPage.plateNumber.tr,
                        'plate',
                        details.plate ?? '',
                        controller.plateController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return CustomSelector(
                            title: DetailsPage.yearModel.tr,
                            items: Helpers.generateYearsList(),
                            onChanged: (value) {
                              controller.inspectionDetails.value?.yearModel =
                                  value?.value;

                              controller.update();
                            },
                            value:
                                controller.inspectionDetails.value?.yearModel,
                            error: controller.formErrors['year_model'],
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.bodyTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.bodyType.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller.inspectionDetails.value?.bodyType =
                                      value?.value;

                                  controller.update();
                                },
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.bodyType,
                                error: controller.formErrors['body_type_id'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository
                                .drivetrainTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.drivetrain.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller
                                          .inspectionDetails
                                          .value
                                          ?.drivetrain =
                                      value?.value;

                                  controller.update();
                                },
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.drivetrain,
                                error: controller.formErrors['drivetrain'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.fuelTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.fuelType.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller.inspectionDetails.value?.fuelType =
                                      value?.value;

                                  controller.update();
                                },
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.fuelType,
                                error: controller.formErrors['fuel_type'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          final fuelType =
                              controller.inspectionDetails.value?.fuelType;
                          if (fuelType != '1') {
                            return SizedBox();
                          }

                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.gasolineTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.gasolineType.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller
                                          .inspectionDetails
                                          .value
                                          ?.gasolineType =
                                      value?.value;

                                  controller.update();
                                },
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.gasolineType,
                                error: controller.formErrors['gasoline_type'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      buildEditableField(
                        DetailsPage.milage.tr,
                        'milage',
                        details.milage ?? '',
                        controller.milageController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository
                                .cylinderNumbers(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.cylindersNo.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller
                                          .inspectionDetails
                                          .value
                                          ?.cylindersNo =
                                      value?.value;

                                  controller.update();
                                },
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.cylindersNo,
                                error: controller.formErrors['cylinders_no'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      buildEditableField(
                        DetailsPage.engineSize.tr,
                        'engine_size',
                        details.enginSize ?? '',
                        controller.enginSizeController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.gearboxTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.gearboxType.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller.inspectionDetails.value?.gearbox =
                                      value?.value;

                                  controller.update();
                                },
                                value:
                                    controller.inspectionDetails.value?.gearbox,
                                error: controller.formErrors['gearbox_type'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      buildEditableField(
                        DetailsPage.exteriorColor.tr,
                        'color',
                        details.color ?? '',
                        controller.colorController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      buildEditableField(
                        DetailsPage.interiorColor.tr,
                        'seats_color',
                        details.seatColor ?? '',
                        controller.seatColorController,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.seatNumbers(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.seatNo.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller.inspectionDetails.value?.seatsNo =
                                      value?.value;

                                  controller.update();
                                },
                                value:
                                    controller.inspectionDetails.value?.seatsNo,
                                error: controller.formErrors['seats_no'],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      GetBuilder<VehicleDetailsController>(
                        init: VehicleDetailsBinding().instance,
                        builder: (controller) {
                          return StreamBuilder<List<Selection>>(
                            stream: controller.assetsRepository.seatTypes(),
                            builder: (context, snapshot) {
                              return CustomSelector(
                                title: DetailsPage.seatType.tr,
                                items: snapshot.data ?? <Selection>[],
                                onChanged: (value) {
                                  controller
                                          .inspectionDetails
                                          .value
                                          ?.seatsType =
                                      value?.value;
                                  controller.update();
                                },
                                error: controller.formErrors['seats_type'],
                                value: controller
                                    .inspectionDetails
                                    .value
                                    ?.seatsType,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: FSizes.spaceBtwItems * 4),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField(
    String label,
    String key,
    String value,
    TextEditingController? textController,
  ) {
    textController ??= TextEditingController(text: value);
    final controller = VehicleDetailsBinding().instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(Get.context!).textTheme.titleLarge),
          const SizedBox(height: 4),
          TextFormField(
            controller: textController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Enter $label",
              errorText: VehicleDetailsBinding().instance.formErrors[key],
            ),
            onSaved: (value) {
              final updated = controller.editableDetails.value;
              controller.editableDetails.value = updated.copyWith(vin: value);
            },
            onChanged: (value) {
              textController?.addListener(() {
                if (controller.formErrors.containsKey(key)) {
                  controller.formErrors.remove(key);
                }
              });
            },
            validator: (value) {
              return FValidation.defaultValidator(value!);
            },
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField<T>({
    required String label,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    T? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          DropdownButton<T>(
            value: value,
            hint: Text("Select $label"),
            isExpanded: true,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
            onChanged: (value) => onChanged(value),
          ),
        ],
      ),
    );
  }
}
