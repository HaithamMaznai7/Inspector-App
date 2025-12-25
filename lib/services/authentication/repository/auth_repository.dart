import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/authentication/models/team.dart';
import 'package:fahis_inspector/services/authentication/models/user.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthRepository {
  final Box box;

  AuthRepository(this.box);

  static const authBox = 'AUTH_BOX';

  Future<void> login(String email, String password) async {
    Network net = Network(
      endpoint: EndPoints.login,
      requestMethod: RequestMethod.post,
    );

    print(EndPoints.login);
    
    net.setBody = {'email_or_phone': email, 'password': password};

    try {
      CustomResponse response = await net.response(RoutingUrl.login);
      final token = response.data['token'];
      final user = User.set(response.data['user']);
      box.put('USER', user?.toJson());
      box.put('USER_TOKEN', token);
      Auth.auth?.reinit();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setTeam(Team team) async {
    Network net = Network(
      endpoint: EndPoints.setTeam,
      requestMethod: RequestMethod.post,
    );

    net.setBody = {'team_id': team.id};

    try {
      CustomResponse response = await net.response(RoutingUrl.home);
      final user = User.set(response.data);
      box.put('USER', user?.toJson());
      Auth.auth?.reinit();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sentOTP(String phoneNumber) async {
    Network net = Network(
      endpoint: EndPoints.verifyMobile,
      requestMethod: RequestMethod.post,
    );

    net.setBody = {
      'phone': phoneNumber.substring(phoneNumber.length - 9).toString(),
    };

    try {
      final response = await net.response(RoutingUrl.login);
      return response.data?['verify_url'];
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sentForgetPassword(String phoneNumber) async {
    Network net = Network(
      endpoint: EndPoints.forgetPassword,
      requestMethod: RequestMethod.post,
    );

    net.setBody = {
      'phone': phoneNumber.substring(phoneNumber.length - 9).toString(),
    };

    try {
      final response = await net.response(RoutingUrl.login);
      return response.data?['verify_url'];
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOTP(String url, String code) async {
    Network net = Network(url: url, requestMethod: RequestMethod.post);

    net.setHeader = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json',
    };

    net.setBody = {'otp': code};
    try {
      CustomResponse? response = await net.response(RoutingUrl.login);
      final token = response.data['token'];
      final user = User.set(response.data['user']);
      box.put('USER', user?.toJson());
      box.put('USER_TOKEN', token);
      Auth.auth?.reinit();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    Network net = Network(
      endpoint: EndPoints.logout,
      requestMethod: RequestMethod.post,
    );

    try {
      CustomResponse? response = await net.response(RoutingUrl.login);
      if (!response.hasError && response.statusCode == 200) {
        box.delete('USER');
        box.delete('USER_TOKEN');
        Auth.auth?.reinit();
        return true;
      }
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }

    return false;
  }
}
