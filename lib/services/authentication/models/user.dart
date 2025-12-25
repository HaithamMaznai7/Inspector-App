import '../verification.dart';
import '../enums/account_status.dart';
import 'city.dart';
import 'team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class User extends MobileVerification {
  int id;
  String mobile;
  String? name;
  String email;
  bool emailVerification;
  bool mobileVerification;
  AccounStatus status;
  City? city;
  String? avatar;
  String role;
  List<Team> teams;
  Locale? lang;

  String get getAvatar =>
      avatar ??
      'https://ui-avatars.com/api/?name=$name&color=7F9CF5&background=EBF4FF';

  // String get getToken => super.token;

  Team? get getCurrentTeam =>
      teams.where((Team team) => team.isCurrent == true).firstOrNull;

  User({
    this.id = 0,
    this.mobile = '',
    this.mobileVerification = false,
    this.name,
    this.email = '',
    this.emailVerification = false,
    this.status = AccounStatus.inactive,
    this.city,
    this.avatar,
    this.role = 'User',
    this.teams = const [],
    this.lang = const Locale('en'),
  });

  factory User.empty() => User();

  Team? get currentTeam => teams.where((team) => team.isCurrent).firstOrNull;

  bool get isCreated => id == 0;
  static User? set(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      emailVerification: map['email_verified'],
      mobile: map['phone_number'],
      mobileVerification: map['phone_number_verified'],
      status: AccounStatus.set(map['account_status']),
      city: City.set(map['city']),
      avatar: map['profile_photo'],
      role: map['role'],
      teams: Team.listSet(map['teams']['teams']),
      lang: Get.deviceLocale,
    );
  }

  toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'email_verified': emailVerification,
    'phone_number': mobile,
    'phone_number_verified': mobileVerification,
    'city': city?.tojson(),
    'profile_photo': avatar,
    'role': role,
    'teams': {'teams': Team.listToJson(teams), 'invitations': []},
  };

  @override
  String getMobileValue() {
    return mobile;
  }

  @override
  bool isMobileVerified() {
    return mobileVerification;
  }
}
