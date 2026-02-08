import 'dart:developer';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:rename/custom_exceptions.dart';
import '../constants/api_endpoints.dart';
import '../http/custom_response.dart';
import 'package:get/get.dart';

class Network extends GetConnect {
  late RequestMethod requestMethod;
  String? url;

  late Map<String, String> _header;
  Map<String, dynamic>? _query;
  var _body;
  bool _isMultipart = false;

  Map<String, String> get header => _header;

  set setQuery(Map<String, dynamic> value) => _query = value;

  set setBody(dynamic value) {
    _body = value;
    _isMultipart = value is FormData;

    if (_isMultipart) {
      _header.remove('Content-Type'); // let GetConnect set it
      _header['Accept'] = 'application/json';
    }
  }

  get getBody => _body;

  get getQuery => _query;

  set setHeaders(Map<String, String> value) {
    _header = value;
  }

  void setHeader(String key, String? value) {
    if (value == null) {
      _header.remove(key);
    } else {
      _header[key] = value;
    }
  }

  void addQuery(String key, String? value) {
    if (_query != null) {
      if (value == null) {
        _query!.remove(key);
      } else {
        _query![key] = value;
      }
    }
  }

  void addBody(String key, String? value) {
    _body ??= {};

    if (value == null) {
      _body!.remove(key);
    } else {
      _body![key] = value;
    }
  }

  Network({
    String? url,
    String? endpoint,
    this.requestMethod = RequestMethod.get,
    String? token,
  }) {
    if (url == null && endpoint == null) {
      throw Exception('No Url');
    }

    this.url = url ?? "${EndPoints.baseUrl}$endpoint";

    _header = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json',
      'Accept-Language': Get.locale?.languageCode ?? 'ar',
      'Authorization': 'Bearer $token',
    };

    if (token == null && AuthBinding().isRegistered) {
      final authController = AuthBinding().instance;
      token = authController.isAuth ? authController.token : null;
    }

    if (token != null) {
      _header['Authorization'] = 'Bearer $token';
    }
    // if (Auth.check) {
    // }
  }

  Future<CustomResponse> response(String? route, {Map? parameters}) async {
    late Response response;

    try {
      switch (requestMethod) {
        case RequestMethod.get:
          response = await get(url!, headers: _header, query: _query);
          break;
        case RequestMethod.post:
          response = await post(url!, _body, headers: _header, query: _query);
          break;
        case RequestMethod.put:
          response = await put(url!, _body, headers: _header, query: _query);
          break;
        case RequestMethod.delete:
          response = await delete(url!, headers: _header, query: _query);
          break;
      }
    } catch (e) {
      log(
        'Error: from Network:response:73 line',
        error: e,
        level: 1,
        name: 'Connection Error',
      );
    }
    
    return CustomResponse.set(response);
  }
}
