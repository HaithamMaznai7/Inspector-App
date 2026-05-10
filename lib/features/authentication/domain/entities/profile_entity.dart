import 'package:equatable/equatable.dart';
import 'package:fahis_inspector/features/authentication/domain/entities/team_entity.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
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
  final List<TeamEntity> teams;

  TeamEntity? get currentTeam => teams.where((t) => t.isCurrent).firstOrNull;
  bool get hasCurrentTeam => currentTeam != null;

  String get avatarUrl =>
      avatar ??
      'https://ui-avatars.com/api/?name=$name&color=7F9CF5&background=EBF4FF';

  @override
  List<Object?> get props => [id, uid, name, mobile, email, role, avatar, teams];
}
