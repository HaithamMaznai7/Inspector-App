import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

enum RequestStatus{ inProgress,pending,approved,finished }

enum GearboxType{ automatic,manual,none }

enum SeatType{ leather , fabric , none }

enum UserType{ 
  inspector, center , customer , administrator , company , support, system;

  static List<UserType> setList(List value){
    List<UserType> roles = [];
    for(String role in value){
      roles.add(UserType.set(role));
    }
    return roles;
  }

  static UserType set(String? value){
    switch(value){
      case 'administrator':
        return UserType.administrator;
      case 'support':
        return UserType.support;
      case 'company_admin':
        return UserType.company;
      case 'center_admin':
        return UserType.center;
      case 'inspector':
        return UserType.inspector;
      case 'system':
        return UserType.system;
      default :
        return UserType.customer;
    }
  }

  String label (){
    switch(this){
      case UserType.system:
        return 'System'.tr;
      case UserType.administrator:
        return 'Administrator'.tr;
      case UserType.support:
        return 'Support'.tr;
      case UserType.center:
        return 'Center Admin'.tr;
      case UserType.inspector:
        return 'Inspector'.tr;
      case UserType.company:
        return 'Company Admin'.tr;
      default:
        return 'Customer'.tr;
    }
  } 
}

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

enum UploadStatus{ uploading, notUploaded, notDownloaded, downloading, live, saved }

enum ObjType { requests , requestDetails , inspectionPoints , inspectionPhotos , inspectionBodies , inspectionBodyNotes , inspectionObds}
