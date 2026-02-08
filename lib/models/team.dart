import 'placeholder_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/team.g.dart';

@JsonSerializable()
class Team {
  int? id;
  PlaceHolderModel? owner;
  String? name;
  String? role;
  bool isCurrent;
  DateTime? joinedAt;
  List<dynamic> permissions;

  Team({
    this.id,
    this.owner,
    this.name,
    this.role,
    this.isCurrent = false,
    this.joinedAt,
    this.permissions = const [],
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  bool get isJoined => joinedAt != null;

  bool get isInvited => joinedAt == null;
}
