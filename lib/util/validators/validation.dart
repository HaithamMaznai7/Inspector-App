import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';

class FValidation {
  final Map<String, dynamic> rules;

  final Map<String, dynamic> resultMessages = {};

  late Map<String, dynamic> values;

  Map<String, String> messages = {};

  FValidation(
    this.rules,
    Map<String, dynamic> values, {
    Map<String, String>? messages,
  }) {
    if (messages == null) {
      this.messages = {};
    } else {
      this.messages = messages;
    }

    this.values = {};
    rules.forEach((key, value) {
      this.values[key] = values[key];
    });

    process();
  }

  void process() {
    rules.forEach((key, rulesList) {
      final value = values[key];
      List<String> allRules = [];
      if (rulesList.runtimeType != List) {
        allRules = rulesList.split('|');
      } else {
        allRules = rulesList;
      }

      for(String fuelRule in allRules) {
        String? attributeString;
        String rule = fuelRule;
        
        [rule, attributeString] = fuelRule.split(':');
        
        if (attributeString.isEmpty) {
          attributeString = null;
        }

        List attributes = attributeString?.split(',') ?? [];
        String? result;
        switch (rule) {
          case 'required':
            result = FValidation.isRequired(
              key,
              value,
              message: messages['$key.required'],
            );
          case 'email':
            result = FValidation.validateEmail(
              key,
              value,
              message: messages['$key.email'],
            );
          case 'mobile':
            result = FValidation.validatePhoneNo(
              key,
              value,
              message: messages['$key.mobile'],
            );
          case 'password':
            result = FValidation.validatePassword(
              key,
              value,
              message: messages['$key.password'],
            );
          case 'digits':
            result = FValidation.validateIsDigitsEquel(
              key,
              value,
              attributes.first,
              message: messages['$key.digits'],
            );
          case 'string':
            result = FValidation.validateIsString(
              key,
              value,
              message: messages['$key.string'],
            );
          case 'numeric':
            result = FValidation.validateIsNumeric(
              key,
              value,
              message: messages['$key.numeric'],
            );
          case 'array':
            result = FValidation.validateIsArray(
              key,
              value,
              message: messages['$key.array'],
            );
          case 'min':
            result = FValidation.validateMin(
              key,
              value,
              attributes.first,
              message: messages['$key.min'],
            );
          case 'max':
            result = FValidation.validateMax(
              key,
              value,
              attributes.first,
              message: messages['$key.max'],
            );
        }

        if (resultMessages[key] == null) {
          resultMessages[key] = [];
        }

        if (result != null) {
          resultMessages[key].add(result);
        }
      };
    });
  }

  bool validated() {
    return resultMessages.isEmpty;
  }

  void validate() {
    dd(validated() ? 'validated' : 'not validated');
    if (!validated()) {
      if (resultMessages.length > 1) {
        throw FNetworkException(
          'message and (${resultMessages.length} errors)',
          errors: resultMessages,
          statusCode: 422,
        );
      } else {
        throw FNetworkException(
          'message',
          errors: resultMessages,
          statusCode: 422,
        );
      }
    }
  }

  bool get fild {
    return true;
  }

  static String? validateEmail(
    String fieldName,
    dynamic value, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        validateIsString(fieldName, value) != null ||
        !GetUtils.isEmail(value)) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be a valid email".trParams({
        'fieldName': fieldName,
      });
    }
    return null;
  }

  static String? validateIsDigitsEquel(
    String fieldName,
    dynamic value,
    int length, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        validateIsString(fieldName, value) != null ||
        value!.length == length) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be length @length digits".trParams({
        'fieldName': fieldName,
        'length': length.toString(),
      });
    }
    return null;
  }

  static String? validateIsString(
    String fieldName,
    dynamic value, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null || value.runtimeType != String) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be length digits".trParams({
        'fieldName': fieldName,
      });
    }
    return null;
  }

  static String? validateIsNumeric(
    String fieldName,
    String? value, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        !GetUtils.isNumericOnly(value!)) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be length @length digits".trParams({
        'fieldName': fieldName,
      });
    }
    return null;
  }

  static String? validateIsArray(
    String fieldName,
    dynamic value, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null || value.runtimeType != List) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be an array".trParams({'fieldName': fieldName});
    }
    return null;
  }

  static String? validateMin(
    String fieldName,
    dynamic value,
    int min, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        !GetUtils.isLengthLessOrEqual(value, min)) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be minmum @min".trParams({'fieldName': fieldName, 'min': min.toString()});
    }
    return null;
  }

  static String? validateMax(
    String fieldName,
    dynamic value,
    int max, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        !GetUtils.isLengthGreaterOrEqual(value, max)) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be minmum @max".trParams({'fieldName': fieldName, 'max': max.toString()});
    }
    return null;
  }

  static String? validateIsDigits(
    String fieldName,
    String? value,
    int length, {
    String? message,
  }) {
    if (value?.length == length) {
      if (message != null) {
        return message;
      }

      return "@fieldName should be length @length digits".trParams({
        'fieldName': fieldName,
        'length': length.toString(),
      });
    }
    return null;
  }

  static String? validatePassword(
    String fieldName,
    dynamic value, {
    String? message,
  }) {
    if (!GetUtils.isLengthGreaterThan(value, 8)) {
      if (message != null) {
        return message;
      }

      return "@fieldName is invalid should be a valid password".trParams({
        'fieldName': fieldName,
      });
    }
    return null;
  }

  static String? validatePhoneNo(
    String fieldName,
    String? value, {
    String? message,
  }) {
    if (isRequired(fieldName, value) != null ||
        !GetUtils.isPhoneNumber(value!)) {
      if (message != null) {
        return message;
      }

      return "@fieldName is invalid should be a valid phone number".trParams({
        'fieldName': fieldName,
      });
    }
    return null;
  }

  static String? validateCarPlate(String value) {
    value = value.replaceAll(' ', '');
    value = value.replaceAll('|', '');

    if (value.isEmpty) {
      return 'The Car Plate must be entered'.tr;
    }

    int valueCount = value.length;

    if (valueCount < 4) {
      return 'The Car Plate length must be less than 4'.tr;
    }

    if (valueCount > 9) {
      return 'The Car Plate length must be less than 9'.tr;
    }

    String letterString = value.substring(0, 3);
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

  static String? isRequired(
    String fieldName,
    dynamic value, {
    String? message,
  }) {
    if (value == null || value.isEmpty) {
      return "@fieldName should be a valid email".trParams({
        'fieldName': fieldName,
      });
    }

    return null;
  }

  // static String? selectionRequired(Selection? value) {
  //   if (value == null || value.isEmpty()) {
  //     return 'The value must be entered'.tr;
  //   }
  //   return null;
  // }

  static String? defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'The value must be entered'.tr;
    }

    if (value == '' ||
        value.isEmpty ||
        value == 'none' ||
        value == 'nul' ||
        value == 'null' ||
        value == 'Choose One'.tr) {
      return 'The value must be entered'.tr;
    }
    return null;
  }
}
