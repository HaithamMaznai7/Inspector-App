// import 'dart:async';
// import 'package:fahis_inspector/services/broadcast/broadcast.dart';
// import 'package:fahis_inspector/services/broadcast/channel_interface.dart';
// import 'package:get/get.dart';
// import 'package:simple_flutter_reverb/simple_flutter_reverb.dart';

// class PrivateChannel implements ChannelInterface {
//   @override
//   final String channelName;
//   @override
//   String? event;
//   StreamController<Map?>? _controller;

//   PrivateChannel(this.channelName, {this.event});

//   Stream<Map?> stream() {
//     _controller = StreamController<Map?>.broadcast();
//     final broadcast = Get.find<BroadcastService>();
//     dd(channelName);
//     if (broadcast.isWeb) {
//       // Web → Reverb
//       broadcast.reverb!.listen((val) {
//         if (val is WebsocketResponse && (event == null || event == val.event)) {
//           _controller?.add(val.data);
//         }
//       }, channelName, isPrivate: true);
//     } else {
//       // Mobile → Pusher
//       broadcast.pusher?.subscribe(
//         channelName: channelName,
//         onEvent: (val) {
//           if (event == null || val.eventName == event) {
//             _controller?.add(val.data);
//           }
//         },
//       );
//     }

//     return _controller!.stream;
//   }

//   void unsubscribe() {
//     final broadcast = Get.find<BroadcastService>();
//     if (broadcast.isWeb) {
//       // broadcast.reverb?.close(channel);
//     } else {
//       broadcast.pusher?.unsubscribe(channelName: channelName);
//     }
//     _controller?.close();
//   }
// }
