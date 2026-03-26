import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPointsRepository extends ListRepository<Point> {
  final Box box;
  final String slug;

  InspectionPointsRepository({required this.box, required this.slug}) {
    fetchFromCache();
  }

  final RxList<Point> _data = RxList<Point>([]);

  Stream<List<Point>> get stream => _data.stream;

  @override
  Future<List<Point>> fetchFromApi() async {
    try {
      final n = Network(endpoint: '${EndPoints.inspections}/$slug/points');

      final r = await n.response(RoutingUrl.home);
      final points = (r.data['points'] as List)
          .map((p) => Point.fromJson(p))
          .toList();
      _data.assignAll(points);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
    } finally {
      await saveToCache();
    }

    return _data.toList();
  }

  Future<List<Point>> generate() async {
    try {
      final n = Network(
        endpoint: '${EndPoints.inspections}/$slug/points',
        requestMethod: RequestMethod.post,
      );

      final r = await n.response(RoutingUrl.home);
      dd(r.data);
      final points = r.data.isNotEmpty
          ? Point.setList(r.data['points'])
          : <Point>[];

      _data.assignAll(points);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (_) {
    } finally {
      await saveToCache();
    }

    return _data;
  }

  Future<void> update(Point point, PointStatus status) async {
    try {
      Network n = Network(
        endpoint: '${EndPoints.points}/${point.id}',
        requestMethod: RequestMethod.post,
      );

      n.setBody = FormData({
        'status': status.value,
        'note': point.note,
        if (point.file != null)
          'image': MultipartFile(
            point.file!,
            filename: point.file!.path.split('/').last,
            contentType: 'image/jpeg', // optional
          ),
      });

      final r = await n.response(RoutingUrl.home);
      point = Point.fromJson(r.data);

      updatePoints(point);
    } on FNetworkException catch (e) {
      e.notify();
      // dd(e.toString());
    } catch (e) {
      dd(e);
    } finally {
      await saveToCache();
    }
  }

  void updatePoints(Point newPoint) {
    final index = _data.indexWhere((p) => p.id == newPoint.id);
    if (index != -1) {
      _data[index] = newPoint;
    } else {
      _data.add(newPoint);
    }
  }

  @override
  List<Point> fetchFromCache() {
    final data = (box.get('Points') as List?) ?? [];

    _data.value = data
        .map((item) => Point.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return _data;
  }

  @override
  Future<void> saveToCache() async {
    final points = _data.map((i) => i.toJson()).toList();
    await box.put('Points', points);
  }

}
