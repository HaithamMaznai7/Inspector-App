import 'city.dart';

class Team {
  int? id;
  City? owner;
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

  static Team set(map) {

    return Team(
      id: map['id'],
      owner: City.set(map['owner']),
      name: map['name'],
      role: map['role'],
      isCurrent: map['current'],
      joinedAt: map['joined_at'] != null ? DateTime.parse(map['joined_at']) : null,
      permissions: map['permissions'] ?? [],
    );
  }

  bool get isJoined => joinedAt != null;

  bool get isInvited => joinedAt == null;

  static List<Team> listSet([List list = const []]) {
    return list.map((item) => Team.set(item)).toList();
  }

  static List<Map<String, dynamic>> listToJson([List<Team> list = const []]) {
    return list.map((item) => item.toJson()).toList();
  }

  factory Team.empty() => Team();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner?.tojson(),
      'name': name,
      'role': role,
      'current': isCurrent,
      'joined_at': joinedAt?.toString(),
      'permissions': permissions,
    };
  }
}
