import 'dart:convert';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/services/broadcast/broadcast_auth.dart';
import 'package:fahis_inspector/services/broadcast/configs.dart';
import 'package:fahis_inspector/services/broadcast/event.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
// import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BroadcastService extends GetxService {
  final WebSocketOptions options;
  final WebSocketChannel broadcast;

  Rxn<BroadcastEvent> responses = Rxn<BroadcastEvent>();
  RxnString socketId = RxnString();

  static BroadcastService? get instance => Get.isRegistered<BroadcastService>()
      ? Get.find<BroadcastService>()
      : Get.put<BroadcastService>(BroadcastService.init());

  BroadcastService(this.options, this.broadcast);

  factory BroadcastService.init() {
    var options = WebSocketOptions(
      key: EndPoints.reverbApp,
      host: EndPoints.domain,
      forceTLS: EndPoints.schema == 'https',
      wsPort: EndPoints.wsPort,
      wssPort: EndPoints.wssPort,
      authentication: null,
    );

    if (auth().isAuth) {
      auth().user?.getIdToken().then((token) {
        options = WebSocketOptions(
          key: EndPoints.reverbApp,
          host: EndPoints.domain,
          forceTLS: EndPoints.schema == 'https',
          wsPort: EndPoints.wsPort,
          wssPort: EndPoints.wssPort,
          authentication: WebsocketAuth(
            authEndpoint: 'broadcasting/auth',
            token: token,
          ),
        );
      });
    }

    final broadcast = WebSocketChannel.connect(options.url);

    final instance = BroadcastService(options, broadcast);

    broadcast.stream.listen(
      instance.onData,
      onError: instance.onError,
      onDone: instance.onDone,
    );

    return instance;
  }

  void onDone() {
    if (kDebugMode) {
      dd('===> broadcasting Done <onDone()>');
    }
  }

  void onData(data) {
    if (kDebugMode) {
      dd('===> broadcasting ... ');
      dd(data);
    }

    final event = BroadcastEvent.get(data);

    if (event.event == 'pusher:connection_established') {
      if (kDebugMode) {
        dd('===> Websocet: Connected :)');
      }

      socketId.value = event.data['socket_id'];
    }

    if (event.event == 'pusher_internal:subscription_succeeded') {
      if (kDebugMode) {
        dd(
          '===> Subscribed to ${event.channel} ${(event.channel?.startsWith(options.getPrefix) ?? false) ? '<private>' : '<public>'} Successfully',
        );
      }
    }

    responses.value = event;
  }

  onError(Object object, StackTrace trace) {
    if (kDebugMode) {
      dd('===> we have an error on broadcasting <onError()>');
    }
  }

  void disconnect() {
    broadcast.sink.close();
    socketId.value = null;
    responses.value = null;
  }

  subscribe(String channel, {bool isPrivate = false}) async {
    // Wait until socketId is available
    while (socketId.value == null) {
      await Future.delayed(Duration(seconds: 3));
    }

    if (kDebugMode) {
      dd(
        '===> Subscribing to $channel ${isPrivate ? '<private>' : '<public>'}',
      );
    }

    // Subscribe to the channel
    try {
      // مصادقة القناة الخاصة
      final jwt = isPrivate
          ? await options.authenticate(
              socket: socketId.value!,
              channel: '${options.getPrefix}$channel',
            )
          : null;

      if (kDebugMode) {
        dd('===> Broadcast Authentication JWT: $jwt');
      }

      // إرسال حدث الاشتراك
      final subscribePayload = {
        'event': 'pusher:subscribe',
        'data': jwt != null
            ? {'auth': jwt, 'channel': '${options.getPrefix}$channel'}
            : {'channel': channel},
      };

      broadcast.sink.add(jsonEncode(subscribePayload));
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
      FLoader.errorSnackBar(
        title: 'Brodcasting error on subscribtion',
        message: 'on authentication and subscribtion',
      );
    }
  }
}
