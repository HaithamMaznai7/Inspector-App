import 'package:fahis_inspector/common/widget/loaders/loaders.dart';
import 'package:fahis_inspector/features/notifications/model/notification.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationRepository extends ListRepository<NotificationModel> {
  static String get cacheKey => "App.Models.User.${Auth.user?.id}";

  final Box<List<Map<String, dynamic>>> box;

  NotificationRepository(this.box);

  final String channel = "App.Models.User.${Auth.user?.id}";

  RxList<NotificationModel> _data = <NotificationModel>[].obs; // الحالة الداخلية

  RxnString status = RxnString(null); // الحالة الداخلية

  Stream<List<NotificationModel>> get stream =>
      _data.stream; // هذا يقدر يسمع له الكنترولر

  Stream<List<NotificationModel>> get() async* {
    // 1. Yield cached data first
    yield await fetchFromCache();

    // 2. Fetch fresh data from API
    try {
      yield await fetchFromApi();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      listenToBroadcast();

      // listenToStatus();
      yield* stream;
    }
  }

  @override
  Future<List<NotificationModel>> fetchFromApi() async {
    // Example API request
    Network n = Network(endpoint: EndPoints.notifications);

    try {
      CustomResponse r = await n.response(RoutingUrl.home);
      
      final notifications = r.data.isNotEmpty
          ? NotificationModel.setList(r.data)
          : <NotificationModel>[];

      // print(inspections);
      _data.assignAll(notifications); // تحديث الحالة

      await saveToCache();

      return _data;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// جلب من الكاش
  @override
  List<NotificationModel> fetchFromCache() {
    List<Map<String, dynamic>> data = [];
    try {
      data = box.get('notifications', defaultValue: []) ?? data;
      _data.value = data.map((item) => NotificationModel.set(item)).toList();
    } catch (_) {}

    return _data;
  }

  @override
  Future<void> saveToCache() async {
    final notifications = _data.map((item) => item.toJson()).toList();
    await box.put('notifications', notifications);
  }

  @override
  void listenToBroadcast() {
    final broadcast = BroadcastService.instance;

    if (kDebugMode) {
    print('===> Notifications Tring Listen To Notifications.');
    }

    broadcast?.subscribe('App.Models.User.${Auth.user?.id}', isPrivate: true);

    broadcast?.responses.listen((event) {
      if (
          event != null &&
          event.channel == 'private-App.Models.User.${Auth.user?.id}' &&
          event.event.contains('BroadcastNotificationCreated')
        ) {
        if(event.data.isNotEmpty){
          FLoader.infoSnackBar(
            title: event.data['title'] ?? 'Default Title',
            message: event.data['description'] ?? 'Default Description'
          );
        }
        fetchFromApi();
      }
    });
  }
}
