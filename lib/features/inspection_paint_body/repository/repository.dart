import 'package:fahis_inspector/features/inspection_paint_body/models/paint_body_part.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPaintBodyRepository extends ListRepository<PaintBodyPart> {
  static String get boxKey => "Inspection_Paint_Body";

  final Box box;
  final String slug;

  InspectionPaintBodyRepository({required this.box, required this.slug});

  final String channel = "App.Models.Inspection.${Auth.user?.id}";

  RxList<PaintBodyPart> _data = RxList<PaintBodyPart>([]);

  Stream<List<PaintBodyPart>> get stream => _data.stream;

  @override
  Future<List<PaintBodyPart>> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/body-points');

    final r = await n.response(RoutingUrl.home);

    final parts = r.data.isNotEmpty
        ? PaintBodyPart.setList(r.data['data'])
        : <PaintBodyPart>[];

    _data.assignAll(parts);

    await saveToCache();

    return _data;
  }

  @override
  List<PaintBodyPart> fetchFromCache() {
    // final data = (box.get(slug) as List?) ?? [];
    // _data.assignAll(
    //   data
    //   .where((item) => item != null) // Filter out nulls
    //   .map((item) => OBDCode.set(Map<String, dynamic>.from(item)))
    //   .toList(),
    // );

    return _data;
  }

  @override
  Future<void> saveToCache() async {
    final codes = _data.map((i) => i.toJson()).toList();
    await box.put(slug, codes);
  }

  Stream<List<PaintBodyPart>> listenToBroadcast() async* {
    yield _data;
    final broadcast = BroadcastService.instance;
    broadcast?.responses.listen((event) {
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-paints-body')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }

  Future<List<PaintBodyPart>> update(PaintBodyPart part) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/body-points/${part.id}',
      requestMethod: RequestMethod.post,
    );

    try {
      final r = await n.response(RoutingUrl.home);

      if(r.data.isNotEmpty){
        part = PaintBodyPart.set(r.data['data']);
      }

      final index = _data.indexWhere((p) => p.id == part.id);
      _data.value[index] = part;

      await saveToCache();
    } catch (_) {
      print('error on storing');
    }

    return _data;
  }
}
