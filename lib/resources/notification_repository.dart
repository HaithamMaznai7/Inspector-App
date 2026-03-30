import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/notification.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationRepository extends ListRepository<Notification> {
  static String get boxKey => "Notifications";

  final Box box;

  NotificationRepository({required this.box});

  final RxList<Notification> _data = RxList<Notification>([]);

  Stream<List<Notification>> get stream => _data.stream;

  @override
  Future<List<Notification>> fetchFromApi() async {
    AppLogger.trace('NotificationRepository', 'fetchFromApi started');
    List<Notification> data = [];
    try {
      final n = Network(endpoint: EndPoints.notifications);
      dd(n.header);
      final r = await n.response(RoutingUrl.home);
      data = (r.data as List)
          .map((item) => Notification.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _data.assignAll(data);
      AppLogger.trace('NotificationRepository', 'fetchFromApi returned ${data.length} notifications');
      dd(_data.toList());
    } catch (e) {
      AppLogger.error('NotificationRepository', 'fetchFromApi failed', e);
      dd(e.toString());
    } finally {
      await saveToCache();
    }

    return data;
  }

  @override
  List<Notification> fetchFromCache() {
    final raw = (box.get('notifications') as List?) ?? [];
    final data = raw
        .map((item) => Notification.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    AppLogger.trace('NotificationRepository', 'fetchFromCache returned ${data.length} notifications');
    return data;
  }

  @override
  Future<void> saveToCache() async {
    final data = _data.map((i) => i.toJson()).toList();
    await box.put('notifications', data);
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
