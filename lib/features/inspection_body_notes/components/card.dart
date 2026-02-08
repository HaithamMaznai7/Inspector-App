import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fahis_inspector/common/widgets/camera/camera.dart';
import 'package:fahis_inspector/common/widgets/components/custom_selector.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/models/menu_item.dart';
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

class InspectionBodyNotesDialog extends StatefulWidget {
  const InspectionBodyNotesDialog({super.key, required this.note});
  final Marker note;

  @override
  State<InspectionBodyNotesDialog> createState() =>
      _InspectionBodyNotesDialogState();
}

class _InspectionBodyNotesDialogState extends State<InspectionBodyNotesDialog> {
  TextEditingController _textEditingController = TextEditingController();

  late Marker _marker;
  bool upload = false;

  @override
  void initState() {
    _marker = widget.note;
    _textEditingController.text = _marker.note ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: FColors.light,
      actions: [
        TextButton(
          onPressed: () => !upload ? _submit() : dd('is not allowed'),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(FColors.primaryColor),
            side: WidgetStateProperty.all(
              const BorderSide(color: FColors.primaryColor),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          child: upload
              ? Center(child: CircularProgressIndicator(color: FColors.white))
              : Text(
                  FTexts.submitBtn.tr,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
        if (_marker.id > 0)
          TextButton(
            onPressed: () => _delete(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              side: WidgetStateProperty.all(
                const BorderSide(color: FColors.primaryColor),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            child: Text(
              FTexts.deleteBtn.tr,
              style: const TextStyle(color: FColors.primaryColor),
            ),
          ),
        TextButton(
          onPressed: () => _cancel(),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            side: WidgetStateProperty.all(
              const BorderSide(color: FColors.primaryColor),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          child: Text(
            FTexts.cancelBtn.tr,
            style: const TextStyle(color: FColors.primaryColor),
          ),
        ),
      ],
      alignment: Alignment.center,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FSizes.lg,
        vertical: FSizes.lg,
      ),
      title: Text(FTexts.markerTitle.tr),
      content: SizedBox(
        width: double.maxFinite,
        height: 300, //
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            widget.note.image != null || widget.note.file != null
                ? SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        FSizes.borderRadiusLg,
                      ),
                      child: Image(
                        image: widget.note.image != null
                            ? NetworkImage(widget.note.image!)
                            : FileImage(widget.note.file!) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: FSizes.spaceBtwItems),
            Container(
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
                  hintText: 'hint',
                  label: const Text('title'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: FSizes.md,
                    horizontal: FSizes.md,
                  ),
                ),
                textAlign: TextAlign.center,
                // onChanged: (value) {
                //   _textEditingController.text = value;
                // },
                onSaved: (value) {
                  //controller.values.add(value!);
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Note is Required' : null,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            StreamBuilder<List<Selection>>(
              stream: InspectionBodyBinding().instance.assetsRepository.bodyNoteTypes(),
              builder: (context, snapshot) {
                return CustomSelector(
                  enable: true,
                  title: 'Select Marker Type'.tr,
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
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _submit() {
    _marker.note = _textEditingController.text;

    if (_marker.note?.isEmpty ?? true) {
      FLoader.warningSnackBar(
        title: 'Note is Required',
        message: "You should to describe the issue",
      );
      return;
    }

    if (_marker.type == null) {
      FLoader.warningSnackBar(
        title: 'Type is Required',
        message: "You should to select a type of issue",
      );
      return;
    }

    Get.back(result: _marker);
  }

  void _cancel() {
    Get.back(result: null);
  }

  void _delete() {}

  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final cameras = await availableCameras();
      _marker.file = await Get.dialog<File>(
        Camera(cameras: cameras),
      );
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // or use FileType.image, FileType.custom, etc.
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _marker.file = File(result.files.single.path!);
        });
      }
    }
  }
}
