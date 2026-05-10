import 'package:get/get.dart';

enum RequestStatus { inProgress, pending, approved, finished }

enum GearboxType { automatic, manual, none }

enum SeatType { leather, fabric, none }

enum UserType {
  inspector,
  center,
  customer,
  administrator,
  company,
  support,
  system;

  static List<UserType> setList(List value) {
    List<UserType> roles = [];
    for (String role in value) {
      roles.add(UserType.set(role));
    }
    return roles;
  }

  static UserType set(String? value) {
    switch (value) {
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
      default:
        return UserType.customer;
    }
  }

  // TODO(Task 8): replace .tr with S.of(context) after localization migration
  String label() {
    switch (this) {
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

enum UploadStatus {
  uploading,
  notUploaded,
  notDownloaded,
  downloading,
  live,
  saved,
}

enum ObjType {
  requests,
  requestDetails,
  inspectionPoints,
  inspectionPhotos,
  inspectionBodies,
  inspectionBodyNotes,
  inspectionObds,
}
