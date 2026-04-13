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
    final hPad = isTablet ? FSizes.xl : FSizes.spaceBtwItems;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleHeader(context, controller, isTablet, hPad),
          Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              FSizes.spaceBtwSections + FSizes.md,
            ),
            child: GetBuilder<VehicleDetailsController>(
              init: VehicleDetailsBinding().instance,
              autoRemove: false,
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: FSizes.spaceBtwSections + FSizes.lg,
                    ),
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
    final logoSize = isTablet
        ? FSizes.iconCircleLg + FSizes.xs
        : FSizes.iconCircleMd;
    final iconSize = isTablet
        ? FSizes.iconMd + FSizes.xxs
        : FSizes.iconMd - FSizes.xxs;

    return Container(
      margin: EdgeInsets.fromLTRB(hPad, FSizes.md, hPad, FSizes.spaceBtwItems),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? FSizes.spaceBtwItems : FSizes.md,
        vertical: isTablet ? FSizes.fontSizeLg : FSizes.borderRadiusLg,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? FColors.primaryColor.withValues(alpha: 0.07)
            : FColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
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
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            child: vehicle?.make?.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    child: CachedNetworkImage(
                      imageUrl: vehicle!.make!.avatar!,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => Icon(
                        Iconsax.car,
                        size: iconSize,
                        color: FColors.primaryColor,
                      ),
                      errorWidget: (_, _, _) => Icon(
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
          const SizedBox(width: FSizes.borderRadiusLg),
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
                  const SizedBox(height: FSizes.xs),
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
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: FColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
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
          padding: const EdgeInsets.only(bottom: FSizes.borderRadiusLg),
          child: Row(
            children: [
              Container(
                width: 3,
                height: FSizes.md,
                decoration: BoxDecoration(
                  color: FColors.primaryColor,
                  borderRadius: BorderRadius.circular(FSizes.xxs),
                ),
              ),
              const SizedBox(width: FSizes.sm),
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
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? FColors.darkerGrey : FColors.white,
            hintText: DetailsPage.vinHint.tr,
            counterText: '',
            errorText: controller.formErrors['vin'],
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: const BorderSide(
                color: FColors.primaryColor,
                width: 1.5,
              ),
            ),
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
                            horizontal: FSizes.borderRadiusLg,
                            vertical: FSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.primaryColor,
                            borderRadius: BorderRadius.circular(
                              FSizes.borderRadiusMd,
                            ),
                          ),
                          child: isSearching
                              ? const SizedBox(
                                  width: FSizes.iconInlineSm,
                                  height: FSizes.iconInlineSm,
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
                                      size: FSizes.iconSm,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: FSizes.xs),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _labeled(
      context,
      label,
      TextFormField(
        controller: textController,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? FColors.darkerGrey : FColors.white,
          hintText: label,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
          errorText: VehicleDetailsBinding().instance.formErrors[key],
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: const BorderSide(
              color: FColors.primaryColor,
              width: 1.5,
            ),
          ),
        ),
        onSaved: (v) {
          final updated = controller.editableDetails.value;
          controller.editableDetails.value = updated.copyWith(vin: v);
        },
        onChanged: (_) {
          if (controller.formErrors.containsKey(key)) {
            controller.formErrors.remove(key);
            controller.update();
          }
        },
        validator: validator ?? (value) => FValidation.defaultValidator(value!),
      ),
    );
  }
}
