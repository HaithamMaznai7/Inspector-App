import 'dart:io';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:get/get.dart';

class FNetworkException extends HttpException {
  final String? title;
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  FNetworkException(
    this.message, {
    this.title,
    this.statusCode = 0,
    this.errors,
  }) : super(message);

  @override
  String toString() {
    return message;
  }

  void notify() {
    // if (title != null) {
    //   FLoader.errorSnackBar(title: title, message: message, duration: 4);
    //   return;
    // }

    if (statusCode == 0) {
      FLoader.errorSnackBar(
        title: 'No Connection'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode >= 500) {
      FLoader.errorSnackBar(
        title: 'Server Error'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode == 422) {
      FLoader.warningSnackBar(
        title: 'Invalid data'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode == 401) {
      FLoader.warningSnackBar(
        title: 'Unauthenticated'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode == 404) {
      FLoader.errorSnackBar(
        title: 'Not Found'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode == 403) {
      FLoader.warningSnackBar(
        title: 'No Permission'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else if (statusCode == 307) {
      FLoader.errorSnackBar(
        title: 'Route is rediredcted'.tr,
        message: 'The route is redirected multi times',
        duration: 4,
      );
      return;
    } else if (statusCode == 405) {
      FLoader.warningSnackBar(
        title: 'Unauthorized'.tr,
        message: message,
        duration: 4,
      );
      return;
    } else {
      FLoader.errorSnackBar(
        title: 'Unknown Error'.tr,
        message: message,
        duration: 4,
      );
      return;
    }
  }

  factory FNetworkException.set(Response? response) {
    if(response == null || response.statusCode == null){
      return FNetworkException(
        'No Internet Connection',
        statusCode: 0,
        title: 'No Connection'
      );
    }

    return FNetworkException(
      response.body['error'] ?? '',
      statusCode: response.statusCode!,
      title: response.body['status'] ?? 'Error',
      errors: response.body['errors']
    );
  }
}
