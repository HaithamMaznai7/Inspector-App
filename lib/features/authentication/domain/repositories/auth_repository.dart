import 'package:fahis_inspector/core/error/api_result.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/login_result.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';

abstract class AuthRepository {
  /// Credential-based login. Returns backend token + firebase custom token.
  Future<ApiResult<LoginResult>> login(String credential, String password);

  /// Re-authenticates using a Firebase ID token (called when Firebase has a
  /// user but no backend token is stored — e.g. after reinstall).
  Future<ApiResult<LoginResult>> reauthenticate(String idToken);

  /// Fetches the authenticated user's profile.
  Future<ApiResult<ProfileEntity>> fetchProfile();

  /// Logs out the current session on the backend.
  Future<ApiResult<void>> logout();

  /// Sends an OTP to [phone]. Returns a verify_token for the verify step.
  Future<ApiResult<String>> sendOtp(String phone);

  /// Verifies an OTP using the [verifyToken] from [sendOtp].
  /// Returns the backend auth token on success.
  Future<ApiResult<String>> verifyOtp(String verifyToken, String otp);

  /// Resets password using the [resetToken] from a reset link.
  /// Returns a new backend auth token on success.
  Future<ApiResult<String>> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  );
}
