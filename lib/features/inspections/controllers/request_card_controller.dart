// import 'dart:io';
// import 'dart:isolate';
// import 'package:fahis_inspector/features/inspections/models/inspection.dart';
// import 'package:fahis_inspector/util/constants/colors.dart';
// import 'package:fahis_inspector/util/constants/enums.dart';
// import 'package:fahis_inspector/util/helpers/helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class RequestCardController extends GetxController{
//   static RequestCardController get instance => Get.find(tag: 'RequestCardController');

//   RxBool isDownloading = false.obs;
//   RxBool isUploading = false.obs;
//   RxList<Inspection> requests = RxList.empty();
//   Widget statusIcon(Inspection request) {
//     switch (request.status){
//       case RequestStatus.pending :
//         return const Icon(Icons.pending_actions_outlined, color: FColors.primaryColor);
//       case RequestStatus.inProgress :
//         return const Icon(Icons.edit, color: FColors.primaryColor);
//       case RequestStatus.approved :
//         return const Icon(Icons.verified, color: FColors.primaryColor);
//       case RequestStatus.finished :
//         return const Icon(Icons.verified_outlined, color: FColors.primaryColor);
//       default :
//         return const SizedBox();
//     }
//   }
//   Color color(Inspection request){
//     if(FHelper.isDarkMode(Get.context!)){
//           return FColors.black;
//     }else{
//           return FColors.white;

//     }

//   }

//   upDate(Inspection request) async {
//     request.uploadStatus = UploadStatus.downloading;
//     var hhh = await Isolate.run((){
//       sleep(const Duration(seconds: 3));
//       return true ;
//     });
//     if(hhh){
//       request.uploadStatus = UploadStatus.saved;
//     }else{
//       request.uploadStatus = UploadStatus.notDownloaded;
//     }
//     return hhh;
//   }

//   upload(Inspection request) async {
//     request.uploadStatus = UploadStatus.uploading;
//     var hhh = await Isolate.run((){
//       sleep(const Duration(seconds: 5));
//       return true ;
//     });
//     if(hhh){
//       request.uploadStatus = UploadStatus.saved;
//     }else{
//       request.uploadStatus = UploadStatus.notUploaded;
//     }
//     return hhh;
//   }

//   download(Inspection request) async {
//     isDownloading.toggle();

//     bool hhh = await Isolate.run((){
//       sleep(const Duration(seconds: 7));
//       return true ;
//     });
//     if(hhh){
//       isDownloading.toggle();
//     }else{
//       isDownloading.toggle();
//     }
//     return hhh;
//   }
// }