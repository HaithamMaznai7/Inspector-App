import 'dart:io';
import 'package:fahis_inspector/features/inspection_obd/models/obd_code.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionObdRepository extends ListRepository<OBDCode> {
  static String get boxKey => "Inspection_Obd";

  final Box box;
  final String slug;

  InspectionObdRepository({required this.box, required this.slug});

  final String channel = "App.Models.Inspection.${Auth.user?.id}";

  RxList<OBDCode> _data = RxList<OBDCode>([]);

  RxnString _report = RxnString();

  Stream<List<OBDCode>> get stream => _data.stream;

  Stream<String?> get reportStream => _report.stream;

  @override
  Future<List<OBDCode>> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/obd-codes');

    final r = await n.response(RoutingUrl.home);

    final bodySides = r.data.isNotEmpty
        ? OBDCode.setList(r.data['codes'])
        : <OBDCode>[];

    _report.value = r.data.isNotEmpty ? r.data['report'] : null;

    _data.assignAll(bodySides);

    await saveToCache();

    return _data;
  }

  @override
  List<OBDCode> fetchFromCache() {
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

  Stream<List<OBDCode>> listenToBroadcast() async* {
    yield _data;
    final broadcast = BroadcastService.instance;
    broadcast?.responses.listen((event) {
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-codes')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }

  Future<List<OBDCode>> store(OBDCode code) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/obd-codes',
      requestMethod: RequestMethod.post,
    );

    n.setBody = {
      'code': code.code,
      'description': code.description
    };

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);

      await saveToCache();
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      print('error on storing');
    }

    return _data;
  }

  Future<List<OBDCode>> update(OBDCode code) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/obd-codes/${code.id}',
      requestMethod: RequestMethod.post,
    );

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);

      await saveToCache();
    } catch (_) {
      print('error on storing');
    }

    return _data;
  }

  Future<List<OBDCode>> delete(OBDCode code) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/obd-codes/${code.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);

      await saveToCache();
    } catch (_) {
      print('error on storing');
    }

    return _data;
  }

  Future<String?> upload(File? file) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/report',
      requestMethod: RequestMethod.post,
    );

    n.setBody = FormData({
      'report': file != null
          ? MultipartFile(
              file,
              filename: file.path.split('/').last,
              contentType: 'pdf', // optional
            )
          : null,
    });

    final r = await n.response(RoutingUrl.home);
    print(r.data);
    final bodySides = r.data.isNotEmpty
        ? OBDCode.setList(r.data['codes'])
        : <OBDCode>[];

    _report.value = r.data.isNotEmpty ? r.data['report'] : null;

    _data.assignAll(bodySides);

    await saveToCache();

    return _report.value;
  }
}
