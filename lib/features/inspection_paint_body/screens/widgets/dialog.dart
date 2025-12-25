import 'package:fahis_inspector/features/inspection_obd/models/obd_code.dart';
import 'package:fahis_inspector/features/inspection_paint_body/models/paint_body_part.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Edit extends StatefulWidget {
  final PaintBodyPart part;

  const Edit({super.key, required this.part});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  late TextEditingController _thicknessController;
  late TextEditingController _substrateController;
  late PaintBodyPart _part;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return AlertDialog(
      title: Text('Add OBD code'.tr),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 20,
      ), // Adjust the horizontal padding
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _thicknessController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Type thickness value here'.tr,
                    focusColor: FColors.primaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _thicknessController.text = '';
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _substrateController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Type substrate type'.tr,
                    focusColor: FColors.primaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
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
                  'Update'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.apply(color: FColors.white),
                ),
              ),
              TextButton(
                onPressed: _cancelOrDelete,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    isDark ? FColors.dark.withOpacity(.4) : FColors.white,
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
                  'Cancel'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.apply(color: FColors.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _part = widget.part;

    _thicknessController = TextEditingController();
    _substrateController = TextEditingController();

    _thicknessController.text = "${_part.thickness}";
    _substrateController.text = _part.substrate ?? '';

    super.initState();
  }

  _submit() async {
    double thickness = double.parse(_thicknessController.text);
    String substrate = _substrateController.text;

    _part.thickness = thickness;
    _part.substrate = substrate;

    Get.back(result: _part);
  }

  _cancelOrDelete() {
    Get.back(result: _part); // Close the dialog
  }
}
