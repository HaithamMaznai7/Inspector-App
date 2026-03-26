import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/photo.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
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
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/photos', requestMethod: RequestMethod.post);

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
      n.setBody = FormData({
        'image': MultipartFile(
          photo.file!,
          filename: photo.file!.path.split('/').last,
          contentType: 'image/jpeg', // optional
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
      }
    } on FNetworkException catch (e) {
      e.notify();
      updatePhoto(oldPhoto);
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
