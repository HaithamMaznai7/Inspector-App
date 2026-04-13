import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fahis_inspector/routes.dart';

class InspectionsRepository extends ListRepository<Inspection> {
  final Box<Map> box;
  final InspectionStage stage;

  InspectionsRepository({required this.box, this.stage = InspectionStage.all});

  final RxList<Inspection> _data = RxList<Inspection>([]);

  int _currentPage = 1;
  int _lastPage = 1;
  RxBool isFetchingMore = false.obs;
  final _total = 0.obs;
  final RxMap<String, int> _counts = RxMap<String, int>({
    for (var stage in InspectionStage.allStages)
      "${stage.value ?? 'all'}_total": 0,
  });

  Stream<List<Inspection>> get stream => _data.stream;
  int get count => _total.value;
  Map<String, int> get total => _counts;

  @override
  Future<List<Inspection>> fetchFromApi({
    String? query,
    InspectionStage? stage,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _data.clear();
    }

    // if (_currentPage >= _lastPage || isFetchingMore.value)
    // {
    //   return _data;
    // }else{
    //   isFetchingMore.value = true;
    //   _currentPage++;
    // }

    final n = Network(endpoint: EndPoints.inspections);

    n.setQuery = {
      'page': _currentPage.toString(),
      'stage': stage?.value ?? this.stage.value,
      'q': ?query,
    };

    try {
      final r = await n.response(RoutingUrl.home);
      final inspections = r.data.isNotEmpty
          ? Inspection.setList(r.data['inspections'])
          : <Inspection>[];
      _total.value = r.data['meta']['total'] ?? _total.value;
      for (var stage in InspectionStage.allStages) {
        _counts["${stage.value ?? 'all'}_total"] =
            r.data['meta']["${stage.value ?? 'all'}_total"] ?? 0;
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
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd('Error fetching inspections: $e');
    }

    return _data;
  }

  @override
  List<Inspection> fetchFromCache({InspectionStage? stage}) {
    List<Inspection> cached = [];
    try {
      final stagesData =
          box.get(
            "Inspections_Meta_User_${FirebaseAuth.instance.currentUser?.uid}",
          ) ??
          {};

      Map pages =
          box.get(
            "Inspections_User_${FirebaseAuth.instance.currentUser?.uid}",
            defaultValue: {},
          ) ??
          {};
      for (String slug in pages.keys.toList()) {
        final item = box.get(slug);
        if (item != null) {
          cached.add(Inspection.fromJson(item));
        }
      }

      for (var stage in InspectionStage.allStages) {
        _counts["${stage.value ?? 'all'}_total"] =
            stagesData["${stage.value ?? 'all'}_total"];
      }

      stage ??= this.stage;

      if (stage.value != InspectionStage.all.value) {
        cached = cached.where((i) => i.stage.value == stage!.value).toList();
      }
    } catch (_) {
      dd('error when fetch cache');
    }

    return cached;
  }

  @override
  Future<void> saveToCache() async {
    Map pages = {};

    for (Inspection inspection in _data.toList()) {
      await box.put(inspection.slug, inspection.toJson());
      pages[inspection.slug] = inspection.id;
    }

    await box.put(
      "Inspections_Meta_User_${FirebaseAuth.instance.currentUser?.uid}",
      Map<String, int>.from(_counts),
    );

    await box.put(
      "Inspections_User_${FirebaseAuth.instance.currentUser?.uid}",
      pages,
    );
  }

  Future<List<Inspection>> fetchNextPage() async {
    if (_currentPage >= _lastPage || isFetchingMore.value) return _data;

    isFetchingMore.value = true;
    _currentPage++;

    try {
      return await fetchFromApi(reset: false, stage: stage);
    } catch (_) {
      _currentPage--; // rollback on failure
      return _data;
    } finally {
      isFetchingMore.value = false;
    }
  }
}
