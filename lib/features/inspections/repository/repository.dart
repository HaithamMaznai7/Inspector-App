import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionsRepository extends ListRepository<Inspection> {
  static String get cacheKey => "Home_Inspections";

  final Box box; // instead of Box<List<Map<String, dynamic>>>
  final InspectionStage status;

  InspectionsRepository({required this.box, this.status = InspectionStage.all});

  final String channel = "App.Models.User.${Auth.user?.id}";

  RxList<Inspection> _data = RxList<Inspection>([]);

  int _currentPage = 1;
  int _lastPage = 1;
  RxBool isFetchingMore = false.obs;
  var _total = 0.obs;
  RxMap<String, int> _counts = RxMap<String, int>({
    for (var stage in InspectionStage.allStages)
      "${stage.value ?? 'all'}_total": 0,
  });

  Stream<List<Inspection>> get stream => _data.stream;
  int get count => _total.value;
  Map<String, int> get total => _counts;

  @override
  Future<List<Inspection>> fetchFromApi({
    String? query,
    InspectionStage status = InspectionStage.all,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _data.clear();
    }

    final n = Network(endpoint: EndPoints.inspections);
    n.setQuery = {
      'page': _currentPage.toString(),
      'stage': status.value,
      if (query != null) 'q': query,
    };

    final r = await n.response(RoutingUrl.home);

    final inspections = r.data.isNotEmpty
        ? Inspection.setList(r.data['inspections'])
        : <Inspection>[];

    _total.value = r.data['meta']['total'] ?? _total.value;
    for (var stage in InspectionStage.allStages) {
      _counts["${stage.value ?? 'all'}_total"] =
          r.data['meta']["${stage.value ?? 'all'}_total"];
    }
    _lastPage = r.data['meta']['last_page'] ?? _lastPage;

    if (reset) {
      _data.value = inspections;
    } else {
      for (final i in inspections) {
        if (_data.where((item) => item.id == i.id).firstOrNull == null) {
          _data.add(i);
        }
      }
    }

    await saveToCache();
    return _data;
  }

  @override
  List<Inspection> fetchFromCache() {
    final data = (box.get('inspections') as List?) ?? [];

    final cached = data
        .map((item) => Inspection.set(Map<String, dynamic>.from(item)))
        .toList();

    if (status == InspectionStage.all) {
      return cached;
    }
    return cached.where((i) => i.stage == status).toList();
  }

  @override
  Future<void> saveToCache() async {
    final inspections = _data.map((i) => i.toJson()).toList();
    await box.put('inspections', inspections);
  }

  Future<List<Inspection>> fetchNextPage() async {
    if (_currentPage >= _lastPage || isFetchingMore.value) return _data;

    isFetchingMore.value = true;
    _currentPage++;

    try {
      return await fetchFromApi(reset: false, status: status);
    } catch (_) {
      _currentPage--; // rollback on failure
      return _data;
    } finally {
      isFetchingMore.value = false;
    }
  }

  Stream<List<Inspection>> listenToBroadcast() async* {
    yield _data;
    final broadcast = BroadcastService.instance;
    broadcast?.responses.listen((event) {
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('new-inspection')) {
        fetchFromApi(status: status);
      }
    });
    yield* stream;
  }
}
