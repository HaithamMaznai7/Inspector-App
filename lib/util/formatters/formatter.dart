import 'package:fahis_inspector/main.dart';

import '../constants/api_endpoints.dart';
import '../localization/localization.dart';
import 'package:intl/intl.dart';

class EFormatter {
  static DateFormat get getDateFormat => FLocalization.isArabic
      ? DateFormat.yMMMMEEEEd()
      : DateFormat.yMMMMEEEEd();

  static String? formattedWithTimezone(DateTime? date) =>
      date != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(date) : null;

  static String? formattedWithTime(DateTime? date) =>
      date != null ? DateFormat("yyyy-MM-dd  -  hh:mm a").format(date) : null;

  static String? formatted(DateTime? date) =>
      date != null ? DateFormat.yMMMMEEEEd().format(date) : null;

  // static String _formatTimezoneOffset(Duration offset) {
  //   final sign = offset.isNegative ? '-' : '+';
  //   final hours = offset.inHours.abs().toString().padLeft(2, '0');
  //   final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  //   return ' $sign$hours:$minutes';
  // }

  static String? formatImageUrl(String? value) {
    if (value != null && value == '') {
      return null;
    }

    if (value != null && value.startsWith('//s3')) {
      return "https:$value";
    }

    if (value != null && value.startsWith('http://localhost/api/')) {
      return value.replaceAll('http://localhost/api/', EndPoints.baseUrl);
    }

    if (value != null && value.startsWith('http://localhost:8000/api/')) {
      return value.replaceAll('http://localhost:8000/api/', EndPoints.baseUrl);
    }

    return value;
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming a 1--digit US phone number format: (123) 456-7890
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (phoneNumber.length <= 6 && phoneNumber.length > 3) {
      return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3)}';
    } else if (phoneNumber.length == 7) {
      return '${phoneNumber[0]} ${phoneNumber.substring(1, 4)} ${phoneNumber.substring(4)}';
    } else if (phoneNumber.length > 7) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}'
          .trim();
    } else if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 1)} (+${phoneNumber.substring(1, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}'
          .trim();
    } else if (phoneNumber.length == 12) {
      return '${phoneNumber.substring(0, 2)} (+${phoneNumber.substring(2, 5)}) ${phoneNumber.substring(5, 8)} ${phoneNumber.substring(8)}'
          .trim();
    } else if (phoneNumber.length == 13) {
      return '${phoneNumber.substring(0, 3)} (+${phoneNumber.substring(3, 6)}) ${phoneNumber.substring(6, 9)} ${phoneNumber.substring(9)}'
          .trim();
    }
    // Add more custom phone number formatting logic for different formats if needed.
    return phoneNumber;
  }

  // Not fully tested.
  static String internationalFormatPhoneNumber(
    String phoneNumber, {
    String code = '966',
  }) {
    // Remove any non-digit characters from the phone number
    var digitOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitOnly.length == 10 && digitOnly[0] == '0' && digitOnly[1] == '5') {
      return '$code${digitOnly.substring(1)}';
    }

    if (digitOnly.length > 9) {
      code = digitOnly.substring(0, digitOnly.length - 9);
      digitOnly = digitOnly.substring(digitOnly.length - 9);

      if (code[0] == '0' && code[1] == '0') {
        code = code.substring(2);
      }

      if (code[0] == '0') {
        code = code.substring(1);
      }

      return '$code$digitOnly';
    }

    if (digitOnly.length == 9 && digitOnly[0] == '5') {
      return '$code$digitOnly';
    }

    return digitOnly;
  }

  static String onChangePlateNumber(String value) {
    // Remove any spaces from the input value
    value = value.replaceAll(' ', '');

    if (value.length < 4) {
      // Remove any non-English/Arabic letters and numbers outside the specified range
      value = value.replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF]'), '');

      final letterCount = RegExp(
        r'[a-zA-Z\u0600-\u06FF]',
      ).allMatches(value).length;

      if (letterCount > 3) {
        // Remove additional letters
        final excessLetters = letterCount - 3;
        final regex = RegExp(r'[a-zA-Z\u0600-\u06FF]');
        for (int i = 0; i < excessLetters; i++) {
          value = value.replaceFirst(regex, '', value.indexOf(regex));
        }
      }
    } else {
      String numberString = value.substring(3);
      String letterString = value.substring(0, 3);

      numberString = numberString.replaceAll(RegExp(r'[^0-9][^0-9]'), '');

      final numberCount = RegExp(r'[0-9]').allMatches(value).length;

      if (numberCount > 6) {
        // Remove additional numbers
        final excessNumbers = numberCount - 6;
        final regex = RegExp(r'[0-9]');
        for (int i = 0; i < excessNumbers; i++) {
          numberString = numberString.replaceFirst(
            regex,
            '',
            numberString.indexOf(regex),
          );
        }
      }

      value = letterString + numberString;
    }

    value = value.replaceAllMapped(
      RegExp(r'[a-zA-Z\u0600-\u06FF]'),
      (match) => '${match.group(0)} ',
    );

    return value..trim();
  }

  static String validateCarPlate(String value, String newValue) {
    dd(value);
    value = value.replaceAll(' ', '');

    if (RegExp(r'^[^a-zA-Z]').hasMatch(value)) {
      newValue += value;
      newValue += ' ';
    }

    return newValue;
  }
}
