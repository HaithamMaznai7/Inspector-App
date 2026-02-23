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

Profile _$UserFromJson(Map json) 
  => Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerification: json['email_verified'],
      mobile: json['phone_number'],
      mobileVerification: json['phone_number_verified'],
      status: AccounStatus.set(json['account_status']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      avatar: json['profile_photo'],
      role: json['role'],
      teams: (json['teams']?['teams'] as List?)
          ?.map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      invitations: (json['teams']?['invitations'] as List?)
          ?.map((e) => Team.fromJson(Map<String, dynamic>.from(e)))
          .toList() ?? [],
      lang: Get.deviceLocale,
  );

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
