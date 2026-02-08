// import 'package:easy_image_viewer/easy_image_viewer.dart';
// import 'package:fahis_inspector/models/selection.dart';
// import '../constants/colors.dart';
// import '../constants/image_strings.dart';
// import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/selection.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:mime/mime.dart';

class Helpers {
  // Future<File?> pickFile(filepicker.FileType fileType) async {
  //   try {
  //     filepicker.FilePickerResult? result =
  //         await filepicker.FilePicker.platform.pickFiles(
  //       allowMultiple: false,
  //       type: fileType,
  //     );
  //     if (result != null) {
  //       //var fileName = result.files.first.name;
  //       var file = result.files.first;
  //       if (file.extension == 'pdf') {
  //         return File(file.path.toString());
  //       } else {
  //         return FHelper.getSnackBar(
  //             message: 'The file is not PDF, You should to upload PDF file.'.tr,
  //             color: FColors.warning,
  //             icon: Icons.attach_file,
  //             duration: 3);
  //       }
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  //   return null;
  // }

  static Future<void> callTo({required String mobile}) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: mobile,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch';
    }
  }

  static void copy(String copiedString) {
    Clipboard.setData(ClipboardData(text: copiedString));
    FLoader.infoSnackBar(
      title: 'Copied to Clipboard',
      message: '$copiedString copied to clipboard!',
      duration: 3,
    );
  }
  
  static List<Selection> generateYearsList() {
    int currentYear = DateTime.now().year + 1;
    List<Selection> yearsList = [];

    yearsList.add(Selection(value: '', label: 'none'));

    for (int year = currentYear; year >= 1990; year--) {
      yearsList.add(Selection(value: year.toString(), label: year.toString()));
    }
  
    return yearsList;
  }

  // static String fileToBase64(File file) {
  //   List<int> imageBytes = file.readAsBytesSync();
  //   String base64String = base64Encode(imageBytes);

  //   String? mimeType = lookupMimeType(file.path); // e.g., image/jpeg
  //   if (mimeType == null) mimeType = 'image/jpeg';

  //   return 'data:$mimeType;base64,$base64String';
  // }

  static List<String> base64FromValid(String base64String) {
    // Remove data URI scheme if present
    final RegExp dataUriRegex = RegExp(r'data:image/(\w+);base64,');
    String extension = 'jpg';

    if (dataUriRegex.hasMatch(base64String)) {
      final match = dataUriRegex.firstMatch(base64String);
      extension = match?.group(1) ?? 'jpg';
      base64String = base64String.split(',').last;
    }

    return [base64String, extension];
  }

  // static Future<File> base64ToFile(String base64String, {String? filename}) async {
  // // Remove data URI scheme if present
  //   List base64 = base64FromValid(base64String);

  //   base64String = base64[0];
  //   String extension = base64[1];

  //   // Decode base64
  //   final bytes = base64Decode(base64String);

  //   // Use temp directory
  //   final dir = await getTemporaryDirectory();
  //   final filePath = path.join(dir.path, filename ?? 'image_${DateTime.now().millisecondsSinceEpoch}.$extension');
  //   final file = File(filePath);

  //   // Write to file
  //   await file.writeAsBytes(bytes);

  //   return file;
  // }

  String imageWithOutBgInBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String result = base64Encode(imageBytes);
    return result;
  }

}

// class NetworkImage extends StatefulWidget {
//   const NetworkImage({super.key, required this.url});
//   final String url;

//   @override
//   State<NetworkImage> createState() => _NetworkImageState();
// }

// class _NetworkImageState extends State<NetworkImage> {
//   double progress = 0.0;
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Center(
//           child: EasyImageView(imageProvider:  
//             Image.network(
//               widget.url,
//               fit: BoxFit.contain,
//               width: double.infinity, 
//               height: double.infinity,
//             ).image 
//           )
//         ),
//         isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: FColors.primaryColor,
//                 ),
//               )
//             : const SizedBox(),
//       ],
//     );
//   }
// }
