import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/city.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssetsRepository {
  final Box<List> assets;

  AssetsRepository(this.assets);

  static Stream<List<City>> getCities() async* {
    List<City> cities = [];
    yield cities;

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

  Stream<List<Selection>> fuelTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-FuelTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.fuelTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-FuelTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd(e.toString());
    }
  }

  Stream<List<Selection>> seatTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-SeatTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.seatTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-SeatTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (_) {
    }
  }

  Stream<List<Selection>> cylinderNumbers() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-CylinderNumbers', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.cylinderNumbers);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-CylinderNumbers', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (_) {
    }
  }

  Stream<List<Selection>> bodyTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-BodyTypes', defaultValue: []) ?? [];
    items = data.map((item) => Selection.fromJson(item)).toList();
    yield items;

    try {
      Network network = Network(endpoint: EndPoints.bodyTypes);
      // dd(network.url);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-BodyTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }

  Stream<List<Selection>> drivetrainTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-DrivetrainTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.drivetrainTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-DrivetrainTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }

  Stream<List<Selection>> gasolineTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-GasolineTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.gasolineTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-GasolineTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }

  Stream<List<Selection>> gearboxTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-GearboxTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.gearboxTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-GearboxTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }

  Stream<List<Selection>> seatNumbers() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-SeatNumbers', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.seatNumbers);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-SeatNumbers', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }

  Stream<List<Selection>> bodyNoteTypes() async* {
    List<Selection> items = [];
    yield items;

    // final box = await Hive.openBox<List>('Assets');
    final data = assets.get('Assets-BodyNoteTypes', defaultValue: []);
    yield data!.map((item) => Selection.fromJson(item)).toList();

    try {
      Network network = Network(endpoint: EndPoints.bodyNoteTypes);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;
        assets.put('Assets-BodyNoteTypes', data);
        items = data
            .map((e) => Selection.fromJson(e))
            .whereType<Selection>()
            .toList();
      }

      yield items;
    } catch (e) {
      dd('Error fetching fuel types: $e');
    }
  }
}
