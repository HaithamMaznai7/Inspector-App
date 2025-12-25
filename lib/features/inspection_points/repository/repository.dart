import 'package:fahis_inspector/features/inspection_points/models/point.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPointsRepository extends ListRepository<Point> {
  static String get boxKey => "Inspection_Points";

  final Box box;
  final String slug;

  InspectionPointsRepository({required this.box, required this.slug});

  String get channel => "App.Models.Inspection.$slug";

  RxList<Point> _data = RxList<Point>([]);

  Stream<List<Point>> get stream => _data.stream;

  @override
  Future<List<Point>> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/points');

    final r = await n.response(RoutingUrl.home);
    final points = r.data.isNotEmpty
        ? Point.setList(r.data['points'])
        : <Point>[];

    _data.assignAll(points);

    await saveToCache();

    return _data;
  }

  Future<void> update(Point point) async {
    final oldPoint = _data.where((p) => p.id == point.id).firstOrNull;

    if (oldPoint == null) {
      throw FNetworkException(
        'Not Found the point',
        statusCode: 404,
        title: "Not Found",
      );
    }

    updatePoints(point);

    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/points/${point.id}',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'status': point.status.value,
      'note': point.note,
      if (point.file != null)
        'image': MultipartFile(
          point.file!,
          filename: point.file!.path.split('/').last,
          contentType: 'image/jpeg', // optional
        ),
    });

    try {
      final r = await n.response(RoutingUrl.home);

      final point = !r.hasError || r.data.isNotEmpty ? Point.set(r.data) : null;

      if (point == null) {
        updatePoints(oldPoint);
      } else {
        updatePoints(point);
      }
    } on FNetworkException catch (e) {
      e.notify();
      updatePoints(oldPoint);
    } catch (e) {
      print(e);
      updatePoints(oldPoint);
    } finally {
      await saveToCache();
    }
  }

  updatePoints(Point newPoint) {
    final index = _data.indexWhere((p) => p.id == newPoint.id);
    if (index != -1) {
      _data[index] = newPoint;
    }
  }

  @override
  List<Point> fetchFromCache() {
    final data = (box.get(slug) as List?) ?? [];

    return data
        .map((item) => Point.set(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveToCache() async {
    final photos = _data.map((i) => i.toJson()).toList();
    await box.put(slug, photos);
  }

  Stream<List<Point>> listenToBroadcast() async* {
    yield _data;
    final broadcast = BroadcastService.instance;
    broadcast?.responses.listen((event) {
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-points')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }
}
