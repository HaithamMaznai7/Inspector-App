abstract class ChannelInterface {
  String get channelName;
  String? get event;

  Stream<Map?> stream();
  void unsubscribe();
}