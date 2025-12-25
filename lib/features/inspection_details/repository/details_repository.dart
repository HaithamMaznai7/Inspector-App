import 'package:fahis_inspector/features/inspection_details/models/inspection_details.dart';
import 'package:fahis_inspector/features/repositories/repository.dart';
import 'package:fahis_inspector/services/broadcast/broadcast.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionDetailsRepository extends BaseRepository<InspectionDetails> {
  static String get boxKey => "Inspection_Details";

  final Box box;
  final String slug;

  InspectionDetailsRepository({required this.box, required this.slug});

  String get channel => "App.Models.Inspection.$slug";

  Rxn<InspectionDetails> _data = Rxn<InspectionDetails>();

  Stream<InspectionDetails?> get stream => _data.stream;

  Future<InspectionDetails?> fetchFromApi() async {
    final n = Network(endpoint: '${EndPoints.inspections}/$slug/details');

    final r = await n.response(RoutingUrl.home);

    final details = r.data != null ? InspectionDetails.set(r.data) : null;

    _data.value = details;

    await saveToCache();

    return _data.value;
  }

  @override
  InspectionDetails? fetchFromCache() {
    final data = box.get(slug) ?? null;

    if (data != null) {
      return InspectionDetails.set(data);
    }

    return null;
  }

  @override
  Future<void> saveToCache() async {
    await box.put(slug, _data.value?.toJson());
  }

  @override
  Stream<InspectionDetails?> listenToBroadcast() async* {
    yield _data.value;

    final broadcast = BroadcastService.instance;

    // while(broadcast?.socketId.value == null)
    // {
    //   await Future.delayed(Duration(seconds: 3));
    // }

    // broadcast?.subscribe(channel, isPrivate: true);

    broadcast?.responses.listen((event) {
      print('update-details');
      print(event);
      if (event != null &&
          event.channel == 'private-$channel' &&
          event.event.contains('update-details')) {
        fetchFromApi();
      }
    });
    yield* stream;
  }

  static Future<bool> update(String slug, InspectionDetails body) async {
    /// connect with the network
    Network n = Network(
      endpoint: '${EndPoints.inspections}/$slug/details',
      requestMethod: RequestMethod.post,
    );
    n.setBody = body.toJson();

    try {
      CustomResponse r = await n.response(RoutingUrl.home);
      return !r.hasError;
    } on FNetworkException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
