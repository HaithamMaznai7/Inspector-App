import 'dart:convert';

class BroadcastEvent {
  final String? channel;
  final String event;
  final Map<String, dynamic> data;

  BroadcastEvent(this.event, {this.data = const {}, this.channel});

  factory BroadcastEvent.fromPusherEvent(event) {
    return BroadcastEvent(
      event.eventName,
      data: event.data,
      channel: event.channelName,
    );
  }

  factory BroadcastEvent.get(String string) {
    final json = jsonDecode(string);
    
    if(json['data'] is String){
      json['data'] = jsonDecode(json['data']);
    }
    return BroadcastEvent(
      json['event'],
      data: json['data'] as Map<String, dynamic>,
      channel: json['channel']
    );
  }

  @override
  String toString() {
    return jsonEncode({
      "channel": channel,
      "event": event,
      "data": data.toString(),
    });
  }
}
