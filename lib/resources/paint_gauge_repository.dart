import 'package:fahis_inspector/models/paint_panel.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persistence + API layer for paint gauge panel data.
///
/// Backend is the source of truth. Session readings are ephemeral
/// and never stored here — only the backend panel state is cached.
class PaintGaugeRepository {
  static const String boxKey = 'PaintGauge';
  static const _tag = 'PaintGaugeRepo';

  final Box box;
  final String slug;

  PaintGaugeRepository({required this.box, required this.slug});

  String get _cacheKey => 'panels_$slug';

  // ── GET panels from API ──────────────────────────────────────────────────

  Future<List<PaintPanel>> fetchPanelsFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/paints');
    final r = await n.response(RoutingUrl.home);

    // Backend wraps the panel list in {"data": {"data": [...]}}
    // r.data is the outer "data" Map, so r.data['data'] is the actual List.
    final rawList = (r.data is Map) ? r.data['data'] : r.data;

    final List<PaintPanel> panels = [];
    if (rawList is List && rawList.isNotEmpty) {
      for (final item in rawList) {
        try {
          panels.add(
            PaintPanel.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        } catch (e) {
          AppLogger.error(_tag, 'Failed to parse panel from API', e);
        }
      }
    }

    await savePanelsToCache(panels);
    AppLogger.info(_tag, 'Fetched ${panels.length} panels from API');
    return panels;
  }

  // ── POST a single panel update ───────────────────────────────────────────

  Future<void> updatePanel(
    PaintPanel panel, {
    required double thickness,
    required String substrate,
    required int measurementCount,
  }) async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/paints/${panel.id}',
      requestMethod: RequestMethod.post,
    );
    n.setBody = {
      'thickness': thickness,
      'substrate': substrate,
      'measurementCount': measurementCount,
    };

    await n.response(RoutingUrl.home);

    // Update cached panel after successful POST
    panel.thickness = thickness;
    panel.substrate = substrate;
    panel.measurementCount = measurementCount;
    await _updateCachedPanel(panel);

    AppLogger.info(
      _tag,
      'POST success: panel ${panel.name} → $thickness μm ($substrate, $measurementCount readings)',
    );
  }

  // ── Cache: full panel list ───────────────────────────────────────────────

  Future<void> savePanelsToCache(List<PaintPanel> panels) async {
    await box.put(_cacheKey, panels.map((p) => p.toJson()).toList());
  }

  List<PaintPanel> fetchPanelsFromCache() {
    final raw = box.get(_cacheKey);
    if (raw == null) return [];

    final List<PaintPanel> result = [];
    for (final item in raw as List) {
      try {
        result.add(PaintPanel.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (e) {
        AppLogger.error(_tag, 'Failed to parse cached panel', e);
      }
    }
    return result;
  }

  // ── Cache: update single panel ───────────────────────────────────────────

  Future<void> _updateCachedPanel(PaintPanel updated) async {
    final panels = fetchPanelsFromCache();
    final idx = panels.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      panels[idx] = updated;
      await savePanelsToCache(panels);
    }
  }

  // ── Cache: clear ─────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    await box.delete(_cacheKey);
    // Also clear legacy cache key if it exists (from old PaintGaugeResult)
    await box.delete(slug);
  }

  // ── Reading slots cache (user's own individual readings) ────────────────

  String get _readingsCacheKey => 'readings_$slug';

  /// Save individual reading values for all panels that have been measured.
  /// Format: {backendId: {readings: [double], substrate: String?, pending: bool}}
  Future<void> saveReadingsCache(Map<int, Map<String, dynamic>> data) async {
    await box.put(_readingsCacheKey, data);
  }

  /// Toggle the "pending sync" flag for a single panel entry.
  Future<void> setPanelPending(int backendId, bool pending) async {
    final data = loadReadingsCache();
    final entry = data[backendId];
    if (entry == null) return;
    entry['pending'] = pending;
    data[backendId] = entry;
    await box.put(_readingsCacheKey, data);
  }

  /// IDs of panels whose cached readings have not yet synced to backend.
  List<int> pendingPanelIds() {
    final data = loadReadingsCache();
    return [
      for (final e in data.entries)
        if (e.value['pending'] == true) e.key,
    ];
  }

  /// Load cached individual readings. Returns empty map if nothing cached.
  Map<int, Map<String, dynamic>> loadReadingsCache() {
    final raw = box.get(_readingsCacheKey);
    if (raw == null) return {};
    try {
      return Map<int, Map<String, dynamic>>.from(
        (raw as Map).map(
          (k, v) => MapEntry(
            k is int ? k : int.parse(k.toString()),
            Map<String, dynamic>.from(v as Map),
          ),
        ),
      );
    } catch (e) {
      AppLogger.error(_tag, 'Failed to parse readings cache', e);
      return {};
    }
  }

  /// Clear cached readings for a single panel.
  Future<void> clearReadingForPanel(int backendId) async {
    final data = loadReadingsCache();
    data.remove(backendId);
    await box.put(_readingsCacheKey, data);
  }

  /// Clear all cached readings for this inspection.
  Future<void> clearReadingsCache() async {
    await box.delete(_readingsCacheKey);
  }

  // ── Saved BLE device (for auto-connect) ─────────────────────────────────

  static const _lastDeviceMacKey = 'last_device_mac';
  static const _lastDeviceNameKey = 'last_device_name';

  Future<void> saveLastDevice(String mac, String name) async {
    await box.put(_lastDeviceMacKey, mac);
    await box.put(_lastDeviceNameKey, name);
  }

  String? get lastDeviceMac => box.get(_lastDeviceMacKey) as String?;
  String? get lastDeviceName => box.get(_lastDeviceNameKey) as String?;
}
