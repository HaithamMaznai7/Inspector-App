import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/error/api_error_model.dart';
import 'package:fahis_inspector/core/error/api_result.dart';
import 'package:fahis_inspector/core/error/network_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResult', () {
    test('success exposes data', () {
      const result = ApiResultSuccess('hello');
      expect(result.data, 'hello');
    });

    test('failure exposes error fields', () {
      const error = ApiErrorModel(statusCode: 404, message: 'Not found');
      const result = ApiResultFailure<String>(error);
      expect(result.error.statusCode, 404);
      expect(result.error.message, 'Not found');
    });

    test('success and failure are different subtypes', () {
      const result = ApiResultSuccess(42);
      expect(result, isA<ApiResultSuccess<int>>());
      expect(result, isNot(isA<ApiResultFailure<int>>()));
    });
  });

  group('NetworkExceptions.fromDioException', () {
    late RequestOptions opts;
    setUp(() => opts = RequestOptions(path: '/test'));

    test('cancel → isCancelled true', () {
      final ex = DioException(requestOptions: opts, type: DioExceptionType.cancel);
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.isCancelled, isTrue);
      expect(result.statusCode, -1);
    });

    test('connectionTimeout → statusCode 0, not cancelled', () {
      final ex = DioException(requestOptions: opts, type: DioExceptionType.connectionTimeout);
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.statusCode, 0);
      expect(result.isCancelled, isFalse);
      expect(result.isNoConnection, isTrue);
    });

    test('connectionError → statusCode 0', () {
      final ex = DioException(requestOptions: opts, type: DioExceptionType.connectionError);
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.statusCode, 0);
    });

    test('401 badResponse → isUnauthorized true', () {
      final ex = DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: opts,
          statusCode: 401,
          data: {'message': 'Unauthenticated'},
        ),
      );
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.isUnauthorized, isTrue);
      expect(result.message, 'Unauthenticated');
    });

    test('422 badResponse → validationErrors populated', () {
      final ex = DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: opts,
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': ['Email is invalid', 'Email is required'],
              'phone': ['Phone is required'],
            },
          },
        ),
      );
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.isValidation, isTrue);
      expect(result.validationErrors!['email'], ['Email is invalid', 'Email is required']);
      expect(result.validationErrors!['phone'], ['Phone is required']);
    });

    test('500 badResponse → isServerError true', () {
      final ex = DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: opts, statusCode: 500, data: {}),
      );
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.isServerError, isTrue);
    });

    test('null response body falls back to status message', () {
      final ex = DioException(
        requestOptions: opts,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: opts, statusCode: 404, data: null),
      );
      final result = NetworkExceptions.fromDioException(ex);
      expect(result.statusCode, 404);
      expect(result.message, isNotEmpty);
    });
  });

  group('ApiErrorModel.validationMessage', () {
    test('returns flattened messages up to maxLines', () {
      const error = ApiErrorModel(
        statusCode: 422,
        message: 'Validation failed',
        validationErrors: {
          'email': ['Email invalid'],
          'phone': ['Phone required'],
          'name': ['Name too short'],
          'age': ['Age required'],
        },
      );
      final msg = error.validationMessage(maxLines: 3);
      expect(msg.split('\n').length, 3);
    });

    test('falls back to message when no validation errors', () {
      const error = ApiErrorModel(statusCode: 500, message: 'Server error');
      expect(error.validationMessage(), 'Server error');
    });
  });
}
