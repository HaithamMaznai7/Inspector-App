import 'package:fahis_inspector/models/book.dart';
import 'package:fahis_inspector/resources/repository.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/util/formatters/formatter.dart';
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

  String get channel => "App.Models.Inspection.$slug";

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
      listenToBroadcast();
      yield* stream;
    }
  }

  @override
  Future<Inspection?> fetchFromApi() async {
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
    final data = (box.get('inspections') as List?) ?? [];

    final cached = data
        .map((item) => Inspection.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return cached.where((i) => i.slug == slug).firstOrNull;
  }

  @override
  Future<void> saveToCache() async {
    final data = (box.get('inspections') as List?) ?? [];

    final cached = data
        .map((item) => Inspection.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    data.clear();
    for (Inspection item in cached) {
      if (item.slug == slug) {
        item = _data.value ?? item;
      }
      data.add(item.toJson());
    }
    await box.put('inspections', data);
  }

  @override
  Stream<Inspection?> listenToBroadcast() async* {
    yield _data.value;
    // final broadcast = BroadcastService.instance;

    // broadcast?.subscribe(channel, isPrivate: true);

    // broadcast?.responses.listen((event) {
    //   if (event != null &&
    //       event.channel == 'private-$channel' &&
    //       event.event.contains('new-inspection')) {
    //     fetchFromApi();
    //   }
    // });
    yield* stream;
  }

  // Future<List<Inspection>> inspections({
  //   int page = 1,
  //   String? order,
  //   String? search,
  //   String? status,
  // }) async {
  //   /// connect with a network and passing the queries
  //   List<Inspection> data = [];
  //   Network network = Network(endpoint: EndPoints.inspections);
  //   // Map<String, dynamic> query = {
  //   //   'page': '$page',
  //   // };
  //   // if (search != null) {
  //   //   query['search'] = search;
  //   // }
  //   // if (order != null) {
  //   //   query['order'] = search;
  //   // }
  //   // if (status != null) {
  //   //   query['status'] = status;
  //   // }
  //   // network.setQuery = query;
  //   /// get
  //   ///  response
  //   try {
  //     CustomResponse response = await network.response(RoutingUrl.home);

  //     // /// if has not any error process data
  //     // dd(response.data);
  //     data = response.data['inspections'] != null
  //         ? Inspection.setList(response.data['inspections'])
  //         : [];

  //     for (Inspection inspection in data) {
  //       inspection.save(_box);
  //     }
  //   } on FNetworkException {
  //     rethrow;
  //   } catch (e) {
  //     // dd(e);
  //     rethrow;
  //   }

  //   return data;
  // }

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

    try {
      CustomResponse r = await n.response(RoutingUrl.inspections);

      if (r.data.isNotEmpty) {
        inspection = Inspection.fromJson(r.data);
        _data.value = inspection; // تحديث الحالة
      }

      await saveToCache();
    } on FNetworkException {
      rethrow;
    } catch (_) {
      rethrow;
    }

    return _data.value ?? inspection;
  }
}

// class RequestResponse{
//   int total;
//   int lastPage;
//   int currentPage;
//   List mapInspections;
//   List<InspectionCollection> get inspections  
//     => InspectionCollection.listFromApi(mapInspections);
    
//   RequestResponse({required this.total, required this.lastPage, required this.currentPage, required this.mapInspections});

// }