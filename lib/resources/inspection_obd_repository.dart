import 'dart:io';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionObdRepository extends ListRepository<OBDCode> {
  static String get boxKey => "Inspection_Obd";

  final Box box;
  final String slug;

  InspectionObdRepository({required this.box, required this.slug});

  final RxList<OBDCode> _data = RxList<OBDCode>([]);

  final RxnString _report = RxnString();

  Stream<List<OBDCode>> get stream => _data.stream;

  Stream<String?> get reportStream => _report.stream;

  @override
  Future<List<OBDCode>> fetchFromApi() async {
    _log('fetchFromApi – GET ${EndPoints.inspections}/$slug/obd-codes');
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/obd-codes');

    final r = await n.response(RoutingUrl.home);

    _log('fetchFromApi – status: ${r.hasError ? "ERROR" : "OK"}, data type: ${r.data.runtimeType}');

    final bodySides = r.data.isNotEmpty
        ? OBDCode.setList(r.data['codes'] ?? [])
        : <OBDCode>[];

    _report.value = r.data.isNotEmpty ? r.data['report'] : null;

    _log('fetchFromApi – parsed ${bodySides.length} codes, report=${_report.value != null}');

    _data.assignAll(bodySides);

    await saveToCache();

    return _data;
  }

  // Read cached OBD codes from Hive and deserialize into OBDCode objects.
  // Per-item try/catch prevents one corrupted entry from blocking all others.
  @override
  List<OBDCode> fetchFromCache() {
    final data = (box.get(slug) as List?) ?? [];

    final List<OBDCode> result = [];
    for (final item in data) {
      try {
        result.add(OBDCode.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (e) {
        _log('fetchFromCache – error parsing item: $e');
      }
    }

    _log('fetchFromCache – loaded ${result.length} codes from cache');
    _data.assignAll(result);
    return _data;
  }

  @override
  Future<void> saveToCache() async {
    final codes = _data.map((i) => i.toJson()).toList();
    await box.put(slug, codes);
    _log('saveToCache – saved ${codes.length} codes');
  }

  Future<List<OBDCode>> store(OBDCode code) async {
    _log('store – POST code="${code.code}", desc="${code.description}"');
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/obd-codes',
      requestMethod: RequestMethod.post,
    );

    n.setBody = {'code': code.code, 'description': code.description};

    try {
      final r = await n.response(RoutingUrl.home);
      _log('store – response status: ${r.hasError ? "ERROR" : "OK"}');

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);
      _log('store – updated ${bodySides.length} codes');

      await saveToCache();
    } on FNetworkException catch (e) {
      _log('store – FNetworkException: ${e.statusCode}');
      e.notify();
    } catch (e) {
      _log('store – error: $e');
    }

    return _data;
  }

  Future<List<OBDCode>> update(OBDCode code) async {
    _log('update – POST code id=${code.id}, code="${code.code}"');
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/obd-codes/${code.id}',
      requestMethod: RequestMethod.post,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      _log('update – response status: ${r.hasError ? "ERROR" : "OK"}');

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);
      _log('update – updated ${bodySides.length} codes');

      await saveToCache();
    } catch (e) {
      _log('update – error: $e');
    }

    return _data;
  }

  Future<List<OBDCode>> delete(OBDCode code) async {
    _log('delete – DELETE code id=${code.id}');
    final n = Network(
      endpoint: 'inspector/codes/${code.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      _log('delete – response status: ${r.hasError ? "ERROR" : "OK"}');

      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'])
          : <OBDCode>[];

      _report.value = r.data.isNotEmpty ? r.data['report'] : null;

      _data.assignAll(bodySides);
      _log('delete – now ${bodySides.length} codes remaining');

      await saveToCache();
    } catch (e) {
      _log('delete – error: $e');
    }

    return _data;
  }

  Future<String?> uploadReport(File? file) async {
    _log('uploadReport – POST ${EndPoints.inspections}/$slug/report, file=${file?.path}');
    
    // Don't send null to backend
    if (file == null) {
      _log('uploadReport – no file provided, skipping API call');
      return null;
    }
    
    try {
      final n = Network(
        endpoint: '${EndPoints.inspections}/$slug/report',
        requestMethod: RequestMethod.post,
      );

      n.setBody = FormData({
        'report': MultipartFile(file, filename: file.path.split('/').last),
      });

      final r = await n.response(RoutingUrl.home);
      _log('uploadReport – response status: ${r.hasError ? "ERROR" : "OK"}');

      if (r.data.isNotEmpty) {
        final codes = r.data['codes'];
        if (codes != null) {
          _data.assignAll(OBDCode.setList(codes));
        }
        _report.value = r.data['report'];
        _log('uploadReport – report URL: ${_report.value}, codes: ${_data.length}');
      }
    } on FNetworkException catch (e) {
      _log('uploadReport – FNetworkException: ${e.statusCode}');
      e.notify();
    } catch (e) {
      _log('uploadReport – error: $e');
    }

    await saveToCache();

    return _report.value;
  }

  Future<String?> removeReport() async {
    _log('removeReport – DELETE ${EndPoints.inspections}/$slug/report');
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/report',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      _log('removeReport – response status: ${r.hasError ? "ERROR" : "OK"}');
      _report.value = r.data.isNotEmpty ? r.data['report'] : null;
      _log('removeReport – report after delete: ${_report.value}');
    } on FNetworkException catch (e) {
      _log('removeReport – FNetworkException: ${e.statusCode}');
      e.notify();
    } catch (e) {
      _log('removeReport – error: $e');
    }
    await saveToCache();

    return _report.value;
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[OBD Repo] $message');
    }
  }
}
