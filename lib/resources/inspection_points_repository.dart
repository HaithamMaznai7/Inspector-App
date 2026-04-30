import 'dart:io';
import 'package:fahis_inspector/enums/point_status.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/point.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
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
    await flushPending();
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
    final localImagePath = point.file?.path;

    // Persist before POST so the change survives app-kill while offline.
    _savePendingPoint(point.id, status, point.note, localImagePath);

    // Optimistic local update — UI reflects the change immediately.
    point.setStatus = status;
    updatePoints(point);
    await saveToCache();

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
            contentType: 'image/jpeg',
          ),
      });

      final r = await n.response(RoutingUrl.home);
      point = Point.fromJson(r.data);

      updatePoints(point);
      await saveToCache();
      _clearPendingPoint(point.id);
    } on FNetworkException catch (e) {
      // Leave pending — will retry on reconnect.
      AppLogger.error(
        '[Offline]',
        'write points/$slug/point${point.id}: POST failed',
        e,
      );
      e.notify();
    } catch (e) {
      dd(e);
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

  // ── Pending points (offline-first write) ──────────────────────────────────

  String get _pendingKey => 'pending_points_$slug';

  void _savePendingPoint(
    int pointId,
    PointStatus status,
    String? note,
    String? localImagePath,
  ) {
    final pending = (box.get(_pendingKey) as List?)?.toList() ?? [];
    // Replace existing entry for same point (user changed status again before sync).
    pending.removeWhere((e) => (e is Map) && e['pointId'] == pointId);
    pending.add({
      'pointId': pointId,
      'status': status.value,
      'note': note,
      'localImagePath': localImagePath,
    });
    box.put(_pendingKey, pending);
    AppLogger.info(
      '[Offline]',
      'write points/$slug/point$pointId: pending=true',
    );
  }

  void _clearPendingPoint(int pointId) {
    final pending = (box.get(_pendingKey) as List?)?.toList() ?? [];
    pending.removeWhere((e) => (e is Map) && e['pointId'] == pointId);
    box.put(_pendingKey, pending);
  }

  List<Map<String, dynamic>> _pendingPoints() {
    final raw = box.get(_pendingKey) as List?;
    if (raw == null || raw.isEmpty) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// True if [pointId] has a pending (unsynced) POST in the local store.
  bool hasPendingPoint(int pointId) =>
      _pendingPoints().any((e) => e['pointId'] == pointId);

  /// Retries all point updates that failed while offline.
  Future<void> flushPending() async {
    final entries = _pendingPoints();
    if (entries.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush points/$slug: ${entries.length} pending points',
    );

    for (final entry in entries) {
      final pointId = entry['pointId'] as int;
      final statusValue = entry['status'] as String;
      final note = entry['note'] as String?;
      final localImagePath = entry['localImagePath'] as String?;

      final n = Network(
        endpoint: '${EndPoints.points}/$pointId',
        requestMethod: RequestMethod.post,
      );

      File? imageFile;
      if (localImagePath != null) {
        final f = File(localImagePath);
        if (f.existsSync()) imageFile = f;
      }

      n.setBody = FormData({
        'status': statusValue,
        'note': note,
        if (imageFile != null)
          'image': MultipartFile(
            imageFile,
            filename: imageFile.path.split('/').last,
            contentType: 'image/jpeg',
          ),
      });

      try {
        final r = await n.response(RoutingUrl.home);
        final point = Point.fromJson(r.data);
        updatePoints(point);
        await saveToCache();
        _clearPendingPoint(pointId);
        AppLogger.info('[]', 'flush points/$slug/point$pointId: success');
      } on FNetworkException catch (e) {
        if (e.statusCode >= 400 && e.statusCode < 600) {
          _clearPendingPoint(pointId);
          AppLogger.warn(
            '[]',
            'flush points/$slug/point$pointId: cleared (${e.statusCode})',
          );
        } else {
          AppLogger.error('[]', 'flush points/$slug/point$pointId: failed', e);
        }
      } catch (e) {
        dd('flushPending points error: $e');
      }
    }
  }
}
