import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/common/widgets/components/custom_selector.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
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
  final bool _uploading = false;

  @override
  void initState() {
    _marker = widget.note;
    _textEditingController.text = _marker.note ?? '';
    super.initState();
  }

  /// Whether an image is available (from network or local file)
  bool get _hasImage => _marker.image != null || _marker.file != null;

  /// Resolves the image provider from either network URL or local file
  ImageProvider? get _imageProvider {
    if (_marker.file != null) return FileImage(_marker.file!);
    if (_marker.image != null) return CachedNetworkImageProvider(_marker.image!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return AlertDialog(
      scrollable: true,
      backgroundColor: isDark ? FColors.dark : FColors.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      titlePadding: const EdgeInsets.fromLTRB(FSizes.lg, FSizes.lg, FSizes.lg, 0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FSizes.lg,
        vertical: FSizes.md,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(FSizes.lg, 0, FSizes.lg, FSizes.md),
      title: Text(
        FTexts.markerTitle.tr,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: FSizes.sm),

            // --- Image preview / capture section ---
            _buildImageSection(isDark),
            const SizedBox(height: FSizes.spaceBtwItems),

            // --- Note text field (no camera icon inside) ---
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? FColors.darkGrey.withValues(alpha: .2)
                    : FColors.grey.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(color: FColors.grey.withValues(alpha: .4)),
              ),
              child: TextFormField(
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  labelText: FTexts.markerInputTitle.tr,
                  hintText: FTexts.markerInputHint.tr,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: FSizes.md,
                    horizontal: FSizes.md,
                  ),
                ),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // --- Marker type selector ---
            StreamBuilder<List<Selection>>(
              stream: InspectionBodyBinding().instance.assetsRepository
                  .bodyNoteTypes(),
              builder: (context, snapshot) {
                return CustomSelector(
                  enable: true,
                  title: FTexts.markerSelectTitle.tr,
                  items: snapshot.data ?? <Selection>[],
                  onChanged: (value) {
                    _marker.type = value?.value;
                  },
                  value: _marker.type,
                );
              },
            ),
          ],
        ),
      ),
      actions: _buildActions(context),
    );
  }

  /// Builds the image preview or placeholder photo capture area
  Widget _buildImageSection(bool isDark) {
    if (_hasImage) {
      // Show image preview with a change-photo overlay button
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            child: Image(
              image: _imageProvider!,
              height: FSizes.imagePreviewMd + FSizes.sm,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
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

    // No image yet — show a tappable placeholder
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: FSizes.imagePreviewSm - FSizes.iconInlineSm,
        decoration: BoxDecoration(
          color: isDark
              ? FColors.darkGrey.withValues(alpha: .2)
              : FColors.grey.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: FColors.primaryColor.withValues(alpha: .3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.camera, size: 32, color: FColors.primaryColor.withValues(alpha: .7)),
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

  /// Builds the action buttons inside a Row (Expanded requires a Flex parent)
  List<Widget> _buildActions(BuildContext context) {
    return [
      Row(
        children: [
          // Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: _uploading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primaryColor,
                foregroundColor: FColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _uploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: FColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(FTexts.submitBtn.tr),
            ),
          ),
          const SizedBox(width: FSizes.sm),

          // Delete button (only for existing markers)
          if (_marker.id > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: FColors.error,
                  side: const BorderSide(color: FColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(FTexts.deleteBtn.tr),
              ),
            ),
            const SizedBox(width: FSizes.sm),
          ],

          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: FColors.darkGrey,
                side: const BorderSide(color: FColors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(FTexts.cancelBtn.tr),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// Validates and returns the marker result
  void _submit() {
    _marker.note = _textEditingController.text;

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

  void _cancel() {
    Get.back(result: null);
  }

  /// Deletes this marker by returning a special signal
  void _delete() {
    Get.back(result: Marker(id: -1, dx: 0, dy: 0));
  }

  /// Opens the camera (mobile) or file picker (desktop) and updates the preview
  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cameras = await availableCameras();
      final file = await Get.dialog<File>(Camera(cameras: cameras));
      if (file != null) {
        setState(() {
          _marker.file = file;
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _marker.file = File(result.files.single.path!);
        });
      }
    }
  }
}
