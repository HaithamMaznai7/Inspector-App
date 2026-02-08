import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/vehicle_details.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleDetailsRepository extends BaseRepository<VehicleDetails> {
  final Box box;
  final String slug;

  VehicleDetailsRepository({required this.box, required this.slug});

  String get channel => "App.Models.Inspection.$slug";

  Rxn<VehicleDetails> _data = Rxn<VehicleDetails>();

  Stream<VehicleDetails?> get stream => _data.stream;

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
    final data = box.get(slug) ?? null;

    if (data != null) {
      return VehicleDetails.fromJson(data);
    }

    return null;
  }

  @override
  Future<void> saveToCache() async {
    await box.put(slug, _data.value?.toJson());
  }

  @override
  Stream<VehicleDetails?> listenToBroadcast() async* {
    yield _data.value;

    final broadcast = BroadcastService.instance;

    // while(broadcast?.socketId.value == null)
    // {
    //   await Future.delayed(Duration(seconds: 3));
    // }

    // broadcast?.subscribe(channel, isPrivate: true);

    broadcast?.responses.listen((event) {
      dd('update-details');
      dd(event);

      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-details')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }

  Future<bool> update(String slug, VehicleDetails body) async {
    /// connect with the network
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/details',
      requestMethod: RequestMethod.post,
    );
    n.setBody = body.toJson();

    try {
      CustomResponse r = await n.response(RoutingUrl.home);
      if (!r.hasError) {
        FLoader.successSnackBar(message: 'Saved');
      }
      return !r.hasError;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
