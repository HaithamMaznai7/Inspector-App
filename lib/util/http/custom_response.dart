import 'dart:convert';
import 'dart:developer';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:get/get.dart';

class CustomResponse {
  dynamic data;
  Map<String, dynamic>? validationErrors;
  bool hasError = false;
  bool unauthorized = false;
  int statusCode = 200;
  String message;
  String? exception;
  // RequestMethod method;

  CustomResponse({
    this.data,
    this.validationErrors,
    this.hasError = false,
    this.unauthorized = false,
    this.statusCode = 200,
    this.message = 'Error',
    // this.method = RequestMethod.get,
    this.exception,
  });

  factory CustomResponse.set(Response? response) {
    try {
      final res = CustomResponse(
        data: response?.body?['data'] ?? {},
        validationErrors: response?.body?['errors'] ?? {},
        hasError: !(response?.isOk ?? true),
        unauthorized: response?.unauthorized ?? true,
        statusCode: response?.statusCode ?? 0,
        message: response?.body?['message'] ?? 'No Message',
        exception: response?.body?['message'] ?? 'No Exception',
      );

      if (res.hasError) {
        throw FNetworkException.set(res);
      }

      return res;
    } catch (e) {
      log(
        'Error: from CustomerResponse:set:46 line',
        error: e,
        level: 2,
        name: 'Covert Response Based Server',
      );

      rethrow;
    }
  }

  @override
  String toString() => jsonEncode({
    'data': data.toString(),
    'validationErrors': validationErrors.toString(),
    'hasError': hasError,
    'unauthorized': unauthorized,
    'statusCode': statusCode,
    'message': message,
    'exception': exception,
  });
}

enum RequestMethod { get, post, put, delete }
