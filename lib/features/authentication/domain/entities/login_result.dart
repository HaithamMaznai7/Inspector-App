import 'package:equatable/equatable.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';

class LoginResult extends Equatable {
  const LoginResult({
    required this.token,
    this.firebaseToken,
    this.profile,
  });

  final String token;
  // Null for reauth/OTP flows that don't return a Firebase custom token.
  final String? firebaseToken;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [token, firebaseToken, profile];
}
