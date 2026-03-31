import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_utils/get_utils.dart';

class AuthRepository {
  Future<dynamic> reauthenticate(String idToken) async {
    try {
      Network net = Network(
        endpoint: EndPoints.reauthentication,
        requestMethod: RequestMethod.post,
      );

      net.setHeaders = {
        'Content-Type': 'application/vnd.api+json',
        'Accept': 'application/vnd.api+json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await net.response(null);

      if (!response.hasError) {
        return response.data;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Profile> fetchProfile() async {
    Network net = Network(
      endpoint: EndPoints.profile,
      requestMethod: RequestMethod.get,
    );

    try {
      final response = await net.response(RoutingUrl.login);

      return Profile.fromJson(response.data);
    } catch (e) {
      return Profile.empty();
    }
  }

  Future<Map> login(String credential, String password) async {
    try {
      Network net = Network(
        endpoint: EndPoints.login,
        requestMethod: RequestMethod.post,
      );

      net.setBody = {
        if (GetUtils.isEmail(credential))
          'email': credential
        else
          'mobile': credential,
        'password': password,
      };

      final response = await net.response(RoutingUrl.login);

      if (!response.hasError) {
        return response.data;
      }
    } catch (e) {
      rethrow;
    }

    return {};
  }

  Future<void> logOut(String? token) async {
    if (token == null) {
      return;
    }

    try {
      Network net = Network(
        endpoint: EndPoints.logout,
        requestMethod: RequestMethod.post,
      );

      await net.response(RoutingUrl.login);

      await FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> sentOTP(String phoneNumber) async {
    // Network net = Network(
    //   endpoint: EndPoints.verifyMobile,
    //   requestMethod: RequestMethod.post,
    // );

    // net.setBody = {
    //   'phone': phoneNumber.substring(phoneNumber.length - 9).toString(),
    // };

    try {
      return '';
      // final response = await net.response(RoutingUrl.login);
      // return response.data?['verify_url'];
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> verifyOTP(String verifyToken, String code) async {
    Network net = Network(
      endpoint: EndPoints.verifyOTP,
      requestMethod: RequestMethod.post,
    );

    net.setHeader('Authorization', 'Bearer $verifyToken');
    net.setBody = {'otp': code};

    try {
      final response = await net.response(RoutingUrl.login);

      return response.data['token'];
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> resetPassword(
    String token,
    String passwordConfirmation,
    String password,
  ) async {
    final Network net = Network(
      endpoint: EndPoints.resetPassword,
      requestMethod: RequestMethod.post,
    );

    net.setHeader('Authorization', 'Bearer $token');
    net.setBody = {
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    try {
      final response = await net.response(null);
      return response.data['token'];
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> forgetPassword(String mobile) async {
    try {
      Network net = Network(
        endpoint: EndPoints.verifyMobile,
        requestMethod: RequestMethod.post,
      );

      net.setBody = {'phone': mobile};

      final response = await net.response(null);

      return response.data['token'];
    } catch (e) {
      rethrow;
    }
  }
}
