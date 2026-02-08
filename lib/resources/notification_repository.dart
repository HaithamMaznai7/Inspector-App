import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/notification.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationRepository extends ListRepository<Notification> {
  static String get boxKey => "Notifications";

  final Box box;

  NotificationRepository({required this.box});

  String get channel => "App.Models.User";

  RxList<Notification> _data = RxList<Notification>([]);

  Stream<List<Notification>> get stream => _data.stream;

  @override
  Future<List<Notification>> fetchFromApi() async {
    List<Notification> data = [];
    try {
      final n = Network(endpoint: EndPoints.notifications);
      dd(n.header);
      final r = await n.response(RoutingUrl.home);
      data = (r.data as List)
          .map((item) => Notification.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _data.assignAll(data);
      dd(_data.value);
    } catch (e) {
      dd(e.toString());
    } finally {
      await saveToCache();
    }

    return data;
  }

  @override
  List<Notification> fetchFromCache() {
    final data = (box.get('notifications') as List?) ?? [];

    return data
        .map((item) => Notification.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveToCache() async {
    final data = _data.map((i) => i.toJson()).toList();
    await box.put('notifications', data);
  }

  Stream<List<Notification>> listenToBroadcast() async* {
    yield _data;
    final broadcast = BroadcastService.instance;
    broadcast?.responses.listen((event) {
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-body-notes')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }

  Future<List<Notification>> update(
    String notification, {
    bool read = true,
  }) async {
    List<Notification> data = [];
    try {
      Network n = Network(
        endpoint: '${EndPoints.notifications}/$notification',
        requestMethod: RequestMethod.post,
      );

      n.setBody = {'action': read ? 'read' : 'unread'};

      final r = await n.response(RoutingUrl.home);

      data = (r.data as List)
          .map((item) => Notification.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _data.assignAll(data);
    } on FNetworkException catch (e) {
      dd(e.errors);
      dd(e.statusCode);
      dd(e.message);
      dd(e.title);
      dd(e.uri);
    } catch (e) {
      rethrow;
    } finally {
      await saveToCache();
    }

    return data;
  }
}
