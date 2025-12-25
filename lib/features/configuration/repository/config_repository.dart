import 'package:fahis_inspector/services/authentication/models/city.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';

class ConfigRepository {

  static Future<List<City>> getCities() async {
    List<City> cities = [];

    try {
      Network network = Network(endpoint: EndPoints.cities);
      CustomResponse response = await network.response(RoutingUrl.home);

      if (!response.hasError) {
        List data = response.data;

        cities = data.map((e) => City.set(e)).whereType<City>().toList();
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
    return cities;
  }
}
