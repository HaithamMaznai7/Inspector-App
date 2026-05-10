import 'dart:async';

import 'package:fahis_inspector/core/services/storage/prefs.dart';
import 'package:fahis_inspector/core/services/storage/secure_storage.dart';
import 'package:fahis_inspector/core/error/api_result.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';
import 'package:fahis_inspector/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fahis_inspector/features/authentication/presentation/cubit/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;
  StreamSubscription<User?>? _authSub;

  // Guard against concurrent sessionExpired calls.
  static bool _handlingExpiry = false;

  FirebaseAuth get _firebase => FirebaseAuth.instance;

  bool get isAuthenticated => state is AuthAuthenticated;

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _clearStaleTokenOnReinstall();
    final token = await SecureStorage.readToken();

    if (token == null && _firebase.currentUser == null) {
      await _clearLocalData();
      emit(const AuthUnauthenticated());
    } else if (token != null) {
      // Emit authenticated immediately so the router can navigate.
      // Profile arrives via the Firebase listener or _fetchProfileInBackground.
      emit(const AuthAuthenticated());
      _fetchProfileInBackground();
    }

    _authSub = _firebase.authStateChanges().listen(_handleFirebaseUser);
  }

  // ── Session events ────────────────────────────────────────────────────────

  /// Called by LoginCubit after a successful credential login.
  Future<void> onLoginSuccess({
    required String token,
    required String firebaseToken,
    ProfileEntity? profile,
  }) async {
    await SecureStorage.saveToken(token);
    await Prefs.setLastUserId(profile?.uid ?? '');
    emit(AuthAuthenticated(profile: profile));
    _fetchProfileInBackground();
    await _firebase.signInWithCustomToken(firebaseToken);
  }

  /// Called after OTP-based login (forget-password flow).
  Future<void> loginAfterOTP(String token) async {
    await SecureStorage.saveToken(token);
    emit(const AuthAuthenticated());
    _fetchProfileInBackground();
  }

  Future<void> logout() async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    try {
      await _repository.logout();
    } catch (_) {}
    await _clearLocalData();
    unawaited(_firebase.signOut().catchError((_) {}));
    emit(const AuthUnauthenticated());
  }

  /// Called by AuthInterceptor on 401. Clears the session without a backend
  /// logout call (token is already invalid).
  Future<void> sessionExpired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;
    try {
      await _clearLocalData();
      unawaited(_firebase.signOut().catchError((_) {}));
      emit(const AuthSessionExpired());
    } finally {
      _handlingExpiry = false;
    }
  }

  // ── Firebase listener ─────────────────────────────────────────────────────

  Future<void> _handleFirebaseUser(User? user) async {
    final currentToken = await SecureStorage.readToken();

    if (user != null && currentToken == null) {
      // Firebase has a user but we have no backend token — reauthenticate.
      emit(const AuthLoading());
      String? idToken;
      try {
        idToken = await user.getIdToken();
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) debugPrint('[AuthCubit] getIdToken failed: ${e.message}');
        await _clearLocalData();
        emit(const AuthUnauthenticated());
        return;
      }
      final result = await _repository.reauthenticate(idToken!);
      switch (result) {
        case ApiResultSuccess(:final data):
          await SecureStorage.saveToken(data.token);
          if (data.profile != null) {
            await Prefs.setLastUserId(data.profile!.uid);
          }
          emit(AuthAuthenticated(profile: data.profile));
          _fetchProfileInBackground();
        case ApiResultFailure():
          await _clearLocalData();
          await _firebase.signOut();
          emit(const AuthUnauthenticated());
      }
    } else if (user == null && currentToken == null) {
      // Both Firebase and backend token gone — fully signed out.
      if (state is! AuthUnauthenticated && state is! AuthSessionExpired) {
        await _clearLocalData();
        emit(const AuthUnauthenticated());
      }
    }
    // Other combinations (user != null && token != null, or user == null &&
    // token != null for OTP sessions) are already handled by init / onLoginSuccess.
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _fetchProfileInBackground() {
    _repository.fetchProfile().then((result) {
      switch (result) {
        case ApiResultSuccess(:final data):
          if (state is AuthAuthenticated) {
            emit((state as AuthAuthenticated).withProfile(data));
            Prefs.setLastUserId(data.uid);
          }
        case ApiResultFailure():
          break;
      }
    });
  }

  /// iOS: Keychain survives uninstall. Clear stale token on first launch.
  Future<void> _clearStaleTokenOnReinstall() async {
    if (Prefs.hasLaunchedBefore) return;
    await SecureStorage.clearToken();
    await Prefs.setHasLaunchedBefore();
  }

  Future<void> _clearLocalData() async {
    await SecureStorage.clearToken();
    await Prefs.clearLastUserId();
    for (final name in ['Auth', 'Assets', 'Inspections', 'Notifications']) {
      try {
        if (Hive.isBoxOpen(name)) await Hive.box(name).clear();
      } catch (_) {}
    }
    try {
      final settings = await Hive.openBox('AppSettings');
      await settings.delete('cachedAuthUid');
      await settings.delete('cachedTeamId');
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
