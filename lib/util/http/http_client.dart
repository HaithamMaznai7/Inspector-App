import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
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

  dynamic get getBody => _body;

  Map<String, dynamic>? get getQuery => _query;

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

    this.url = url ?? "${ApiConfig.baseUrl}$endpoint";

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

    // Prevent requests from hanging indefinitely.
    httpClient.timeout = const Duration(seconds: 30);
  }

  Future<CustomResponse> response(String? route, {Map? parameters}) async {
    Response? response;

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
      if (kDebugMode) {
        print('┌─── API ERROR ─────────────────────────────');
        print('│ ${requestMethod.name.toUpperCase()} $url');
        print('│ $e');
        print('└───────────────────────────────────────────');
      }
    }

    if (kDebugMode && response != null) {
      final bodyStr = response.body?.toString() ?? '';
      final isError =
          response.statusCode != null && response.statusCode! >= 300;
      final preview = isError
          ? bodyStr
          : (bodyStr.length > 300 ? '${bodyStr.substring(0, 300)}…' : bodyStr);
      if (kDebugMode) {
        print('┌─── API RESPONSE ──────────────────────────');
      }
      if (kDebugMode) {
        print('│ Status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('│ Body: $preview');
      }
      if (kDebugMode) {
        print('└───────────────────────────────────────────');
      }
    }

    if (response == null || response.statusCode == null) {
      // A null response with no caught exception means the request was
      // cancelled (e.g. user navigated away). This is not a real network
      // failure — throw silently so callers can handle it without showing
      // a misleading "No Connection" snackbar to the user.
      throw FNetworkException('', statusCode: -1);
    }

    return CustomResponse.set(response);
  }
}
