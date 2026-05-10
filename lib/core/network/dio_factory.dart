import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/constants/api_endpoints.dart';
import 'package:fahis_inspector/core/network/interceptors/auth_interceptor.dart';
import 'package:fahis_inspector/core/network/interceptors/error_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/vnd.api+json',
          'Accept': 'application/vnd.api+json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);

    return dio;
  }
}
