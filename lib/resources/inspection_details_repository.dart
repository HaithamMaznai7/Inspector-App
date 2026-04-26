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

/// Represents a detected multi-inspector conflict on the inspection's stage
/// transition. [baselineStage] is the stage we saw when we queued the change;
/// [server] is the live inspection from the API.
class StageConflict {
  final String? pendingStage;
  final String? baselineStage;
  final Inspection server;
  final Map<String, dynamic> payload;

  StageConflict({
    required this.pendingStage,
    required this.baselineStage,
    required this.server,
    required this.payload,
  });
}

class InspectionDetailsRepository extends BaseRepository<Inspection> {
  final Box box;
  final String slug;

  InspectionDetailsRepository({required this.box, required this.slug});

  final Rxn<Inspection> _data = Rxn<Inspection>(null);
  final Rxn<StageConflict> _conflict = Rxn<StageConflict>();

  Stream<Inspection?> get stream => _data.stream;

  /// Emits a [StageConflict] when a pending stage transition can't be
  /// replayed because another inspector moved the stage in the meantime.
  Stream<StageConflict?> get conflictStream => _conflict.stream;

  StageConflict? get currentConflict => _conflict.value;

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

    // Capture the server-side baseline stage BEFORE this mutation so
    // flushPendingStage() can detect conflicts with other inspectors.
    final baselineStage = _data.value?.stage.value;

    // Persist before POST so the stage change survives app-kill while offline.
    _savePendingStage(inspection.stage.value, inspection.note, baselineStage);

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

  void _savePendingStage(
    String? stageValue,
    String? note,
    String? baselineStage,
  ) {
    box.put(_pendingKey, {
      'stage': stageValue,
      'general_notes': note,
      'baselineStage': baselineStage,
    });
    AppLogger.info('[Offline]', 'write stage/$slug: pending=$stageValue');
  }

  void _clearPendingStage() {
    box.delete(_pendingKey);
  }

  /// True if there is a pending (unsynced) stage transition.
  bool hasPendingStage() => box.containsKey(_pendingKey);

  /// Retries the pending stage transition if one exists.
  ///
  /// Conflict-aware: if the server's current stage differs from the baseline
  /// we stored at save-time, another inspector moved the inspection and we
  /// surface a [StageConflict] instead of blindly overwriting.
  Future<void> flushPendingStage() async {
    final raw = box.get(_pendingKey);
    if (raw == null) return;
    final body = Map<String, dynamic>.from(raw as Map);
    final payload = {
      'stage': body['stage'],
      'general_notes': body['general_notes'],
    };
    final baselineStage = body['baselineStage'] as String?;

    if (baselineStage != null) {
      try {
        final check = Network(endpoint: '${EndPoints.inspections}/$slug');
        final sr = await check.response(RoutingUrl.home);
        if (sr.data.isNotEmpty) {
          final server = Inspection.fromJson(sr.data);
          if (server.stage.value != baselineStage) {
            AppLogger.info(
              '[Offline]',
              'flush stage/$slug: conflict — baseline=$baselineStage '
                  'server=${server.stage.value}',
            );
            _conflict.value = StageConflict(
              pendingStage: body['stage'] as String?,
              baselineStage: baselineStage,
              server: server,
              payload: payload,
            );
            return;
          }
        }
      } on FNetworkException catch (e) {
        AppLogger.error('[Offline]', 'flush stage/$slug: pre-check failed', e);
        return;
      } catch (_) {
        // Continue to POST on non-network error; last-writer-wins fallback.
      }
    }

    await _postPendingStage(payload);
  }

  Future<void> _postPendingStage(Map<String, dynamic> payload) async {
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
      AppLogger.error('[Offline]', 'flush stage/$slug: failed', e);
    } catch (e) {
      AppLogger.error('[Offline]', 'flush stage/$slug: error', e);
    }
  }

  /// Resolution: overwrite the server with the queued stage transition.
  Future<void> resolveConflictKeepMine() async {
    final c = _conflict.value;
    if (c == null) return;
    await _postPendingStage(c.payload);
    _conflict.value = null;
  }

  /// Resolution: discard the queued transition and accept the server stage.
  Future<void> resolveConflictUseServer() async {
    final c = _conflict.value;
    if (c == null) return;
    _data.value = c.server;
    await saveToCache();
    _clearPendingStage();
    _conflict.value = null;
  }
}
