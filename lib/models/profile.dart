import 'package:fahis_inspector/services/auth/enums/account_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'city.dart';
import 'team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serializables/profile.g.dart';

@JsonSerializable()
class Profile {
  int id;
  String uid;
  String? mobile;
  String? name;
  String? email;
  bool emailVerification;
  bool mobileVerification;
  AccounStatus status;
  City? city;
  String? avatar;
  String role;
  List<Team> teams;
  List<Team> invitations;
  Locale? lang;

  String get getAvatar =>
      avatar ??
      'https://ui-avatars.com/api/?name=$name&color=7F9CF5&background=EBF4FF';

  // String get getToken => super.token;

  Team? get getCurrentTeam =>
      teams.where((Team team) => team.isCurrent == true).firstOrNull;

  Profile({
    this.id = 0,
    this.uid = '',
    this.mobile,
    this.mobileVerification = false,
    this.name,
    this.email,
    this.emailVerification = false,
    this.status = AccounStatus.inactive,
    this.city,
    this.avatar,
    this.role = 'User',
    this.teams = const [],
    this.invitations = const [],
    this.lang = const Locale('ar'),
  });

  factory Profile.empty() => Profile();

  factory Profile.fromFirebase(User user) => _$UserFromFirebase(user);

  factory Profile.fromJson(Map json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  Team? get currentTeam => teams.where((team) => team.isCurrent).firstOrNull;

  bool get isCreated => id == 0;

  bool get isEmpty =>
      identityHashCode(toJson()) == identityHashCode(Profile.empty().toJson());

  bool isFromFirebase(User user) => identityHashCode(toJson()) ==
        identityHashCode(Profile.fromFirebase(user).toJson());
  // @override
  // String getMobileValue() {
  //   return mobile;
  // }

  // @override
  // bool isMobileVerified() {
  //   return mobileVerification;
  // }
}
