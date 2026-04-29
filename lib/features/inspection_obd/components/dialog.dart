import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/obd_code.dart';
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
  late TextEditingController _descController;
  OBDCode? _code;

  bool get _isEditing => (_code?.id ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _code = widget.code;
    _codeController = TextEditingController(text: _code?.code ?? '');
    _descController = TextEditingController(text: _code?.description ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
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
                  _buildField(
                    context,
                    isDark,
                    label: InspectionPage.obdCodeLabel.tr,
                    icon: Iconsax.cpu,
                    controller: _codeController,
                    hint: InspectionPage.obdCodeHint.tr,
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
