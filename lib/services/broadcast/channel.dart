// import 'dart:async';
// import 'package:fahis_inspector/services/broadcast/broadcast.dart';
// import 'package:fahis_inspector/services/broadcast/channel_interface.dart';
// import 'package:fahis_inspector/services/broadcast/my_web_socket.dart';
// import 'package:get/get.dart';
// import 'package:simple_flutter_reverb/simple_flutter_reverb.dart';


// class Channel implements ChannelInterface {
//   @override
//   final String channelName;
//   @override
//   final String? event;
//   StreamController<Map?>? _controller;

//   Channel(this.channelName, {this.event});

//   Stream<Map?> stream() {
    
//     _controller = StreamController<Map?>.broadcast();
//     final broadcast = WebSocket.find;

//     // broadcast.createConnection().listen((val) {
//     //   if (val is WebsocketResponse && (event == null || event == val.event)) {
//     //     _controller?.add(val.data);
//     //   }
//     // }, channelName);
    

//     return _controller!.stream;
//   }

//   void unsubscribe() {
//     final broadcast = Get.find<BroadcastService>();
//     if (broadcast.isWeb) {
//       // broadcast.reverb?.close(channelName);
//     } else {
//       broadcast.pusher?.unsubscribe(channelName: channelName);
//     }
//     _controller?.close();
//   }
// }
