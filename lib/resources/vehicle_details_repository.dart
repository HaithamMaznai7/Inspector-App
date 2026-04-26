import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Represents a detected multi-inspector conflict on the vehicle payload:
/// [baseline] is what the local device saw before it queued [payload],
/// [server] is what the server reports now. When [baseline] != [server]
/// another inspector modified the record while we were offline.
class VehicleConflict {
  final Map<String, dynamic> payload;
  final VehicleDetails baseline;
  final VehicleDetails server;

  VehicleConflict({
    required this.payload,
    required this.baseline,
    required this.server,
  });
}

class VehicleDetailsRepository extends BaseRepository<VehicleDetails> {
  final Box box;
  final String slug;

  VehicleDetailsRepository({required this.box, required this.slug});

  final Rxn<VehicleDetails> _data = Rxn<VehicleDetails>();
  final Rxn<VehicleConflict> _conflict = Rxn<VehicleConflict>();

  Stream<VehicleDetails?> get stream => _data.stream;

  /// Emits a [VehicleConflict] whenever [flushPending] detects that the
  /// server moved between the time we queued the pending update and the
  /// time we tried to push it. Controllers listen and surface a dialog.
  Stream<VehicleConflict?> get conflictStream => _conflict.stream;

  VehicleConflict? get currentConflict => _conflict.value;

  @override
  Future<VehicleDetails?> fetchFromApi() async {
    await flushPending();
    try {
      final n = Network(endpoint: '${EndPoints.inspections}/$slug/details');

      final r = await n.response(RoutingUrl.home);

      final details = r.data != null ? VehicleDetails.fromJson(r.data) : null;

      _data.value = details;

      await saveToCache();
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    }

    return _data.value;
  }

  @override
  VehicleDetails? fetchFromCache() {
    final data = box.get(slug);

    if (data != null && data is Map) {
      return VehicleDetails.fromJson(data);
    }

    return null;
  }

  @override
  Future<void> saveToCache() async {
    await box.put(slug, _data.value?.toJson());
  }

  Future<bool> update(String slug, VehicleDetails body) async {
    /// connect with the network
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/details',
      requestMethod: RequestMethod.post,
    );

    // Defensive null-safety: strip null entries entirely.
    // DO NOT convert nulls to '' — foreign-key fields like body_type_id,
    // cylinders_no, seats_no cause SQL constraint violations (SQLSTATE 23000)
    // when the backend receives an empty string instead of null/absent.
    final jsonBody = body.toJson();
    jsonBody.removeWhere((key, value) => value == null || value == '');

    dd('[VehicleDetails] POST body: $jsonBody');

    // Capture the pre-edit server state as a baseline BEFORE the optimistic
    // mutation so the conflict check in flushPending() can tell whether any
    // other inspector changed the record while we were offline.
    final baseline = _data.value;

    // Persist before POST so the change survives app-kill while offline.
    _savePendingUpdate(jsonBody, baseline);

    // Optimistic local cache update.
    _data.value = body;
    await saveToCache();

    n.setBody = jsonBody;

    try {
      CustomResponse r = await n.response(RoutingUrl.home);
      if (!r.hasError) {
        _clearPendingUpdate();
        FLoader.successSnackBar(message: 'Saved');
      }
      return !r.hasError;
    } on FNetworkException {
      // Leave pending for transport failures — will retry on reconnect.
      // Rethrow so the controller can handle 422 validation errors.
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // ── Pending vehicle details (offline-first write) ─────────────────────────

  String get _pendingKey => 'pending_vehicle_$slug';

  void _savePendingUpdate(
    Map<String, dynamic> body,
    VehicleDetails? baseline,
  ) {
    box.put(_pendingKey, {
      'payload': body,
      'baseline': baseline?.toJson(),
      'savedAt': DateTime.now().toIso8601String(),
    });
    AppLogger.info('[Offline]', 'write vehicle/$slug: pending=true');
  }

  void _clearPendingUpdate() {
    box.delete(_pendingKey);
  }

  /// True if there is a pending (unsynced) vehicle details update.
  bool hasPendingUpdate() => box.containsKey(_pendingKey);

  /// Retries the pending vehicle details update if one exists.
  ///
  /// Conflict-aware: before pushing, we GET the current server state and
  /// compare it to the baseline we captured at save-time. If another
  /// inspector moved the record, we surface a [VehicleConflict] via
  /// [conflictStream] and leave the pending entry intact until the user
  /// resolves it via [resolveConflictKeepMine] / [resolveConflictUseServer].
  Future<void> flushPending() async {
    final raw = box.get(_pendingKey);
    if (raw == null) return;

    // Backward-compat: old entries were stored as the raw payload map.
    final stored = Map<String, dynamic>.from(raw as Map);
    Map<String, dynamic> payload;
    VehicleDetails? baseline;
    if (stored.containsKey('payload')) {
      payload = Map<String, dynamic>.from(stored['payload'] as Map);
      final b = stored['baseline'];
      if (b is Map) {
        baseline = VehicleDetails.fromJson(Map<String, dynamic>.from(b));
      }
    } else {
      payload = stored;
    }

    // Conflict check — skip if we have no baseline to compare against.
    if (baseline != null) {
      try {
        final check = Network(
          endpoint: '${EndPoints.inspections}/$slug/details',
        );
        final sr = await check.response(RoutingUrl.home);
        final server = sr.data != null
            ? VehicleDetails.fromJson(sr.data)
            : null;
        if (server != null && server != baseline) {
          AppLogger.info(
            '[Offline]',
            'flush vehicle/$slug: conflict detected — awaiting user',
          );
          _conflict.value = VehicleConflict(
            payload: payload,
            baseline: baseline,
            server: server,
          );
          return;
        }
      } on FNetworkException catch (e) {
        AppLogger.error(
          '[Offline]',
          'flush vehicle/$slug: pre-check failed',
          e,
        );
        return; // still offline — retry on next reconnect
      } catch (_) {
        // Continue to POST on non-network error; last-writer-wins fallback.
      }
    }

    await _postPending(payload);
  }

  Future<void> _postPending(Map<String, dynamic> payload) async {
    AppLogger.info('[Offline]', 'flush vehicle/$slug: retrying pending update');
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/details',
      requestMethod: RequestMethod.post,
    );
    n.setBody = payload;

    try {
      final r = await n.response(RoutingUrl.home);
      if (!r.hasError) {
        if (r.data != null) {
          _data.value = VehicleDetails.fromJson(r.data);
          await saveToCache();
        }
        _clearPendingUpdate();
        AppLogger.info('[Offline]', 'flush vehicle/$slug: success');
      }
    } on FNetworkException catch (e) {
      AppLogger.error('[Offline]', 'flush vehicle/$slug: failed', e);
    } catch (e) {
      dd('flushPending vehicle error: $e');
    }
  }

  /// Resolution: user chose to overwrite the server with their pending
  /// payload. Posts the stored payload and clears the conflict.
  Future<void> resolveConflictKeepMine() async {
    final c = _conflict.value;
    if (c == null) return;
    await _postPending(c.payload);
    _conflict.value = null;
  }

  /// Resolution: user chose to discard their pending edits and accept the
  /// server's copy. Updates the local cache to server state and drops the
  /// pending queue.
  Future<void> resolveConflictUseServer() async {
    final c = _conflict.value;
    if (c == null) return;
    _data.value = c.server;
    await saveToCache();
    _clearPendingUpdate();
    _conflict.value = null;
  }
}
