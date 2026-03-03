part of '../profile.dart';

Profile _$UserFromFirebase(User user) => Profile(
  uid: user.uid,
  name: user.displayName,
  email: user.email,
  emailVerification: user.emailVerified,
  mobile: user.phoneNumber,
  mobileVerification: user.emailVerified,
  status: AccounStatus.set('Active'),
  city: City.fromJson({'id': 99, 'name': 'جدة'}),
  avatar: user.photoURL,
  role: 'SYSTEM',
  teams: [].map((element) => Team.fromJson(element)).toList(),
  lang: Get.deviceLocale,
);

Profile _$UserFromJson(Map json) {
  final teamsData = json['teams'];

  List<Team> teams = [];
  List<Team> invitations = [];

  if (teamsData is Map) {
    // Legacy backend shape: { "teams": [...], "invitations": [...] }
    teams = (teamsData['teams'] as List?)
        ?.map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList() ?? [];
    invitations = (teamsData['invitations'] as List?)
        ?.map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList() ?? [];
  } else if (teamsData is List) {
    // Current backend shape: flat list directly under user.teams
    teams = teamsData
        .map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Invitations are a separate top-level field.
  // Backend has a typo ("invatations") — check both spellings.
  final invitationsRaw = json['invitations'] ?? json['invatations'];
  if (invitationsRaw is List) {
    invitations = invitationsRaw
        .map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  return Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerification: json['email_verified'] ?? false,
      mobile: json['phone_number'],
      mobileVerification: json['phone_number_verified'] ?? false,
      status: AccounStatus.set(json['account_status']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      avatar: json['profile_photo'],
      role: json['role'] ?? 'User',
      teams: teams,
      invitations: invitations,
      lang: Get.deviceLocale,
  );
}

Map<String, dynamic> _$UserToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'email_verified': instance.emailVerification,
  'phone_number': instance.mobile,
  'phone_number_verified': instance.mobileVerification,
  'city': instance.city?.toJson(),
  'profile_photo': instance.avatar,
  'role': instance.role,
  'teams': {
    'teams': instance.teams.map((e) => e.toJson()).toList(),
    'invitations': instance.invitations.map((e) => e.toJson()).toList(),
  },
};
