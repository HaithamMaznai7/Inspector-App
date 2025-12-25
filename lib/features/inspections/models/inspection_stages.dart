import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fahis_inspector/util/constants/colors.dart';

enum InspectionStage {
  all('All', null, Iconsax.home, FColors.primaryColor),
  pending('Pending', 'pending', Iconsax.timer, FColors.darkGrey),
  accepted('Accepted', 'accepted', Iconsax.add, Colors.blueAccent),

  // in-progress group
  info('Info', 'info', Iconsax.information, Colors.lightBlue),
  points('Points', 'points', Iconsax.location, Colors.teal),
  photos('Photos', 'photos', Iconsax.camera, Colors.purple),
  body('Body', 'body', Iconsax.car, Colors.indigo),
  obd('OBD', 'obd', Iconsax.setting_3, Colors.deepPurple),

  finished('Finished', 'finished', Iconsax.wallet, Colors.green),
  rejected('Rejected', 'rejected', Iconsax.refresh, Colors.redAccent),
  reviewed('Reviewed', 'reviewed', Iconsax.archive, Colors.brown);

  final String label;
  String get getLabel => label.tr;
  final String? value;
  final IconData icon;
  final Color color;

  const InspectionStage(this.label, this.value, this.icon, this.color);

  /// Get enum from string (from API or query param)
  static InspectionStage fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return InspectionStage.pending;
      case 'accepted':
        return InspectionStage.accepted;
      case 'info':
        return InspectionStage.info;
      case 'points':
        return InspectionStage.points;
      case 'photos':
        return InspectionStage.photos;
      case 'body':
        return InspectionStage.body;
      case 'obd':
        return InspectionStage.obd;
      case 'finished':
        return InspectionStage.finished;
      case 'rejected':
        return InspectionStage.rejected;
      case 'reviewed':
        return InspectionStage.reviewed;
      case 'all':
      default:
        return InspectionStage.all;
    }
  }

  String? get valueBasedInProgress {
    switch (this) {
      case InspectionStage.info:
        return 'in_progress'; // you can customize this if needed
      case InspectionStage.points:
        return 'in_progress'; // you can customize this if needed
      case InspectionStage.photos:
        return 'in_progress'; // you can customize this if needed
      case InspectionStage.body:
        return 'in_progress'; // you can customize this if needed
      case InspectionStage.obd:
        return 'in_progress'; // you can customize this if needed
      default:
        return value;
    }
  }

  /// Grouping helper: is this an in-progress stage?
  bool get isInProgress =>
      this == InspectionStage.info ||
      this == InspectionStage.points ||
      this == InspectionStage.photos ||
      this == InspectionStage.body ||
      this == InspectionStage.obd;

  bool get editable =>
      this == InspectionStage.info ||
      this == InspectionStage.points ||
      this == InspectionStage.photos ||
      this == InspectionStage.body ||
      this == InspectionStage.obd;

  bool get isShowTabs => InspectionStage.pending != this && InspectionStage.accepted != this;
  
  bool get canEditInfo => ! [InspectionStage.pending, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get canEditPoint => ! [InspectionStage.pending, InspectionStage.accepted, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get canEditPhoto => ! [InspectionStage.pending, InspectionStage.accepted, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get canEditBody => ! [InspectionStage.pending, InspectionStage.accepted, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get canEditObd => ! [InspectionStage.pending, InspectionStage.accepted, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get canFinish => ! [InspectionStage.pending, InspectionStage.accepted, InspectionStage.finished, InspectionStage.reviewed].contains(this);
  bool get isFinished => 
    this == InspectionStage.finished ||
    this == InspectionStage.reviewed;



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
      case InspectionStage.pending:
        return InspectionStage.accepted;
      case InspectionStage.accepted:
        return InspectionStage.finished;
      case InspectionStage.info:
        return InspectionStage.finished;
      case InspectionStage.points:
        return InspectionStage.finished;
      case InspectionStage.photos:
        return InspectionStage.finished;
      case InspectionStage.body:
        return InspectionStage.finished;
      case InspectionStage.obd:
        return InspectionStage.finished;
      case InspectionStage.rejected:
        return InspectionStage.finished;
      default:
        return null;
    }
  }

  InspectionStage? get cancel {
    switch (this) {
      // case InspectionStage.pending:
      //   return InspectionStage.rejected;
      default:
        return null;
    }
  }
}
