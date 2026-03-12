import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/common/widgets/components/color_picker_field.dart';
import 'package:fahis_inspector/common/widgets/components/custom_selector.dart';
import 'package:fahis_inspector/common/widgets/components/saudi_plate_picker.dart';
import 'package:fahis_inspector/features/vehicle_details/controller.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/constants/vehicle_colors.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class VehicleDetailsView extends StatelessWidget {
  const VehicleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VehicleDetailsBinding().instance;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);
    final hPad = isTablet ? 32.0 : 20.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleHeader(context, controller, isTablet, hPad),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 48),
            child: GetBuilder<VehicleDetailsController>(
              init: VehicleDetailsBinding().instance,
              autoRemove: false,
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: FColors.primaryColor,
                      ),
                    ),
                  );
                }
                final details = controller.editableDetails.value;

                return Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Section 1: Identification ─────────────────────
                      _section(
                        context,
                        title: DetailsPage.sectionIdentification.tr,
                        children: [
                          _buildVinField(context, controller),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          _labeled(
                            context,
                            DetailsPage.plateNumber.tr,
                            SaudiPlatePicker(
                              controller: controller.plateController,
                              errorText: controller.formErrors['plate'],
                              onChanged: () {
                                if (controller.formErrors.containsKey(
                                  'plate',
                                )) {
                                  controller.formErrors.remove('plate');
                                  controller.update();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          GetBuilder<VehicleDetailsController>(
                            init: VehicleDetailsBinding().instance,
                            builder: (c) => CustomSelector(
                              title: DetailsPage.yearModel.tr,
                              items: Helpers.generateYearsList(),
                              onChanged: (v) {
                                c.inspectionDetails.value?.yearModel = v?.value;
                                c.update();
                              },
                              value: c.inspectionDetails.value?.yearModel,
                              error: c.formErrors['year_model'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // ── Section 2: Specifications ─────────────────────
                      _section(
                        context,
                        title: DetailsPage.sectionSpecifications.tr,
                        children: [
                          _twoCol(
                            isTablet,
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              builder: (c) => StreamBuilder<List<Selection>>(
                                stream: c.assetsRepository?.bodyTypes(),
                                builder: (_, snap) => CustomSelector(
                                  title: DetailsPage.bodyType.tr,
                                  items: snap.data ?? [],
                                  onChanged: (v) {
                                    c.inspectionDetails.value?.bodyType =
                                        v?.value;
                                    c.update();
                                  },
                                  value: c.inspectionDetails.value?.bodyType,
                                  error: c.formErrors['body_type_id'],
                                ),
                              ),
                            ),
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              builder: (c) => StreamBuilder<List<Selection>>(
                                stream: c.assetsRepository?.drivetrainTypes(),
                                builder: (_, snap) => CustomSelector(
                                  title: DetailsPage.drivetrain.tr,
                                  items: snap.data ?? [],
                                  onChanged: (v) {
                                    c.inspectionDetails.value?.drivetrain =
                                        v?.value;
                                    c.update();
                                  },
                                  value: c.inspectionDetails.value?.drivetrain,
                                  error: c.formErrors['drivetrain'],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          GetBuilder<VehicleDetailsController>(
                            init: VehicleDetailsBinding().instance,
                            builder: (c) => StreamBuilder<List<Selection>>(
                              stream: c.assetsRepository?.fuelTypes(),
                              builder: (_, snap) => CustomSelector(
                                title: DetailsPage.fuelType.tr,
                                items: snap.data ?? [],
                                onChanged: (v) {
                                  c.inspectionDetails.value?.fuelType =
                                      v?.value;
                                  c.update();
                                },
                                value: c.inspectionDetails.value?.fuelType,
                                error: c.formErrors['fuel_type'],
                              ),
                            ),
                          ),
                          GetBuilder<VehicleDetailsController>(
                            init: VehicleDetailsBinding().instance,
                            builder: (c) {
                              if (c.inspectionDetails.value?.fuelType != '1') {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  const SizedBox(height: FSizes.spaceBtwItems),
                                  StreamBuilder<List<Selection>>(
                                    stream: c.assetsRepository?.gasolineTypes(),
                                    builder: (_, snap) => CustomSelector(
                                      title: DetailsPage.gasolineType.tr,
                                      items: snap.data ?? [],
                                      onChanged: (v) {
                                        c
                                                .inspectionDetails
                                                .value
                                                ?.gasolineType =
                                            v?.value;
                                        c.update();
                                      },
                                      value: c
                                          .inspectionDetails
                                          .value
                                          ?.gasolineType,
                                      error: c.formErrors['gasoline_type'],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          buildEditableField(
                            context,
                            DetailsPage.milage.tr,
                            'milage',
                            details.milage ?? '',
                            controller.milageController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'fieldRequired'.tr;
                              }
                              if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                                return 'milageNumbersOnly'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          _twoCol(
                            isTablet,
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              builder: (c) => StreamBuilder<List<Selection>>(
                                stream: c.assetsRepository?.cylinderNumbers(),
                                builder: (_, snap) => CustomSelector(
                                  title: DetailsPage.cylindersNo.tr,
                                  items: snap.data ?? [],
                                  onChanged: (v) {
                                    c.inspectionDetails.value?.cylindersNo =
                                        v?.value;
                                    c.update();
                                  },
                                  value: c.inspectionDetails.value?.cylindersNo,
                                  error: c.formErrors['cylinders_no'],
                                ),
                              ),
                            ),
                            buildEditableField(
                              context,
                              DetailsPage.engineSize.tr,
                              'engine_size',
                              details.enginSize ?? '',
                              controller.enginSizeController,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'fieldRequired'.tr;
                                }
                                if (!RegExp(
                                  r'^\d+(\.\d+)?$',
                                ).hasMatch(v.trim())) {
                                  return 'ccNumbersOnly'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          GetBuilder<VehicleDetailsController>(
                            init: VehicleDetailsBinding().instance,
                            builder: (c) => StreamBuilder<List<Selection>>(
                              stream: c.assetsRepository?.gearboxTypes(),
                              builder: (_, snap) => CustomSelector(
                                title: DetailsPage.gearboxType.tr,
                                items: snap.data ?? [],
                                onChanged: (v) {
                                  c.inspectionDetails.value?.gearbox = v?.value;
                                  c.update();
                                },
                                value: c.inspectionDetails.value?.gearbox,
                                error: c.formErrors['gearbox_type'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // ── Section 3: Colors & Seating ───────────────────
                      _section(
                        context,
                        title: DetailsPage.sectionInterior.tr,
                        children: [
                          _twoCol(
                            isTablet,
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              autoRemove: false,
                              builder: (c) => ColorPickerField(
                                label: DetailsPage.exteriorColor.tr,
                                colors: VehicleColors.exterior,
                                controller: c.colorController,
                                errorText: c.formErrors['color'],
                                onChanged: () {
                                  if (c.formErrors.containsKey('color')) {
                                    c.formErrors.remove('color');
                                    c.update();
                                  }
                                },
                              ),
                            ),
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              autoRemove: false,
                              builder: (c) => ColorPickerField(
                                label: DetailsPage.interiorColor.tr,
                                colors: VehicleColors.interior,
                                controller: c.seatColorController,
                                errorText: c.formErrors['seats_color'],
                                onChanged: () {
                                  if (c.formErrors.containsKey('seats_color')) {
                                    c.formErrors.remove('seats_color');
                                    c.update();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: FSizes.spaceBtwItems),
                          _twoCol(
                            isTablet,
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              builder: (c) => StreamBuilder<List<Selection>>(
                                stream: c.assetsRepository?.seatNumbers(),
                                builder: (_, snap) => CustomSelector(
                                  title: DetailsPage.seatNo.tr,
                                  items: snap.data ?? [],
                                  onChanged: (v) {
                                    c.inspectionDetails.value?.seatsNo =
                                        v?.value;
                                    c.update();
                                  },
                                  value: c.inspectionDetails.value?.seatsNo,
                                  error: c.formErrors['seats_no'],
                                ),
                              ),
                            ),
                            GetBuilder<VehicleDetailsController>(
                              init: VehicleDetailsBinding().instance,
                              builder: (c) => StreamBuilder<List<Selection>>(
                                stream: c.assetsRepository?.seatTypes(),
                                builder: (_, snap) => CustomSelector(
                                  title: DetailsPage.seatType.tr,
                                  items: snap.data ?? [],
                                  onChanged: (v) {
                                    c.inspectionDetails.value?.seatsType =
                                        v?.value;
                                    c.update();
                                  },
                                  value: c.inspectionDetails.value?.seatsType,
                                  error: c.formErrors['seats_type'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Vehicle header card ─────────────────────────────────────────────────────

  Widget _buildVehicleHeader(
    BuildContext context,
    VehicleDetailsController controller,
    bool isTablet,
    double hPad,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicle = controller.mainController.inspection.value.vehicle;
    final logoSize = isTablet ? 56.0 : 48.0;
    final iconSize = isTablet ? 26.0 : 22.0;

    return Container(
      margin: EdgeInsets.fromLTRB(hPad, 16, hPad, 20),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 18 : 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? FColors.primaryColor.withValues(alpha: 0.07)
            : FColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: vehicle?.make?.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl: vehicle!.make!.avatar!,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Icon(
                        Iconsax.car,
                        size: iconSize,
                        color: FColors.primaryColor,
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Iconsax.car,
                        size: iconSize,
                        color: FColors.primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.car,
                    size: iconSize,
                    color: FColors.primaryColor,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle?.make?.label ?? ''} ${vehicle?.model?.label ?? ''}'
                      .trim(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (vehicle?.year != null && vehicle!.year!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vehicle.year!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (vehicle?.year != null && vehicle!.year!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vehicle.year!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section container with accent title ────────────────────────────────────

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: FColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.025)
                : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  // ── Responsive 2-column row ─────────────────────────────────────────────────

  Widget _twoCol(bool isTablet, Widget a, Widget b) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: FSizes.md),
          Expanded(child: b),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        a,
        const SizedBox(height: FSizes.spaceBtwItems),
        b,
      ],
    );
  }

  // ── Field with label ────────────────────────────────────────────────────────

  Widget _labeled(BuildContext context, String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: FSizes.xs),
        field,
      ],
    );
  }

  // ── VIN field ───────────────────────────────────────────────────────────────

  Widget _buildVinField(
    BuildContext context,
    VehicleDetailsController controller,
  ) {
    return Obx(() {
      final isSearching = controller.isSearchingVin.value;
      final vinLength = controller.vinController.text.trim().length;
      final canSearch = vinLength == 17 && !isSearching;
      final showSuffix = canSearch || isSearching;

      return _labeled(
        context,
        DetailsPage.vin.tr,
        TextFormField(
          controller: controller.vinController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 17,
          decoration: InputDecoration(
            hintText: DetailsPage.vinHint.tr,
            counterText: '',
            errorText: controller.formErrors['vin'],
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: showSuffix
                  ? Padding(
                      key: const ValueKey('vin_search_btn'),
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: GestureDetector(
                        onTap: canSearch
                            ? () => controller.searchByVin()
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Iconsax.search_normal_1,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DetailsPage.vinSearchBtn.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('vin_empty')),
            ),
          ),
          onChanged: (_) => controller.update(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'fieldRequired'.tr;
            }
            if (value.trim().length != 17) return 'vinMustBe17'.tr;
            return null;
          },
        ),
      );
    });
  }

  // ── Editable text field ─────────────────────────────────────────────────────

  Widget buildEditableField(
    BuildContext context,
    String label,
    String key,
    String value,
    TextEditingController? textController, {
    String? Function(String?)? validator,
  }) {
    textController ??= TextEditingController(text: value);
    final controller = VehicleDetailsBinding().instance;
    return _labeled(
      context,
      label,
      TextFormField(
        controller: textController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: label,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
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
        validator: validator ?? (value) => FValidation.defaultValidator(value!),
      ),
    );
  }
}
