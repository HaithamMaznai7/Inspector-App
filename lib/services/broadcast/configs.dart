import 'package:fahis_inspector/services/broadcast/broadcast_auth.dart';

class WebSocketOptions {
  final String key;
  final String host;
  final num wsPort;
  final num wssPort;
  final bool forceTLS;
  final WebsocketAuth? authentication;
  final bool usePrefix;
  final String prefix;

  WebSocketOptions({
    required this.key,
    required this.host,
    this.wsPort = 8080,
    this.wssPort = 443,
    this.forceTLS = false,
    this.authentication,
    this.usePrefix = true,
    this.prefix = 'private-',
  });

  String get getPrefix => usePrefix ? prefix : '';

  String get getScheme => forceTLS ? 'wss' : 'ws';

  int get port => (forceTLS ? wssPort : wsPort).toInt();

  Uri get url => Uri(
    scheme: getScheme,
    host: host,
    port: port,
    path: '/app/$key',
    queryParameters: {'protocol': '7', 'client': 'flutter'},
  );

  String get schema => forceTLS ? 'https://' : 'http://';

  String get authUrl => '$schema$host';

  authenticate({required String channel, required String socket}) =>
      authentication?.authenticate(authUrl, socket, channel);
}
