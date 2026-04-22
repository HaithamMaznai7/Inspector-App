import 'dart:io';

import 'package:fahis_inspector/common/widgets/camera/image_quality_checker.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection_body_notes.dart';
import 'package:fahis_inspector/models/marker.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
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
    await flushPendingMarkers();
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

  // ── Pending markers (offline-first write) ──────────────────────────────────

  String get _pendingKey => 'pending_body_$slug';

  /// Saves a marker as pending-sync before the POST so it survives app-kill.
  /// Returns a [tempKey] that uniquely identifies this pending entry.
  int _savePendingMarker(int bodyId, Marker note, String? localImagePath) {
    final tempKey = DateTime.now().millisecondsSinceEpoch;
    final pending = box.get(_pendingKey)?.toList() ?? [];
    pending.add({
      'tempKey': tempKey,
      'bodyId': bodyId,
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type,
      'note': note.note,
      'localImagePath': localImagePath,
    });
    box.put(_pendingKey, pending);
    AppLogger.info(
      '[Offline]',
      'write body/$slug/marker$tempKey: pending=true',
    );
    return tempKey;
  }

  void _clearPendingMarker(int tempKey) {
    final pending = box.get(_pendingKey)?.toList() ?? [];
    pending.removeWhere((e) => (e is Map) && e['tempKey'] == tempKey);
    box.put(_pendingKey, pending);
    AppLogger.info(
      '[Offline]',
      'flush body/$slug/marker$tempKey: success — cleared',
    );
  }

  /// Returns pending marker entries that have not yet been POSTed.
  List<Map<String, dynamic>> pendingMarkers() {
    final raw = box.get(_pendingKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Retries all pending markers (writes + deletes). Returns when all have
  /// been attempted. Idempotent: safe to call from both the per-controller
  /// reconnect worker and the global [OfflineSyncService] dispatcher.
  Future<void> flushPendingMarkers() async {
    await _flushPendingWrites();
    await _flushPendingDeletes();
  }

  Future<void> _flushPendingWrites() async {
    final entries = pendingMarkers();
    if (entries.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush body/$slug: ${entries.length} pending markers',
    );

    for (final entry in entries) {
      final tempKey = entry['tempKey'] as int;
      final bodyId = entry['bodyId'] as int;
      final localImagePath = entry['localImagePath'] as String?;

      final n = Network(
        endpoint: '${EndPoints.inspections}/$slug/bodies/$bodyId',
        requestMethod: RequestMethod.post,
      );

      File? imageFile;
      if (localImagePath != null) {
        final f = File(localImagePath);
        if (f.existsSync()) imageFile = f;
      }

      n.setBody = FormData({
        'dx': entry['dx'],
        'dy': entry['dy'],
        'type': entry['type'],
        'note': entry['note'],
        if (imageFile != null)
          'image': MultipartFile(
            imageFile,
            filename: imageFile.path.split('/').last,
            contentType: 'image/jpeg',
          ),
      });

      try {
        final r = await n.response(RoutingUrl.home);
        final bodySides = r.data.isNotEmpty
            ? CarBody.setList(r.data)
            : <CarBody>[];
        _data.assignAll(bodySides);
        await saveToCache();
        _clearPendingMarker(tempKey);
      } on FNetworkException catch (e) {
        AppLogger.error('[Offline]', 'flush body/$slug/marker$tempKey: failed', e);
        // Leave pending — will retry on next reconnect.
      } catch (e) {
        AppLogger.error('[Offline]', 'flush body/$slug/marker$tempKey: error', e);
      }
    }
  }

  // ── Pending marker deletes (offline-first delete) ──────────────────────────

  String get _pendingDeleteKey => 'pending_delete_marker_$slug';

  void _savePendingDelete(int noteId) {
    final raw = box.get(_pendingDeleteKey);
    final pending = raw?.toList() ?? [];
    if (!pending.contains(noteId)) {
      pending.add(noteId);
      box.put(_pendingDeleteKey, pending);
    }
    AppLogger.info(
      '[Offline]',
      'delete body/$slug/marker$noteId: pending=true',
    );
  }

  void _clearPendingDelete(int noteId) {
    final raw = box.get(_pendingDeleteKey);
    if (raw == null) return;
    final pending = raw.toList()..removeWhere((id) => id == noteId);
    box.put(_pendingDeleteKey, pending);
  }

  List<int> _pendingDeletes() {
    final raw = box.get(_pendingDeleteKey);
    return raw?.map((e) => e as int).toList() ?? [];
  }

  /// True if [noteId] has a pending (unsynced) DELETE in the local store.
  bool hasPendingDelete(int noteId) => _pendingDeletes().contains(noteId);

  /// Removes a marker from the in-memory CarBody list by note id.
  void _removeMarkerLocally(int noteId) {
    for (int i = 0; i < _data.length; i++) {
      final body = _data[i];
      if (body.notes.any((m) => m.id == noteId)) {
        body.notes.removeWhere((m) => m.id == noteId);
        _data[i] = body;
      }
    }
  }

  Future<void> _flushPendingDeletes() async {
    final ids = _pendingDeletes();
    if (ids.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush body/$slug: ${ids.length} pending deletes',
    );

    for (final id in List<int>.from(ids)) {
      final n = Network(
        endpoint: '${EndPoints.notes}/$id',
        requestMethod: RequestMethod.delete,
      );
      try {
        final r = await n.response(RoutingUrl.home);
        final bodySides = r.data.isNotEmpty
            ? CarBody.setList(r.data)
            : <CarBody>[];
        if (bodySides.isNotEmpty) _data.assignAll(bodySides);
        await saveToCache();
        _clearPendingDelete(id);
        AppLogger.info('[Offline]', 'flush body/$slug/delete$id: success');
      } on FNetworkException catch (e) {
        // 404 = already gone on the server — treat as success.
        if (e.statusCode == 404) {
          _clearPendingDelete(id);
          AppLogger.info(
            '[Offline]',
            'flush body/$slug/delete$id: already gone (404)',
          );
        } else {
          AppLogger.error(
            '[Offline]',
            'flush body/$slug/delete$id: failed',
            e,
          );
        }
      } catch (e) {
        AppLogger.error('[Offline]', 'flush body/$slug/delete$id: error', e);
      }
    }
  }

  // ── Store (create a new marker) ─────────────────────────────────────────────

  /// Creates a new body note marker. Returns true if immediately synced,
  /// false if saved locally as pending (will sync on next reconnect).
  Future<bool> store(CarBody body, Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/bodies/${body.id}',
      requestMethod: RequestMethod.post,
    );

    final imageFile = note.file != null
        ? await ImageCompressor.compress(note.file!)
        : null;

    // Persist before the network call so data survives app-kill.
    final tempKey = _savePendingMarker(
      body.id,
      note,
      imageFile?.path,
    );

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type,
      'note': note.note,
      if (imageFile != null)
        'image': MultipartFile(
          imageFile,
          filename: imageFile.path.split('/').last,
          contentType: 'image/jpeg',
        ),
    });

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? CarBody.setList(r.data)
          : <CarBody>[];

      _data.assignAll(bodySides);
      _clearPendingMarker(tempKey);
      return true;
    } on FNetworkException {
      // Leave pending — returns false so the controller can show an appropriate
      // "saved locally" message instead of a success toast.
      return false;
    } finally {
      await saveToCache();
    }
  }

  Future<void> update(Marker note) async {
    Network n = Network(
      endpoint: '${EndPoints.notes}/${note.id}',
      requestMethod: RequestMethod.post,
    );

    final imageFile = note.file != null
        ? await ImageCompressor.compress(note.file!)
        : null;

    n.setBody = FormData({
      'dx': note.dx,
      'dy': note.dy,
      'type': note.type,
      'note': note.note,
      if (imageFile != null)
        'image': MultipartFile(
          imageFile,
          filename: imageFile.path.split('/').last,
          contentType: 'image/jpeg',
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
      rethrow;
    } finally {
      await saveToCache();
    }
  }

  /// Deletes a marker optimistically. Returns `true` when the DELETE
  /// committed or the server already lacked the marker (404); returns
  /// `false` when the operation was queued locally for retry on reconnect.
  /// The marker is removed from the local cache in both cases — on failure
  /// it stays removed and the pending-delete queue ensures the server is
  /// reconciled later.
  Future<bool> delete(Marker note) async {
    // Persist pending marker + optimistic local removal BEFORE the network
    // call so the removal survives app-kill while offline.
    _savePendingDelete(note.id);
    _removeMarkerLocally(note.id);
    await saveToCache();

    final n = Network(
      endpoint: '${EndPoints.notes}/${note.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);

      final bodySides = r.data.isNotEmpty
          ? CarBody.setList(r.data)
          : <CarBody>[];

      if (bodySides.isNotEmpty) _data.assignAll(bodySides);
      await saveToCache();
      _clearPendingDelete(note.id);
      return true;
    } on FNetworkException catch (e) {
      // 404 = already gone on the server; our optimistic removal was correct.
      if (e.statusCode == 404) {
        _clearPendingDelete(note.id);
        return true;
      }
      // Offline or server failure — leave pending queue for reconnect retry.
      return false;
    } catch (e) {
      dd('delete marker error: $e');
      return false;
    }
  }
}
