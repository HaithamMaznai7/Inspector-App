import 'dart:developer';
import 'dart:io';
import 'package:fahis_inspector/common/widget/loaders/loaders.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';

class Network extends GetConnect {
  late RequestMethod requestMethod;
  String? url;

  late Map<String, String> _header;
  Map<String, dynamic>? _query;
  var _body;
  bool _isMultipart = false;

  Map<String, String> get header => _header;

  set setQuery(Map<String, dynamic> value) => _query = value;

  set setBody(dynamic value) {
    _body = value;
    _isMultipart = value is FormData;

    if (_isMultipart) {
      _header.remove('Content-Type'); // let GetConnect set it
      _header['Accept'] = 'application/json';
    }
  }

  get getBody => _body;

  set setHeader(Map<String, String> value) {
    _header = value;
  }

  Network({
    String? url,
    String? endpoint,
    this.requestMethod = RequestMethod.get,
  }) {
    if (url == null && endpoint == null) {
      throw Exception('No Url');
    }

    this.url = url ?? "${EndPoints.baseUrl}$endpoint";

    _header = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json',
    };

    if (Auth.check) {
      _header['Authorization'] = 'Bearer ${Auth.getToken}';
    }
  }

  Future<CustomResponse> response(String route, {Map? parameters}) async {
    Response? response;
    try {
      switch (requestMethod) {
        case RequestMethod.get:
          response = await get(url!, headers: header, query: _query);
          break;
        case RequestMethod.post:
          response = await post(url!, _body, headers: header, query: _query);
          break;
        case RequestMethod.put:
          response = await put(url!, _body, headers: header, query: _query);
          break;
        case RequestMethod.delete:
          response = await delete(url!, headers: header, query: _query);
          break;
      }
    } catch (e) {
      log(
        'Error: from Network:response:73 line',
        error: e,
        level: 1,
        name: 'Connection Error',
      );
    }

    return CustomResponse.set(response);
  }
}

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
    if (title != null) {
      FLoader.errorSnackBar(title: title, message: message, duration: 4);
      return;
    }

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
      Get.offAllNamed(RoutingUrl.home);
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

  factory FNetworkException.set(CustomResponse response) {
    if (response.statusCode == 422) {
      return FNetworkException(
        response.message,
        statusCode: response.statusCode,
        errors: response.validationErrors,
      );
    }
    return FNetworkException(response.message, statusCode: response.statusCode);
  }
}
