import 'dart:developer';
import 'package:fahis_inspector/routes.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../http/custom_response.dart';
import 'package:get/get.dart';

class Network extends GetConnect {
  late RequestMethod requestMethod;
  String? url;

  late Map<String, String> _header;
  Map<String, dynamic>? _query;
  dynamic _body;
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

    // Resolve token: use provided token, or fall back to AuthService token
    if (token == null && AuthBinding().isRegistered) {
      final authController = AuthBinding().instance;
      token = authController.isAuth ? authController.token : null;
    }

    // LOCALIZATION: Read the current locale at request-creation time.
    // This ensures every API call carries the correct language preference.
    final lang = Get.locale?.languageCode ?? 'ar';

    _header = {
      'Content-Type': 'application/vnd.api+json',
      'Accept': 'application/vnd.api+json',
      'Accept-Language': lang,
    };

    if (token != null) {
      _header['Authorization'] = 'Bearer $token';
    }
  }

  Future<CustomResponse> response(String? route, {Map? parameters}) async {
    late Response response;

    // DEBUG: Log outgoing request details so we can verify the language
    // header is correct and trace any backend localization issues.
    if (kDebugMode) {
      print('┌─── API REQUEST ───────────────────────────');
      print('│ ${requestMethod.name.toUpperCase()} $url');
      print('│ Accept-Language: ${_header['Accept-Language']}');
      if (_query != null && _query!.isNotEmpty) {
        print('│ Query: $_query');
      }
      print('└───────────────────────────────────────────');
    }

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

    // DEBUG: Log the response so we can verify the backend returned
    // data in the expected language. Truncate body to avoid log spam.
    if (kDebugMode) {
      final bodyStr = response.body?.toString() ?? '';
      final isError = response.statusCode != null && response.statusCode! >= 300;
      // Show full body for errors (422, 500, etc.) to aid debugging
      final preview = isError
          ? bodyStr
          : (bodyStr.length > 300
              ? '${bodyStr.substring(0, 300)}…'
              : bodyStr);
      print('┌─── API RESPONSE ──────────────────────────');
      print('│ Status: ${response.statusCode}');
      print('│ Body: $preview');
      print('└───────────────────────────────────────────');
    }

    return CustomResponse.set(response);
  }
}
