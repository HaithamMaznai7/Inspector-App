import 'package:fahis_inspector/app/services/app_service.dart';
import 'package:fahis_inspector/features/configuration/models/app_config.dart';
import 'package:fahis_inspector/services/authentication/models/team.dart';
import 'package:fahis_inspector/services/authentication/models/user.dart';
import 'package:fahis_inspector/services/authentication/repository/auth_repository.dart';
import 'package:fahis_inspector/services/authentication/repository/user_repository.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Auth extends GetxService {
  static Auth? get auth =>
      Get.isRegistered<Auth>(tag: 'Auth') ? Get.find<Auth>(tag: 'Auth') : null;

  static UserRepository? get userRepo =>
      auth?.box != null ? UserRepository(auth!.box) : null;
  static AuthRepository? get authRepo =>
      auth?.box != null ? AuthRepository(auth!.box) : null;

  late Box box;

  final Rxn<User> _user = Rxn<User>(null);
  final RxnString _token = RxnString(null);
  final RxString _local = 'ar'.obs;
  final RxBool isAuthenticated = false.obs;

  String? get token =>_token.value;
  User? get currentUser => _user.value;
  String get currentLocal => Get.locale?.languageCode ?? 'ar';

  static bool get check =>
      auth?._token.value != null && auth?._user.value != null;
  static String? get getToken => auth?._token.value;
  static User? get user => auth?._user.value;
  static String get local => Get.locale?.languageCode ?? 'ar';
  static set local(String value) {
    auth?._local.value = value;
    auth?.box.put('APP_LOCAL', value);
    if (['ar', 'en'].contains(value)) {
      Get.updateLocale(Locale(value));
    }
  }

  // List<dynamic> get teams => currentUser?->tames ?? [];
  // Map<String, dynamic>? get currentTeam => currentUser?['current_team'];

  static bool can(String permission) {
    return auth?._user.value?.currentTeam?.permissions.contains(permission) ??
        false;
  }

  Future<Auth> init() async {
    box = await Hive.openBox(AuthRepository.authBox);

    _local.value = box.get('APP_Auth', defaultValue: 'ar') ?? 'ar';
    final storedToken = box.get('USER_TOKEN', defaultValue: null);
    if (storedToken != null) {
      _token.value = storedToken;
      try {
        final valid = await _fetchUser();
        if (valid) {
          _token.value = box.get('USER_TOKEN');
          _user.value = User.set(box.get('USER'));
          isAuthenticated.value = check;
        } else {
          forgetUser(forceRedirect: false);
        }
      } catch (e) {
        print(e);
        forgetUser(forceRedirect: false);
      }
    }
    return this;
  }

  Future<void> reinit() async {
    _token.value = box.get('USER_TOKEN');
    _user.value = User.set(box.get('USER'));
    isAuthenticated.value = check;
  }

  Future<bool> _fetchUser() async {
    try {
      final user = await UserRepository(box).getUser();
      _user.value = user;
      return true;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> login(String email, String password) async =>
      await Auth.authRepo!.login(email, password);

  static Future<void> loginByMobile(String mobile) async =>
      await Auth.auth?.loginWithMobile(mobile);

  static Future<void> setTeam(Team team) async =>
      await Auth.auth?.changeTeam(team);

  Future<void> changeTeam(Team team) async {
    try {
      await AuthRepository(box).setTeam(team);
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithMobile(String mobile) async {
    try {
      final user = User(mobile: mobile);
      await user.verify();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static logout() => Auth.auth?.forgetUser();

  void forgetUser({bool forceRedirect = true}) {
    _user.value = null;
    _token.value = null;
    box.delete('USER_TOKEN');
    box.delete('USER');
    isAuthenticated.value = false;

    if (forceRedirect && Get.currentRoute != RoutingUrl.login) {
      Get.offAllNamed(RoutingUrl.login);
    }
  }
}
