import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/features/configuration/models/selection_model.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';

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

  static List<Selection> generateYearsList() {
    int currentYear = DateTime.now().year + 1;
    List<Selection> yearsList = [];

    yearsList.add(Selection(value: '', label: 'none'));

    for (int year = currentYear; year >= 1990; year--) {
      yearsList.add(Selection(value: year.toString(), label: year.toString()));
    }
  
    return yearsList;
  }

  static String fileToBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64String = base64Encode(imageBytes);

    String? mimeType = lookupMimeType(file.path); // e.g., image/jpeg
    if (mimeType == null) mimeType = 'image/jpeg';

    return 'data:$mimeType;base64,$base64String';
  }

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

class FImage extends StatelessWidget {
  const FImage({super.key,
      this.image,
      this.height = 100,
      this.width = 100,
      this.placeHolder});

  final String? image;
  final double height;
  final double width;
  final Widget? placeHolder;
  final Widget defaultPlaceHolder =
    const Icon(Icons.camera_alt, size: 50, color: Colors.grey);
  @override
  Widget build(BuildContext context) {
    if(image == null){
      if (placeHolder == null) {
        return EasyImageView(
          imageProvider: Image.asset(
            FImages.appIcon,
            fit: BoxFit.cover,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
      }
      else{
        return placeHolder!;
      }
    }
    else{ 
      if (image!.startsWith('https://') || image!.startsWith('http://')){
        return EasyImageView(
          imageProvider: Image.network(
            image!,
            fit: BoxFit.contain,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
        // NetworkImage(url: image!);
      }
      else if (image!.startsWith('//s3')){
        return EasyImageView(
          imageProvider: Image.network(
            'https:${image!}',
            fit: BoxFit.contain,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
      }
      else{
        return EasyImageView(
          imageProvider: Image.memory(
            base64Decode(Helpers.base64FromValid(image!)[0]),
            fit: BoxFit.contain,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
      }
    }
  
  }
}

class NetworkImage extends StatefulWidget {
  const NetworkImage({super.key, required this.url});
  final String url;

  @override
  State<NetworkImage> createState() => _NetworkImageState();
}

class _NetworkImageState extends State<NetworkImage> {
  double progress = 0.0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: EasyImageView(imageProvider:  
            Image.network(
              widget.url,
              fit: BoxFit.contain,
              width: double.infinity, 
              height: double.infinity,
            ).image 
          )
        ),
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: FColors.primaryColor,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
