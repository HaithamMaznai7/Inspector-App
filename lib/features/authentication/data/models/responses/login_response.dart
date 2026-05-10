import 'package:fahis_inspector/features/authentication/data/models/responses/profile_response.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/login_result.dart';

class LoginResponse {
  const LoginResponse({
    required this.token,
    this.firebaseToken,
    this.profile,
  });

  final String token;
  final String? firebaseToken;
  final ProfileResponse? profile;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        firebaseToken: json['firebase_token'] as String?,
        profile: json['user'] != null
            ? ProfileResponse.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  LoginResult toEntity() => LoginResult(
        token: token,
        firebaseToken: firebaseToken,
        profile: profile?.toEntity(),
      );
}
