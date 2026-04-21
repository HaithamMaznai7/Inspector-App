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

class VehicleDetailsRepository extends BaseRepository<VehicleDetails> {
  final Box box;
  final String slug;

  VehicleDetailsRepository({required this.box, required this.slug});

  final Rxn<VehicleDetails> _data = Rxn<VehicleDetails>();

  Stream<VehicleDetails?> get stream => _data.stream;

  @override
  Future<VehicleDetails?> fetchFromApi() async {
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

    // Persist before POST so the change survives app-kill while offline.
    _savePendingUpdate(jsonBody);

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

  void _savePendingUpdate(Map<String, dynamic> body) {
    box.put(_pendingKey, body);
    AppLogger.info('[Offline]', 'write vehicle/$slug: pending=true');
  }

  void _clearPendingUpdate() {
    box.delete(_pendingKey);
  }

  /// True if there is a pending (unsynced) vehicle details update.
  bool hasPendingUpdate() => box.containsKey(_pendingKey);

  /// Retries the pending vehicle details update if one exists.
  Future<void> flushPending() async {
    final raw = box.get(_pendingKey);
    if (raw == null) return;
    final body = Map<String, dynamic>.from(raw as Map);
    AppLogger.info('[Offline]', 'flush vehicle/$slug: retrying pending update');

    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/details',
      requestMethod: RequestMethod.post,
    );
    n.setBody = body;

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
}
