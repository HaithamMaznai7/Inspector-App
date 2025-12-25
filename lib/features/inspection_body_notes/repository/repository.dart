import 'package:fahis_inspector/features/inspection_body_notes/models/inspection_body_notes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionBodyRepository extends ListRepository<CarBody> {
  static String get boxKey => "Inspection_Body";

  final Box box;
  final String slug;

  InspectionBodyRepository({required this.box, required this.slug});

  String get channel => "App.Models.Inspection.$slug";

  RxList<CarBody> _data = RxList<CarBody>([]);

  Stream<List<CarBody>> get stream => _data.stream;

  @override
  Future<List<CarBody>> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/bodies');

    final r = await n.response(RoutingUrl.home);

    final bodySides = r.data.isNotEmpty ? CarBody.setList(r.data) : <CarBody>[];

    _data.assignAll(bodySides);

    await saveToCache();

    return _data;
  }

  @override
  List<CarBody> fetchFromCache() {
    final data = (box.get(slug) as List?) ?? [];

    return data
        .map((item) => CarBody.set(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveToCache() async {
    final bodySides = _data.map((i) => i.toJson()).toList();
    await box.put(slug, bodySides);
  }

  Stream<List<CarBody>> listenToBroadcast() async* {
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

  Future<void> store(CarBody body, Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/bodies/${body.id}',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type?.id,
      'note': note.note,
      if (note.file != null)
        'image': MultipartFile(
          note.file!,
          filename: note.file!.path.split('/').last,
          contentType: 'image/jpeg', // optional
        ),
    });

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? CarBody.setList(r.data)
          : <CarBody>[];

      _data.assignAll(bodySides);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print(e);
    } finally {
      await saveToCache();
    }
  }

  Future<void> update(Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/notes/${note.id}',
      requestMethod: RequestMethod.post,
    );

    print(note.type?.id);

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type?.id,
      'note': note.note,
      if (note.file != null)
        'image': MultipartFile(
          note.file!,
          filename: note.file!.path.split('/').last,
          contentType: 'image/jpeg', // optional
        ),
    });

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? CarBody.setList(r.data)
          : <CarBody>[];

      _data.assignAll(bodySides);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print(e);
    } finally {
      await saveToCache();
    }
  }

  Future<void> delete(Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/notes/${note.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? CarBody.setList(r.data)
          : <CarBody>[];

      _data.assignAll(bodySides);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print(e);
    } finally {
      await saveToCache();
    }
  }
}
