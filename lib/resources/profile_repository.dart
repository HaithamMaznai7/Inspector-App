import 'dart:io';

import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/profile.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:fahis_inspector/util/http/custom_response.dart';
import 'package:fahis_inspector/util/http/http_client.dart';
import 'package:get/get.dart';

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

  Future<Profile> switchTeam(int teamId) async {
    final net = Network(
      endpoint: EndPoints.setTeam,
      requestMethod: RequestMethod.post,
    );

    net.setBody = {'team_id': teamId};

    try {
      await net.response(RoutingUrl.home);
      // Re-fetch full profile to get updated current team
      return await fetchProfile();
    } catch (e) {
      dd('Error switching team: $e');
      rethrow;
    }
  }

  /// Deletes the current user account via DELETE /user.
  Future<void> deleteAccount() async {
    final net = Network(
      endpoint: EndPoints.deleteAccount,
      requestMethod: RequestMethod.delete,
    );
    await net.response(null);
  }

  /// Updates the user profile via PUT /user with form-data.
  /// Accepts: name, city (id), profile_photo_path (File).
  Future<Profile> updateProfile({
    required String name,
    int? cityId,
    File? photo,
  }) async {
    final net = Network(
      endpoint: EndPoints.updateProfile,
      requestMethod: RequestMethod.post,
    );

    final form = FormData({
      'name': name,
      if (cityId != null) 'city': cityId.toString(),
      if (photo != null)
        'profile_photo_path': MultipartFile(
          photo,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
    });

    net.setBody = form;

    try {
      final response = await net.response(RoutingUrl.home);
      return Profile.fromJson(response.data['user']);
    } catch (e) {
      dd('Error updating profile: $e');
      rethrow;
    }
  }
}
