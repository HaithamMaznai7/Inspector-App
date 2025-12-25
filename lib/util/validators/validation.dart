import 'package:fahis_inspector/features/configuration/models/selection_model.dart';
import 'package:get/get.dart';

class FValidation{
  static String? validateEmail(String? value) {
    if(value == null){
      return "Provide valid Email".tr;
    }
    if (!GetUtils.isEmail(value)) {
      return "Provide valid Email".tr;
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < 8) {
      return "password_validation".tr;
    }
    return null;
  }

  static String? validatePhoneNo(String value) {
    if (value.length < 9 || value.length > 12) {
      return "phone_number_validation".tr;
    }
    return null;
  }

  static String? validateCarPlate(String value) {
    value = value.replaceAll(' ', '');
    value = value.replaceAll('|', '');

    if (value.isEmpty) {
      return 'The Car Plate must be entered'.tr;
    }

    int valueCount = value.length ;

    if(valueCount < 4){
      return 'The Car Plate length must be less than 4'.tr;
    }

    if(valueCount > 9){
      return 'The Car Plate length must be less than 9'.tr;
    }

    String letterString = value.substring(0,3);
    String numberString = value.substring(3);


    if (!GetUtils.isNumericOnly(numberString)) {
      return 'The last charts in Car Plate must be numbers'.tr;
    }

    if (RegExp(r'^[^A-Z]').hasMatch(letterString)) {
      return 'The First 3 charts in Car Plate must be letters'.tr;
    }

    return null;
  }

  static String? validateMilage(String value) {
    if (value.isEmpty) {
      return 'The Milage must be entered'.tr;
    }

    if (!GetUtils.isNumericOnly(value)) {
      return 'The Milage must be numbers'.tr;
    }
    return null;
  }

  static String? validateEngineSize(String value) {
    if (value.isEmpty) {
      return 'The Engine Size must be entered'.tr;
    }

    // Validate that the value contains only digits and optionally a decimal point
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return 'The Engine Size must be normal numbers or decimal'.tr;
    }

    return null;
  }

  static String? validateVIN(String vin) {
    if (vin.isEmpty) {
      return 'The VIN must be entered'.tr;
    }

    if (vin.isNotEmpty && vin.length <= 9) {
      return 'The VIN length must be greater than 12'.tr;
    }

    if (vin.length > 9 && vin.length <= 12) {
      return '${vin.length - 17} ${vin.length > 17 ? '+' : ''}'.tr;
    }

    return null; // Return true if the VIN is valid
  }

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'The value must be entered'.tr;
    }

    if (value.length < 3) {
      return 'The value must be of 3 characters or more'.tr;
    }
    return null;
  }

  static String? selectionRequired(Selection? value) {
    if (value == null || value.isEmpty()) {
      return 'The value must be entered'.tr;
    }
    return null;
  }

  static String? defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'The value must be entered'.tr;
    }

    if(value == '' || value.isEmpty || value == 'none' || value == 'nul' || value == 'null' || value == 'Choose One'.tr){
      return 'The value must be entered'.tr;
    }
    return null;
  }
}