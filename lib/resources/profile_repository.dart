import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';

class ProfileRepository {
  ProfileRepository();

  /// Fetches the current user profile from the backend.
  Future<Profile> fetchProfile() async {
    final net = Network(
      endpoint: EndPoints.profile,
      requestMethod: RequestMethod.get,
    );
    final response = await net.response(RoutingUrl.home);
    return Profile.fromJson(response.data);
  }

  /// Switches the current active team for the user.
  Future<Profile> switchTeam(int teamId) async {
    final net = Network(
      endpoint: EndPoints.setTeam,
      requestMethod: RequestMethod.put,
    );

    net.setBody = {'team_id': teamId};

    try {
      final response = await net.response(RoutingUrl.home);
      return Profile.fromJson(response.data);
    } catch (e) {
      dd('Error switching team: $e');
      rethrow;
    }
  }

  /// Updates the user profile. Only sends fields the backend needs.
  Future<Profile> updateProfile({
    required String name,
    required int? cityId,
  }) async {
    final net = Network(
      endpoint: EndPoints.profile,
      requestMethod: RequestMethod.put,
    );

    net.setBody = {
      'name': name,
      if (cityId != null) 'city_id': cityId,
    };

    try {
      final response = await net.response(RoutingUrl.home);
      return Profile.fromJson(response.data);
    } catch (e) {
      dd('Error updating profile: $e');
      rethrow;
    }
  }
}
