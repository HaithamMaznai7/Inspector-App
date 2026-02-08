import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/common/widgets/auth/otp_dialog.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/services/auth/enums/verification_type.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanVerification {
  UserVerifiationType get type => UserVerifiationType.email;
  bool get isVerified => false;
  String get value => '';

  Future<void> verify() async {
    bool resent = false;

    dd(value);
    late Map<String, String?> values;

    do {
      values = await _send();

      resent = values['action'] == 'resent';

      if (!resent) {
        break;
      }
    } while (resent);

    if (values['code'] == null) {
      throw Exception('Error');
    }

    if (values['url'] == null) {
      throw Exception('Error');
    }

    await _verifyOtp(values['url']!, values['code']!);
  }

  @override
  String toString() => value;

  Future<Map<String, String?>> _send() async {
    String? url, code, action;

    try {
      switch (type) {
        case UserVerifiationType.mobile:
          url = await auth().sentOTP(value);
        default:
          url = await auth().sentOTP(value);
      }

      await Get.dialog(OTPDialog()).then((result) {
        try {
          code = result['code'];
          action = result['action'];
        } catch (_) {}
      });
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      FLoader.errorSnackBar(
        title: 'No Connection'.tr,
        message: 'message',
        duration: 10,
      );
    }

    return {'url': url, 'code': code, 'action': action};
  }

  Future<void> _verifyOtp(String url, String code) async {
    FFullScreenLoader.openPage(
      page: Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: FColors.primaryColor),
        ),
      ),
    );

    try {
      await auth().verifyOTP(url, code);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      FLoader.errorSnackBar(
        title: 'No Connection'.tr,
        message: e.toString(),
        duration: 10,
      );
    } finally {
      FFullScreenLoader.stopLoading();
    }
  }
}

class MobileVerification extends CanVerification {
  @override
  UserVerifiationType get type => UserVerifiationType.email;

  @override
  bool get isVerified => isMobileVerified();

  @override
  String get value => getMobileValue();

  String getMobileValue() {
    return '';
  }

  bool isMobileVerified() {
    return false;
  }
}

class EmailVerification extends CanVerification {
  @override
  UserVerifiationType get type => UserVerifiationType.email;

  @override
  bool get isVerified => isEmailVerified();

  @override
  String get value => getEmailValue();

  String getEmailValue() {
    return '';
  }

  bool isEmailVerified() {
    return false;
  }
}
