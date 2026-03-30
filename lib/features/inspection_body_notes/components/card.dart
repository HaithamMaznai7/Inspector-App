import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionBodyNotesDialog extends StatefulWidget {
  const InspectionBodyNotesDialog({super.key, required this.note});
  final Marker note;

  @override
  State<InspectionBodyNotesDialog> createState() =>
      _InspectionBodyNotesDialogState();
}

class _InspectionBodyNotesDialogState extends State<InspectionBodyNotesDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _marker = widget.note;
    _textEditingController.text = _marker.note ?? '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  bool get _hasImage => _marker.image != null || _marker.file != null;
  bool get _isEditing => _marker.id > 0;

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
            color: FColors.grey.withValues(alpha: isDark ? 0.15 : 0.2),
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
                  _buildImageSection(context, isDark),
                  const SizedBox(height: FSizes.lg),
                  _buildNoteField(context, isDark),
                  const SizedBox(height: FSizes.lg),
                  _buildTypeSection(context, isDark),
                  const SizedBox(height: FSizes.lg),
                  _buildActionRow(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FSizes.md, 12, FSizes.md, FSizes.sm),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.warning_2,
                  color: FColors.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FTexts.markerTitle.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_isEditing)
                      Text(
                        FTexts.editBtn.tr,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: FColors.grey),
                      ),
                  ],
                ),
              ),
              if (_isEditing) ...[
                _ActionIcon(
                  icon: Iconsax.trash,
                  onTap: _delete,
                  color: FColors.error,
                  bg: FColors.error.withValues(alpha: 0.08),
                ),
                const SizedBox(width: FSizes.xs),
              ],
              _ActionIcon(
                icon: Icons.close_rounded,
                onTap: _cancel,
                color: isDark ? FColors.grey : FColors.dark,
                bg: FColors.grey.withValues(alpha: isDark ? 0.1 : 0.12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image section ──────────────────────────────────────────────

  Widget _buildImageSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Iconsax.camera, label: FTexts.markerAddPhoto.tr),
        const SizedBox(height: FSizes.sm),
        if (_hasImage) ...[
          // Full image preview with change overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                child: _marker.file != null
                    ? Image.file(
                        _marker.file!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: _marker.image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 160,
                          color: FColors.grey.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: FColors.primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 160,
                          color: FColors.grey.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(Iconsax.image, color: FColors.grey),
                          ),
                        ),
                      ),
              ),
              // Change photo button overlay
              Positioned(
                bottom: FSizes.sm,
                right: FSizes.sm,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.dark.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusLg,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.camera,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          FTexts.markerChangePhoto.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Placeholder tap zone
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? FColors.darkGrey.withValues(alpha: 0.2)
                    : FColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: FColors.primaryColor.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.camera,
                      size: 20,
                      color: FColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    FTexts.markerAddPhoto.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: FColors.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Note field ─────────────────────────────────────────────────

  Widget _buildNoteField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          icon: Iconsax.note_text,
          label: FTexts.markerInputTitle.tr,
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: _textEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          minLines: 2,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: FTexts.markerInputHint.tr,
            hintStyle: TextStyle(
              color: isDark
                  ? FColors.grey.withValues(alpha: 0.45)
                  : FColors.darkGrey,
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark
                ? FColors.darkGrey.withValues(alpha: 0.2)
                : FColors.grey.withValues(alpha: 0.13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: isDark
                    ? FColors.grey.withValues(alpha: 0.2)
                    : FColors.darkGrey.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: isDark
                    ? FColors.grey.withValues(alpha: 0.2)
                    : FColors.darkGrey.withValues(alpha: 0.4),
              ),
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

  // ── Type scrollable list ───────────────────────────────────────

  Widget _buildTypeSection(BuildContext context, bool isDark) {
    return StreamBuilder<List<Selection>>(
      stream: InspectionBodyBinding().instance.assetsRepository.bodyNoteTypes(),
      builder: (context, snapshot) {
        final types = snapshot.data ?? <Selection>[];
        if (types.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(
              icon: Iconsax.tag,
              label: FTexts.markerSelectTitle.tr,
            ),
            const SizedBox(height: FSizes.sm),
            Container(
              constraints: const BoxConstraints(maxHeight: 210),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: isDark
                      ? FColors.grey.withValues(alpha: 0.2)
                      : FColors.darkGrey.withValues(alpha: 0.4),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: types.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: FSizes.md,
                    endIndent: FSizes.md,
                    color: FColors.grey.withValues(alpha: isDark ? 0.12 : 0.4),
                  ),
                  itemBuilder: (context, index) {
                    final t = types[index];
                    final isSelected = _marker.type == t.value;
                    return InkWell(
                      onTap: () => setState(
                        () => _marker.type = isSelected ? null : t.value,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        color: isSelected
                            ? FColors.primaryColor.withValues(alpha: 0.07)
                            : isDark
                            ? FColors.darkGrey.withValues(alpha: 0.2)
                            : FColors.grey.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? FColors.primaryColor
                                      : isDark
                                      ? FColors.light
                                      : FColors.dark,
                                ),
                              ),
                            ),
                            const SizedBox(width: FSizes.sm),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey(true),
                                      color: FColors.primaryColor,
                                      size: 20,
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      key: const ValueKey(false),
                                      color: FColors.grey.withValues(
                                        alpha: isDark ? 0.35 : 0.9,
                                      ),
                                      size: 20,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Action buttons ─────────────────────────────────────────────

  Widget _buildActionRow(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Save button — full width, prominent
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Iconsax.tick_circle, size: 18),
          label: Text(
            FTexts.submitBtn.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: FColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: FSizes.sm),
        // Cancel — text style, subtle
        TextButton(
          onPressed: _cancel,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? FColors.grey : FColors.darkGrey,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            FTexts.cancelBtn.tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ── Logic ──────────────────────────────────────────────────────

  void _submit() {
    _marker.note = _textEditingController.text.trim();

    if (_marker.note?.isEmpty ?? true) {
      FLoader.warningSnackBar(
        title: FTexts.markerNoteRequired.tr,
        message: FTexts.markerNoteRequiredMsg.tr,
      );
      return;
    }

    if (_marker.type == null) {
      FLoader.warningSnackBar(
        title: FTexts.markerTypeRequired.tr,
        message: FTexts.markerTypeRequiredMsg.tr,
      );
      return;
    }

    Get.back(result: _marker);
  }

  void _cancel() => Get.back(result: null);

  Future<void> _delete() async {
    final isDark = FHelper.isDarkMode(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? FColors.dark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          InspectionPage.deleteBodyNote.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? FColors.light : FColors.dark,
          ),
        ),
        content: Text(
          InspectionPage.deleteBodyNoteConfirm.tr,
          style: TextStyle(
            color: isDark ? FColors.grey : FColors.darkGrey,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              FTexts.cancelBtn.tr,
              style: const TextStyle(color: FColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(
                color: FColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) Get.back(result: Marker(id: -1, dx: 0, dy: 0));
  }

  Future<void> _pickImage() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final file = await Camera.open();
    if (file != null) setState(() => _marker.file = file);
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final color = isDark ? FColors.grey : FColors.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
