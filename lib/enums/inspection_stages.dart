import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fahis_inspector/util/constants/colors.dart';

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum InspectionStage {
  all('All', null, Iconsax.home, FColors.primaryColor),
  pending('Pending', 'pending', Iconsax.timer, FColors.darkGrey),
  accepted('Accepted', 'accepted', Iconsax.add, Colors.blueAccent),
  info('Info', 'info', Iconsax.information, Colors.lightBlue),
  points('Points', 'points', Iconsax.location, Colors.teal),
  photos('Photos', 'photos', Iconsax.camera, Colors.purple),
  body('Body', 'body', Iconsax.car, Colors.indigo),
  obd('OBD', 'obd', Iconsax.setting_3, Colors.deepPurple),
  finished('Finished', 'finished', Iconsax.wallet, Colors.green),
  rejected('Rejected', 'rejected', Iconsax.refresh, Colors.redAccent),
  reviewed('Reviewed', 'reviewed', Iconsax.archive, Colors.brown);

  const InspectionStage(this.label, this.value, this.icon, this.color);

  final String label;
  String get getLabel {
    switch (value) {
      case 'pending':
        return 'pend inspection'.tr;
      case 'accepted':
        return 'accept inspection'.tr;
      case 'info':
        return 'change vehicle info'.tr;
      case 'points':
        return 'inspect points'.tr;
      case 'photos':
        return 'upload photos'.tr;
      case 'body':
        return 'set body notes'.tr;
      case 'obd':
        return 'inspect obd'.tr;
      case 'finished':
        return 'finish inspection'.tr;
      case 'reviewed':
        return 'approve inspection'.tr;
      case 'rejected':
        return 'reject inspection'.tr;
      default:
        return 'Next'.tr;
    }
  }

  final String? value;
  final IconData icon;
  final Color color;

  String? get valueBasedInProgress {
    switch (value) {
      case 'info':
        return 'in_progress'; // you can customize this if needed
      case 'points':
        return 'in_progress'; // you can customize this if needed
      case 'photos':
        return 'in_progress'; // you can customize this if needed
      case 'body':
        return 'in_progress'; // you can customize this if needed
      case 'obd':
        return 'in_progress'; // you can customize this if needed
      default:
        return value;
    }
  }

  String? toJson() => value;

  static InspectionStage fromJson(String? json) =>
      values.where((item) => item.value == json).first;

  static InspectionStage? fromIndex(int index) {
    switch (index) {
      case 0:
        return InspectionStage.info;
      case 1:
        return InspectionStage.points;
      case 2:
        return InspectionStage.photos;
      case 3:
        return InspectionStage.body;
      case 4:
        return InspectionStage.obd;
      default:
        return null;
    }
  }

  /// Grouping helper: is this an in-progress stage?
  static const map = {
    InspectionStage.all: null,
    InspectionStage.pending: 'pending',
    InspectionStage.accepted: 'accepted',
    InspectionStage.info: 'info',
    InspectionStage.points: 'points',
    InspectionStage.photos: 'photos',
    InspectionStage.body: 'body',
    InspectionStage.obd: 'obd',
    InspectionStage.finished: 'finished',
    InspectionStage.rejected: 'rejected',
    InspectionStage.reviewed: 'reviewed',
  };

  bool get isInProgress =>
      value == InspectionStage.info.value ||
      value == InspectionStage.points.value ||
      value == InspectionStage.photos.value ||
      value == InspectionStage.body.value ||
      value == InspectionStage.obd.value;

  bool get editable =>
      value == InspectionStage.info.value ||
      value == InspectionStage.points.value ||
      value == InspectionStage.photos.value ||
      value == InspectionStage.body.value ||
      value == InspectionStage.obd.value;

  bool get isShowTabs => [
    InspectionStage.pending.value,
    InspectionStage.accepted.value,
  ].contains(value);

  bool get canEditInfo => ![
    InspectionStage.pending,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get canEditPoint => ![
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get canEditPhoto => ![
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get canEditBody => ![
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get canEdit => [
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.info,
    InspectionStage.points,
    InspectionStage.photos,
    InspectionStage.body,
    InspectionStage.obd,
    InspectionStage.rejected,
  ].contains(this);
  bool get canEditObd => ![
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get canFinish => ![
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.finished,
    InspectionStage.reviewed,
  ].contains(this);
  bool get isFinished =>
      this == InspectionStage.finished || this == InspectionStage.reviewed;

  /// Used to map all in-progress stages to the same filter group
  static List<InspectionStage> get progressStages => [
    InspectionStage.info,
    InspectionStage.points,
    InspectionStage.photos,
    InspectionStage.body,
    InspectionStage.obd,
  ];

  static List<InspectionStage> get allStages => [
    InspectionStage.all,
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.info,
    InspectionStage.points,
    InspectionStage.photos,
    InspectionStage.body,
    InspectionStage.obd,
    InspectionStage.finished,
    InspectionStage.rejected,
    InspectionStage.reviewed,
  ];

  static List<InspectionStage> get stages => [
    InspectionStage.pending,
    InspectionStage.accepted,
    InspectionStage.info,
    InspectionStage.points,
    InspectionStage.photos,
    InspectionStage.body,
    InspectionStage.obd,
    InspectionStage.finished,
    InspectionStage.rejected,
    InspectionStage.reviewed,
  ];

  @override
  toString() => name;

  InspectionStage? get next {
    switch (this) {
      case InspectionStage.info:
        return InspectionStage.points;
      case InspectionStage.points:
        return InspectionStage.photos;
      case InspectionStage.photos:
        return InspectionStage.body;
      case InspectionStage.body:
        return InspectionStage.obd;
      case InspectionStage.obd:
        return InspectionStage.finished;
      default:
        return null;
    }
  }

  InspectionStage? get back {
    switch (this) {
      case InspectionStage.points:
        return InspectionStage.info;
      case InspectionStage.photos:
        return InspectionStage.points;
      case InspectionStage.body:
        return InspectionStage.photos;
      case InspectionStage.obd:
        return InspectionStage.body;
      default:
        return null;
    }
  }

  InspectionStage? get cancel {
    switch (this) {
      case InspectionStage.accepted:
        return InspectionStage.pending;
      case InspectionStage.finished:
        return InspectionStage.rejected;
      case InspectionStage.reviewed:
        return InspectionStage.rejected;
      default:
        return null;
    }
  }
}
