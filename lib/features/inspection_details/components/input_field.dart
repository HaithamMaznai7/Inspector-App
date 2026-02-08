import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:fahis_inspector/util/validators/validation.dart';
import 'package:flutter/material.dart';

class FRowInput extends StatelessWidget {
  const FRowInput({
    super.key,
    required this.title,
    required this.icon,
    required this.hint,
    required this.validatesNumbers,
    required this.textController,
    this.isPlateNumber = false,
    this.isNumber = false,
    this.isMilage = false,
    this.enable = true,
  });

  final bool enable, isNumber, isPlateNumber, isMilage;
  final String title, hint;
  final int validatesNumbers;
  final IconData icon;
  final TextEditingController textController;
  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
          color: isDark ? FColors.darkGrey.withOpacity(.2) : FColors.grey.withOpacity(.8) ,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg)
      ),
      child: TextFormField(
          enabled: enable,
          // readOnly: controller.inspection.value.status == RequestStatus.finished || controller.inspection.value.status == RequestStatus.approved ,
          controller: textController,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            prefixIcon: Icon(icon),
            hintText: hint ,
            label: Text(title),
            contentPadding: const EdgeInsets.symmetric(vertical: FSizes.md, horizontal: FSizes.md),
          ),
          textAlign: TextAlign.center,
          onChanged: (value) {
            // if(validatesNumbers == 2){
            //   // textController.text = EFormatter.validateCarPlate(value, textController.text);
            // }
          }  ,
          onSaved: (value) {
            //controller.values.add(value!);
          },
          validator: (value) {
            String? error;
            switch (validatesNumbers){
              case 1 :
                error = FValidation.validateVIN(value!);
              case 2 :
                error = FValidation.validateCarPlate(value!);
              case 3 :
                error = FValidation.validateMilage(value!);
              case 4 :
                error = FValidation.validateEngineSize(value!);
              case 5 :
                error = FValidation.isRequired('field', value!);
              default:
                error = FValidation.isRequired('field', value!);

            }
            return error;
          }
      ),
    );
  }
}
