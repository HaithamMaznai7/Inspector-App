import 'dart:convert';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
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
        // Global 401/403 interceptor: if the user is authenticated and
        // gets a 401 or 403, their session has expired. Trigger forced logout.
        if (response.statusCode == 401 || response.statusCode == 403) {
          _handleUnauthorized();
        }

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

  /// Handles 401/403 responses globally by triggering session expiry
  /// on the AuthService (if registered and currently authenticated).
  static void _handleUnauthorized() {
    try {
      final binding = AuthBinding();
      if (binding.isRegistered && binding.instance.isAuth) {
        if (kDebugMode) {
          debugPrint('[Session] 401/403 detected – triggering sessionExpired()');
        }
        binding.instance.sessionExpired();
      }
    } catch (_) {
      // Never let interceptor logic crash the app
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
