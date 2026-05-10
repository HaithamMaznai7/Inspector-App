import 'package:equatable/equatable.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before [AuthCubit.init] completes.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Active session in progress (login / logout / reauthentication).
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Valid backend token present. Profile may be null while fetching.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({this.profile});

  final ProfileEntity? profile;

  bool get hasCurrentTeam => profile?.hasCurrentTeam ?? false;

  AuthAuthenticated withProfile(ProfileEntity profile) =>
      AuthAuthenticated(profile: profile);

  @override
  List<Object?> get props => [profile];
}

/// No valid session.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Backend returned 401 — token rejected.
final class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}
