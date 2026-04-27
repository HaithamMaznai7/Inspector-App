import 'package:fahis_inspector/models/book.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fahis_inspector/routes.dart';

class InspectionDetailsRepository extends BaseRepository<Inspection> {
  final Box box;
  final String slug;

  InspectionDetailsRepository({required this.box, required this.slug});

  final Rxn<Inspection> _data = Rxn<Inspection>(null);

  Stream<Inspection?> get stream => _data.stream;

  Stream<Inspection?> get() async* {
    // 1. Yield cached data first
    yield fetchFromCache();

    // 2. Fetch fresh data from API
    try {
      yield await fetchFromApi();
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      yield* stream;
    }
  }

  @override
  Future<Inspection?> fetchFromApi() async {
    await flushPendingStage();
    Network n = Network(endpoint: '${EndPoints.inspections}/$slug');

    CustomResponse r = await n.response(RoutingUrl.home);

    try {
      Inspection? inspection;

      if (r.data.isNotEmpty) {
        inspection = Inspection.fromJson(r.data);
      }

      // dd(inspections);
      _data.value = inspection; // تحديث الحالة

      await saveToCache();

      return _data.value;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  //جلب من الكاش
  @override
  Inspection? fetchFromCache() {
    final raw = box.get('inspection');
    if (raw == null) return null;
    try {
      return Inspection.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveToCache() async {
    if (_data.value == null) return;
    await box.put('inspection', _data.value!.toJson());
  }

  Future<Book?> getBook() async {
    /// connect with the network
    Network n = Network(endpoint: 'inspector/inspections/$slug/book');

    /// get the response
    CustomResponse? r = await n.response(RoutingUrl.home);
    Book? book;

    /// if there is not any error
    if (r.data != null && r.data['data'] is Map<String, dynamic>) {
      book = Book.fromJson(r.data['data']);
    }

    return book;
  }

  Future<Book?> setBook({Book? book}) async {
    /// connect with the network
    Network n = Network(
      endpoint: 'inspector/inspections/$slug/book/update',
      requestMethod: RequestMethod.post,
    );
    // Defensive null-safety: replace null values with empty strings
    Map body = {
      'owner': {
        'name': _data.value?.customer?.name ?? '',
        'mobile': _data.value?.customer?.phone ?? '',
        'city': _data.value?.customer?.city?.id ?? '',
      },
      'center': book?.branch?.id ?? '',
      'inspector': book?.inspector?.id ?? '',
      'date': book?.date != null
          ? EFormatter.formattedWithTimezone(book!.date!)
          : '',
    };
    n.setBody = body;

    /// get the response
    CustomResponse r = await n.response(RoutingUrl.home);

    /// if there is not any error
    if (!r.hasError) {
      /// store the data in the variable
      book = Book.fromJson(r.data['data']);
    }
    return book;
  }

  static Future<Inspection> setStatus({
    required Inspection inspection,
    String? status,
    String? note,
  }) async {
    /// connect with the network
    Network n = Network(
      endpoint: '${EndPoints.inspections}/${inspection.slug}/change-status',
      requestMethod: RequestMethod.post,
    );
    Map<String, dynamic> body = {};

    if (status != null) body['status'] = status;
    if (note != null) body['note'] = note;

    n.setBody = body;

    /// get the response
    CustomResponse? r = await n.response(RoutingUrl.home);
    if (!r.hasError && r.data != null) {
      inspection.setDetails(r.data['data']);
    }

    return inspection;

    /// if there is not any error
  }

  Future<Inspection> update(Inspection inspection) async {
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug',
      requestMethod: RequestMethod.post,
    );

    n.setBody = {
      'stage': inspection.stage.value,
      'general_notes': inspection.note,
    };

    // Persist before POST so the stage change survives app-kill while offline.
    _savePendingStage(inspection.stage.value, inspection.note);

    try {
      CustomResponse r = await n.response(RoutingUrl.inspections);

      if (r.data.isNotEmpty) {
        inspection = Inspection.fromJson(r.data);
        _data.value = inspection;
      }

      await saveToCache();
      _clearPendingStage();
    } on FNetworkException {
      // Leave pending for transport failures — will retry on reconnect.
      rethrow;
    } catch (_) {
      rethrow;
    }

    return _data.value ?? inspection;
  }

  // ── Pending stage transition (offline-first write) ────────────────────────

  String get _pendingKey => 'pending_stage_$slug';

  void _savePendingStage(String? stageValue, String? note) {
    box.put(_pendingKey, {'stage': stageValue, 'general_notes': note});
    AppLogger.info('[Offline]', 'write stage/$slug: pending=$stageValue');
  }

  void _clearPendingStage() {
    box.delete(_pendingKey);
  }

  /// True if there is a pending (unsynced) stage transition.
  bool hasPendingStage() => box.containsKey(_pendingKey);

  /// Retries the pending stage transition if one exists.
  /// Last-writer-wins: no client-side conflict detection.
  Future<void> flushPendingStage() async {
    final raw = box.get(_pendingKey);
    if (raw == null) return;
    final body = Map<String, dynamic>.from(raw as Map);
    final payload = {
      'stage': body['stage'],
      'general_notes': body['general_notes'],
    };

    AppLogger.info(
      '[Offline]',
      'flush stage/$slug: retrying stage=${payload['stage']}',
    );
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug',
      requestMethod: RequestMethod.post,
    );
    n.setBody = payload;

    try {
      final r = await n.response(RoutingUrl.inspections);
      if (r.data.isNotEmpty) {
        final inspection = Inspection.fromJson(r.data);
        _data.value = inspection;
        await saveToCache();
      }
      _clearPendingStage();
      AppLogger.info('[Offline]', 'flush stage/$slug: success');
    } on FNetworkException catch (e) {
      final code = e.statusCode;
      if (code == 0) {
        // No connection — keep pending so it retries on reconnect.
        AppLogger.error('[Offline]', 'flush stage/$slug: no connection', e);
        return;
      }
      // Any other error (4xx, 5xx, or unexpected): drop pending and pull
      // fresh server state so the UI doesn't stay stuck on "will sync".
      AppLogger.error(
        '[Offline]',
        'flush stage/$slug: flush failed (HTTP $code) — dropping pending',
        e,
      );
      _clearPendingStage();
      try {
        final fresh = Network(endpoint: '${EndPoints.inspections}/$slug');
        final r2 = await fresh.response(RoutingUrl.home);
        if (r2.data.isNotEmpty) {
          _data.value = Inspection.fromJson(r2.data);
          await saveToCache();
        }
      } catch (_) {
        /* best-effort refresh */
      }
    } catch (e) {
      AppLogger.error('[Offline]', 'flush stage/$slug: error', e);
    }
  }
}
