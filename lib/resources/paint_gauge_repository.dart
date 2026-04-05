import 'package:fahis_inspector/models/paint_gauge_result.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local persistence for paint gauge session data.
///
/// Stores [PaintGaugeResult] in Hive under the inspection slug.
/// Backend API integration will be added when the endpoint is ready.
class PaintGaugeRepository {
  static const String boxKey = 'PaintGauge';

  final Box box;
  final String slug;

  PaintGaugeRepository({required this.box, required this.slug});

  /// Persist the full session result to Hive.
  Future<void> saveToCache(PaintGaugeResult result) async {
    await box.put(slug, result.toJson());
    AppLogger.info('PaintGaugeRepo', 'Saved to cache for $slug');
  }

  /// Read cached result for this inspection, or null if none.
  PaintGaugeResult? fetchFromCache() {
    final raw = box.get(slug);
    if (raw == null) return null;
    try {
      return PaintGaugeResult.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      AppLogger.error('PaintGaugeRepo', 'Failed to parse cache for $slug', e);
      return null;
    }
  }

  /// Remove cached data for this inspection.
  Future<void> clearCache() async {
    await box.delete(slug);
  }

  // TODO: Backend integration — submit result to API
  // Future<void> submitToApi(PaintGaugeResult result) async {
  //   final n = Network(
  //     endpoint: '${EndPoints.inspections}/$slug/paint-gauge',
  //     requestMethod: RequestMethod.post,
  //   );
  //   n.setBody = FormData(result.toJson());
  //   await n.response(RoutingUrl.home);
  // }
}
