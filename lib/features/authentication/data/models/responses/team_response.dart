import 'package:fahis_inspector/features/authentication/domain/entities/team_entity.dart';

class TeamResponse {
  const TeamResponse({
    required this.id,
    required this.isCurrent,
    this.type,
    this.name,
    this.role,
  });

  final int id;
  final String? type;
  final String? name;
  final String? role;
  final bool isCurrent;

  factory TeamResponse.fromJson(Map<String, dynamic> json) => TeamResponse(
        id: json['id'] as int,
        type: json['type'] as String?,
        name: json['name'] as String?,
        role: json['role'] as String?,
        isCurrent: json['isCurrent'] as bool? ?? false,
      );

  TeamEntity toEntity() => TeamEntity(
        id: id,
        type: type,
        name: name,
        role: role,
        isCurrent: isCurrent,
      );
}
