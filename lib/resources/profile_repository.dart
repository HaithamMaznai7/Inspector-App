import 'dart:io';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileRepository {
  ProfileRepository();

  Future<Profile> updateProfile(Profile profile) async {

    Network net = Network(endpoint: EndPoints.profile, requestMethod: RequestMethod.post);

    net.setBody = {
      'name': profile.name ?? '',
      'email': profile.email ?? '',
      'city': profile.city ?? ''
    };

    try {
      CustomResponse? response = await net.response(RoutingUrl.login);
      return Profile.fromJson(response.data);
    } catch(e){
      rethrow;
    }
  }

  Stream<Profile> getUser({Profile? profile}) async* {
    Map? json;
    try {

      profile ??= Profile.empty();
      yield profile;

      Network net = Network(
        endpoint: EndPoints.profile,
        requestMethod: RequestMethod.post,
      );
      final response = await net.response(RoutingUrl.login);

      yield Profile.fromJson(response.data);

    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
