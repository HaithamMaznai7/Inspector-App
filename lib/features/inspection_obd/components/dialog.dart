import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/obd_ble/services/dtc_description_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddingObdCode extends StatefulWidget {
  final OBDCode? code;

  const AddingObdCode({super.key, this.code});

  @override
  State<AddingObdCode> createState() => _AddingObdCodeState();
}

class _AddingObdCodeState extends State<AddingObdCode> {
  late TextEditingController _codeController;
  late TextEditingController _vinController;
  late TextEditingController _descController;
  OBDCode? _code;
  DtcResult? _aiResult;
  bool _isLookingUp = false;

  bool get _isEditing => (_code?.id ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _code = widget.code;
    _codeController = TextEditingController(text: _code?.code ?? '');
    _vinController = TextEditingController();
    _descController = TextEditingController(text: _code?.description ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _vinController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _lookupDescription() async {
    final dtc = _codeController.text.trim();
    if (dtc.isEmpty) {
      FLoader.warningSnackBar(
        title: InspectionPage.obdCodeRequired.tr,
        message: InspectionPage.obdCodeRequiredMsg.tr,
      );
      return;
    }

    setState(() {
      _isLookingUp = true;
      _aiResult = null;
    });

    final lang = Get.locale?.languageCode == 'ar' ? 'ar' : 'en';
    final result = await DtcDescriptionService.describe(
      dtc: dtc,
      vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
      lang: lang,
    );

    if (!mounted) return;
    setState(() {
      _isLookingUp = false;
      _aiResult = result;
      if (result != null) _descController.text = result.description;
    });
  }

  void _submit() {
    final code = _codeController.text.trim();
    final desc = _descController.text.trim();

    if (code.isEmpty) {
      FLoader.warningSnackBar(
        title: InspectionPage.obdCodeRequired.tr,
        message: InspectionPage.obdCodeRequiredMsg.tr,
      );
      return;
    }
    if (desc.isEmpty) {
      FLoader.warningSnackBar(
        title: InspectionPage.obdDescRequired.tr,
        message: InspectionPage.obdDescRequiredMsg.tr,
      );
      return;
    }

    if (_code == null) {
      _code = OBDCode(id: 0, code: code, description: desc);
    } else {
      _code!.code = code;
      _code!.description = desc;
    }
    Get.back(result: _code);
  }

  void _cancel() => Get.back(result: null);

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FColors.dark : FColors.light,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, isDark),
          Divider(
            height: 1,
            color: FColors.grey.withValues(alpha: isDark ? 0.15 : 0.02),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                FSizes.lg,
                FSizes.lg,
                FSizes.lg,
                FSizes.lg + bottomInset + bottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCodeField(context, isDark),
                  const SizedBox(height: FSizes.lg),
                  _buildField(
                    context,
                    isDark,
                    label: InspectionPage.obdVinLabel.tr,
                    icon: Iconsax.car,
                    controller: _vinController,
                    hint: InspectionPage.obdVinHint.tr,
                  ),
                  const SizedBox(height: FSizes.lg),
                  _buildField(
                    context,
                    isDark,
                    label: InspectionPage.obdDescLabel.tr,
                    icon: Iconsax.note_text,
                    controller: _descController,
                    hint: InspectionPage.obdDescHint.tr,
                    maxLines: 4,
                    minLines: 2,
                  ),
                  if (_aiResult != null && _aiResult!.hasCauses) ...[
                    const SizedBox(height: FSizes.lg),
                    _buildAiSection(
                      context,
                      isDark,
                      title: InspectionPage.obdCausesLabel.tr,
                      icon: Iconsax.warning_2,
                      content: _aiResult!.causes,
                      isList: true,
                    ),
                  ],
                  if (_aiResult != null && _aiResult!.hasSuggestion) ...[
                    const SizedBox(height: FSizes.sm),
                    _buildAiSection(
                      context,
                      isDark,
                      title: InspectionPage.obdSuggestionLabel.tr,
                      icon: Iconsax.setting_2,
                      content: _aiResult!.suggestion,
                      isList: false,
                    ),
                  ],
                  const SizedBox(height: FSizes.lg),
                  _buildActions(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField(BuildContext context, bool isDark) {
    final labelColor = isDark ? FColors.grey : FColors.darkGrey;
    final borderColor = isDark
        ? FColors.grey.withValues(alpha: 0.2)
        : FColors.darkGrey.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.cpu, size: FSizes.iconSm, color: labelColor),
            const SizedBox(width: FSizes.xs),
            Text(
              InspectionPage.obdCodeLabel.tr,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: InspectionPage.obdCodeHint.tr,
            hintStyle: TextStyle(
              color: isDark
                  ? FColors.grey.withValues(alpha: 0.45)
                  : FColors.darkGrey.withValues(alpha: 0.9),
              fontSize: FSizes.fontSizeSm,
            ),
            filled: true,
            fillColor: isDark
                ? FColors.darkGrey.withValues(alpha: 0.2)
                : FColors.grey.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: const BorderSide(
                color: FColors.primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(FSizes.md),
            suffixIcon: _isLookingUp
                ? const Padding(
                    padding: EdgeInsets.all(FSizes.sm),
                    child: SizedBox(
                      width: FSizes.iconSm,
                      height: FSizes.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FColors.primaryColor,
                      ),
                    ),
                  )
                : Tooltip(
                    message: InspectionPage.obdAiLookup.tr,
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.search_normal,
                        color: FColors.primaryColor,
                        size: FSizes.iconSm,
                      ),
                      onPressed: _lookupDescription,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Read-only card for AI-generated causes / suggestion sections.
  Widget _buildAiSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required String content,
    required bool isList,
  }) {
    final bg = isDark
        ? FColors.darkGrey.withValues(alpha: 0.25)
        : FColors.primaryColor.withValues(alpha: 0.05);
    final border = FColors.primaryColor.withValues(alpha: 0.18);
    final labelColor = isDark ? FColors.grey : FColors.darkGrey;

    // Parse bullet lines (lines starting with "-" or "•")
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: FSizes.iconXs, color: FColors.primaryColor),
              const SizedBox(width: FSizes.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          if (isList)
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: FColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Text(
                        // Strip leading dash/bullet from the raw text
                        line.replaceFirst(RegExp(r'^[-•]\s*'), ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.6,
              ),
              textDirection: TextDirection.rtl,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FSizes.md, 12, FSizes.md, FSizes.sm),
      child: Column(
        children: [
          const SizedBox(height: FSizes.fontSizeSm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.cpu,
                  color: FColors.primaryColor,
                  size: FSizes.iconSm,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  (_isEditing
                          ? InspectionPage.obdEditCode
                          : InspectionPage.obdAddCode)
                      .tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _cancel,
                child: Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: FColors.grey.withValues(alpha: isDark ? 0.1 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: FSizes.iconSm,
                    color: isDark ? FColors.grey : FColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    bool isDark, {
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int minLines = 1,
  }) {
    final labelColor = isDark ? FColors.grey : FColors.darkGrey;
    final borderColor = isDark
        ? FColors.grey.withValues(alpha: 0.2)
        : FColors.darkGrey.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: FSizes.iconSm, color: labelColor),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: TextInputType.text,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? FColors.grey.withValues(alpha: 0.45)
                  : FColors.darkGrey.withValues(alpha: 0.9),
              fontSize: FSizes.fontSizeSm,
            ),
            filled: true,
            fillColor: isDark
                ? FColors.darkGrey.withValues(alpha: 0.2)
                : FColors.grey.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: const BorderSide(
                color: FColors.primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(FSizes.md),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Iconsax.tick_circle, size: FSizes.fontSizeLg),
          label: Text(
            FTexts.submitBtn.tr,
            style: const TextStyle(
              fontSize: FSizes.fontSizeMd,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: FColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            padding: const EdgeInsets.symmetric(vertical: FSizes.fontSizeSm),
          ),
        ),
        const SizedBox(height: FSizes.sm),
        TextButton(
          onPressed: _cancel,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? FColors.grey : FColors.darkGrey,
            padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
          ),
          child: Text(
            FTexts.cancelBtn.tr,
            style: const TextStyle(
              fontSize: FSizes.fontSizeSm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
