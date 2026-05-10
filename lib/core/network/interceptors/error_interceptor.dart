import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/error/network_exceptions.dart';

/// Transforms every [DioException] into an [ApiErrorModel] and attaches it to
/// [DioException.error]. Repositories extract it via `e.error as ApiErrorModel`.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = NetworkExceptions.fromDioException(err);
    handler.next(err.copyWith(error: apiError));
  }
}
