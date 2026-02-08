import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum PointStatus{
  good, note, none ;

  String? get value {
    switch(this){
      case PointStatus.good:
        return 'Good';
      case PointStatus.note:
        return 'Note';
      default:
        return 'N/A';
    }
  } 

  String toString(){
    switch(this){
      case PointStatus.good:
        return 'Good'.tr;
      case PointStatus.note:
        return 'Note'.tr;
      default:
        return 'N/A'.tr;
    }
  }

  Color color(){
    switch(this){
      case PointStatus.good:
        return FColors.success;
      case PointStatus.note:
        return FColors.warning;
      default:
        return FColors.darkGrey;
    }
  }

  IconData icon(){
    switch(this){
      case PointStatus.good:
        return Iconsax.chart_success;
      case PointStatus.note:
        return Iconsax.note;
      default:
        return Iconsax.box_remove;
    }
  }

  static PointStatus set(String? status) {
    if (status == null) {
      return PointStatus.none;
    }
    switch (status) {
      case 'Good' :
        return PointStatus.good;
      case 'Note' :
        return PointStatus.note;
      case 'N/A' :
        return PointStatus.none;
      default:
        return PointStatus.none;
    }
  }
}
