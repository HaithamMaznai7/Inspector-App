import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:get/get.dart';
import 'enums.dart';

class FEnumHelpers{
  FEnumHelpers._();

  static String pointStatusToString(PointStatus status, {bool isShown = false}) {
    if(isShown){
      switch (status) {
        case PointStatus.good :
          return 'good'.tr;
        case PointStatus.note :
          return 'notes'.tr;
        case PointStatus.none :
          return 'na'.tr;
      }
    }
    else{
      switch (status) {
        case PointStatus.good:
          return 'Good';
        case PointStatus.note:
          return 'Note';
        case PointStatus.none:
          return 'N/A';
      }
    }
  }



  static String requestStatusToString(RequestStatus status, {bool isDisplay = false}) {
    if(isDisplay) {
      switch (status) {
        case RequestStatus.inProgress :
          return 'In Progress'.tr;
        case RequestStatus.pending :
          return 'Pending'.tr;
        case RequestStatus.approved :
          return 'Approved'.tr;
        case RequestStatus.finished :
          return 'Finished'.tr;
      }
    }else{
      switch (status) {
        case RequestStatus.inProgress :
          return 'In Progress';
        case RequestStatus.pending :
          return 'Pending';
        case RequestStatus.approved :
          return 'Approved';
        case RequestStatus.finished :
          return 'Finished';
      }
    }
  }

  static RequestStatus stringToRequestStatus(String? status) {
    if (status == null) {
      return RequestStatus.inProgress;
    }
    status = clearString(status);
    switch (status) {
      case 'inprogress' :
        return RequestStatus.inProgress;
      case 'pending' :
        return RequestStatus.pending;
      case 'approved' :
        return RequestStatus.approved;
      case 'finished' :
        return RequestStatus.finished;
      default:
        return RequestStatus.inProgress;
    }
  }

  static String? gearboxTypeToString(GearboxType type) {
    switch (type) {
      case GearboxType.automatic:
        return FTexts.automatic.capitalize;
      case GearboxType.manual:
        return FTexts.manual.capitalize;
      default:
        return 'none';
    }

  }

  // static GearboxType stringToGearboxType(String? type) {
  //   if (type == null) {
  //     return GearboxType.none;
  //   }
  //   type = clearString(type);
  //   switch (type) {
  //     case FTexts.automatic :
  //       return GearboxType.automatic;
  //     case 'اوتوماتيك' :
  //       return GearboxType.automatic;
  //     case FTexts.manual :
  //       return GearboxType.manual;
  //     case 'عادي' :
  //       return GearboxType.manual;
  //     default:
  //       return GearboxType.none;
  //   }
  // }

  static String uploadStatusToString(UploadStatus status) {
    switch (status) {
      case UploadStatus.live :
        return 'live';
      case UploadStatus.notUploaded :
        return 'notuploaded';
      case UploadStatus.notDownloaded :
        return 'notdownloaded';
      case UploadStatus.downloading :
        return 'downloading';
      case UploadStatus.uploading :
        return 'uploading';
      case UploadStatus.saved :
        return 'saved';
    }
  }

  static UploadStatus stringToUploadStatus(String? status) {
    if (status == null) {
      return UploadStatus.live;
    }
    status = clearString(status);
    switch (status) {
      case 'live' :
        return UploadStatus.live;
      case 'notuploaded' :
        return UploadStatus.notUploaded;
      case 'notdownloaded' :
        return UploadStatus.notDownloaded;
      case 'downloading' :
        return UploadStatus.downloading;
      case 'uploading' :
        return UploadStatus.uploading;
      case 'saved' :
        return UploadStatus.saved;
      default:
        return UploadStatus.live;
    }
  }

  static String clearString(String status) {
    status = status.replaceAll(' ', '');
    return status.toLowerCase();
  }

}