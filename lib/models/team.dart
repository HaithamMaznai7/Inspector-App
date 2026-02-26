import 'placeholder_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/team.g.dart';

@JsonSerializable()
class Team {
  int? id;
  PlaceHolderModel? owner;
  String? type;
  String? name;
  String? role;
  bool isCurrent;
  DateTime? joinedAt;
  DateTime? invitedAt;
  List<dynamic> permissions;

  Team({
    this.id,
    this.owner,
    this.type,
    this.name,
    this.role,
    this.isCurrent = false,
    this.joinedAt,
    this.invitedAt,
    this.permissions = const [],
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  bool get isJoined => joinedAt != null;

  bool get isInvited => joinedAt == null && invitedAt != null;

  bool get isSystem => type == 'system';

  bool get isCompany => type == 'company';

  bool get isCenter => type == 'center';

  bool get isCenterBranch => type == 'centerBranch';

  /// Teams eligible for selection (system, center, or centerBranch).
  bool get isSelectableTeam => isSystem || isCenter || isCenterBranch;

  String? get ownerLogo => owner?.avatar;
}
