import 'dart:io';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/authentication/models/user.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserRepository {
  final Box box;
  UserRepository(this.box);

  Future<User> updateProfile(User user) async {
    sleep(Duration(seconds: 1));
    return user;
    // if(! Auth.check()){
    //   return null;
    // }

    // if(Auth.user() != null){
    //   return null;
    // }

    // Network net = Network(endpoint: EndPoints.profile, requestMethod: RequestMethod.post);

    // net.setBody = {
    //   'name': name ?? Auth.user()!.name,
    //   'email': email ?? Auth.user()?.email,
    //   'city': cityID ?? Auth.user()?.city?.id
    // };

    // try {
    //   CustomResponse? response = await net.response(RoutingUrl.login);
    //   if(! response.hasError && response.statusCode == 200){
    //     Auth.setUser = response.data['data'];
    //   }

    // }catch(e){
    //   throw e;
    // }

    // return null;
  }

  Future<User?> getUser() async {
    Network net = Network(endpoint: EndPoints.profile);
    try {
      net.setHeader = {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json',
        'Authorization': 'Bearer ${box.get('USER_TOKEN')}',
      };


      CustomResponse response = await net.response(RoutingUrl.login);

      final user = User.set(response.data);
      box.put('USER', user?.toJson());
      Auth.auth?.reinit();
      return user;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
