import 'package:dio/dio.dart';
import 'api_error_model.dart';

class NetworkExceptions {
  NetworkExceptions._();

  static ApiErrorModel fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.cancel:
        return const ApiErrorModel(
          statusCode: -1,
          message: '',
          isCancelled: true,
        );

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiErrorModel(
          statusCode: 0,
          message: 'Connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiErrorModel(
          statusCode: 0,
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _fromResponse(exception.response);

      case DioExceptionType.badCertificate:
        return const ApiErrorModel(
          statusCode: 0,
          message: 'Secure connection failed.',
        );

      case DioExceptionType.unknown:
        return const ApiErrorModel(
          statusCode: 0,
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  static ApiErrorModel _fromResponse(Response? response) {
    if (response == null) {
      return const ApiErrorModel(
        statusCode: 0,
        message: 'No response from server.',
      );
    }

    final statusCode = response.statusCode ?? 0;
    final body = response.data;
    final isMap = body is Map<String, dynamic>;

    final message = isMap
        ? ((body['message'] as String?)?.isNotEmpty == true
            ? body['message'] as String
            : (body['error'] as String?) ?? _messageForStatus(statusCode))
        : _messageForStatus(statusCode);

    Map<String, List<String>>? validationErrors;
    if (statusCode == 422 && isMap) {
      final raw = body['errors'];
      if (raw is Map<String, dynamic>) {
        validationErrors = raw.map((key, value) {
          final msgs = value is List
              ? value.whereType<String>().toList()
              : [value.toString()];
          return MapEntry(key, msgs);
        });
      }
    }

    return ApiErrorModel(
      statusCode: statusCode,
      message: message,
      validationErrors: validationErrors,
    );
  }

  static String _messageForStatus(int code) => switch (code) {
        401 => 'Session expired. Please log in again.',
        403 => 'You don\'t have permission to perform this action.',
        404 => 'The requested resource could not be found.',
        413 => 'The file is too large. Please use a smaller file.',
        422 => 'Please check your input and try again.',
        _ when code >= 500 => 'Something went wrong on the server.',
        _ => 'Something went wrong. Please try again.',
      };
}
