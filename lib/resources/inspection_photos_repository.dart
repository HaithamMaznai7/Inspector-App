import 'dart:io';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionPhotosRepository extends ListRepository<Photo> {
  final Box box;
  final String slug;

  InspectionPhotosRepository({required this.box, required this.slug});

  final RxList<Photo> _data = RxList<Photo>([]);

  Stream<List<Photo>> get stream => _data.stream;

  @override
  Future<List<Photo>> fetchFromApi() async {
    await flushPending();
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/photos');

    final r = await n.response(RoutingUrl.home);

    final photos = r.data.isNotEmpty
        ? Photo.setList(r.data['photos'])
        : <Photo>[];

    _data.assignAll(photos);

    await saveToCache();

    return _data;
  }

  /// Resets all photos to image: null by calling POST /inspections/{slug}/photos.
  /// Same endpoint as generate — the backend treats it as a full reset.
  Future<List<Photo>> resetAll() async => generate();

  Future<List<Photo>> generate() async {
    final n = Network(
      endpoint: '${EndPoints.inspections}/$slug/photos',
      requestMethod: RequestMethod.post,
    );

    final r = await n.response(RoutingUrl.home);

    final photos = r.data.isNotEmpty
        ? Photo.setList(r.data['photos'])
        : <Photo>[];

    _data.value = photos;

    await saveToCache();

    return _data;
  }

  @override
  List<Photo> fetchFromCache() {
    final data = (box.get('Photos') as List?) ?? [];

    return data
        .map((item) => Photo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> saveToCache() async {
    final photos = _data.map((i) => i.toJson()).toList();
    await box.put('Photos', photos);
  }

  // ── Pending upload store ─────────────────────────────────────────────────────

  String get _pendingKey => 'pending_photos_$slug';

  void _savePendingUpload(int photoId, String localFilePath) {
    final raw = box.get(_pendingKey) as List?;
    final pending = raw?.toList() ?? [];
    // Replace existing entry for same slot (user re-took photo before sync)
    pending.removeWhere((e) => (e is Map) && e['photoId'] == photoId);
    pending.add({'photoId': photoId, 'localFilePath': localFilePath});
    box.put(_pendingKey, pending);
    AppLogger.info(
      '[Offline]',
      'write photos/$slug/photo$photoId: pending=true',
    );
  }

  void _clearPendingUpload(int photoId) {
    final raw = box.get(_pendingKey) as List?;
    if (raw == null) return;
    final pending = raw.toList();
    pending.removeWhere((e) => (e is Map) && e['photoId'] == photoId);
    box.put(_pendingKey, pending);
  }

  List<Map<String, dynamic>> _pendingUploads() {
    final raw = box.get(_pendingKey) as List?;
    if (raw == null || raw.isEmpty) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// True if there is a pending (unsynced) upload for this photo slot.
  bool hasPendingUpload(int photoId) =>
      _pendingUploads().any((e) => e['photoId'] == photoId);

  /// Retries any photo uploads that failed while offline.
  Future<void> flushPending() async {
    final entries = _pendingUploads();
    if (entries.isEmpty) return;
    AppLogger.info(
      '[Offline]',
      'flush photos/$slug: ${entries.length} pending uploads',
    );

    for (final entry in entries) {
      final photoId = entry['photoId'] as int;
      final path = entry['localFilePath'] as String;
      final file = File(path);

      if (!file.existsSync()) {
        // File was purged from temp dir — can't retry, clear the entry.
        _clearPendingUpload(photoId);
        AppLogger.info(
          '[Offline]',
          'flush photos/$slug/photo$photoId: file gone — cleared',
        );
        continue;
      }

      AppLogger.info('[Offline]', 'flush photos/$slug/photo$photoId: syncing');

      final n = Network(
        endpoint: '${EndPoints.photos}/$photoId',
        requestMethod: RequestMethod.post,
      );
      n.setBody = FormData({
        'image': MultipartFile(
          file,
          filename: file.path.split('/').last,
          contentType: 'image/jpeg',
        ),
      });

      try {
        await n.response(RoutingUrl.home);
        _clearPendingUpload(photoId);
        // Refresh the full list so the grid reflects the uploaded state.
        await fetchFromApi();
        AppLogger.info(
          '[Offline]',
          'flush photos/$slug/photo$photoId: success',
        );
      } on FNetworkException catch (e) {
        AppLogger.error(
          '[Offline]',
          'flush photos/$slug/photo$photoId: failed',
          e,
        );
      } catch (e) {
        dd('flushPending photos error: $e');
      }
    }
  }

  // ── update ───────────────────────────────────────────────────────────────────

  Future<void> update(Photo photo) async {
    final oldPhoto = _data.where((p) => p.id == photo.id).firstOrNull;

    if (oldPhoto == null) {
      throw FNetworkException(
        'Not Found the photo',
        statusCode: 404,
        title: "Not Found",
      );
    }

    updatePhoto(photo);

    Network n = Network(
      endpoint: '${EndPoints.photos}/${photo.id}',
      requestMethod: RequestMethod.post,
    );

    if (photo.file != null) {
      // Save pending BEFORE the network call so the file path survives app-kill.
      _savePendingUpload(photo.id, photo.file!.path);
      n.setBody = FormData({
        'image': MultipartFile(
          photo.file!,
          filename: photo.file!.path.split('/').last,
          contentType: 'image/jpeg',
        ),
      });
    } else {
      // No file selected, skip API call
      return;
    }

    try {
      final r = await n.response(RoutingUrl.home);

      final point = !r.hasError || r.data.isNotEmpty
          ? Photo.fromJson(r.data)
          : null;

      if (point == null) {
        updatePhoto(oldPhoto);
      } else {
        updatePhoto(point);
        _clearPendingUpload(photo.id); // synced — remove pending flag
      }
    } on FNetworkException catch (e) {
      e.notify();
      updatePhoto(oldPhoto); // rollback optimistic UI; pending flag stays
    } catch (e) {
      dd(e);
      updatePhoto(oldPhoto);
    } finally {
      await saveToCache();
    }
  }

  Future<void> delete(Photo photo) async {
    Network n = Network(
      endpoint: '${EndPoints.photos}/${photo.id}',
      requestMethod: RequestMethod.delete,
    );

    try {
      final r = await n.response(RoutingUrl.home);
      final newPhoto = !r.hasError || r.data.isNotEmpty
          ? Photo.fromJson(r.data)
          : null;

      if (newPhoto == null) {
        updatePhoto(photo);
      } else {
        updatePhoto(newPhoto);
      }
    } on FNetworkException catch (e) {
      e.notify();
      updatePhoto(photo);
    } catch (e) {
      dd(e);
      updatePhoto(photo);
    } finally {
      await saveToCache();
    }
  }

  void updatePhoto(Photo newPhoto) {
    final index = _data.indexWhere((p) => p.id == newPhoto.id);
    if (index != -1) {
      _data[index] = newPhoto;
    }
  }
}
