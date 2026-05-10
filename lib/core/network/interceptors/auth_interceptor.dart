import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/di/setup_get_it.dart';
import 'package:fahis_inspector/core/services/storage/secure_storage.dart';
import 'package:fahis_inspector/features/authentication/presentation/cubit/auth_cubit.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if the caller already set Authorization (e.g. reauthenticate uses Firebase ID token).
    if (!options.headers.containsKey('Authorization')) {
      final token = await SecureStorage.readToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorage.clearToken();
      await getIt<AuthCubit>().sessionExpired();
    }
    handler.next(err);
  }
}
