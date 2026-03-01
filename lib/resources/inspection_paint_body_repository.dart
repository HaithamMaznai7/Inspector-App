import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/paint_body_part.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPaintBodyRepository extends ListRepository<PaintBodyPart> {
  static String get boxKey => "Inspection_Body";

  final Box box;
  final String slug;

  InspectionPaintBodyRepository({required this.box, required this.slug});

  String get channel => "App.Models.Inspection.$slug";

  final RxList<PaintBodyPart> _data = RxList<PaintBodyPart>([]);

  Stream<List<PaintBodyPart>> get stream => _data.stream;

  @override
  Future<List<PaintBodyPart>> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/bodies');

    final r = await n.response(RoutingUrl.home);

    final bodySides = r.data.isNotEmpty
        ? PaintBodyPart.setList(r.data)
        : <PaintBodyPart>[];

    _data.assignAll(bodySides);

    await saveToCache();

    return _data;
  }

  @override
  List<PaintBodyPart> fetchFromCache() {
    final data = (box.get(slug) as List?) ?? [];

    return data
        .map((item) => PaintBodyPart.set(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveToCache() async {
    final bodySides = _data.map((i) => i.toJson()).toList();
    await box.put(slug, bodySides);
  }

  @override
  Stream<List<PaintBodyPart>> listenToBroadcast() async* {
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

  Future<List<PaintBodyPart>> update(PaintBodyPart part) async {
    Network n = Network(
      endpoint:
          '${EndPoints.inspections}/${part.inspection}/paint-body/${part.part}',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'thickness': part.thickness,
      'substrate': part.substrate,
      'measurementCount': part.measurementCount,
    });

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? PaintBodyPart.setList(r.data)
          : <PaintBodyPart>[];

      _data.assignAll(bodySides);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e);
    } finally {
      await saveToCache();
    }

    return _data;
  }
}
