import 'dart:async';

import 'package:fahis_inspector/resources/assets_repository.dart';
import 'package:fahis_inspector/resources/inspection_body_repository.dart';
import 'package:fahis_inspector/resources/inspection_details_repository.dart';
import 'package:fahis_inspector/resources/inspection_obd_repository.dart';
import 'package:fahis_inspector/resources/inspection_photos_repository.dart';
import 'package:fahis_inspector/resources/inspection_points_repository.dart';
import 'package:fahis_inspector/resources/paint_gauge_repository.dart';
import 'package:fahis_inspector/resources/vehicle_details_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Global coordinator that drains every inspection's pending offline writes
/// whenever connectivity returns — regardless of which screen is active.
///
/// Without this, flushes only fire inside editor controllers (Points, Body,
/// Photos, OBD, Vehicle, Paint). A user sitting on Home or the Details screen
/// when the network comes back would see their offline edits linger in Hive
/// until they opened the Steps screen. This service closes that gap.
///
/// The per-controller `ever(onReconnect)` workers are kept in place as a
/// belt-and-suspenders redundancy for V1 — they're idempotent with the global
/// flush and guard against double-POSTs via each repo's pending-entry removal.
class OfflineSyncService extends GetxController {
  static OfflineSyncService get instance =>
      Get.find<OfflineSyncService>(tag: BindingTags.offlineSync);

  static const _tag = 'OfflineSync';

  /// True while [flushAll] is running. UI components bind to this to show a
  /// sync banner ("Syncing offline changes...").
  final RxBool isSyncing = false.obs;

  /// Total pending writes across all slugs and queues. Drives badge counts.
  final RxInt pendingCount = 0.obs;

  Worker? _reconnectWorker;

  @override
  void onInit() {
    super.onInit();
    _reconnectWorker = ever(ConnectionService.instance.onReconnect, (_) {
      flushAll();
      _prefetchAssets();
    });
    // Seed the count so any UI bound to it renders the correct initial state.
    refreshPendingCount();
    // Populate reference-data caches for offline-first users.
    _prefetchAssets();
  }

  @override
  void onClose() {
    _reconnectWorker?.dispose();
    super.onClose();
  }

  // ── Slug enumeration ──────────────────────────────────────────────────────

  /// Reads all slugs the user has ever cached from the per-user inspections
  /// list box. Returns an empty list if the user is unauthenticated or the
  /// box has never been written.
  Future<List<String>> _enumerateSlugs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    try {
      final listBox = await Hive.openBox<Map>('Inspections_User_$uid');
      final raw = listBox.get(
        'Inspections_User_$uid',
        defaultValue: <dynamic, dynamic>{},
      );
      if (raw is! Map) return [];
      return raw.keys.map((e) => e.toString()).toList();
    } catch (e) {
      AppLogger.error(_tag, 'enumerateSlugs failed', e);
      return [];
    }
  }

  // ── Pending count (for UI badges) ─────────────────────────────────────────

  /// Scans every slug's queues and updates [pendingCount]. Safe to call
  /// repeatedly — purely a read.
  Future<void> refreshPendingCount() async {
    try {
      final slugs = await _enumerateSlugs();
      int count = 0;

      for (final slug in slugs) {
        final inspectionBox = await Hive.openBox('Inspection_$slug');
        if (inspectionBox.containsKey('pending_vehicle_$slug')) count++;
        if (inspectionBox.containsKey('pending_stage_$slug')) count++;

        final assets = await Hive.openBox<List>(slug);
        for (final key in [
          'pending_points_$slug',
          'pending_body_$slug',
          'pending_photos_$slug',
          'pending_obd_$slug',
          // Delete queues — parallel to the write queues above.
          'pending_delete_obd_$slug',
          'pending_delete_photo_$slug',
          'pending_delete_marker_$slug',
        ]) {
          final raw = assets.get(key);
          if (raw is List) count += raw.length;
        }
      }

      final paintBox = await Hive.openBox(PaintGaugeRepository.boxKey);
      for (final slug in slugs) {
        final readingsRaw = paintBox.get('readings_$slug');
        if (readingsRaw is Map) {
          for (final v in readingsRaw.values) {
            if (v is Map && v['pending'] == true) count++;
          }
        }
      }

      pendingCount.value = count;
    } catch (e) {
      AppLogger.error(_tag, 'refreshPendingCount failed', e);
    }
  }

  // ── Flush ─────────────────────────────────────────────────────────────────

  /// Walks every cached slug and calls `flushPending` on each per-resource
  /// repository. Each repo's flush is idempotent — no-op when nothing queued,
  /// leaves the queue intact on network failure so the next reconnect retries.
  ///
  /// Guarded by [isSyncing] so concurrent triggers (onReconnect + app-resume
  /// firing near-simultaneously) don't double-run.
  Future<void> flushAll() async {
    if (isSyncing.value) return;

    final slugs = await _enumerateSlugs();
    if (slugs.isEmpty) return;

    isSyncing.value = true;
    AppLogger.info(_tag, 'flushAll: ${slugs.length} inspection(s)');

    try {
      for (final slug in slugs) {
        await _flushSlug(slug);
      }
    } catch (e) {
      AppLogger.error(_tag, 'flushAll error', e);
    } finally {
      isSyncing.value = false;
      await refreshPendingCount();
      AppLogger.info(_tag, 'flushAll complete — pending=${pendingCount.value}');
    }
  }

  Future<void> _prefetchAssets() async {
    try {
      final box = await Hive.openBox<List>('Assets');
      await AssetsRepository(box).prefetchAll();
      AppLogger.info(_tag, 'prefetchAssets: done');
    } catch (e) {
      AppLogger.error(_tag, 'prefetchAssets failed', e);
    }
  }

  Future<void> _flushSlug(String slug) async {
    try {
      final inspectionBox = await Hive.openBox('Inspection_$slug');
      final assets = await Hive.openBox<List>(slug);

      await InspectionDetailsRepository(
        slug: slug,
        box: inspectionBox,
      ).flushPendingStage();

      await VehicleDetailsRepository(
        slug: slug,
        box: inspectionBox,
      ).flushPending();

      await InspectionPointsRepository(
        slug: slug,
        box: assets,
      ).flushPending();

      await InspectionBodyRepository(
        slug: slug,
        box: assets,
      ).flushPendingMarkers();

      await InspectionPhotosRepository(
        slug: slug,
        box: assets,
      ).flushPending();

      await InspectionObdRepository(
        slug: slug,
        box: assets,
      ).flushPending();

      final paintBox = await Hive.openBox(PaintGaugeRepository.boxKey);
      await PaintGaugeRepository(
        slug: slug,
        box: paintBox,
      ).flushPending();
    } catch (e) {
      AppLogger.error(_tag, 'flush slug=$slug failed', e);
    }
  }
}
