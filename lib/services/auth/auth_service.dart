import 'dart:async';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/resources/auth_repository.dart';
import 'package:fahis_inspector/services/auth/secure_token_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  AuthService();

  FirebaseAuth get firebase => FirebaseAuth.instance;

  RxBool isLoggingIn = false.obs;
  final RxnString _token = RxnString(null);
  final RxnString _idToken = RxnString(null);
  final Rxn<Profile> _profile = Rxn<Profile>(null);

  User? get user => firebase.currentUser;
  String? get token => _token.value;
  String? get idToken => _idToken.value;

  Stream<User?> get userChanges => firebase.userChanges();
  Stream<String?> get tokenChange => _token.stream;
  Stream<String?> get idTokenChange => _idToken.stream;

  Profile? get profile => _profile.value;

  bool get isAuth => firebase.currentUser != null && _token.value != null;

  late final StreamSubscription<User?> _authSub;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();

    // ever(_token, _handleAuthChange);
  }

  // void _handleAuthChange(String? token) {
  //   if (token != null &&
  //       firebase.currentUser != null &&
  //       RoutingUrl.guestPages.contains(Get.currentRoute)) {
  //     // print('app is auth');
  //     _goTo(RoutingUrl.home);
  //   } else if (token == null &&
  //       RoutingUrl.authPages.contains(Get.currentRoute)) {
  //     // print('app is guest');
  //     _goTo(RoutingUrl.login);
  //   }
  // }

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
      _idToken.value = await user.getIdToken();
      try {
        final data = await AuthRepository().reauthenticate(_idToken.value!);
        _token.value = data['token'];
        await SecureTokenStorage().save(_token.value!);
        _profile.value = data['user'] != null
            ? Profile.fromJson(data['user'])
            : _profile.value;
      } catch (e) {
        await firebase.signOut();
      }
    }

    if (user != null && _token.value != null) {
      if (_profile.value == null ||
          _profile.value!.isEmpty ||
          _profile.value!.isFromFirebase(user)) {
        _profile.value = await AuthRepository().fetchProfile();
      }
      _goTo(RoutingUrl.home);
    } else {
      _idToken.value = null;
      _profile.value = null;
      _token.value = null;

      _goTo(RoutingUrl.login);
    }
  }

  Future<void> logOut() async {
    await AuthRepository().logOut(token);
    await SecureTokenStorage().clear();
    _token.value = null;
    _profile.value = Profile.empty();
    _idToken.value = null;
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

  Future<void> login(String credential, String password) async {
    final data = await AuthRepository().login(credential, password);
    if (data.containsKey('token') && data.containsKey('firebase_token')) {
      _token.value = data['token'];
      await SecureTokenStorage().save(_token.value!);
      await firebase.signInWithCustomToken(data['firebase_token'] as String);
    }
  }
}
