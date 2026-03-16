import 'dart:async';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/resources/auth_repository.dart';
import 'package:fahis_inspector/services/auth/secure_token_storage.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends GetxController {
  AuthService();

  /// Guard flag to prevent multiple simultaneous session-expiry flows.
  static bool _isHandlingSessionExpiry = false;

  FirebaseAuth get firebase => FirebaseAuth.instance;

  RxBool isLoggingIn = false.obs;
  RxBool isLoggingOut = false.obs;
  final RxnString _token = RxnString(null);
  final RxnString _idToken = RxnString(null);
  final Rxn<Profile> _profile = Rxn<Profile>(null);
  final RxList<City> _cities = <City>[].obs;
  User? get user => firebase.currentUser;
  String? get token => _token.value;
  String? get idToken => _idToken.value;

  Stream<User?> get userChanges => firebase.userChanges();
  Stream<String?> get tokenChange => _token.stream;
  Stream<String?> get idTokenChange => _idToken.stream;

  Profile? get profile => _profile.value;
  Rxn<Profile> get profileRx => _profile;

  /// Update the cached profile (e.g. after team switch).
  set profile(Profile? value) => _profile.value = value;

  List<City> get cities => _cities;
  set cities(List<City> value) => _cities.assignAll(value);

  bool get isAuth => _token.value != null;

  late final StreamSubscription<User?> _authSub;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Restore the backend token from secure storage before listening to auth changes.
    // This prevents the app from signing out a previously logged-in user.
    await _restoreTokenFromStorage();

    // No session found: clear any stale local data and let the auth
    // listener redirect to login once it fires.
    if (_token.value == null && firebase.currentUser == null) {
      if (kDebugMode) {
        debugPrint('[AuthService] No session found – clearing local data');
      }
      await clearLocalData();
    }

    _initAuthListener();
  }

  Future<void> _restoreTokenFromStorage() async {
    try {
      final storedToken = await SecureTokenStorage().read();
      if (storedToken != null) {
        _token.value = storedToken;
        if (kDebugMode) {
          debugPrint('[AuthService] Token restored from secure storage');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[AuthService] No stored token found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] Error restoring token: $e');
      }
      _token.value = null;
    }
  }

  @override
  void onClose() {
    _authSub.cancel();
    super.onClose();
  }

  void _initAuthListener() {
    _authSub = firebase.authStateChanges().listen(changeUser);
  }

  void _goTo(String route) {
    if (Get.currentRoute != route) {
      Get.offAllNamed(route);
    }
  }

  Future<void> changeUser(User? user) async {
    if (user != null && _token.value == null) {
      // No stored token - try to reauthenticate with Firebase ID token
      _idToken.value = await user.getIdToken();
      try {
        final data = await AuthRepository().reauthenticate(_idToken.value!);
        _token.value = data['token'];
        if (_token.value != null) {
          await SecureTokenStorage().save(_token.value!);
        }
        _profile.value = data['user'] != null
            ? Profile.fromJson(data['user'])
            : _profile.value;
      } catch (e) {
        await firebase.signOut();
        return;
      }
    }

    if (user != null && _token.value != null) {
      // User is authenticated - navigate immediately, fetch profile in background
      // getIdToken() can throw on network failure; we already have the backend
      // token so navigation should not be blocked by a Firebase network error.
      if (_idToken.value == null) {
        try {
          _idToken.value = await user.getIdToken();
        } on FirebaseAuthException catch (e) {
          if (kDebugMode) {
            debugPrint('[AuthService] getIdToken failed (network?): ${e.message}');
          }
          // Non-fatal — continue with null idToken
        }
      }

      // If profile is loaded, check if user has a current team
      final profileLoaded = _profile.value != null && !_profile.value!.isEmpty;
      final hasCurrentTeam =
          profileLoaded && _profile.value!.teams.any((t) => t.isCurrent);

      if (profileLoaded && !hasCurrentTeam) {
        _goTo(RoutingUrl.selectTeam);
      } else {
        _goTo(RoutingUrl.home);
      }

      // Fetch profile in the background so it doesn't block navigation
      if (!profileLoaded || _profile.value!.isFromFirebase(user)) {
        AuthRepository().fetchProfile().then((profile) {
          _profile.value = profile;
        }).catchError((_) {});
      }
    } else if (_token.value != null) {
      // No Firebase user but we have a backend token (OTP / token-only session).
      // Navigate to home without requiring Firebase sign-in.
      final profileLoaded = _profile.value != null && !_profile.value!.isEmpty;
      if (!profileLoaded) {
        AuthRepository().fetchProfile().then((profile) {
          _profile.value = profile;
        }).catchError((_) {});
      }
      _goTo(RoutingUrl.home);
    } else {
      _idToken.value = null;
      _profile.value = null;
      _token.value = null;

      // Show onboarding for first-time users, otherwise go to login.
      // The 'AppSettings' box persists across logouts but is cleared on
      // app uninstall/reinstall, so onboarding only shows once.
      final settingsBox = await Hive.openBox('AppSettings');
      final hasSeenOnboarding =
          settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;

      if (hasSeenOnboarding) {
        _goTo(RoutingUrl.login);
      } else {
        _goTo(RoutingUrl.onBoarding);
      }
    }
  }

  Future<void> logOut() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    FLoader.showLogoutLoading();

    try {
      // 1. Backend logout — best effort, never block on failure.
      try {
        await AuthRepository().logOut(token);
      } catch (_) {}

      // 2. Clear all local state while we still control the UI.
      await clearLocalData();

      // 3. Determine destination before touching navigation.
      final settingsBox = await Hive.openBox('AppSettings');
      final hasSeenOnboarding =
          settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;
      final destination =
          hasSeenOnboarding ? RoutingUrl.login : RoutingUrl.onBoarding;

      // 4. Dismiss the loading dialog BEFORE navigating.
      //    On iOS, calling Get.offAllNamed while a dialog is on the stack
      //    can fail to clear the underlying routes, leaving the home screen
      //    visible. Closing the dialog first gives us a clean nav stack.
      if (Get.isDialogOpen ?? false) Get.back();

      // 5. Navigate explicitly and clear the entire back stack.
      //    We do this here rather than relying on the changeUser(null)
      //    listener so the navigation happens exactly once, deterministically,
      //    without any race condition with the Firebase auth state stream.
      Get.offAllNamed(destination);

      // 6. Firebase sign-out fires in the background after we have already
      //    navigated away. When changeUser(null) eventually fires, _goTo's
      //    guard (Get.currentRoute == destination) prevents a second navigation.
      unawaited(firebase.signOut().catchError((_) {}));
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthService] logOut – error: $e');
      if (Get.isDialogOpen ?? false) Get.back();
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Called when the backend returns 401 or the token is invalid.
  /// Skips the backend logout call (token is already invalid).
  /// Uses a guard flag to prevent multiple simultaneous calls.
  Future<void> sessionExpired() async {
    if (_isHandlingSessionExpiry) {
      if (kDebugMode) {
        debugPrint('[AuthService] sessionExpired already in progress – skipping');
      }
      return;
    }
    _isHandlingSessionExpiry = true;

    if (kDebugMode) {
      debugPrint('[AuthService] sessionExpired – clearing session');
    }

    try {
      // Clear all local data (tokens, Hive caches)
      await clearLocalData();

      // Show message before sign-out (sign-out triggers navigation)
      FLoader.warningSnackBar(
        title: 'sessionExpired'.tr,
        message: 'sessionExpiredMsg'.tr,
        duration: 4,
      );

      // Firebase sign-out triggers changeUser(null) → navigates to login
      await firebase.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] sessionExpired – error: $e');
      }
    } finally {
      _isHandlingSessionExpiry = false;
    }
  }

  Future<String> forgetPassword(String mobile) =>
      AuthRepository().forgetPassword(mobile);

  Future<void> resetPassword(String url, String code, String password) async {
    _token.value = await AuthRepository().resetPassword(url, code, password);
  }

  Future<String> sentOTP(String mobile) => AuthRepository().sentOTP(mobile);

  Future<String?> verifyOTP(String verifyToken, String code) async {
    return await AuthRepository().verifyOTP(verifyToken, code);
  }

  /// Called after a successful OTP-based login (forget-password flow).
  /// Stores the session token and navigates to home without requiring Firebase sign-in.
  Future<void> loginAfterOTP(String token) async {
    _token.value = token;
    await SecureTokenStorage().save(token);

    // Fetch profile in background — don't block navigation
    AuthRepository().fetchProfile().then((profile) {
      _profile.value = profile;
    }).catchError((_) {});

    _goTo(RoutingUrl.home);
  }

  /// Clears all local session data: secure token storage, in-memory
  /// auth state, and Hive inspection/asset caches. Called on logout,
  /// session expiry, and when no valid session is found at startup.
  Future<void> clearLocalData() async {
    // 1. Secure token storage
    await SecureTokenStorage().clear();

    // 2. In-memory auth state
    _token.value = null;
    _idToken.value = null;
    _profile.value = Profile.empty();
    _cities.clear();

    // 3. Disconnect WebSocket so the authenticated connection is closed
    //    and no further events are dispatched with the stale token.
    BroadcastService.instance?.disconnect();

    // 4. Hive caches — clear boxes that hold inspection data.
    //    These boxes are typed as Box<List> in StorageService.
    try {
      // Clear typed boxes if they are open
      if (Hive.isBoxOpen('Auth')) {
        await Hive.box<List>('Auth').clear();
      }
      if (Hive.isBoxOpen('Assets')) {
        await Hive.box<List>('Assets').clear();
      }
      if (Hive.isBoxOpen('Inspections')) {
        await Hive.box<List>('Inspections').clear();
      }

      // Clear Notifications box (untyped)
      if (Hive.isBoxOpen('Notifications')) {
        await Hive.box('Notifications').clear();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService] clearLocalData – Hive error: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[AuthService] Local data cleared');
    }
  }

  Future<void> login(String credential, String password) async {
    final data = await AuthRepository().login(credential, password);
    if (data.containsKey('token') && data.containsKey('firebase_token')) {
      _token.value = data['token'];
      await SecureTokenStorage().save(_token.value!);

      // Parse profile from login response so we can check for current team
      if (data['user'] != null) {
        _profile.value = Profile.fromJson(data['user']);
      }

      await firebase.signInWithCustomToken(data['firebase_token'] as String);
    }
  }
}
