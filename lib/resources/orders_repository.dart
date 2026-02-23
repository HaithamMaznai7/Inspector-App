import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/order.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fahis_inspector/routes.dart';

class OrdersRepository extends ListRepository<Order> {
  final Box<Map> box;
  final String type;

  OrdersRepository({required this.box, required this.type});

  final RxList<Order> _data = RxList<Order>([]);

  int _currentPage = 1;
  int _lastPage = 1;
  RxBool isFetchingMore = false.obs;
  final _total = 0.obs;
  final RxMap<String, int> _counts = RxMap<String, int>({
    'all_total': 0,
    'pending_total': 0,
    'approved_total': 0,
    'processing_total': 0,
    'canceled_total': 0,
    'rejected_total': 0,
    'completed_total': 0,
    'refunded_total': 0,
  });

  Stream<List<Order>> get stream => _data.stream;
  int get count => _total.value;
  Map<String, int> get total => _counts;

  @override
  Future<List<Order>> fetchFromApi({
    String? query,
    String? status,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _data.clear();
    }

    final endpoint = type == 'b2c' ? EndPoints.ordersB2c : EndPoints.ordersB2b;
    final n = Network(endpoint: endpoint);

    n.setQuery = {
      'page': _currentPage.toString(),
      if (status != null && status != 'all') 'status': status,
      if (query != null) 'q': query,
    };

    try {
      final r = await n.response(RoutingUrl.home);
      final orders = r.data.isNotEmpty && r.data['orders'] != null
          ? (r.data['orders'] as List)
              .map((json) => Order.fromJson(json))
              .toList()
          : <Order>[];

      _total.value = r.data['meta']['total'] ?? _total.value;
      _counts['all_total'] = r.data['meta']['all_total'] ?? 0;
      _counts['pending_total'] = r.data['meta']['pending_total'] ?? 0;
      _counts['approved_total'] = r.data['meta']['approved_total'] ?? 0;
      _counts['processing_total'] = r.data['meta']['processing_total'] ?? 0;
      _counts['canceled_total'] = r.data['meta']['canceled_total'] ?? 0;
      _counts['rejected_total'] = r.data['meta']['rejected_total'] ?? 0;
      _counts['completed_total'] = r.data['meta']['completed_total'] ?? 0;
      _counts['refunded_total'] = r.data['meta']['refunded_total'] ?? 0;

      _lastPage = r.data['meta']['last_page'] ?? _lastPage;

      if (reset) {
        _data.assignAll(orders);
      } else {
        for (final order in orders) {
          if (_data.where((item) => item.id == order.id).firstOrNull == null) {
            _data.add(order);
          }
        }
      }

      await saveToCache();
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd('Error fetching orders: $e');
    }

    return _data;
  }

  @override
  List<Order> fetchFromCache({String? status}) {
    List<Order> cached = [];
    try {
      final countsData =
          box.get(
            "Orders_${type}_Meta_User_${FirebaseAuth.instance.currentUser?.uid}",
          ) ??
          {};

      Map pages =
          box.get(
            "Orders_${type}_User_${FirebaseAuth.instance.currentUser?.uid}",
            defaultValue: {},
          ) ??
          {};

      for (String slug in pages.keys.toList()) {
        final item = box.get(slug);
        if (item != null) {
          cached.add(Order.fromJson(item));
        }
      }

      _counts.addAll(Map<String, int>.from(countsData));

      if (status != null && status != 'all') {
        cached = cached.where((o) => o.status == status).toList();
      }
    } catch (_) {
      dd('error when fetch orders cache');
    }

    return cached;
  }

  @override
  Future<void> saveToCache() async {
    Map pages = {};

    for (Order order in _data) {
      await box.put(order.slug, order.toJson());
      pages[order.slug] = order.id;
    }

    await box.put(
      "Orders_${type}_Meta_User_${FirebaseAuth.instance.currentUser?.uid}",
      Map<String, int>.from(_counts),
    );

    await box.put(
      "Orders_${type}_User_${FirebaseAuth.instance.currentUser?.uid}",
      pages,
    );
  }

  Future<List<Order>> fetchNextPage() async {
    if (_currentPage >= _lastPage || isFetchingMore.value) return _data;

    isFetchingMore.value = true;
    _currentPage++;

    try {
      return await fetchFromApi(reset: false);
    } catch (_) {
      _currentPage--;
      return _data;
    } finally {
      isFetchingMore.value = false;
    }
  }

  @override
  void listenToBroadcast() {
    // No broadcast support for orders yet
  }

  Future<String?> createOrderItem(int itemId) async {
    final n = Network(
      endpoint: '${EndPoints.orderItems}/$itemId',
      requestMethod: RequestMethod.post,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      if (r.data != null && r.data['slug'] != null) {
        return r.data['slug'] as String;
      }
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd('Error creating order item: $e');
    }

    return null;
  }
}
