import 'package:dio/dio.dart';
import 'package:fahis_inspector/core/error/api_error_model.dart';
import 'package:fahis_inspector/core/error/api_result.dart';
import 'package:fahis_inspector/core/error/network_exceptions.dart';
import 'package:fahis_inspector/core/network/api_service.dart';
import 'package:fahis_inspector/features/authentication/data/models/responses/login_response.dart';
import 'package:fahis_inspector/features/authentication/data/models/responses/profile_response.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/login_result.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';
import 'package:fahis_inspector/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<ApiResult<LoginResult>> login(
    String credential,
    String password,
  ) async {
    try {
      final body = {
        if (credential.contains('@')) 'email': credential
        else 'mobile': credential,
        'password': password,
      };
      final res = await _api.login(body);
      final result = LoginResponse.fromJson(res.data as Map<String, dynamic>);
      return ApiResultSuccess(result.toEntity());
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<LoginResult>> reauthenticate(String idToken) async {
    try {
      final res = await _api.reauthenticate('Bearer $idToken');
      final result = LoginResponse.fromJson(res.data as Map<String, dynamic>);
      return ApiResultSuccess(result.toEntity());
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<ProfileEntity>> fetchProfile() async {
    try {
      final res = await _api.fetchProfile();
      final profile = ProfileResponse.fromJson(res.data as Map<String, dynamic>);
      return ApiResultSuccess(profile.toEntity());
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _api.logout();
      return const ApiResultSuccess(null);
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<String>> sendOtp(String phone) async {
    try {
      final res = await _api.sendOtp({'phone': phone});
      final token = (res.data as Map<String, dynamic>)['token'] as String;
      return ApiResultSuccess(token);
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<String>> verifyOtp(
    String verifyToken,
    String otp,
  ) async {
    try {
      final res = await _api.verifyOtp('Bearer $verifyToken', {'otp': otp});
      final token = (res.data as Map<String, dynamic>)['token'] as String;
      return ApiResultSuccess(token);
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }

  @override
  Future<ApiResult<String>> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final body = {
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      final res = await _api.resetPassword('Bearer $resetToken', body);
      final token = (res.data as Map<String, dynamic>)['token'] as String;
      return ApiResultSuccess(token);
    } on DioException catch (e) {
      return ApiResultFailure(e.error is ApiErrorModel
          ? e.error as ApiErrorModel
          : NetworkExceptions.fromDioException(e));
    }
  }
}
