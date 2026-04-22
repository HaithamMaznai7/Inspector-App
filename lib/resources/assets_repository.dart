import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssetsRepository {
  final Box<List> assets;

  AssetsRepository(this.assets);

  // ── Offline guard ──────────────────────────────────────────────────────────
  // Reference / lookup endpoints are not retry-safe offline (no pending queue),
  // so every fetch short-circuits when offline to:
  //   1. Stop spamming the log with expected network failures
  //   2. Let the stream close cleanly with the cached value as its last emit
  bool get _isOnline => ConnectionService.instance.isConnectionGood.value;

  static Stream<List<City>> getCities() async* {
    List<City> cities = [];
    yield cities;

    if (!ConnectionService.instance.isConnectionGood.value) return;

    try {
      Network network = Network(endpoint: EndPoints.cities);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;

        cities = data.map((e) => City.fromJson(e)).whereType<City>().toList();
      }
    } catch (e) {
      dd('Error fetching cities: $e');
    }
    yield cities;
  }

  Stream<List<Selection>> fuelTypes() =>
      _fetchSelection('Assets-FuelTypes', EndPoints.fuelTypes, 'fuel types');

  Stream<List<Selection>> seatTypes() =>
      _fetchSelection('Assets-SeatTypes', EndPoints.seatTypes, 'seat types');

  Stream<List<Selection>> cylinderNumbers() => _fetchSelection(
        'Assets-CylinderNumbers',
        EndPoints.cylinderNumbers,
        'cylinder numbers',
      );

  Stream<List<Selection>> bodyTypes() =>
      _fetchSelection('Assets-BodyTypes', EndPoints.bodyTypes, 'body types');

  Stream<List<Selection>> drivetrainTypes() => _fetchSelection(
        'Assets-DrivetrainTypes',
        EndPoints.drivetrainTypes,
        'drivetrain types',
      );

  Stream<List<Selection>> gasolineTypes() => _fetchSelection(
        'Assets-GasolineTypes',
        EndPoints.gasolineTypes,
        'gasoline types',
      );

  Stream<List<Selection>> gearboxTypes() => _fetchSelection(
        'Assets-GearboxTypes',
        EndPoints.gearboxTypes,
        'gearbox types',
      );

  Stream<List<Selection>> seatNumbers() => _fetchSelection(
        'Assets-SeatNumbers',
        EndPoints.seatNumbers,
        'seat numbers',
      );

  Stream<List<Selection>> bodyNoteTypes() => _fetchSelection(
        'Assets-BodyNoteTypes',
        EndPoints.bodyNoteTypes,
        'body note types',
      );

  // ── Shared stream helper ───────────────────────────────────────────────────
  // Yields cached value first so the UI renders immediately, then short-
  // circuits when offline, otherwise refreshes from API and yields the fresh
  // value. One place owns the shape — no more copy-paste drift.
  Stream<List<Selection>> _fetchSelection(
    String cacheKey,
    String endpoint,
    String label,
  ) async* {
    final cached = assets.get(cacheKey, defaultValue: []) ?? [];
    yield cached.map<Selection>((e) => Selection.fromJson(e)).toList();

    if (!_isOnline) return;

    try {
      final response = await Network(endpoint: endpoint).response(
        RoutingUrl.home,
      );
      if (!response.hasError) {
        final List data = response.data;
        assets.put(cacheKey, data);
        yield data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }
    } catch (e) {
      dd('Error fetching $label: $e');
    }
  }

  // ── Prefetch ───────────────────────────────────────────────────────────────
  // Populates all asset caches in parallel. Called by [OfflineSyncService] on
  // first online boot / reconnect so users who installed offline can use the
  // Vehicle Details dropdowns without opening the screen first.
  //
  // `eagerError: false` so one failing endpoint doesn't cancel the rest.
  // Skipped entirely when every cache key already has data — caches have no
  // TTL today, so "populated" is treated as "fresh".
  Future<void> prefetchAll() async {
    if (!_isOnline) return;

    const cacheKeys = [
      'Assets-FuelTypes',
      'Assets-SeatTypes',
      'Assets-CylinderNumbers',
      'Assets-BodyTypes',
      'Assets-DrivetrainTypes',
      'Assets-GasolineTypes',
      'Assets-GearboxTypes',
      'Assets-SeatNumbers',
      'Assets-BodyNoteTypes',
    ];
    final allPopulated = cacheKeys.every((k) {
      final v = assets.get(k);
      return v is List && v.isNotEmpty;
    });
    if (allPopulated) return;

    await Future.wait([
      _prefetchOne('Assets-FuelTypes', EndPoints.fuelTypes, 'fuel types'),
      _prefetchOne('Assets-SeatTypes', EndPoints.seatTypes, 'seat types'),
      _prefetchOne(
        'Assets-CylinderNumbers',
        EndPoints.cylinderNumbers,
        'cylinder numbers',
      ),
      _prefetchOne('Assets-BodyTypes', EndPoints.bodyTypes, 'body types'),
      _prefetchOne(
        'Assets-DrivetrainTypes',
        EndPoints.drivetrainTypes,
        'drivetrain types',
      ),
      _prefetchOne(
        'Assets-GasolineTypes',
        EndPoints.gasolineTypes,
        'gasoline types',
      ),
      _prefetchOne(
        'Assets-GearboxTypes',
        EndPoints.gearboxTypes,
        'gearbox types',
      ),
      _prefetchOne(
        'Assets-SeatNumbers',
        EndPoints.seatNumbers,
        'seat numbers',
      ),
      _prefetchOne(
        'Assets-BodyNoteTypes',
        EndPoints.bodyNoteTypes,
        'body note types',
      ),
    ], eagerError: false);
  }

  Future<void> _prefetchOne(
    String cacheKey,
    String endpoint,
    String label,
  ) async {
    try {
      final response = await Network(endpoint: endpoint).response(
        RoutingUrl.home,
      );
      if (!response.hasError) {
        await assets.put(cacheKey, response.data as List);
      }
    } catch (e) {
      dd('Error prefetching $label: $e');
    }
  }
}
