import 'dart:async';
import 'dart:io';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/cached_image_key.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
    await flushPending();
    _log('fetchFromApi – GET ${EndPoints.inspections}/$slug/obd-codes');
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/obd-codes');

    final r = await n.response(RoutingUrl.home);

    _log(
      'fetchFromApi – status: ${r.hasError ? "ERROR" : "OK"}, data type: ${r.data.runtimeType}',
    );

    final bodySides = r.data.isNotEmpty
        ? OBDCode.setList(r.data['codes'] ?? [])
        : <OBDCode>[];

    _report.value = r.data.isNotEmpty ? r.data['report'] : null;

    _log(
      'fetchFromApi – parsed ${bodySides.length} codes, report=${_report.value != null}',
    );

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

    // Merge queued-but-not-synced codes so they render in the list with a
    // pending badge, not just as a background task. Each pending entry gets
    // a negative placeholder id so the UI can still show it before the
    // server assigns a real one on flush.
    for (final pending in _pendingCodes()) {
      final code = pending['code']?.toString();
      if (code == null) continue;
      if (result.any((c) => c.code == code)) continue;
      result.add(OBDCode(
        id: -DateTime.now().millisecondsSinceEpoch,
        code: code,
        description: pending['description']?.toString() ?? '',
        isPending: true,
      ));
    }

    _data.assignAll(result);

    // Re-hydrate a queued report so the pending badge + in-app viewer still
    // work after app-kill while offline. The server URL is restored by the
    // next successful fetchFromApi; the pending sentinel takes priority here.
    final pendingPath = pendingReportPath();
    if (pendingPath != null) _report.value = _pendingReportUri(pendingPath);

    return _data;
  }

  @override
  Future<void> saveToCache() async {
    final codes = _data.map((i) => i.toJson()).toList();
    await box.put(slug, codes);
    _log('saveToCache – saved ${codes.length} codes');
  }

  // ── Pending OBD codes (offline-first write) ────────────────────────────────

  String get _pendingKey => 'pending_obd_$slug';

  void _savePendingCode(OBDCode code) {
    final pending = (box.get(_pendingKey) as List?)?.toList() ?? [];
    final alreadyQueued = pending.any((e) => (e as Map)['code'] == code.code);
    if (alreadyQueued) return;
    pending.add({'code': code.code, 'description': code.description});
    box.put(_pendingKey, pending);
    AppLogger.info('[Offline]', 'write obd/$slug/${code.code}: pending=true');
  }

  void _clearPendingCode(String code) {
    final pending = (box.get(_pendingKey) as List?)?.toList() ?? [];
    pending.removeWhere((e) => (e is Map) && e['code'] == code);
    box.put(_pendingKey, pending);
  }

  List<Map<String, dynamic>> _pendingCodes() {
    final raw = box.get(_pendingKey) as List?;
    if (raw == null || raw.isEmpty) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// True if [code] has a pending (unsynced) POST in the local store.
  bool hasPendingCode(String code) =>
      _pendingCodes().any((e) => e['code'] == code);

  /// Retries all OBD codes (writes + deletes) that failed while offline.
  /// Idempotent: safe to call from both the per-controller reconnect worker
  /// and the global [OfflineSyncService] dispatcher.
  Future<void> flushPending() async {
    await _flushPendingWrites();
    await _flushPendingDeletes();
    await _flushPendingReport();
  }

  Future<void> _flushPendingWrites() async {
    final entries = _pendingCodes();
    if (entries.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush obd/$slug: ${entries.length} pending codes',
    );

    for (final entry in entries) {
      final code = entry['code'] as String;
      final n = Network(
        endpoint: '${EndPoints.inspections}/$slug/obd-codes',
        requestMethod: RequestMethod.post,
      );
      n.setBody = {'code': code, 'description': entry['description']};
      try {
        final r = await n.response(RoutingUrl.home);
        final codes = r.data.isNotEmpty
            ? OBDCode.setList(r.data['codes'])
            : <OBDCode>[];
        _report.value = r.data.isNotEmpty ? r.data['report'] : null;
        _data.assignAll(codes);
        await saveToCache();
        _clearPendingCode(code);
        AppLogger.info('[Offline]', 'flush obd/$slug/$code: success');
      } on FNetworkException catch (e) {
        AppLogger.error('[Offline]', 'flush obd/$slug/$code: failed', e);
      } catch (e) {
        _log('flushPendingWrites – error for code=$code: $e');
      }
    }
  }

  // ── Pending OBD deletes (offline-first delete) ─────────────────────────────

  String get _pendingDeleteKey => 'pending_delete_obd_$slug';

  void _savePendingDelete(int codeId) {
    final raw = box.get(_pendingDeleteKey) as List?;
    final pending = raw?.toList() ?? [];
    if (!pending.contains(codeId)) {
      pending.add(codeId);
      box.put(_pendingDeleteKey, pending);
    }
    AppLogger.info('[Offline]', 'delete obd/$slug/code$codeId: pending=true');
  }

  void _clearPendingDelete(int codeId) {
    final raw = box.get(_pendingDeleteKey) as List?;
    if (raw == null) return;
    final pending = raw.toList()..removeWhere((id) => id == codeId);
    box.put(_pendingDeleteKey, pending);
  }

  List<int> _pendingDeletes() {
    final raw = box.get(_pendingDeleteKey) as List?;
    return raw?.map((e) => e as int).toList() ?? [];
  }

  Future<void> _flushPendingDeletes() async {
    final ids = _pendingDeletes();
    if (ids.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush obd/$slug: ${ids.length} pending deletes',
    );

    for (final id in List<int>.from(ids)) {
      final n = Network(
        endpoint: 'inspector/codes/$id',
        requestMethod: RequestMethod.delete,
      );
      try {
        await n.response(RoutingUrl.home);
        _clearPendingDelete(id);
        AppLogger.info('[Offline]', 'flush obd/$slug/delete$id: success');
      } on FNetworkException catch (e) {
        // 404 = already gone on the server — treat as success.
        if (e.statusCode == 404) {
          _clearPendingDelete(id);
          AppLogger.info(
            '[Offline]',
            'flush obd/$slug/delete$id: already gone (404)',
          );
        } else {
          AppLogger.error('[Offline]', 'flush obd/$slug/delete$id: failed', e);
        }
      } catch (e) {
        _log('flushPendingDeletes – error for id=$id: $e');
      }
    }
  }

  // ── Store ───────────────────────────────────────────────────────────────────

  /// Returns true when the POST succeeded and the code is synced with the
  /// server. Returns false when the request failed (offline, timeout, etc.)
  /// — the code remains in the pending queue and `flushPending` retries on
  /// reconnect.
  Future<bool> store(OBDCode code) async {
    _log('store – POST code="${code.code}", desc="${code.description}"');

    // Save before POST so the code survives app-kill while offline.
    _savePendingCode(code);

    // Optimistic UI: append with isPending=true + a negative placeholder id
    // so the row renders immediately. Replaced on successful POST with the
    // server entity (real id, isPending=false).
    if (!_data.any((c) => c.code == code.code)) {
      _data.add(OBDCode(
        id: -DateTime.now().millisecondsSinceEpoch,
        code: code.code,
        description: code.description,
        isPending: true,
      ));
    }

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
      _clearPendingCode(code.code);
      return true;
    } on FNetworkException catch (e) {
      _log('store – FNetworkException: ${e.statusCode} — queued as pending');
      // Optimistic entry stays in _data with isPending=true; flushPending
      // will retry on reconnect and replace it with the server entity.
      return false;
    } catch (e) {
      _log('store – error: $e');
      return false;
    }
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

  /// Deletes an OBD code optimistically. Returns `true` when the DELETE
  /// committed to the server, `false` when it was queued locally for retry
  /// on reconnect (offline, timeout, 5xx). The code is removed from the
  /// local cache in both cases — on failure it stays removed and the
  /// pending-delete queue ensures the server is reconciled later.
  Future<bool> delete(OBDCode code) async {
    _log('delete – DELETE code id=${code.id}');

    // Persist pending marker + optimistic local removal BEFORE the network
    // call so the removal survives app-kill while offline.
    _savePendingDelete(code.id);
    _data.removeWhere((c) => c.id == code.id);
    await saveToCache();

    final n = Network(
      endpoint: 'inspector/codes/${code.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      _log('delete – response status: ${r.hasError ? "ERROR" : "OK"}');

      // Server may echo the full codes list; reconcile when present.
      final bodySides = r.data.isNotEmpty
          ? OBDCode.setList(r.data['codes'] ?? [])
          : <OBDCode>[];
      if (bodySides.isNotEmpty ||
          (r.data is Map && r.data.containsKey('codes'))) {
        _report.value = r.data.isNotEmpty ? r.data['report'] : _report.value;
        _data.assignAll(bodySides);
      }

      await saveToCache();
      _clearPendingDelete(code.id);
      _log('delete – synced, ${_data.length} codes remaining');
      return true;
    } on FNetworkException catch (e) {
      // 404 = already gone on the server; our optimistic removal was correct.
      if (e.statusCode == 404) {
        _clearPendingDelete(code.id);
        _log('delete – 404 already gone, cleared pending');
        return true;
      }
      // Offline or server failure — leave pending queue for reconnect retry.
      _log('delete – FNetworkException: ${e.statusCode} — queued as pending');
      return false;
    } catch (e) {
      _log('delete – error: $e — queued as pending');
      return false;
    }
  }

  /// Uploads the OBD report. On network failure the file is copied to
  /// app-private storage and queued for retry — the caller gets the local
  /// path back so the UI can still display the picked document while it
  /// waits for reconnect.
  ///
  /// Returns the server URL on success, or `pending://<absolute-path>` when
  /// queued offline. Returns null if the caller passed no file.
  Future<String?> uploadReport(File? file) async {
    _log(
      'uploadReport – POST ${EndPoints.inspections}/$slug/report, file=${file?.path}',
    );

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
        _log(
          'uploadReport – report URL: ${_report.value}, codes: ${_data.length}',
        );
        // Clear any prior pending report — this upload replaced it.
        await _clearPendingReport();
        // Warm PDF cache so offline open works without extra round-trip.
        final url = _report.value;
        if (url != null && url.isNotEmpty) {
          _warmReportCache(url);
        }
      }
    } on FNetworkException catch (e) {
      _log(
        'uploadReport – FNetworkException: ${e.statusCode} — queued as pending',
      );
      final localPath = await _savePendingReport(file);
      _report.value = _pendingReportUri(localPath);
      await saveToCache();
      return _report.value;
    } catch (e) {
      _log('uploadReport – error: $e');
    }

    await saveToCache();

    return _report.value;
  }

  // ── Pending OBD report upload (offline-first file queue) ───────────────────
  //
  // The report endpoint is a single-file overwrite, not an append list. To
  // survive offline + app-kill we copy the picked file into app-private
  // storage and persist its path in Hive under `pending_report_$slug`.
  // [_flushPendingReport] retries on reconnect; on success the local copy is
  // deleted and the cache is warmed with the server URL.

  String get _pendingReportKey => 'pending_report_$slug';

  /// Returns the `pending://` sentinel URL that the UI can recognise and
  /// treat as "show the local file while we wait for reconnect".
  String _pendingReportUri(String absolutePath) => 'pending://$absolutePath';

  /// True if a report upload is waiting for reconnect. UI callers use this
  /// to render a pending badge next to the uploaded document.
  bool hasPendingReport() => box.get(_pendingReportKey) != null;

  /// Returns the local file path of a queued report, or null if none.
  String? pendingReportPath() {
    final raw = box.get(_pendingReportKey);
    if (raw is Map) return raw['path']?.toString();
    if (raw is String) return raw;
    return null;
  }

  Future<String> _savePendingReport(File src) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/inspector_reports/$slug');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final originalName = src.path.split(Platform.pathSeparator).last.isNotEmpty
        ? src.path.split(Platform.pathSeparator).last
        : src.path.split('/').last;
    final dest = File('${dir.path}/$originalName');
    await src.copy(dest.path);

    await box.put(_pendingReportKey, {
      'path': dest.path,
      'name': originalName,
      'savedAt': DateTime.now().toIso8601String(),
    });
    AppLogger.info('[Offline]', 'write report/$slug: pending=true');
    return dest.path;
  }

  Future<void> _clearPendingReport() async {
    final raw = box.get(_pendingReportKey);
    if (raw == null) return;
    final path = (raw is Map) ? raw['path']?.toString() : raw.toString();
    if (path != null) {
      try {
        final f = File(path);
        if (f.existsSync()) await f.delete();
      } catch (e) {
        _log('clearPendingReport – delete failed: $e');
      }
    }
    await box.delete(_pendingReportKey);
  }

  Future<void> _flushPendingReport() async {
    final raw = box.get(_pendingReportKey);
    if (raw == null) return;

    final path = (raw is Map) ? raw['path']?.toString() : raw.toString();
    if (path == null) {
      await box.delete(_pendingReportKey);
      return;
    }
    final file = File(path);
    if (!file.existsSync()) {
      AppLogger.warn(
        '[Offline]',
        'flush report/$slug: local file missing — dropping pending entry',
      );
      await box.delete(_pendingReportKey);
      return;
    }

    AppLogger.info('[Offline]', 'flush report/$slug: uploading $path');

    try {
      final n = Network(
        endpoint: '${EndPoints.inspections}/$slug/report',
        requestMethod: RequestMethod.post,
      );
      n.setBody = FormData({
        'report': MultipartFile(file, filename: file.path.split('/').last),
      });
      final r = await n.response(RoutingUrl.home);

      if (r.data.isNotEmpty) {
        final codes = r.data['codes'];
        if (codes != null) _data.assignAll(OBDCode.setList(codes));
        _report.value = r.data['report'];
        await saveToCache();
        final url = _report.value;
        if (url != null && url.isNotEmpty) _warmReportCache(url);
      }
      await _clearPendingReport();
      AppLogger.info('[Offline]', 'flush report/$slug: success');
    } on FNetworkException catch (e) {
      AppLogger.error('[Offline]', 'flush report/$slug: failed', e);
    } catch (e) {
      _log('flushPendingReport – error: $e');
    }
  }

  /// Downloads the uploaded report into [DefaultCacheManager] so that a
  /// subsequent offline open does not need network. Errors are swallowed —
  /// the cache warm-up is best-effort and should never block the caller.
  ///
  /// Keyed by [stableCacheKey] so SAS query rotation doesn't invalidate the
  /// cache on each fetch (controller's openReport() uses the same key).
  void _warmReportCache(String url) {
    unawaited(
      DefaultCacheManager()
          .getSingleFile(url, key: stableCacheKey(url))
          .then(
            (_) {},
            onError: (e) => _log('warmReportCache – failed for $url: $e'),
          ),
    );
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
