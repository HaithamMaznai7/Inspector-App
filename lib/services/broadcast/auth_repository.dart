import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class WebsocketAuth extends GetConnect {
  final String authEndpoint;
  final String? token;

  String get authorization => 'Bearer $token';

  WebsocketAuth({this.authEndpoint = 'broadcasting/auth', this.token});

  Future<String> authenticate(
    String domain,
    String socketID,
    String channel,
  ) async {
    try {
      
      final response = await post(
        '$domain/$authEndpoint',
        {'socket_id': socketID, 'channel_name': channel},
        headers: {
          if (token != null) 'Authorization': authorization,
          'Accept': 'application/vnd.api+json',
          'Content-Type': 'application/vnd.api+json',
        },
      );

      return response.body['auth'];

    } on FNetworkException {
      rethrow;
    } catch (e) {
      if(kDebugMode){
        print('===> Broadcast Authentication Error');
        print(e);
      }
      rethrow;
    }
  }
}
