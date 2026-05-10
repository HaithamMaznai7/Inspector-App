import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  const TeamEntity({
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

  bool get isSystem => type == 'system';
  bool get isCenter => type == 'center';
  bool get isCenterBranch => type == 'centerBranch';
  bool get isSelectableTeam => isSystem || isCenter || isCenterBranch;

  @override
  List<Object?> get props => [id, type, name, role, isCurrent];
}
