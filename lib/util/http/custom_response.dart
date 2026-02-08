import 'dart:convert';
import 'package:fahis_inspector/util/http/network_exception.dart';
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
    this.statusCode = 0,
    this.message = 'Error',
    this.exception,
  });

  factory CustomResponse.set(Response response) {
    try {
      final hasError =
          response.statusCode == null ||
          response.statusCode! > 299 ||
          response.statusCode! < 200;
      
      if(hasError){
        throw FNetworkException.set(response);
      }

      return CustomResponse(
        data: response.body?['data'] ?? {},
        hasError: false,
        unauthorized: false,
        statusCode: response.statusCode!,
        message: response.body?['message'] ?? '',
      );
    } catch (e) {
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
