import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class InspectionNotesDialog extends StatefulWidget {
  const InspectionNotesDialog(this.point, {super.key});
  final Point point;

  @override
  State<InspectionNotesDialog> createState() => _InspectionNotesDialogState();
}

class _InspectionNotesDialogState extends State<InspectionNotesDialog> {
  late TextEditingController _textEditingController;
  late Point _point;

  /// Whether an image is available (from network or local file)
  bool get _hasImage =>
      (_point.image != null && (_point.image?.isNotEmpty ?? false)) ||
      _point.file != null;

  /// Resolves the image provider from either local file or network URL
  ImageProvider? get _imageProvider {
    if (_point.file != null) return FileImage(_point.file!);
    if (_point.image != null && _point.image!.isNotEmpty) {
      return CachedNetworkImageProvider(_point.image!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(InspectionPage.addNoteTitle.tr),
        automaticallyImplyLeading: false,
        leading: BackPageButton(color: FColors.primaryColor),
      ),
      body: Column(
        children: [
          // --- Scrollable content area ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Image section ---
                  _buildImageSection(isDark),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // --- Note text field (no camera icon inside) ---
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? FColors.darkGrey.withValues(alpha: .2)
                          : FColors.grey.withValues(alpha: .15),
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusLg),
                      border: Border.all(color: FColors.grey.withValues(alpha: .4)),
                    ),
                    child: TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: InspectionPage.noteHint.tr,
                        labelText: InspectionPage.noteFieldLabel.tr,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: FSizes.md,
                          horizontal: FSizes.md,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? InspectionPage.noteValidation.tr
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom action buttons ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              child: Row(
                children: [
                  // Submit button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primaryColor,
                        foregroundColor: FColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(FTexts.submitBtn.tr),
                    ),
                  ),
                  // Delete photo button (only when a local file is set)
                  if (_point.file != null) ...[
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _delete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FColors.error,
                          side: const BorderSide(color: FColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.borderRadiusLg),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(FTexts.deleteBtn.tr),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the image preview or a tappable camera placeholder
  Widget _buildImageSection(bool isDark) {
    if (_hasImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.35,
              child: EasyImageView(
                doubleTapZoomable: true,
                imageProvider: _imageProvider!,
              ),
            ),
          ),
          // Change photo overlay button
          Positioned(
            bottom: FSizes.sm,
            right: FSizes.sm,
            child: Material(
              color: FColors.dark.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(FSizes.sm),
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(FSizes.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.sm,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.camera, size: 16, color: FColors.white),
                      const SizedBox(width: 4),
                      Text(
                        FTexts.markerChangePhoto.tr,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.apply(color: FColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // No image — show tappable placeholder
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.2,
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: .2)
              : FColors.grey.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: FColors.primaryColor.withValues(alpha: .3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.camera,
              size: 40,
              color: FColors.primaryColor.withValues(alpha: .7),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              FTexts.markerAddPhoto.tr,
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: FColors.primaryColor.withValues(alpha: .7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _point = widget.point;
    _textEditingController = TextEditingController();
    _textEditingController.text = _point.note ?? '';

    super.initState();
  }

  void _submit() {
    if (_point.image == null && _point.file == null) {
      FLoader.warningSnackBar(
        title: InspectionPage.imageRequired.tr,
        message: InspectionPage.imageRequiredMsg.tr,
      );
      return;
    }

    _point.note = _textEditingController.text;

    if (_point.note == null || _point.note!.isEmpty) {
      FLoader.warningSnackBar(
        title: InspectionPage.noteRequired.tr,
        message: InspectionPage.noteRequiredMsg.tr,
      );
      return;
    }

    Get.back<Point>(result: _point, canPop: true);
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  void _delete() {
    setState(() {
      if (_point.file != null) {
        _point.file = null;
      }
    });
  }

  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final file = await Camera.open(hint: _point.title);
      if (file != null) {
        setState(() {
          _point.file = file;
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _point.file = File(result.files.single.path!);
        });
      }
    }
  }
}
