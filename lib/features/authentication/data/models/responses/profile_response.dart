import 'package:fahis_inspector/features/authentication/data/models/responses/team_response.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/profile_entity.dart';

class ProfileResponse {
  const ProfileResponse({
    required this.id,
    required this.uid,
    required this.role,
    required this.teams,
    this.name,
    this.mobile,
    this.email,
    this.avatar,
  });

  final int id;
  final String uid;
  final String? name;
  final String? mobile;
  final String? email;
  final String role;
  final String? avatar;
  final List<TeamResponse> teams;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        id: json['id'] as int,
        uid: json['uid'] as String? ?? '',
        name: json['name'] as String?,
        mobile: json['mobile'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String? ?? 'User',
        avatar: json['avatar'] as String?,
        teams: (json['teams'] as List<dynamic>? ?? [])
            .map((e) => TeamResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  ProfileEntity toEntity() => ProfileEntity(
        id: id,
        uid: uid,
        name: name,
        mobile: mobile,
        email: email,
        role: role,
        avatar: avatar,
        teams: teams.map((t) => t.toEntity()).toList(),
      );
}
