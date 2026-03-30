import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionBodyRepository extends ListRepository<CarBody> {
  final Box<List> box;
  final String slug;

  InspectionBodyRepository({required this.box, required this.slug});

  final RxList<CarBody> _data = RxList<CarBody>([]);

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

  // WHAT: Read cached body notes from Hive and deserialize into CarBody objects.
  // WHY: Hive stores all maps as Map<dynamic, dynamic>. Without explicit casting,
  //      CarBody.fromJson → Marker.fromJson will crash with type casting error.
  // HOW: Each item is cast via Map<String, dynamic>.from() before passing to
  //      CarBody.fromJson. A try/catch per item prevents one corrupted entry
  //      from blocking all others.
  // EDGE CASES:
  //   - Cache is empty → returns empty list
  //   - Cache contains corrupted data → skipped, returns partial list
  @override
  List<CarBody> fetchFromCache() {
    final data = box.get('BodyNotes') ?? [];

    final List<CarBody> result = [];
    for (final item in data) {
      try {
        result.add(CarBody.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (e) {
        // WHAT: Skip corrupted cache entries instead of crashing.
        // WHY: One bad entry shouldn't prevent all other body notes from loading.
        dd('Error parsing cached body note: $e');
      }
    }
    return result;
  }

  @override
  Future<void> saveToCache() async {
    final bodySides = _data.map((i) => i.toJson()).toList();
    await box.put('BodyNotes', bodySides);
  }

  Future<void> store(CarBody body, Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/bodies/${body.id}',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type,
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
      dd(e);
    } finally {
      await saveToCache();
    }
  }

  Future<void> update(Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.notes}/${note.id}',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type,
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
      dd(e);
    } finally {
      await saveToCache();
    }
  }

  Future<void> delete(Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.notes}/${note.id}',
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
      dd(e);
    } finally {
      await saveToCache();
    }
  }
}
