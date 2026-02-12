import 'dart:io';
import 'package:camera/camera.dart';
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

class InspectionNotesDialog extends StatefulWidget {
  const InspectionNotesDialog(this.point, {super.key});
  final Point point;

  @override
  State<InspectionNotesDialog> createState() => _InspectionNotesDialogState();
}

class _InspectionNotesDialogState extends State<InspectionNotesDialog> {
  late TextEditingController _textEditingController;
  late Point _point;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Scaffold(
      // scrollable: true ,
      backgroundColor: FColors.light,
      // alignment: Alignment.center,
      appBar: AppBar(
        title: Text(InspectionPage.addNoteTitle.tr),
        automaticallyImplyLeading: false,
        leading: BackPageButton(color: FColors.primaryColor),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            (_point.image != null && (_point.image?.isNotEmpty ?? false)) ||
                    (_point.file != null)
                ? Expanded(
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusLg,
                      ),
                      child: EasyImageView(
                        doubleTapZoomable: true,
                        imageProvider: _point.file != null
                            ? Image.file(
                                _point.file!,
                                fit: BoxFit.contain,
                              ).image
                            : Image.network(
                                "${_point.image}",
                                fit: BoxFit.contain,
                              ).image,
                      ),
                    ),
                  )
                : Spacer(),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: FSizes.spaceBtwInputFields,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? FColors.darkGrey.withOpacity(.2)
                    : FColors.grey.withOpacity(.8),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: TextFormField(
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  suffix: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                  ),
                  hintText: InspectionPage.noteHint.tr,
                  label: Text(InspectionPage.noteFieldLabel.tr),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: FSizes.md,
                    horizontal: FSizes.md,
                  ),
                ),
                textAlign: TextAlign.center,
                validator: (value) =>
                    value == null || value.isEmpty ? InspectionPage.noteValidation.tr : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: _submit,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        FColors.primaryColor,
                      ),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: FColors.primaryColor),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    child: Text(
                      FTexts.submitBtn.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (_point.file != null)
                  TextButton(
                    onPressed: _delete,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: FColors.primaryColor),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    child: Text(
                      FTexts.deleteBtn.tr,
                      style: const TextStyle(color: FColors.primaryColor),
                    ),
                  ),
              ],
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

  void _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cameras = await availableCameras();
      _point.file = await Get.dialog<File>(Camera(cameras: cameras));
      setState(() {});
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // or use FileType.image, FileType.custom, etc.
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _point.file = File(result.files.single.path!);
        });
      }
    }
  }
}
